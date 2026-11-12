#!/bin/bash
# Builds the Prevent App Nap synthetic-boundary ownership harness against a
# source tree with ASan/UBSan and runs every test in its own process (macOS only).
#
#   tests/ownership/run.sh <repo-root> <fixed|baseline>
#
# <repo-root> provides prevent-app-nap/ (plugin sources and the bundled
# 4D Plugin API). The harness itself always comes from this script's
# directory, so the SAME harness can be run against an immutable baseline
# (git archive of the base SHA) and against the fixed tree.
#
# In "fixed" mode every test must pass. In "baseline" mode the tests named
# in EXPECTED_BASELINE_FAILURES must fail and every other test (the
# controls) must pass; anything else is a harness or model error.
set -euo pipefail

SRC=$(cd "$1/prevent-app-nap" && pwd)
MODE=$2
HERE=$(cd "$(dirname "$0")" && pwd)
OUT=$(mktemp -d)
trap 'rm -rf "$OUT"' EXIT

EXPECTED_BASELINE_FAILURES="
defect_picture_fromfile_ownership
defect_picture_setbytes_leak
defect_picture_createcopy_ownership
defect_picture_grayscale_owner_leak
defect_picture_getsize_owner_leak
defect_picture_thumbnail_owner_leak
"

SAN="-g -O1 -fno-omit-frame-pointer -fsanitize=address,undefined -fno-sanitize-recover=undefined"
API="$SRC/4D Plugin API"
# Same prefix header as the Xcode target (GCC_PREFIX_HEADER); every source is
# compiled as Objective-C++ like the Xcode target (explicitFileType), without ARC.
INC=(-include "$SRC/4D Plugin_Prefix.pch" -I "$API" -I "$API/Classes" -I "$SRC")

objs=()
cc() { # <file>
    local o="$OUT/$(basename "$1").o"
    xcrun clang $SAN -w -x objective-c++ -std=c++17 -fno-objc-arc "${INC[@]}" -c "$1" -o "$o"
    objs+=("$o")
}

cc "$API/4DPluginAPI.c"
for f in "$API"/Classes/*.cpp; do cc "$f"; done
cc "$SRC/4DPlugin.cpp"
cc "$HERE/engine_harness.mm"

xcrun clang++ $SAN "${objs[@]}" -framework Foundation -framework CoreFoundation -framework Cocoa -o "$OUT/harness"

export ASAN_OPTIONS=abort_on_error=0:halt_on_error=1
export UBSAN_OPTIONS=print_stacktrace=1:halt_on_error=1

bad=0
for t in $("$OUT/harness" --list); do
    if "$OUT/harness" "$t" >"$OUT/$t.log" 2>&1; then got=pass; else got=fail; fi
    expect=pass
    if [ "$MODE" = baseline ] && grep -qx "$t" <<<"$EXPECTED_BASELINE_FAILURES"; then expect=fail; fi
    if [ "$got" = "$expect" ]; then status=OK; else status=UNEXPECTED; bad=1; fi
    printf '%-12s %-5s (expected %-4s) %s\n' "$status" "$got" "$expect" "$t"
    if [ "$got" = fail ]; then sed 's/^/    | /' "$OUT/$t.log"; fi
    # A sanitizer report or engine violation is only acceptable as a named
    # baseline failure (the double free and over-read are the defects).
    if [ "$expect" = pass ] && grep -qE 'ERROR: AddressSanitizer|runtime error:|ENGINE VIOLATION' "$OUT/$t.log"; then
        echo "UNEXPECTED   sanitizer/engine violation in $t"; bad=1
    fi
done

if [ $bad -ne 0 ]; then echo "RESULT ($MODE): FAILED"; exit 1; fi
echo "RESULT ($MODE): all outcomes as expected"

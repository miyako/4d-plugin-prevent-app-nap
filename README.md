![version](https://img.shields.io/badge/version-17%2B-3E8B93)
![platform](https://img.shields.io/static/v1?label=platform&message=mac-intel%20|%20mac-arm64&color=blue)
[![license](https://img.shields.io/github/license/miyako/4d-plugin-prevent-app-nap)](LICENSE)
![downloads](https://img.shields.io/github/downloads/miyako/4d-plugin-prevent-app-nap/total)

# 4d-plugin-prevent-app-nap

Prevents App Nap and system sleep assertions using
[`NSProcessInfo.beginActivityWithOptions:reason:`](https://developer.apple.com/documentation/foundation/nsprocessinfo/1415995-beginactivitywithoptions).
The plugin wraps that API in two commands: `BEGIN IMPORTANT ACTIVITY` starts an
activity with a chosen set of assertions, and `END IMPORTANT ACTIVITY` ends it.
Neither command returns a value.

## Command reference

| Command | Returns | Purpose |
|---|---|---|
| [BEGIN IMPORTANT ACTIVITY](#begin-important-activity) | nothing | Starts an activity that keeps the Mac awake / prevents termination |
| [END IMPORTANT ACTIVITY](#end-important-activity) | nothing | Ends the activity started by `BEGIN IMPORTANT ACTIVITY` |

**Platforms:** macOS (Intel and Apple silicon)

---

## Requirements & platform notes

- **macOS only.** The commands are implemented with `NSProcessInfo`, a
  macOS API. The bundle also ships a prebuilt Windows binary, but its behavior
  is not covered by this documentation.
- **One activity at a time, per plugin.** `BEGIN IMPORTANT ACTIVITY` ends any
  activity the plugin is currently holding before starting the new one, so a
  second `BEGIN` silently replaces the first. There is no per-process tracking:
  an activity started by one 4D process is ended by a `BEGIN` or `END` issued
  by any other process using the plugin.
- **Automatic cleanup on exit.** When the 4D process that started an activity
  closes, the plugin ends the activity automatically. You normally do not need
  to call `END IMPORTANT ACTIVITY` before quitting, but calling it explicitly
  is good practice.
- Both commands are marked thread-safe in the plugin manifest and are
  marshalled to the main thread internally.

---

## BEGIN IMPORTANT ACTIVITY

### Syntax

```4d
BEGIN IMPORTANT ACTIVITY ( options ; reason )
```

### Parameters

| Parameter | Type | Description |
|---|---|---|
| `options` | Longint | Bitmask of assertions to enable. Combine the constants below with `+`. Pass `0` for an activity with no assertions. |
| `reason` | Text | Human-readable explanation shown with the assertion (e.g. in Activity Monitor's Energy pane). If empty, `"important activity"` is used. |
| Result | — | The command returns nothing. |

`options` is a bitmask; each bit maps to one `NSActivityOptions` flag:

| Constant | Value | Effect |
|---|---|---|
| `Prevent display sleep` | 1 | Prevents the display from sleeping (`NSActivityIdleDisplaySleepDisabled`) |
| `Prevent system sleep` | 2 | Prevents the system from idle sleeping (`NSActivityIdleSystemSleepDisabled`) |
| `Prevent sudden termination` | 4 | Prevents the process from being suddenly terminated (`NSActivitySuddenTerminationDisabled`) |
| `Prevent automatic termination` | 8 | Prevents the process from being automatically terminated (`NSActivityAutomaticTerminationDisabled`) |

### Description

`BEGIN IMPORTANT ACTIVITY` calls
`[[NSProcessInfo processInfo] beginActivityWithOptions:reason:]`. The active
assertions appear in Activity Monitor (Energy tab) and in `pmset -g assertions`
while the activity is held.

Calling `BEGIN IMPORTANT ACTIVITY` while an activity is already active ends
the previous activity first, then starts the new one — there is never more
than one activity per plugin instance.

### Example

From the plugin's README (the project's own usage example):

```4d
BEGIN IMPORTANT ACTIVITY (\
Prevent system sleep;\
"4D is super busy!!!")

TRACE

END IMPORTANT ACTIVITY
```

Variations:

```4d
// keep the display awake while a long render runs
BEGIN IMPORTANT ACTIVITY (Prevent display sleep+Prevent system sleep;"Rendering")

// numeric bitmask form: 1+2 = display and system sleep prevention
BEGIN IMPORTANT ACTIVITY (3;"Batch export")

// no assertions at all is accepted; the activity still shows up in assertions
BEGIN IMPORTANT ACTIVITY (0;"")
```

---

## END IMPORTANT ACTIVITY

### Syntax

```4d
END IMPORTANT ACTIVITY
```

### Parameters

| Parameter | Type | Description |
|---|---|---|
| Result | — | The command returns nothing. |

### Description

`END IMPORTANT ACTIVITY` calls
`[[NSProcessInfo processInfo] endActivity:]` for the activity the plugin is
currently holding, if any. It is a no-op when no activity is active.

The plugin also ends the activity automatically when the calling 4D process
exits, so an explicit `END` is only needed to release the assertions before
the process finishes.

### Example

```4d
BEGIN IMPORTANT ACTIVITY (Prevent system sleep;"Downloading")

// ... work that must not sleep ...

END IMPORTANT ACTIVITY
```

---

## Error handling & troubleshooting

- **No error is ever raised.** Both commands return nothing and report
  failures only through `NSLog`. If `beginActivityWithOptions:reason:` cannot
  start an activity, the command silently does nothing.
- **The assertion may not prevent sleep on its own.** macOS coalesces and
  times out assertions; `NSActivityIdleSystemSleepDisabled` assertions are
  typically limited and can be broken by other system activity. Check
  `pmset -g assertions` to confirm the assertion is actually held.
- **The `reason` string is truncated by the system.** Very long reasons are
  shortened in the assertions list; keep it short.
- **Only the latest `BEGIN` matters.** Because a new `BEGIN` ends the previous
  activity, code that expects two concurrent activities (e.g. one per user
  process) will not get them.
- **Windows is not documented.** A prebuilt `Windows64` binary ships in the
  bundle, but the plugin's commands are implemented with macOS-only APIs and
  this reference describes the macOS behavior only.

## Quick reference

```4d
// start: keep system + display awake
BEGIN IMPORTANT ACTIVITY (Prevent system sleep+Prevent display sleep;"Working")

// end early
END IMPORTANT ACTIVITY

// or let process exit end it automatically
```

Releases: <https://github.com/miyako/4d-plugin-prevent-app-nap/releases>

4D will appear as "preventing sleep" in Activity Monitor

<img width="946" alt="2018-11-19 18 11 05" src="https://user-images.githubusercontent.com/1725068/48697010-dcac6c80-ec26-11e8-9ae6-6f70b685e499.png">

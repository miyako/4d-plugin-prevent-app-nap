![version](https://img.shields.io/badge/version-17%2B-3E8B93)
![platform](https://img.shields.io/static/v1?label=platform&message=mac-intel%20|%20mac-arm64&color=blue)
[![license](https://img.shields.io/github/license/miyako/4d-plugin-prevent-app-nap)](LICENSE)
![downloads](https://img.shields.io/github/downloads/miyako/4d-plugin-prevent-app-nap/total)

# 4d-plugin-prevent-app-nap
Prevent App Nap using [beginActivityWithOptions:reason:](https://developer.apple.com/documentation/foundation/nsprocessinfo/1415995-beginactivitywithoptions) 

## Syntax

```
BEGIN IMPORTANT ACTIVITY (options;reason)
END IMPORTANT ACTIVITY
```

Parameter|Type|Description
------------|------------|----
options|LONGINT|combination of ``Prevent system sleep`` ``Prevent automatic termination`` ``Prevent display sleep`` ``Prevent sudden termination``
reason|TEXT|

**Note**: ``END IMPORTANT ACTIVITY`` is automatically called when you close your application

## Examples

```
BEGIN IMPORTANT ACTIVITY (\
Prevent system sleep;\
"4D is super busy!!!")

TRACE

END IMPORTANT ACTIVITY 
```

4D will appear as "preventing sleep" in Activity Monitor

<img width="946" alt="2018-11-19 18 11 05" src="https://user-images.githubusercontent.com/1725068/48697010-dcac6c80-ec26-11e8-9ae6-6f70b685e499.png">

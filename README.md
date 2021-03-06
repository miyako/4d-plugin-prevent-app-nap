# 4d-plugin-prevent-app-nap
Prevent App Nap using [beginActivityWithOptions:reason:](https://developer.apple.com/documentation/foundation/nsprocessinfo/1415995-beginactivitywithoptions) 

### Platform

| carbon | cocoa | win32 | win64 |
|:------:|:-----:|:---------:|:---------:|
|<img src="https://cloud.githubusercontent.com/assets/1725068/22371562/1b091f0a-e4db-11e6-8458-8653954a7cce.png" width="24" height="24" />|<img src="https://cloud.githubusercontent.com/assets/1725068/22371562/1b091f0a-e4db-11e6-8458-8653954a7cce.png" width="24" height="24" />|||

```
spctl -a -vv -t install Prevent App Nap/Prevent App Nap.bundle: accepted
source=Notarized Developer ID
origin=Developer ID Application: keisuke miyako (Y69CWUC25B)
```

### Version

<img src="https://cloud.githubusercontent.com/assets/1725068/18940649/21945000-8645-11e6-86ed-4a0f800e5a73.png" width="32" height="32" /> <img src="https://cloud.githubusercontent.com/assets/1725068/18940648/2192ddba-8645-11e6-864d-6d5692d55717.png" width="32" height="32" /> <img src="https://user-images.githubusercontent.com/1725068/41266195-ddf767b2-6e30-11e8-9d6b-2adf6a9f57a5.png" width="32" height="32" />

![preemption xx](https://user-images.githubusercontent.com/1725068/41327179-4e839948-6efd-11e8-982b-a670d511e04f.png)

### Releases

[1.0](https://github.com/miyako/4d-plugin-prevent-app-nap/releases/tag/1.0)

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

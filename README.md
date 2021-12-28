# Audio & Video Call

## A Flutter Application for Audio & Video Call with Flutter_webRTC.

**Android Application Sample**

 Welcome Page                 |   Join Rooom Page        |  Create Room Page         |  Audio Call Page 
:-------------------------:|:-------------------------:|:-------------------------:|:-------------------------:|
![](https://user-images.githubusercontent.com/75465325/143185654-4f7b12e4-640c-4cb8-aa51-23b2b3325510.jpg)|![](https://user-images.githubusercontent.com/75465325/143185944-9f4e5381-61e2-4b5d-9de1-28595af59402.jpg)|![](https://user-images.githubusercontent.com/75465325/143186127-2264da50-d1a9-4e9b-a30f-6732d0dd0426.jpg)|![](https://user-images.githubusercontent.com/75465325/143186222-fd732a6e-2939-4c37-a9f8-a5a6f9496336.jpg)|


## For Android 
**Ensure the following permission is present in your Android Manifest file, located in <project root>/android/app/src/main/AndroidManifest.xml:**

 > uses-feature android:name="android.hardware.camera"
 
 > uses-feature android:name="android.hardware.camera.autofocus" 
 
 > uses-permission android:name="android.permission.CAMERA"
 
 > uses-permission android:name="android.permission.RECORD_AUDIO"
 
 > uses-permission android:name="android.permission.ACCESS_NETWORK_STATE"
 
 > uses-permission android:name="android.permission.CHANGE_NETWORK_STATE" 
 
 > uses-permission android:name="android.permission.MODIFY_AUDIO_SETTINGS"
 
 > uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE"
 
 > uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE"
 
 > uses-permission android:name="android.permission.WRITE_INTERNAL_STORAGE"
 
 > uses-permission android:name="android.permission.MANAGE_EXTERNAL_STORAGE" tools:ignore="ScopedStorage"
 
 > uses-permission android:name="android.permission.FOREGROUND_SERVICE" 
 
**If you need to use a Bluetooth device, please add:**

 > uses-permission android:name="android.permission.BLUETOOTH"
 
 > uses-permission android:name="android.permission.BLUETOOTH_ADMIN"

**Also you will need to set your build settings to Java 8, because official WebRTC jar now uses static methods in EglBase interface. Just add this to your app level build.gradle:**

 android {
 
     
     compileOptions {
 
         sourceCompatibility JavaVersion.VERSION_1_8
 
         targetCompatibility JavaVersion.VERSION_1_8
 
     }
 
 }
 
If necessary, in the same build.gradle you will need to increase minSdkVersion of defaultConfig up to 21 (currently default Flutter generator set it to 16).
 
###### Important reminder 
**When you compile the release apk, you need to add the following operations, Setup Proguard Rules**(https://github.com/flutter-webrtc/flutter-webrtc/commit/d32dab13b5a0bed80dd9d0f98990f107b9b514f4)
 
## For iOS 
**Add the following entry to your Info.plist file, located in <project root>/ios/Runner/Info.plist:**

 <key>NSCameraUsageDescription</key>
 
 <string>$(PRODUCT_NAME) Camera Usage!</string>
 
 <key>NSMicrophoneUsageDescription</key>
 
 <string>$(PRODUCT_NAME) Microphone Usage!</string>
 
This entry allows your app to access camera and microphone.
 
 
 ## How to Use

Add all following flutter plugins as dependency in your pubspec.yaml file.

 Create a Signaling() Class Object then use their following methods to their respective use
 
| Method | Description |
| --- | --- |
| openUserMedia() | To open camera and mic for local video rendering |
| createRoom() | To create room and get room id|
| joinRoom() | To join room with room id|
| hangUp() | To hang up call|
| switchCamera() | To rotate camera |
| muteMic() | To mute or unmute audio |
| switchCall() | To switch call from audio to video or vice versa |
 
 
## Flutter plugins
Plugin Name        | 
:-------------------------|
|[flutter_webrtc](https://pub.dev/packages/flutter_webrtc)|
|[firebase_core](https://pub.dev/packages/firebase_core) |
|[cloud_firestore](https://pub.dev/packages/cloud_firestore) |
|[permission_handler](https://pub.dev/packages/permission_handler)|


## Upcoming Features
- Direct Audio Call
- Switch Camera view on tap in camera screen
- Direct call without room id & ring like real call


## Created & Maintained By

[Deorwine Infotech](https://deorwine.com/)

 
 
 
 

> If you found this project helpful or you learned something from the source code and want to thank team deorwine then please connect on us different platform:
>  * [Site](https://deorwine.com/)
>  * [Linkedin](https://www.linkedin.com/company/deorwine-infotech)
>  * [Facebook](https://www.facebook.com/deorinfo/)
>  * [Instagram](https://www.instagram.com/deorwine_infotech/)
>  * [Twitter ](https://twitter.com/DeorwineI)
>  * you can also contact us on email info@deorwine.com 

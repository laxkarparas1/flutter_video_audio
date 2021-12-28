import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_video_audio_webrtc/model/user.dart';
import 'package:flutter_video_audio_webrtc/signaling.dart';
import 'package:flutter_video_audio_webrtc/utilities/call_utilities.dart';
import 'package:flutter_video_audio_webrtc/utilities/constant.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:workmanager/workmanager.dart';

bool isVideoCall = false;
bool isFromAudio = false;

User? currentUser;

const simpleTaskKey = "simpleTask";
const rescheduledTaskKey = "rescheduledTask";
const failedTaskKey = "failedTask";
const simpleDelayedTask = "simpleDelayedTask";
const simplePeriodicTask = "simplePeriodicTask";
const simplePeriodic1HourTask = "simplePeriodic1HourTask";


void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) {
    print("this is in task $task");
//     print(filePath);
    uploadData(filePath!);
    switch (task) {
      case simpleTaskKey:
        print("$simpleTaskKey was executed. inputData = $inputData");
        // final prefs = await SharedPreferences.getInstance();
        // prefs.setBool("test", true);
        // print("Bool from prefs: ${prefs.getBool("test")}");
        break;
      case rescheduledTaskKey:

        print("$rescheduledTaskKey was executed. inputData = $inputData");
        return Future.value(true);
      case failedTaskKey:
        print('failed task was executed');
        return Future.error('failed');
      case simpleDelayedTask:
        print("$simpleDelayedTask was executed");
        break;
      case simplePeriodicTask:
        print("$simplePeriodicTask was executed");
        break;
      case simplePeriodic1HourTask:
        print("$simplePeriodic1HourTask was executed");
        break;
      case Workmanager.iOSBackgroundTask:
        print("The iOS background fetch was triggered");
        print("You can access other plugins in the background, for example Directory.getTemporaryDirectory():");
        break;
    }
     return Future.value(true);
  });
}

class FlutterVideoAudioWebrtc {
  static const MethodChannel _channel = MethodChannel('flutter_video_audio_webrtc');

  static Future<String?> get platformVersion async {
    final String? version = await _channel.invokeMethod('getPlatformVersion');
    return version;
  }

  makeCall(
      {
        required GlobalKey<NavigatorState> key,
        required BuildContext context,
        required User? senderUser,
        required Map<String,dynamic> receiverUser,
        required bool videoCall,
        required bool fromAudio,
      }
      ) async {

    isVideoCall = videoCall;
    isFromAudio = fromAudio;
    currentUser = senderUser;

    if(await _checkPermission()){
      print("this is in dial function  ${await _checkPermission()}");

     try{
       Workmanager().initialize(
         callbackDispatcher,
         isInDebugMode: true
     );

     }
     catch(e){
       print("this is erroe $e");
     }

      return CallUtils.dial(
        from: User(
          uid: senderUser!.uid,
          name: senderUser.name,
        ),
        to: User(
          uid: receiverUser['uid'],
          name: receiverUser['name'],
          token: receiverUser['token']
        ),
        context: context,
        video: videoCall,
        serverKey: serverKey
      );

    }else {
      throw "Please allow permissions to continue";
    }

  }

  Future<bool> _checkPermission() async {
    final   status = await Permission.storage.request();
    final camera = await Permission.camera.request();
    final audio = await Permission.microphone.request();
    final  manageStatus = await Permission.manageExternalStorage.request();

    if ((status == PermissionStatus.granted || manageStatus == PermissionStatus.granted) && camera == PermissionStatus.granted && audio == PermissionStatus.granted ) {
      print('Permission granted');
      return true;
    } else if (status == PermissionStatus.denied || manageStatus == PermissionStatus.denied|| camera == PermissionStatus.denied || audio == PermissionStatus.denied ) {
      print('Permission denied. Show a dialog and again ask for the permission');
      return false;
    } else {
      print('Take the user to the settings page.');
      await openAppSettings();
      return false;
    }

  }
}

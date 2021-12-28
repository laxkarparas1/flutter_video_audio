import 'dart:convert';
import 'dart:math';

import 'package:flutter_video_audio_webrtc/callscreens/camera_screen.dart';
import 'package:flutter_video_audio_webrtc/model/call.dart';
import 'package:flutter_video_audio_webrtc/model/user.dart';
import 'package:flutter_video_audio_webrtc/resources/call_methods.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;



class CallUtils {
  static final CallMethods callMethods = CallMethods();


 static triggerNotification(User? to , String serverKey, bool isVideoCall1, User? currentUser1)async{
    var response = await http.post(Uri.parse('https://fcm.googleapis.com/fcm/send'),
        headers: <String, String>{
          "Content-Type": "application/json",
          "Authorization": "key=$serverKey"
        },
        body: jsonEncode({
          "to": to!.token,
          "notification": {
            "title": "Incoming ${isVideoCall1 ? "Video" : "Audio"} Call",
            "body":  "from ${currentUser1!.name}",
            "mutable_content": true,
            "sound": "Tri-tone"
          },

        })
    );
    print("this is notification response ${response.body}");

  }

  static dial({GlobalKey<NavigatorState>? key,User? from, User? to, context,bool? video, String? serverKey}) async {
    Call call = Call(
      callerId: from!.uid,
      callerName: from.name,
      callerPic: from.profilePhoto,
      receiverId: to!.uid,
      receiverName: to.name,
      receiverPic: to.profilePhoto,
      video: video,
      channelId: Random().nextInt(1000).toString(),
    );

    triggerNotification(to , serverKey!, video!, from);

    bool callMade = await callMethods.makeCall(call: call);

    call.hasDialled = true;

    if (callMade) {
      // triggerNotification(to);
      Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) =>
            CameraScreen(
              fromCreate: true,
              call: call,
            )
          )
      );
    }
  }
}

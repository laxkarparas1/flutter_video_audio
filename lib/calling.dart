// library flutter_video_audio_webrtc;
//
// import 'dart:io';
// import 'package:flutter_video_audio_webrtc/model/user.dart';
// import 'package:flutter_video_audio_webrtc/resources/call_methods.dart';
// import 'package:flutter_video_audio_webrtc/utilities/call_utilities.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_webrtc/flutter_webrtc.dart';
// import 'package:flutter_video_audio_webrtc/model/call.dart';
// import 'package:flutter/cupertino.dart';
// import 'package:flutter/painting.dart';
// import 'package:flutter/services.dart';
// import 'package:flutter_video_audio_webrtc/signaling.dart';
//
// part 'callscreens/camera_screen.dart';
//
//
// bool isVideoCall = false;
// bool isFromAudio = false;
//
// User? currentUser;
//
// makeCall(
// {
//   required GlobalKey<NavigatorState> key,
//   required BuildContext context,
//   required User? senderUser,
//   required Map<String,dynamic> receiverUser,
//   required bool videoCall,
//   required bool fromAudio,
// }
//     ){
//
//   isVideoCall = videoCall;
//   isFromAudio = fromAudio;
//   currentUser = senderUser;
//
//   return CallUtils.dial(
//     from: User(
//       uid: senderUser!.uid,
//       name: senderUser.name,
//     ),
//     to: User(
//       uid: receiverUser['uid'],
//       name: receiverUser['name'],
//     ),
//     context: context,
//     video: videoCall,
//   );
//
// }
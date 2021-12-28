import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_video_audio_webrtc/callscreens/camera_screen.dart';
import 'package:flutter_video_audio_webrtc/model/call.dart';
import 'package:flutter_video_audio_webrtc/resources/call_methods.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';



class PickupScreen extends StatelessWidget {
  final Call? call;
  final CallMethods callMethods = CallMethods();
  final FlutterLocalNotificationsPlugin fln = FlutterLocalNotificationsPlugin();


  PickupScreen({

    @required this.call,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        alignment: Alignment.center,
        padding: EdgeInsets.symmetric(vertical: 100),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              "Incoming ${call!.video!? "Video Call": "Audio Call"}...",
              style: const TextStyle(
                fontSize: 30,
              ),
            ),
            SizedBox(height: 44),
            CircleAvatar(
              radius: 100,
              backgroundColor: Colors.white,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(100),
                child: CachedNetworkImage(
                  imageUrl: call!.callerPic ?? "https://m.media-amazon.com/images/I/91u1OKpJzWL._SX679_.jpg",
                  progressIndicatorBuilder: (context, url, downloadProgress) =>
                      CircularProgressIndicator(value: downloadProgress.progress),
                  errorWidget: (context, url, error) => Icon(Icons.error),
                ),
              ),
            ),
            SizedBox(height: 15),
            Text(
              call!.callerName!,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
            SizedBox(height: 75),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                IconButton(
                  icon: Icon(Icons.call_end),
                  color: Colors.redAccent,
                  onPressed: () async {
                    fln.cancelAll();
                    await callMethods.endCall(call: call);

                  },
                ),
                SizedBox(width: 25),
                IconButton(
                  icon: Icon(Icons.call),
                  color: Colors.green,
                  onPressed: () async =>
                      await Permission.camera.isGranted && await Permission.microphone.isGranted
                          ? Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) {
                                  fln.cancelAll();
                                 return CameraScreen(fromCreate: false,roomID: call!.callerId,call: call,);
                                }
                                    //CallScreen(currentUser:currentUser,call: call!),

                              ),
                            )
                          : {},
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter_video_audio_webrtc/callscreens/pickup/pickup_screen.dart';
import 'package:flutter_video_audio_webrtc/model/call.dart';
import 'package:flutter_video_audio_webrtc/model/user.dart';
import 'package:flutter_video_audio_webrtc/resources/call_methods.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class PickupLayout extends StatelessWidget {
  final Widget? scaffold;
  final CallMethods callMethods = CallMethods();
  final User? currentUser;

  PickupLayout({
    @required this.scaffold, this.currentUser,
  });


  @override
  Widget build(BuildContext context) {
    print("this is current user ${currentUser!.uid}");
    return (currentUser != null)
        ? StreamBuilder<DocumentSnapshot>(
            stream: callMethods.callStream(uid: currentUser!.uid),
            builder: (context, snapshot) {
              if (snapshot.hasData && snapshot.data!.data != null) {
                print("this is data == ${snapshot.data!.data()}");
                final data = snapshot.data!.data();
                Call call;
              if(data != null){
                 call = Call.fromMap(data as Map<dynamic,dynamic>);
              }else{
                 call = Call();
              }
                if ( call.hasDialled != null  && !call.hasDialled! ) {

                  return PickupScreen(call: call);
                }
              }
              return scaffold!;
            },
          )
        : Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
  }
}

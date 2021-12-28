import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_video_audio_webrtc/callscreens/pickup/pickup_layout.dart';
import 'package:flutter_video_audio_webrtc/flutter_video_audio_webrtc.dart';
import 'package:flutter_video_audio_webrtc/model/user.dart';
import 'package:permission_handler/permission_handler.dart';
import 'main.dart';
import 'package:http/http.dart' as http;


class AllUser extends StatefulWidget {
  const AllUser({Key? key}) : super(key: key);

  @override
  _AllUserState createState() => _AllUserState();
}

class _AllUserState extends State<AllUser> {
  Stream<QuerySnapshot<Object?>>? stream = FirebaseFirestore.instance.collection('user').snapshots();

  // getAvailableUser(){
  //   FirebaseFirestore db = FirebaseFirestore.instance;
  //   // roomRef = db.collection('rooms').doc();
  //   CollectionReference roomRef = db.collection('user');
  //   stream = roomRef.snapshots();
  //   setState(() {
  //
  //   });
  //   print(roomRef.get());
  // }


  FlutterLocalNotificationsPlugin fln = FlutterLocalNotificationsPlugin();

  @override
  void initState() {
    // TODO: implement initState
fln.cancelAll();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return PickupLayout(
      currentUser: currentUser1,
      scaffold: Scaffold(
        body:  StreamBuilder<QuerySnapshot<Object?>>(
            stream: stream,
            builder: (BuildContext context, AsyncSnapshot<QuerySnapshot<Object?>> snapshot) {
              if(!snapshot.hasData){
                return Container(
                    margin: EdgeInsets.only(top: 20),
                    child: Center(child: CircularProgressIndicator()));
              }
              else{
                List<QueryDocumentSnapshot<Object?>>? docData = snapshot.data!.docs;

                if(docData.isNotEmpty){
                  return  ListView.builder(
                    itemCount: docData.length,
                    itemBuilder: (BuildContext context, int index){
                      var data = docData[index].data() as Map<String,dynamic>;
                      print("this is data $data");
                      return ListTile(
                        title: Text(data['name']),trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                          children: [
                            data['uid'] == currentUser1!.uid ? Container() : Container(
                            height: 35,
                            width: 100,
                            color: Colors.blue,
                            child: MaterialButton(
                              onPressed: data['uid'] == currentUser1!.uid ? null : ()async{
                                if( true){
                                 try{
                                  setState((){
                                    isVideoCall1 = false;
                                    isFromAudio1 = true;
                                  });

                                  FlutterVideoAudioWebrtc flutterCall = FlutterVideoAudioWebrtc();
                                  flutterCall.makeCall(
                                      key: navigatoryKey,
                                      context: context,
                                      senderUser: User(
                                    uid: currentUser1!.uid,
                                    name: currentUser1!.name,
                                  ),
                                      receiverUser: data,
                                      videoCall: false,
                                      fromAudio: true);
                                }catch(e){
                                  print("thisis error $e");
                                }
                               }
                               else{
                                 print("on");
                                 final   status = await Permission.storage.request();
                                 print(status.isGranted);
                                 final camera = await Permission.camera.request();
                                 final audio = await Permission.microphone.request();
                                 print(camera.isGranted);
                                 print(audio.isGranted);
                               }
                               },
                              child: Text( data['uid'] == currentUser1!.uid ?"Self" :"Audio Call",style: TextStyle(color: Colors.white),),
                            ),
                      ),
                            SizedBox(width: 10,),
                            Container(
                              height: 35,
                              width: 100,
                              color: Colors.blue,
                              child: MaterialButton(
                                onPressed: data['uid'] == currentUser1!.uid ? (){
                                  print("f");

                                }  : () async {
                                  if( true){

                                    setState((){
                                      isVideoCall1 = true;
                                      isFromAudio1 = false;
                                    });

                                   // triggerNotification(User(
                                   //    token: data['token']
                                   //  ));
                                   FlutterVideoAudioWebrtc flutterCall = FlutterVideoAudioWebrtc();
                                    flutterCall.makeCall(key: navigatoryKey, context: context, senderUser: User(
                                      uid: currentUser1!.uid,
                                      name: currentUser1!.name,
                                    ), receiverUser: data, videoCall: true, fromAudio: false);
                                  }
                                  },
                                child: Text( data['uid'] == currentUser1!.uid ?"Self" :"Video Call",style: TextStyle(color: Colors.white),),
                              ),
                            ),
                          ],
                        ),);
                    },);
                }else{
                  return Container(
                      height: 100,
                      child: Center(child: Text("There isn't any user available",style: TextStyle(color: Colors.black),)));
                }
              }

            })
        ,
      ),
    );
  }
}

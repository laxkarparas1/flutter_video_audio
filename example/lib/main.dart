import 'dart:async';
import 'dart:convert';


import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_video_audio_webrtc/model/user.dart';
import 'package:flutter_video_audio_webrtc_example/utils/notification.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_video_audio_webrtc_example/all_user.dart';
import 'package:flutter_video_audio_webrtc_example/utils/local.dart';


import 'login.dart';


final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

const AndroidNotificationChannel channel = AndroidNotificationChannel(
    'high_importance_channel',
    'High Importance Notifications',
    description: 'This channel is used for important notifications.',
    importance: Importance.high,
    playSound: true,
   // sound: RawResourceAndroidNotificationSound('arrive')
);

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()?.createNotificationChannel(channel);
  await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
    alert: true,
    badge: true,
    sound: true,
  );
  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
  MyNotification().initialize(flutterLocalNotificationsPlugin, channel);

  await _checkPermission();
bool isLogin =  false;
if(await HelperFunctions.getUserLoggedIn() ?? false){
  var user = await HelperFunctions.getUserId();
  currentUser1 = User.fromMap(jsonDecode(user!));
  FirebaseFirestore db = FirebaseFirestore.instance;
  DocumentReference roomRef = db.collection('user').doc('${currentUser1!.uid}');
  var roomSnapshot = await roomRef.get();
 if(roomSnapshot.exists){
   isLogin = true;
 }else{
   currentUser1 = User();
 }
}
  runApp(MyApp(isLogIn: isLogin,));

}

final GlobalKey<NavigatorState> navigatoryKey =  GlobalKey<NavigatorState>();
class MyApp extends StatelessWidget {
final bool? isLogIn;

  const MyApp({Key? key, this.isLogIn}) : super(key: key);
  @override
  Widget build(BuildContext context) {

    return MaterialApp(
      navigatorKey: navigatoryKey,
      debugShowCheckedModeBanner: false,
      onGenerateRoute: (RouteSettings settings){
        switch(settings.name){
          case '/':
            return MaterialPageRoute(builder: (context) => AllUser() );
        }
      },
      title: 'Paras WebRTC',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: isLogIn! ? AllUser(): LoginPage()
    );

  }
}

bool isVideoCall1 = true;
bool isFromAudio1 = false;

User? recieverUser;
User?  currentUser1 ;

Future<bool> _checkPermission() async {
  final   status = await Permission.storage.request();
  final camera = await Permission.camera.request();
  final audio = await Permission.microphone.request();
  final  manageStatus = await Permission.manageExternalStorage.request();

  if (status == PermissionStatus.granted || manageStatus == PermissionStatus.granted && camera == PermissionStatus.granted && audio == PermissionStatus.granted ) {
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


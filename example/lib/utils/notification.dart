import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import '../main.dart';


FirebaseMessaging messaging = FirebaseMessaging.instance;

class MyNotification {
  initialize(FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin, AndroidNotificationChannel channel) async{

    messaging.getToken().then((token) {
      print("++++++---------------+++++++"+token.toString()); // Print the Token in Console
    });

    var androidInitialize =  AndroidInitializationSettings('logo');
    var iOSInitialize = new IOSInitializationSettings();
    var initializationsSettings = new InitializationSettings(android: androidInitialize, iOS: iOSInitialize);
    flutterLocalNotificationsPlugin.initialize(initializationsSettings, onSelectNotification: (String? payload) async {
      try {
        if (payload != null && payload.isNotEmpty) {
          flutterLocalNotificationsPlugin.cancelAll();
          navigatoryKey.currentState!.pushNamed('/');
        }
      } catch (e) {
        print(e.toString());
      }
      return;
    });
    FirebaseMessaging.onMessage.listen((RemoteMessage? message) {
      print(message!.data);
      RemoteNotification? notification = message.notification;
      if(notification!.body=="Your order has been delivered"){
       print("in body");
      }
      if (notification != null) {
        print("============="+notification.body!);
       MyNotification.showBigTextNotification(notification, flutterLocalNotificationsPlugin, channel,message);

      }

    });
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print('A new onMessageOpenedApp event was published!');
      RemoteNotification notification = message.notification!;
      if (notification != null) {
        print("ok");
        // Get.showSnackbar(Ui.SuccessSnackBar(message: notification.body));
      }
    });
  }

  static Future<void> showBigTextNotification(RemoteNotification message, FlutterLocalNotificationsPlugin fln, AndroidNotificationChannel channel,RemoteMessage messageData) async {
   // print(messageData.data["id"]);

    var android = AndroidNotificationDetails(
      channel.id,
      channel.name,
     channelDescription:channel.description,
      color: Colors.blue,
      playSound: true,
      icon: 'logo',
      importance: Importance.max,
      priority: Priority.high,
      fullScreenIntent: true,
     // sound: RawResourceAndroidNotificationSound('arrive')
    );
    var iOS = IOSNotificationDetails(presentAlert: true,presentSound: true,);

    String _title = message.title!;
    String _body = message.body!;
    NotificationDetails platformChannelSpecifics = NotificationDetails(android: android, iOS: iOS);


    await fln.show(0, _title, _body, platformChannelSpecifics, payload:"dfds" );

  //  messageData.data["id"].toString()

  }
}

Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  var androidInitialize = new AndroidInitializationSettings('logo');
  var iOSInitialize = new IOSInitializationSettings();
  var initializationsSettings = new InitializationSettings(android: androidInitialize, iOS: iOSInitialize);
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
  const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'high_importance_channel', // id
      'High Importance Notifications', // title
      description: 'This channel is used for important notifications.', // description
      importance: Importance.high,
      playSound: true);
  flutterLocalNotificationsPlugin.initialize(initializationsSettings);

 MyNotification.showBigTextNotification(message.notification!, flutterLocalNotificationsPlugin, channel,message);

}
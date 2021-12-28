import 'dart:convert';
import 'dart:math';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_video_audio_webrtc/model/user.dart';
import 'package:flutter_video_audio_webrtc_example/resources/firebase_methods.dart';
import 'package:flutter_video_audio_webrtc_example/utils/local.dart';
import 'all_user.dart';
import 'main.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  TextEditingController nameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController usernameController = TextEditingController();
  final  GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  String? fcmToken;
  void getToken(){
    _firebaseMessaging.getToken().then((token){
      setState(() {
        fcmToken = token;
      });
    });
  }
  @override
  void initState() {
    // TODO: implement initState
    getToken();
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return  Scaffold(
      body: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            commonTextField(label: "Full Name",
                controller: nameController,
                validator: (val){
              if(val!.isEmpty){
                return "Please enter name";
              }
              else{
                return null;
              }
            }
            ),
            commonTextField(label: "Email", controller: emailController,
                validator: (val){
                  if(val!.isEmpty){
                    return "Please enter email";
                  }
                  else{
                    return null;
                  }
                }),
            commonTextField(label: "Username", controller: usernameController,
                validator: (val){
                  if(val!.isEmpty){
                    return "Please enter username";
                  }
                  else{
                    return null;
                  }
                }),
            const SizedBox(
              height: 40,
            ),
           materialButton(buttonText: "Log In", onPressed: onLogin)
          ],
        ),
      ),
    );

  }
  onLogin(){
   if(_formKey.currentState!.validate()){
     String uid = Random().nextInt(10000).toString();
    setState(() {
      currentUser1 = User(
          uid: uid,
          name: nameController.text,
          email: emailController.text,
          username: usernameController.text
      );
    });

     FirebaseMethods().addDataToDb(User(
         uid: uid,
         name: nameController.text,
         email: emailController.text,
         username: usernameController.text,
       token:  fcmToken
     )).then((value) async {
      await HelperFunctions.saveUserLoggedIn(true);
      await HelperFunctions.saveUserId(jsonEncode(User().toMap(User(
          uid: uid,
          name: nameController.text,
          email: emailController.text,
          username: usernameController.text,
          token:  fcmToken
      ))));

       Navigator.push(context, MaterialPageRoute(builder: (context)=> const AllUser()));
     });

   }
  }
  Container commonTextField({
  required String label,
    required TextEditingController controller,
    required String? Function(String?)? validator
}){
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20,vertical: 10),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          label: Text(label),
          border: const OutlineInputBorder()
        ),
        validator: validator,
      ),
    );
  }
  Container materialButton({required String? buttonText,required void Function()? onPressed,}) {
    return Container(
        height: 45,
        margin: const EdgeInsets.symmetric(horizontal: 20),
        decoration: const BoxDecoration(color: Colors.blue),
        child: MaterialButton(
          onPressed: onPressed,
          child: Center(child: Text(buttonText!,style: const TextStyle(
            color: Colors.white
          ),)),
        ),
      );
  }
}


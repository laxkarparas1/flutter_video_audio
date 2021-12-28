import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_video_audio_webrtc/flutter_video_audio_webrtc.dart';
import 'package:flutter_video_audio_webrtc/model/call.dart';
import 'package:flutter_video_audio_webrtc/resources/call_methods.dart';
import 'package:flutter_video_audio_webrtc/signaling.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';

class CameraScreen extends StatefulWidget {
  final String? roomID;
  final bool? fromCreate;
  final Call? call;
final GlobalKey<NavigatorState>? navigatorKey;
  const CameraScreen({Key? key, this.roomID, this.fromCreate, this.call, this.navigatorKey}) : super(key: key);

  @override
  _CameraScreenState createState() {
    isVideoCall = call!.video!;
   return _CameraScreenState();
  }
}



class _CameraScreenState extends State<CameraScreen> {
  final CallMethods callMethods = CallMethods();
  Signaling? signaling;
  RTCVideoRenderer _localRenderer = RTCVideoRenderer();
  RTCVideoRenderer _remoteRenderer = RTCVideoRenderer();
  MediaRecorder media = MediaRecorder();
  String? roomId;
  bool fromCreate = false;
  bool isMute = false;
  bool isLarge = false;
  RTCPeerConnection? peerConnection;


  openCamera(RTCVideoRenderer remoteRenderer, RTCVideoRenderer localRenderer)async{
  await  signaling!.openUserMedia(localRenderer, remoteRenderer, video: isVideoCall);
    setState(() {

    });
  }

  createRoom(RTCVideoRenderer remoteRenderer,)async{
    roomId = await signaling!.createRoom(remoteRenderer,currentUser: currentUser);
  //  textEditingController.text = roomId!;
  }

  _switchCamera() {
    signaling!.switchCamera();
  }
  _switchCall() {
    signaling!.switchCall();
    setState(() {
      isVideoCall = !isVideoCall;
    });
  }

  _muteMic() {
    setState((){
      isMute = !isMute;
    });
    signaling!.muteMic();
  }

  @override
  void initState() {
    _localRenderer.initialize();
    _remoteRenderer.initialize();
    signaling = Signaling(navigatoryKey: widget.navigatorKey);
    signaling!.onAddRemoteStream = ((stream) {
      _remoteRenderer.srcObject = stream;
      setState(() {});
    });

    fromCreate = widget.fromCreate!;
    print("this is from Create $fromCreate");
    isFromAudio = widget.call!.video! ? false : true;
  Future.delayed(Duration(seconds: 2),() async {
    openCamera(_remoteRenderer,_localRenderer);
  });
Future.delayed(Duration(seconds: 4),() async {
  if(fromCreate){
    await  createRoom(_remoteRenderer);
  }
  else{

    await signaling!.joinRoom(
      widget.roomID,
      _remoteRenderer,
    );
    setState(() {

    });
  }
});

SystemChrome.setPreferredOrientations([
  DeviceOrientation.portraitUp,
]);
    super.initState();
  }

  @override
  void didChangeDependencies() {
    // TODO: implement didChangeDependencies
    print("this is in didChangeDependencies");
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    _localRenderer.dispose();
    _remoteRenderer.dispose();
    signaling!.cancel();
    //hangUp();
    super.dispose();
  }

  getVideoRender(MediaStream stream) async {
    // var stream1 = await navigator.mediaDevices
    //     .getUserMedia({'video': true, 'audio': true});
    print("this is stream23 ${stream}");
    final Directory appDirectory = Directory('/storage/emulated/0/DCIM/');
    final String videoDirectory = '${appDirectory.path}';
    await Directory(videoDirectory).create(recursive: true);

    final String currentTime = DateTime.now().millisecondsSinceEpoch.toString();
    final String filePath = "$videoDirectory/${currentTime}.mp4";
    var videoTracks = stream.getVideoTracks();
    //var audioTracks = stream.getAudioTracks();
    await media.start(filePath,
        videoTrack: videoTracks.first,
        audioChannel: RecorderAudioChannel.INPUT);
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    ThemeData theme = Theme.of(context);
    return Scaffold(
      body:_remoteRenderer == null ? const Center(
        child: CircularProgressIndicator(
          backgroundColor: Colors.blue,
        ),
      ): OrientationBuilder(
          builder: (context, orientation) {
            return  Container(
          child: isVideoCall ? Stack(children: <Widget>[
            Positioned(
              left: 0.0,
              right: 0.0,
              top: 0.0,
              bottom: 0.0,
              child: Container(
                margin: const EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 0.0),
                width: size.width,
                height: size.height,
                child: RTCVideoView(isLarge ? _localRenderer:_remoteRenderer,objectFit: RTCVideoViewObjectFit.RTCVideoViewObjectFitCover,),
                //decoration: BoxDecoration(color: Colors.black54),
              )),
            Positioned(
            left: 20.0,
            top: 20.0,
            child: GestureDetector(
              onTap: (){
                setState((){
                  isLarge = !isLarge;
                });
              },
              child: Container(
                margin: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
                width: size.width*0.25,
                height: size.height*0.18,
                child: RTCVideoView(isLarge ? _remoteRenderer :_localRenderer, mirror: true,objectFit: RTCVideoViewObjectFit.RTCVideoViewObjectFitCover,),
                // decoration: BoxDecoration(color: Colors.black54),
              ),
            ),
          ),
            Positioned(
              bottom: 20.0,
              left: 0,
              right: 0,
              child:  actionButton(theme),
            )
        ]): Container(
            height: size.height,
            width: size.width,
            color: theme.primaryColor,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Spacer(),
                Text("Audio Call",style: TextStyle(
                    fontSize: 30,color: Colors.white
                ),),
                SizedBox(
                  height: 100,
                ),
                CircleAvatar(
                  radius: 80,
                  child: Icon(Icons.person,size: 100,),
                ),
                SizedBox(
                  height: 120,
                ),
                actionButton(theme),
                Spacer(),
              ],
            ),
          ),
      );
      }
      ),

    );
  }

  hangUp() async {
    signaling!.hangUp(_localRenderer);
    await callMethods.endCall(call: widget.call).then((value) =>  Navigator.pop(context));
   // Navigator.pop(context);
  }

  Row actionButton(ThemeData theme) {
    return Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                mainAxisSize: MainAxisSize.min,
                children: [
                  isVideoCall ?  _buttons(
                      onPressed: _switchCamera,
                      icon:   Icons.switch_camera,
                      title: "Switch Camera",
                      fontColor: theme.primaryColorDark
                  ): Container(),
                  _buttons(
                      onPressed: _muteMic,
                      icon:   isMute ? Icons.mic_off_outlined: Icons.mic_none_rounded,
                      title: "Mute",
                      fontColor: theme.primaryColorDark
                  ),
                  _buttons(
                      onPressed: hangUp,
                      icon:  Icons.phone_disabled_rounded,
                      title: "End Call",
                      fontColor: Colors.white,
                      buttonColor: Colors.red
                  ),
                  isFromAudio ? Container():  _buttons(
                      onPressed: _switchCall,
                      icon: isVideoCall ? Icons.volume_up_sharp : Icons.video_call_outlined,
                      title:  isVideoCall ?  "Audio Call" :"Video Call" ,
                      fontColor: theme.primaryColorDark
                  ),
                ],
              );
  }

  Container _buttons({@required Function()? onPressed,@required String? title ,@required IconData? icon,Color? fontColor, Color? buttonColor}) {
    return Container(
      height: 50,
      width: 50,
      margin: EdgeInsets.symmetric(horizontal: isVideoCall ? 5: 20),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30),
          color: buttonColor ?? Colors.white.withOpacity(0.7)
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(30),
        child: MaterialButton(
          padding: EdgeInsets.zero,
            onPressed: onPressed,
            child:  Center(child: Icon(icon,size: 22,color: Colors.white,)),
        ),
      ),
    );
  }
}

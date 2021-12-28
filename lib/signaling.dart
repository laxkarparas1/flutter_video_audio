import 'dart:convert';
import 'dart:io';

import 'package:amazon_s3_cognito/amazon_s3_cognito.dart';
import 'package:amazon_s3_cognito/aws_region.dart';
import 'package:amazon_s3_cognito/image_data.dart';
import 'package:flutter_video_audio_webrtc/model/user.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:path_provider/path_provider.dart';
import 'package:video_compress/video_compress.dart';
import 'package:workmanager/workmanager.dart';

typedef void StreamStateCallback(MediaStream stream);

String? filePath;

class Signaling {
bool isConnected = false;
  MediaRecorder media = MediaRecorder();

RTCVideoRenderer? localVideoForHang;

bool isVideoCall = false;

  Map<String, dynamic> configuration = {
    'iceServers': [
      {
        'urls': [
          'stun:stun1.l.google.com:19302',
          'stun:stun2.l.google.com:19302'
        ]
      }
    ]
  };

  RTCPeerConnection? peerConnection;
  MediaStream? localStream;
  MediaStream? remoteStream;
  String? roomId;
  String? currentRoomText;
  StreamStateCallback? onAddRemoteStream;
  final GlobalKey<NavigatorState>? navigatoryKey;

  Signaling({required this.navigatoryKey});

  Future<String> createRoom(RTCVideoRenderer remoteRenderer,{required User? currentUser}) async {

    FirebaseFirestore db = FirebaseFirestore.instance;
   // DocumentReference roomRef = db.collection('rooms').doc();
    DocumentReference roomRef = db.collection('call').doc(currentUser!.uid);

    print('Create PeerConnection with configuration: $configuration');

    peerConnection = await createPeerConnection(configuration);

    registerPeerConnectionListeners();

    localStream?.getTracks().forEach((track) {
      print("this is track $track");
      print("this is peerConnection before add $peerConnection");
      peerConnection?.addTrack(track, localStream!);
    });
    print("this is peerConnection after add $peerConnection");

    var callerCandidatesCollection = roomRef.collection('callerCandidates');
    print("this is callerCandidatesCollection before add $callerCandidatesCollection");
    peerConnection?.onIceCandidate = (RTCIceCandidate candidate) {
      print('Got candidate: ${candidate.toMap()}');
      callerCandidatesCollection.add(candidate.toMap());
    };
    print("this is callerCandidatesCollection after add $callerCandidatesCollection");


    RTCSessionDescription offer = await peerConnection!.createOffer();
    await peerConnection!.setLocalDescription(offer);
    print('Created offer: $offer');

    Map<String, dynamic> roomWithOffer = {'offer': offer.toMap()};

    await roomRef.set(roomWithOffer);
    var roomId = roomRef.id;
    print('New room created with SDK offer. Room ID: $roomId');
    currentRoomText = 'Current room is $roomId - You are the caller!';

    peerConnection?.onTrack = (RTCTrackEvent event) {
      print('Got remote track: ${event.streams[0]}');

      event.streams[0].getTracks().forEach((track) {
        print('Add a track to the remoteStream $track');
        remoteStream?.addTrack(track);
      });
    };
    roomRef.snapshots().listen((snapshot) async {
      print('Got updated room: ${snapshot.data()}');
      Map<String, dynamic> data = snapshot.data() as Map<String, dynamic>;
      print("this is call type ${data['answer']}");
      if (peerConnection?.getRemoteDescription() != null &&
          data['answer'] != null) {
        var answer = RTCSessionDescription(
          data['answer']['sdp'],
          data['answer']['type'],
        );

        print("Someone tried to connect");
        await peerConnection?.setRemoteDescription(answer);
          print("this is is 8");
          //try{
          //   Map<String, dynamic> mediaConstraints = {
          //     'audio': true,
          //     'video': {
          //       'mandatory': {
          //         'minWidth': '640', // Provide your own width, height and frame rate here
          //         'minHeight': '480',
          //         'minFrameRate': '60',
          //       },
          //       'facingMode': 'user',
          //       'optional': [],
          //     }
          //   };
            //var vdoStart = await FlutterScreenRecording.startRecordScreenAndAudio("videoName");
            // var data =  await mediaRecorder().start(File(await MyHomePage().createState().createFolder()+'/${stream.id}.mp4').path,videoTrack: stream.getVideoTracks().first,audioChannel: RecorderAudioChannel.INPUT);
            // MediaStream stream = await navigator.getDisplayMedia(mediaConstraints);
            //var stream = await navigator.mediaDevices.getDisplayMedia(mediaConstraints);
          //  var stream = await createLocalMediaStream('key');
       // MediaStream stream = await navigator.mediaDevices.getDisplayMedia(mediaConstraints);
       //  MediaStream stream = remoteStream!;
       //  print("this is stream ${stream}");
       //      final Directory appDirectory = Directory('/storage/emulated/0/DCIM/');
       //      final String videoDirectory = '${appDirectory.path}';
       //      await Directory(videoDirectory).create(recursive: true);
       //
       //      final String currentTime = DateTime.now().millisecondsSinceEpoch.toString();
       //      final String filePath = "$videoDirectory/${currentTime}.mp4";
       //      var videoTracks = stream.getVideoTracks();
       //      var audioTracks = stream.getAudioTracks();
       //    Future.delayed(Duration(seconds: 4),(){
       //      media.start(filePath,
       //          videoTrack: videoTracks.first,
       //          audioChannel: RecorderAudioChannel.INPUT);
       //    });
            //  await vdoFile.start(await MyHomePage().createState().createFolder(),videoTrack: stream.getVideoTracks().first,audioChannel: RecorderAudioChannel.INPUT);
          // }catch(e){
          //   print("this is e $e");
          // }
      }
    });

    roomRef.collection('calleeCandidates').snapshots().listen((snapshot) {
      snapshot.docChanges.forEach((change) {
        if (change.type == DocumentChangeType.added) {
          Map<String, dynamic> data = change.doc.data() as Map<String, dynamic>;
          print('Got new remote ICE candidate: ${jsonEncode(data)}');
          peerConnection!.addCandidate(
            RTCIceCandidate(
              data['candidate'],
              data['sdpMid'],
              data['sdpMLineIndex'],
            ),
          );
        }
      });
    });


    return roomId;
  }

  Future<void> joinRoom(String? roomId, RTCVideoRenderer remoteVideo) async {
    FirebaseFirestore db = FirebaseFirestore.instance;
    DocumentReference roomRef = db.collection('call').doc('$roomId');
    var roomSnapshot = await roomRef.get();
    print('Got room ${roomSnapshot.exists}');

    if (roomSnapshot.exists) {
      print('Create PeerConnection with configuration: $configuration');
      peerConnection = await createPeerConnection(configuration);

      registerPeerConnectionListeners();

      localStream?.getTracks().forEach((track) {
        peerConnection?.addTrack(track, localStream!);
      });

      var calleeCandidatesCollection = roomRef.collection('calleeCandidates');
      peerConnection!.onIceCandidate = (RTCIceCandidate candidate) {
        if (candidate == null) {
          print('onIceCandidate: complete!');
          return;
        }
        print('onIceCandidate: ${candidate.toMap()}');
        calleeCandidatesCollection.add(candidate.toMap());
      };

      peerConnection?.onTrack = (RTCTrackEvent event) {
        print('Got remote track: ${event.streams[0]}');
        event.streams[0].getTracks().forEach((track) {
          print('Add a track to the remoteStream: $track');
          remoteStream?.addTrack(track);
        });
      };

      var data = roomSnapshot.data() as Map<String, dynamic>;
      print('Got offer $data');
      var offer = data['offer'];
      await peerConnection?.setRemoteDescription(
        RTCSessionDescription(offer['sdp'], offer['type']),
      );
      var answer = await peerConnection!.createAnswer();
      print('Created Answer $answer');

      await peerConnection!.setLocalDescription(answer);

      Map<String, dynamic> roomWithAnswer = {
        'answer': {'type': answer.type, 'sdp': answer.sdp}
      };

      await roomRef.update(roomWithAnswer);

      roomRef.collection('callerCandidates').snapshots().listen((snapshot) {
        snapshot.docChanges.forEach((document) {
          var data = document.doc.data() as Map<String, dynamic>;
          print(data);
          print('Got new remote ICE candidate: $data');
          peerConnection!.addCandidate(
            RTCIceCandidate(
              data['candidate'],
              data['sdpMid'],
              data['sdpMLineIndex'],
            ),
          );
        });
      });
    }
  }

  Future<void> openUserMedia(
    RTCVideoRenderer localVideo,
    RTCVideoRenderer remoteVideo,
      {required bool? video}) async {

    isVideoCall = video!;

    localVideoForHang = localVideo;
    var stream = await navigator.mediaDevices
        .getUserMedia({'video': video, 'audio': true});

    localVideo.srcObject = stream;
    localStream = stream;

   if (video){
     remoteVideo.srcObject = await createLocalMediaStream('key');
   }
    //remoteVideo.srcObject = await createLocalMediaStream('key');

    print("this is stream ");
    //MediaStreamTrack vdoTrack;
    // var stream = await navigator.mediaDevices
    //     .getUserMedia({'video': true, 'audio': true});
    var stream1 = await  createLocalMediaStream('key');
    print("this is stream ${stream.id}");
    print("this is stream1 ${stream1.id}");

  }

  Future<void> hangUp(RTCVideoRenderer localVideo) async {
    List<MediaStreamTrack> tracks = [];
     if (remoteStream != null) {
       tracks = localVideo.srcObject!.getTracks();
     }

     tracks.forEach((track) {
      track.stop();
    });

    if (remoteStream != null) {
      remoteStream!.getTracks().forEach((track) => track.stop());
    }
    if (peerConnection != null) peerConnection!.close();

    if (roomId != null) {
      var db = FirebaseFirestore.instance;
      var roomRef = db.collection('call').doc(roomId);
      var calleeCandidates = await roomRef.collection('calleeCandidates').get();
      calleeCandidates.docs.forEach((document) => document.reference.delete());

      var callerCandidates = await roomRef.collection('callerCandidates').get();
      callerCandidates.docs.forEach((document) => document.reference.delete());

      await roomRef.delete();
    }

    if (remoteStream != null && isVideoCall) {
      await media.stop();
      Workmanager().registerPeriodicTask(
        "1",
        "myTask",
        frequency: Duration(seconds: 10),
        constraints: Constraints(
          networkType: NetworkType.connected,
        ),
      );

      // String? AWS_S3_REGION= AwsRegion.AP_SOUTH_1;
      // String? AWS_BUCKET="test-goodfit";
      // String? AWS_URL="https://test-goodfit.s3.ap-south-1.amazonaws.com/";
      // String? AWS_POOL_ID = "ap-south-1:cbc48e5d-8d66-473c-8555-50586f990a2d";

    //  MediaInfo? mediaInfo = await VideoCompress.compressVideo(
    //     filePath!,
    //     quality: VideoQuality.DefaultQuality,
    //     deleteOrigin: false, // It's false by default
    //   );

      // Workmanager().registerPeriodicTask(
      //   "3",
      //   "simplePeriodicTask",
      //   frequency: Duration(seconds: 10),
      // );
//
// print("this is size of file ${mediaInfo!.duration}");
// print("this is size of file ${mediaInfo.filesize}");
// print("this is size of file ${mediaInfo.path}");
// print("this is size of file ${mediaInfo.title}");


      // final String currentTime = DateTime.now().millisecondsSinceEpoch.toString();
      // ImageData imageData = ImageData(currentTime, mediaInfo.path!, uniqueId: currentTime, imageUploadFolder: "flutter_webRtc_p");
      //
      // String? fileUrl = await AmazonS3Cognito.upload(AWS_BUCKET, AWS_POOL_ID, AWS_S3_REGION, AWS_S3_REGION, imageData).then((value) {
      //   File(filePath!).delete();
      // });
    }

     if (localStream != null)  {
       localStream!.dispose();
     }
     if (remoteStream != null)  {
       remoteStream?.dispose();
     }
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
    media.start(filePath,
        videoTrack: videoTracks.first,
        audioChannel: RecorderAudioChannel.INPUT);
  }

  void registerPeerConnectionListeners() {
    peerConnection?.onIceGatheringState = (RTCIceGatheringState state) {
      print('ICE gathering state changed: $state');
    };

    peerConnection?.onConnectionState = (RTCPeerConnectionState state) async {
      print('Connection state change: $state');
      if(state == RTCPeerConnectionState.RTCPeerConnectionStateConnected){
        print("this is in state");
        isConnected = true;
       if(remoteStream != null){
       //  final Directory appDirectory = Directory('/storage/emulated/0/DCIM/');
         final appDirectory = await getTemporaryDirectory();
         final String videoDirectory = '${appDirectory.path}';
         await Directory(videoDirectory).create(recursive: true);

         final String currentTime = DateTime.now().millisecondsSinceEpoch.toString();
         filePath = "$videoDirectory/$currentTime.mp4";
         var videoTracks = remoteStream!.getVideoTracks();

         try{
           await  media.start(filePath!,
               videoTrack: videoTracks.first,
               audioChannel: RecorderAudioChannel.INPUT);

         }catch(e){
           print("this is error $e");
         }
       }
       else{
         // print("this is remote stream ${remoteStream!.getVideoTracks()}");
       }
     }
      else if(state == RTCPeerConnectionState.RTCPeerConnectionStateFailed || state == RTCPeerConnectionState.RTCPeerConnectionStateDisconnected || state == RTCPeerConnectionState.RTCPeerConnectionStateClosed){
        print("this is disconnect");
        //todo: create pushNamed
        navigatoryKey!.currentState!.pushNamed('/');
        // isConnected = false;

      }
    };

    peerConnection?.onSignalingState = (RTCSignalingState state) async {
      print('Signaling state change: $state');

    };

    peerConnection?.onIceGatheringState = (RTCIceGatheringState state) async {
      print('ICE connection state change: $state');

    };

    peerConnection?.onAddStream = (MediaStream stream) {
      print("Add remote stream");
      onAddRemoteStream?.call(stream);
      remoteStream = stream;
    };


  }

  void switchCamera() {
    if (localStream != null) {
      Helper.switchCamera(localStream!.getVideoTracks()[0]);

    }
  }

  void muteMic() {
    if (localStream != null) {
      bool enabled = localStream!.getAudioTracks()[0].enabled;
      localStream!.getAudioTracks()[0].enabled = !enabled;
    }
  }

  void switchCall(){
    if(localStream != null && remoteStream != null){
      bool enabled = localStream!.getVideoTracks()[0].enabled && remoteStream!.getVideoTracks()[0].enabled;
      localStream!.getVideoTracks()[0].enabled = !enabled;
      remoteStream!.getVideoTracks()[0].enabled = !enabled;
    }
  }

  void cancel(){
    // if(peerConnection != null){
    //   peerConnection!.close();
    // }
   if(localStream != null){
     localStream!.dispose();
   }
    if(remoteStream != null) {
      remoteStream!.dispose();
    }
  }

// Future compressimage(File image) async {
//   final tempdir = await getTemporaryDirectory();
//   final path = tempdir.path;
//   i.Image imagefile = i.decodeImage(image.readAsBytesSync());
//   final compressedImagefile = File('$path.jpg')
//     ..writeAsBytesSync(i.encodeJpg(imagefile, quality: 80));
//   // setState(() {
//   return compressedImagefile;
//   // });
// }

}
uploadData(String filePath) async {

  String? AWS_S3_REGION= AwsRegion.AP_SOUTH_1;
  String? AWS_BUCKET="test-goodfit";
  String? AWS_URL="https://test-goodfit.s3.ap-south-1.amazonaws.com/";
  String? AWS_POOL_ID = "ap-south-1:cbc48e5d-8d66-473c-8555-50586f990a2d";

  MediaInfo? mediaInfo = await VideoCompress.compressVideo(
    filePath,
    quality: VideoQuality.DefaultQuality,
    deleteOrigin: false, // It's false by default
  );

  // Workmanager().registerPeriodicTask(
  //   "3",
  //   "simplePeriodicTask",
  //   frequency: Duration(seconds: 10),
  // );

  print("this is size of file ${mediaInfo!.duration}");
  print("this is size of file ${mediaInfo.filesize}");
  print("this is size of file ${mediaInfo.path}");
  print("this is size of file ${mediaInfo.title}");


  final String currentTime = DateTime.now().millisecondsSinceEpoch.toString();
  ImageData imageData = ImageData(currentTime, mediaInfo.path!, uniqueId: currentTime, imageUploadFolder: "flutter_webRtc_p");

  String? fileUrl = await AmazonS3Cognito.upload(AWS_BUCKET, AWS_POOL_ID, AWS_S3_REGION, AWS_S3_REGION, imageData).then((value) {
    print("this is value after upload $value");
    File(filePath).delete();
  });
}
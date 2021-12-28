import 'dart:io';


import 'package:flutter_video_audio_webrtc/flutter_video_audio_webrtc.dart';
import 'package:flutter_video_audio_webrtc/model/user.dart';
import 'package:cloud_firestore/cloud_firestore.dart';



const String USERS_COLLECTION = "user";

class FirebaseMethods {
  // final FirebaseAuth _auth = FirebaseAuth.instance;
  // GoogleSignIn _googleSignIn = GoogleSignIn();
  static final FirebaseFirestore firestore = FirebaseFirestore.instance;

  static final CollectionReference _userCollection =
      _firestore.collection(USERS_COLLECTION);

  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  User user = User();

  Future<User> getUserDetails() async {
    // FirebaseUser currentUser = await getCurrentUser();

    DocumentSnapshot documentSnapshot =
        await _userCollection.doc(currentUser!.uid).get();

    return User.fromMap(documentSnapshot.data()  as Map<String,dynamic>);
  }

  Future<void> addDataToDb(User currentUser) async {
    // String username = Utils.getUsername(currentUser.email);

    user = User(
        uid: currentUser.uid,
        email: currentUser.email,
        name: currentUser.name,
        // profilePhoto: currentUser.photoUrl,
        username: currentUser.username,
    token: currentUser.token,
    );

    firestore
        .collection(USERS_COLLECTION)
        .doc(currentUser.uid)
        .set(user.toMap(user) as Map<String,dynamic>);
  }
  // Future<void> signOut() async {
  //   await _googleSignIn.signOut();
  //   return await _auth.signOut();
  // }

  // Future<List<User>> fetchAllUsers(FirebaseUser currentUser) async {
  //   List<User> userList = List<User>();
  //
  //   QuerySnapshot querySnapshot =
  //       await firestore.collection(USERS_COLLECTION).getDocuments();
  //   for (var i = 0; i < querySnapshot.documents.length; i++) {
  //     if (querySnapshot.documents[i].documentID != currentUser.uid) {
  //       userList.add(User.fromMap(querySnapshot.documents[i].data));
  //     }
  //   }
  //   return userList;
  // }

  // Future<void> addMessageToDb(
  //     Message message, User sender, User receiver) async {
  //   var map = message.toMap();
  //
  //   await firestore
  //       .collection(MESSAGES_COLLECTION)
  //       .document(message.senderId)
  //       .collection(message.receiverId)
  //       .add(map);
  //
  //   return await firestore
  //       .collection(MESSAGES_COLLECTION)
  //       .document(message.receiverId)
  //       .collection(message.senderId)
  //       .add(map);
  // }

  // Future<String> uploadImageToStorage(File imageFile) async {
  //   // mention try catch later on
  //
  //   try {
  //     _storageReference = FirebaseStorage.instance
  //         .ref()
  //         .child('${DateTime.now().millisecondsSinceEpoch}');
  //     StorageUploadTask storageUploadTask =
  //         _storageReference.putFile(imageFile);
  //     var url = await (await storageUploadTask.onComplete).ref.getDownloadURL();
  //     // print(url);
  //     return url;
  //   } catch (e) {
  //     return null;
  //   }
  // }

  // void setImageMsg(String url, String receiverId, String senderId) async {
  //   Message message;
  //
  //   message = Message.imageMessage(
  //       message: "IMAGE",
  //       receiverId: receiverId,
  //       senderId: senderId,
  //       photoUrl: url,
  //       timestamp: Timestamp.now(),
  //       type: 'image');
  //
  //   // create imagemap
  //   var map = message.toImageMap();
  //
  //   // var map = Map<String, dynamic>();
  //   await firestore
  //       .collection(MESSAGES_COLLECTION)
  //       .document(message.senderId)
  //       .collection(message.receiverId)
  //       .add(map);
  //
  //   firestore
  //       .collection(MESSAGES_COLLECTION)
  //       .document(message.receiverId)
  //       .collection(message.senderId)
  //       .add(map);
  // }
  //
  // void uploadImage(File image, String receiverId, String senderId,
  //     ImageUploadProvider imageUploadProvider) async {
  //   // Set some loading value to db and show it to user
  //   imageUploadProvider.setToLoading();
  //
  //   // Get url from the image bucket
  //   String url = await uploadImageToStorage(image);
  //
  //   // Hide loading
  //   imageUploadProvider.setToIdle();
  //
  //   setImageMsg(url, receiverId, senderId);
  // }
}

class User {
  String? uid;
  String? name;
  String? email;
  String? username;
  String? status;
  String? token;
  int? state;
  String? profilePhoto;

  User({
    this.uid,
    this.name,
    this.email,
    this.username,
    this.status,
    this.state,
    this.token,
    this.profilePhoto,
  });

  Map toMap(User user) {
    var data = Map<String, dynamic>();
    data['uid'] = user.uid;
    data['name'] = user.name;
    data['email'] = user.email;
    data['username'] = user.username;
    data["status"] = user.status;
    data["token"] = user.token;
    data["state"] = user.state;
    data["profile_photo"] = user.profilePhoto;
    return data;
  }

  // Named constructor
  User.fromMap(Map<String, dynamic> mapData) {
    this.uid = mapData['uid'];
    this.name = mapData['name'];
    this.email = mapData['email'];
    this.username = mapData['username'];
    this.status = mapData['status'];
    this.token = mapData['token'];
    this.state = mapData['state'];
    this.profilePhoto = mapData['profile_photo'];
  }
}

import 'package:shared_preferences/shared_preferences.dart';

class HelperFunctions{

  static String UserLoggedInKey = "isLoggedIn";
  static String userLastActivityKey = "lastSeen";
  static String User = "User";
  static String isSignIn = "isSignIn";

  /// saving data
  static Future<dynamic> saveUserLoggedIn(bool isUserLoggedIn) async{
    SharedPreferences preferences = await SharedPreferences.getInstance();
    return await preferences.setBool(UserLoggedInKey, isUserLoggedIn);
  }
  static Future<dynamic> saveUserId(String userId) async{
    SharedPreferences preferences = await SharedPreferences.getInstance();
    return await preferences.setString(User, userId);
  }

  /// fetching data

  static Future<dynamic> getUserLoggedIn() async{
    SharedPreferences preferences = await SharedPreferences.getInstance();
    return  preferences.getBool(UserLoggedInKey);
  }


  static Future<String?> getUserId() async{
    SharedPreferences preferences = await SharedPreferences.getInstance();
    return  preferences.getString(User);
  }

  /// remove data from

  static Future<dynamic> removeUserLoggedIn() async{
    SharedPreferences preferences = await SharedPreferences.getInstance();
    return await preferences.remove(UserLoggedInKey);
  }
  static Future<bool> removeUser() async{
    SharedPreferences preferences = await SharedPreferences.getInstance();
    return await preferences.remove(User);
  }

}
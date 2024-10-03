import 'package:shared_preferences/shared_preferences.dart';

class LocalSavedData {
  static SharedPreferences? preferences;

  // initialize
  static Future<void> init() async {
    preferences = await SharedPreferences.getInstance();
  }

  // saved the userId
  static Future<void> saveUserId(String id) async {
    await preferences!.setString("userId", id);
  }

  //read the userId
  static String getUserId() {
    return preferences!.getString("userId") ?? "";
  }

    // saved the user name
  static Future<void> saveUserName (String name) async {
    await preferences!.setString("name", name);
  }

  //read the userName
  static String getUserName() {
    return preferences!.getString("name") ?? "";
  }

    // saved the user phone
  static Future<void> saveUserPhone(String phone) async {
    await preferences!.setString("phone", phone);
  }

  //read the userPhone
  static String getUserPhone() {
    return preferences!.getString("phone") ?? "";
  }

    // saved the user profile pic
  static Future<void> saveUserProfile(String profile) async {
    await preferences!.setString("profile", profile);
  }

  //read the user profile pic
  static String getUserProfile() {
    return preferences!.getString("profile") ?? "";
  }

    // saved the user profile pic
  static Future<void> saveImageMessage(String image) async {
    await preferences!.setString("image-message", image);
  }
  

static Future<void> saveImageStatus(String status) async {
    await preferences!.setString("image-status", status);
  }
  static String getImageStatus()   {
    return preferences!.getString("image-status") ?? '';
  }
  
  
  //read the user profile pic
  static String getImageMessage() {
    return preferences!.getString("image-message") ?? "";
  }

    static Future<void> saveImageMessageId(String image) async {
    await preferences!.setString("image-message-id", image);
  }

  //read the user profile pic
  static String getImageMessageId() {
    return preferences!.getString("image-message-id") ?? "";
  }

// clear all the saved data
  static clearAllData() async {
    final bool? data = await preferences!.clear();
    print("cleared all data from local : $data");
  }
}

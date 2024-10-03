import 'package:chatty/controllers/appwrite_controllers.dart';
import 'package:chatty/controllers/local_saved_data.dart';
import 'package:chatty/model/user_data.dart';
import 'package:flutter/foundation.dart';

class UserDataProvider extends ChangeNotifier {
  String _userId = "";
  String _userName = "";
  String _userProfilePic = "";
  String _userPhoneNumber = "";
  String _userDeviceToken = "";

  String get getUserId => _userId;
  String get getUserName => _userName;
  String get getUserProfile => _userProfilePic;
  String get getUserNumber => _userPhoneNumber;
  String get getUserToken => _userDeviceToken;

// load the data from the device
  void localDatafromLocal() {
    _userId = LocalSavedData.getUserId();
    _userPhoneNumber = LocalSavedData.getUserPhone();
    _userProfilePic = LocalSavedData.getUserName();
    _userProfilePic = LocalSavedData.getUserProfile();
    _userPhoneNumber = LocalSavedData.getUserPhone();
    notifyListeners();
  }

  // set User id
  void setUserId(String id) {
    _userId = id;
    LocalSavedData.saveUserId(id);
    notifyListeners();
  }

  // to load the data from our appwrite database user collection
  void loadUserData(String userId) async {
    UserData? userData = await getUserDetails(userId: userId);
    if (userData != null) {
      _userName = userData.name ?? "";
      _userProfilePic = userData.profilePic ?? "";
      _userPhoneNumber = userData.phone ;
      notifyListeners();
    }
  }

  // set User name
  void setUserName(String name) {
    _userName = name;
    LocalSavedData.saveUserName(name);
    notifyListeners();
  }

  // set User Phone
  void setUserPhone(String phone) {
    _userPhoneNumber = phone;
    LocalSavedData.saveUserPhone(phone);
    notifyListeners();
  }

  // set User
  void setProfilePic(String pic) {
    _userProfilePic = pic;
    LocalSavedData.saveUserProfile(pic);
    notifyListeners();
  }

  void setDeviceToken(String token) {
    _userDeviceToken = token;
    notifyListeners();
  }

  void clearAllProvider() {
    _userId = "";
    _userName = "";
    _userProfilePic = "";
    _userPhoneNumber = "";
    _userDeviceToken = "";
    notifyListeners();
  }
}

import 'dart:convert';
import 'dart:io' as io;
import 'package:appwrite/appwrite.dart';
import 'package:appwrite/models.dart';
import 'package:chatty/controllers/local_saved_data.dart';
import 'package:chatty/main.dart';
import 'package:chatty/model/chat_data_model.dart';
import 'package:chatty/model/message_model.dart';
import 'package:chatty/model/user_data.dart';
import 'package:chatty/providers/chat_provider.dart';
import 'package:chatty/providers/user_data_provider.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import '../widgets/show_toast.dart';
import 'package:http/http.dart' as http;

Client client = Client()
    .setEndpoint('https://cloud.appwrite.io/v1')
    .setProject('66aa910e0005af7899c0')
    .setSelfSigned(status: true); // For self signed certificates, only use for

const String db = "66aa9533001a512025c8";
const String userCollection = "66aa954f003c8576273c";
const String storageBucket = "66acbc050000e1c2bc32";
const String chatCollection = "66adab81000be561c932";

const String appWriteEndpoint = 'https://cloud.appwrite.io';
const String projectID = '66aa910e0005af7899c0';

var selectedImage = '';
io.File? selectedImageFile;

Account account = Account(client);
final Databases databases = Databases(client);
final Storage storage = Storage(client);
final Realtime realtime = Realtime(client);
bool sendingImage = false;
RealtimeSubscription? subscription;
// final box = GetStorage();

// to subscribe to realtime changes
subscribeToRealtime({required String userId}) {
  subscription = realtime.subscribe([
    "databases.$db.collections.$chatCollection.documents",
    "databases.$db.collections.$userCollection.documents"
  ]);

  print("subscribing to realtime");

  subscription!.stream.listen((data) {
    print("some event happend");
    // print(data.events);
    // print(data.payload);
    final firstItem = data.events[0].split(".");
    final eventType = firstItem[firstItem.length - 1];
    print("event type is $eventType");
    if (eventType == "create") {
      Provider.of<ChatProvider>(navigatorKey.currentState!.context,
              listen: false)
          .loadChats(userId);
    } else if (eventType == "update") {
      Provider.of<ChatProvider>(navigatorKey.currentState!.context,
              listen: false)
          .loadChats(userId);
    } else if (eventType == "delete") {
      Provider.of<ChatProvider>(navigatorKey.currentState!.context,
              listen: false)
          .loadChats(userId);
    }
  });
}

//save phone number to database (while creating a new account)
Future savePhoneToDb({required String phoneno, required String userId}) async {
  try {
    final response = await databases.createDocument(
        databaseId: db,
        collectionId: userCollection,
        documentId: userId,
        data: {"phone_no": phoneno, "userId": userId});

    print(response);
    return true;
  } on AppwriteException catch (e) {
    print("Cannot save to user database : $e");
    return false;
  }
}

//check whether the phone number exist in the DB or not
Future<String> checkPhoneNumber({required phoneno}) async {
  try {
    final DocumentList matchUser = await databases.listDocuments(
        databaseId: db,
        collectionId: userCollection,
        queries: [Query.equal("phone_no", phoneno)]);

    if (matchUser.total > 0) {
      final Document user = matchUser.documents[0];

      if (user.data["phone_no"] != null || user.data["phone_no"] != "") {
        return user.data["userId"];
      } else {
        print("No user exist on db");
        return "user don't exist";
      }
    } else {
      print("No user exist on db");
      return "user don't exist";
    }
  } on AppwriteException catch (e) {
    print("error on reading database $e");
    return "user don't exist";
  }
}

//create a phone session by sending an OTP to the phone number
Future<String> createPhoneSession({required String phone}) async {
  try {
    final userId = await checkPhoneNumber(phoneno: phone);
    if (userId == "user don't exist") {
      // if userId 'phone number' does not exit creates a new user account using phone number
      final Token data =
          await account.createPhoneToken(userId: ID.unique(), phone: phone);

      // save the new user to user collection
      savePhoneToDb(phoneno: phone, userId: data.userId);
      return data.userId;
    }

    // if user is an existing user
    else {
      // create phone token for existing user
      final Token data =
          await account.createPhoneToken(userId: userId, phone: phone);
      return data.userId;
    }
  } catch (e) {
    print("error on create phone session :$e");
    return "login error";
  }
}

// function to log in with OTP
Future<bool> loginWithOtp({required String otp, required String userId}) async {
  try {
    final Session session =
        await account.updatePhoneSession(userId: userId, secret: otp);
    print(session.userId);
    return true;
  } catch (e) {
    print("error logging in with OTP :$e");
    return false;
  }
}

// to check whether a session exist or not
Future<bool> checkSessions() async {
  try {
    final Session session = await account.getSession(sessionId: "current");
    print("Session exit ${session.$id}");
    return true;
  } catch (e) {
    print("Session doesn't exit. Please login!");
    return false;
  }
}

// to logout and delete a session
Future logoutUser() async {
  await account.deleteSession(sessionId: "current");
}

// load user data from appwrite collections
Future<UserData?> getUserDetails({required String userId}) async {
  try {
    final response = await databases.getDocument(
        databaseId: db, collectionId: userCollection, documentId: userId);
    print("getting user data");
    print(response.data);
    Provider.of<UserDataProvider>(navigatorKey.currentContext!, listen: false)
        .setUserName(response.data["name"] ?? "");
    Provider.of<UserDataProvider>(navigatorKey.currentContext!, listen: false)
        .setProfilePic(response.data["profile_pic"] ?? "");
    return UserData.toMap(response.data);
  } catch (e) {
    print("error getting user data :$e");
    return null;
  }
}

// update the user data
Future<bool> updateUserDetails(
    {required String userId, required String name}) async {
  try {
    final data = await databases.updateDocument(
        databaseId: db,
        collectionId: userCollection,
        documentId: userId,
        data: {
          "name": name,
          // "profile_pic": pic,
        });
    Provider.of<UserDataProvider>(navigatorKey.currentContext!, listen: false)
        .setUserName(name);
    //  Provider.of<UserDataProvider>(navigatorKey.currentContext!, listen: false)
    //      .setProfilePic(pic);
    print(data);
    return true;
  } on AppwriteException catch (e) {
    print("cannot save to db :$e");
    return false;
  }
}

Future<Document?> getUserDocument(dynamic url) async {
  try {
    final response = await databases.listDocuments(
      databaseId: db,
      collectionId: userCollection,
      queries: [
        Query.equal('userId', LocalSavedData.getUserId()),
      ],
    );

    if (response.documents.isNotEmpty) {
      final userDoc = response.documents.first;

      // Update the user's profile URL
      await _updateUserProfileUrl(userDoc.$id, url);

      return userDoc;
    } else {
      debugPrint(
          'No document found for user ID: ${LocalSavedData.getUserId()}');
      return null;
    }
  } catch (e) {
    debugPrint('Failed to fetch user document: $e');
    return null;
  }
}

Future<Document?> getMessageUsingDocumentId(dynamic id) async {
  try {
    final response = await databases.listDocuments(
      databaseId: db,
      collectionId: chatCollection,
      // queries: [
      //   Query.equal('userId', LocalSavedData.getImageMessageId()),
      // ],
    );

    if (response.documents.isNotEmpty) {
      debugPrint("Reponse ${response.documents}");
      // final userDoc = response.documents.first;

      // Update the user's profile URL
      // await _updateUserProfileUrl(userDoc.$id, url);

      // return userDoc;
    } else {
      debugPrint(
          'No document found for user ID: ${LocalSavedData.getUserId()}');
      return null;
    }
  } catch (e) {
    debugPrint('Failed to fetch user document: $e');
    return null;
  }
}

Future<void> _updateUserProfileUrl(String documentId, String profileUrl) async {
  try {
    await databases.updateDocument(
      databaseId: db,
      collectionId: userCollection,
      documentId: documentId,
      data: {'profile_pic': profileUrl},
    );
    debugPrint('User profile URL updated successfully');
  } catch (e) {
    debugPrint('Failed to update user profile URL: $e');
  }
}

// upload and save image to storage bucket to appwrite database(create new image)
Future<String?> saveImageToBucket({required InputFile image}) async {
  try {
    final response = await storage.createFile(
        bucketId: storageBucket, fileId: ID.unique(), file: image);
    print("The response after save to bucket ${response.$id}");
    return response.$id;
  } catch (e) {
    print("error on saving mage to bucket :$e");
    return null;
  }
}

// update an image in bucket : first delete then create new
Future<String?> updateImageOnBucket(
    {required String oldImageId, required InputFile image}) async {
  try {
    //delete the old image and await its completion
    deleteImagefromBucket(oldImageId: oldImageId);

    // create a new image and await its completion
    final newImage = saveImageToBucket(image: image);
    return newImage;
  } catch (e) {
    print("cannot update/ delete image :$e");
    return null;
  }
}

// to only delete the image from the storage bucket
Future<bool> deleteImagefromBucket({required String oldImageId}) async {
  try {
    //delete the old image
    await storage.deleteFile(bucketId: storageBucket, fileId: oldImageId);

    return true;
  } catch (e) {
    print("Error deleting image :$e");
    return false;
  }
}

// to search all the users from the database
Future<DocumentList?> searchUsers(
    {required String searchItem, required String userId}) async {
  try {
    final DocumentList users = await databases.listDocuments(
        databaseId: db,
        collectionId: userCollection,
        queries: [
          Query.search("phone_no", searchItem),
          Query.notEqual("userId", userId)
        ]);
    print("Total match users ${users.total}");
    return users;
  } catch (e) {
    print("Error on searching users : $e");
    return null;
  }
}

// create a new chat and save to database
// Future createNewChat(
//     {required String message,
//     required String senderId,
//     required String receiverId,
//     required bool isImage,
//     required String messageId,
//     String? status,
//     }) async {
//   try {
//     // final id = ID.unique();
//     final msg = await databases.createDocument(
//         databaseId: db,
//         collectionId: chatCollection,
//         documentId: ID.unique(),
//         data: {
//           "message": message,
//           "senderId": senderId,
//           "receiverId": receiverId,
//           "timestamp": DateTime.now().toIso8601String(),
//           "isSeenbyReceiver": false,
//           "isImage": isImage,
//           "userData": [senderId, receiverId],
//           if(isImage)"status":messageId
//         });

//     print("Message sent");
//     return true;
//   } catch (e) {
//     print("Failed to send message :$e");
//     return false;
//   }

// }

Future createNewChat({
  required String message,
  required String senderId,
  required String receiverId,
  required bool isImage,
  required String messageId,
  String? status,
}) async {
  try {
    debugPrint("isImage ${isImage}");
    var msgId =  ID.unique();
    final msg = await databases.createDocument(
        databaseId: db,
        collectionId: chatCollection,
        documentId:msgId,
        data: {
          "message": message,
          "senderId": senderId,
          "receiverId": receiverId,
          "timestamp": DateTime.now().toIso8601String(),
          "isSeenbyReceiver": false,
          "isImage": isImage,
          "userData": [senderId, receiverId],
          if (isImage) "status": status,
          "messageId":msgId
        });

    print("Message sent");
    return msg.$id;
  } catch (e) {
    print("Failed to send message :$e");
    return null;
  }
}

// create a new chat and save to database
Future createImageChat(
    {required String message,
    required String senderId,
    required String receiverId,
    required bool isImage}) async {
  try {
    var messageId = ID.unique();
    final msg = await databases.createDocument(
        databaseId: db,
        collectionId: chatCollection,
        documentId: messageId,
        data: {
          "message": message,
          "senderId": senderId,
          "receiverId": receiverId,
          "timestamp": DateTime.now().toIso8601String(),
          "isSeenbyReceiver": false,
          "isImage": isImage,
          "userData": [senderId, receiverId],
          "messageId":messageId
        });

    print("Message sent ${msg.$id}  $messageId");
    return messageId;
  } catch (e) {
    print("Failed to send message :$e");
    return '';
  }
}

// to delete the chat from database chat collection
Future deleteCurrentUserChat({required String chatId}) async {
  try {
    await databases.deleteDocument(
        databaseId: db, collectionId: chatCollection, documentId: chatId);
  } catch (e) {
    print("Error on deleting chat message : $e");
  }
}

// edit our chat message and update to database
Future editChat({
  required String chatId,
  required String message,
}) async {
  try {
    await databases.updateDocument(
        databaseId: db,
        collectionId: chatCollection,
        documentId: chatId,
        data: {"message": message});
    print("Message updated");
  } catch (e) {
    print("Error on editing message :$e");
  }
}

// to list all the chats belonging to the current user
Future<Map<String, List<ChatDataModel>>?> currentUserChats(
    String userId) async {
  try {
    var results = await databases
        .listDocuments(databaseId: db, collectionId: chatCollection, queries: [
      Query.or(
          [Query.equal("senderId", userId), Query.equal("receiverId", userId)]),
      Query.orderDesc("timestamp"),
      Query.limit(2000)
    ]);

    final DocumentList chatDocuments = results;

    print(
        "Chat documents ${chatDocuments.total} and documents ${chatDocuments.documents.length}");
    Map<String, List<ChatDataModel>> chats = {};

    if (chatDocuments.documents.isNotEmpty) {
      for (var i = 0; i < chatDocuments.documents.length; i++) {
        var doc = chatDocuments.documents[i];
        String sender = doc.data["senderId"];
        String receiver = doc.data["receiverId"];

        MessageModel message = MessageModel.fromMap(doc.data);

        List<UserData> users = [];
        for (var user in doc.data["userData"]) {
          users.add(UserData.toMap(user));
        }

        String key = (sender == userId) ? receiver : sender;

        if (chats[key] == null) {
          chats[key] = [];
        }
        chats[key]!.add(ChatDataModel(message: message, users: users));
      }
    }

    return chats;
  } catch (e) {
    print("Error in reading current user chats :$e");
    return null;
  }
}

// to update isSeen message status
Future updateIsSeen({required List<String> chatsIds}) async {
  try {
    for (var chatId in chatsIds) {
      await databases.updateDocument(
          databaseId: db,
          collectionId: chatCollection,
          documentId: chatId,
          data: {"isSeenbyReceiver": true});
      print("Update is seen");
    }
  } catch (e) {
    print("Error in update is seen :$e");
  }
}

// to update the online status
Future updateOnlineStatus(
    {required bool status, required String userId}) async {
  try {
    await databases.updateDocument(
        databaseId: db,
        collectionId: userCollection,
        documentId: userId,
        data: {"isOnline": status});
    print("Updated user online status $status ");
  } catch (e) {
    print("Unable to update online status : $e");
  }
}

// to save users device token to user collection
Future saveUserDeviceToken(String token, String userId) async {
  try {
    await databases.updateDocument(
        databaseId: db,
        collectionId: userCollection,
        documentId: userId,
        data: {"device_token": token});
    print("Device token saved to db");

    return true;
  } catch (e) {
    print("Cannot save device token :$e");
    return false;
  }
}

// to send notification to other user
Future sendNotificationtoOtherUser({
  required String notificationTitle,
  required String notificationBody,
  required String deviceToken,
}) async {
  try {
    print("sending notification");
    final Map<String, dynamic> body = {
      "deviceToken": deviceToken,
      "message": {"title": notificationTitle, "body": notificationBody},
    };

    final response = await http.post(
        Uri.parse("https://66b43733e14335df74a8.appwrite.global/"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(body));

    if (response.statusCode == 200) {
      print("Notification sent to other user");
    }
  } catch (e) {
    print("Notification cannot be sent");
  }
}

void toastSuccess({required String e}) {
  showToast(
    msg: e,
    toastLength: Toast.LENGTH_SHORT,
    fontSize: 15,
    textColor: Colors.white,
    toastGravity: ToastGravity.CENTER,
    backgroundColor: Colors.green.withOpacity(0.9),
  );
}

void toastError({required String e}) {
  showToast(
    msg: e,
    toastLength: Toast.LENGTH_SHORT,
    fontSize: 15,
    textColor: Colors.white,
    toastGravity: ToastGravity.TOP,
    backgroundColor: Colors.red.withOpacity(0.9),
  );
}

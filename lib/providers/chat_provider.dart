import 'dart:async';
import 'package:chatty/controllers/appwrite_controllers.dart';
import 'package:chatty/controllers/local_saved_data.dart';
import 'package:chatty/model/chat_data_model.dart';
import 'package:chatty/model/message_model.dart';
import 'package:chatty/model/user_data.dart';
import 'package:flutter/material.dart';

class ChatProvider extends ChangeNotifier {
  Map<String, List<ChatDataModel>> chats = {};
  bool _isLoading = false;

  // get all users Chats
  Map<String, List<ChatDataModel>> get getAllChats => chats;

  //add a getter for the loading state
  bool get isLoading => _isLoading;

  Timer? _debounce;

  // to load all current user chats
  void loadChats(String currentUser) async {
    _isLoading = true; //Set loading to true when loading starts
    // notifyListeners(); //Notify listeners to update the UI

    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(Duration.zero, () async {
      Map<String, List<ChatDataModel>>? loadedChats =
          await currentUserChats(currentUser);

      if (loadedChats != null) {
        chats = loadedChats;

        chats.forEach((key, value) {
          // sorting in descending timestamp
          value.sort(
              (a, b) => a.message.timestamp.compareTo(b.message.timestamp));
        });
        print("Chats updated in provider");
        notifyListeners();
      }
      _isLoading = false; //Set loading to false when loading is complete
      notifyListeners(); // Notify listeners to update the UI
    });
  }

  Future<bool> updateMessageStatus(
      {required String status,
      required BuildContext ctx,
      required String url}) async {
    try {
      debugPrint("Documentt id ${LocalSavedData.getImageMessageId()}");
      // Update the document with the new status
      final updatedDocument = await databases.updateDocument(
        databaseId: db,
        collectionId: chatCollection,
        documentId: LocalSavedData.getImageMessageId(),
        data: {"status": status, "message": url},
      );

      debugPrint("Document updated: ${updatedDocument.$id}, Status: $status");
      return true;
    } catch (e) {
      debugPrint("Failed to update document: $e");
      return false;
    }
  }

  // add the chat message when user sends a new message to someone else
  void addMessage(
      MessageModel message, String currentUser, List<UserData> users) {
    try {
      if (message.sender == currentUser) {
        if (chats[message.receiver] == null) {
          chats[message.receiver] = [];
        }

        chats[message.receiver]!
            .add(ChatDataModel(message: message, users: users));
      } else {
        // the current user is receiver
        if (chats[message.sender] == null) {
          chats[message.sender] = [];
        }

        chats[message.sender]!
            .add(ChatDataModel(message: message, users: users));
      }

      notifyListeners();
    } catch (e) {
      print("Error in chatProvider adding message");
    }
  }

  // delete message from chats data
  void deleteMessage(MessageModel message, String currentUser) async {
    try {
      // user is delete the message
      if (message.sender == currentUser) {
        chats[message.receiver]!
            .removeWhere((element) => element.message.messageId == message.messageId);

        if (message.isImage == true) {
          deleteImagefromBucket(oldImageId: message.message);
          print("Image deleted from bucket!");
        }

        deleteCurrentUserChat(chatId: message.messageId!);
      } else {
        // current user is receiver
        chats[message.sender]!
            .removeWhere((element) => element.message.messageId == message.messageId);
        print("Message deleted successfully!");
      }
      notifyListeners();
    } catch (e) {
      print("Error on message deletion");
    }
  }

  // clear all chats
  void clearChats() {
    chats = {};
    notifyListeners();
  }
}

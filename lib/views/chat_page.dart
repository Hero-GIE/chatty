import 'package:cached_network_image/cached_network_image.dart';
import 'package:chatty/constant/app_color.dart';
import 'package:chatty/constant/chat_messages.dart';
import 'package:chatty/controllers/appwrite_controllers.dart';
import 'package:chatty/model/message_model.dart';
import 'package:chatty/model/user_data.dart';
import 'package:chatty/providers/chat_provider.dart';
import 'package:chatty/providers/user_data_provider.dart';
import 'package:chatty/widgets/image_dialog.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../controllers/local_saved_data.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  TextEditingController messageController = TextEditingController();
  TextEditingController editmessageController = TextEditingController();
  bool _isSendButtonEnabled = false;

  String recentMessageId = '';
  late String currentUserId;
  late String currentUserName;

  @override
  void initState() {
    final userDataProvider =
        Provider.of<UserDataProvider>(context, listen: false);
    currentUserId = userDataProvider.getUserId ?? '';
    currentUserName = userDataProvider.getUserName ?? '';

    // Load chats if currentUserId is not empty
    if (currentUserId.isNotEmpty) {
      Provider.of<ChatProvider>(context, listen: false)
          .loadChats(currentUserId);
    }

    // Add listener to the message controller
    messageController.addListener(_onMessageChanged);

    super.initState();
  }

  void _onMessageChanged() {
    setState(() {
      _isSendButtonEnabled = messageController.text.trim().isNotEmpty;
    });
  }

  @override
  void dispose() {
    // Dispose the controller to avoid memory leaks
    messageController.dispose();
    super.dispose();
  }

// to send simple text message
  void _sendMessage({required UserData receiver, required String messageId}) {
    if (_isSendButtonEnabled) {
      setState(() {
        createNewChat(
                message: messageController.text,
                senderId: currentUserId,
                receiverId: receiver.userId,
                isImage: false,
                messageId: messageId)
            .then((messageId) {
          if (messageId != null) {
            Provider.of<ChatProvider>(context, listen: false).addMessage(
                MessageModel(
                    message: messageController.text,
                    sender: currentUserId,
                    receiver: receiver.userId,
                    timestamp: DateTime.now().toIso8601String(),
                    isSeenByReceiver: false,
                    messageId: messageId),
                currentUserId,
                [UserData(phone: "", userId: currentUserId), receiver]);
            sendNotificationtoOtherUser(
                notificationTitle: '$currentUserName sent you a message',
                notificationBody: messageController.text,
                deviceToken: receiver.deviceToken!);
            messageController.clear();
            _isSendButtonEnabled = false;
          }
        }).catchError((e) {
          debugPrint("err ${e.toString()}");
        });
      });
    }
  }

  void _sendImageMessage(
      {required UserData receiver,
      required String imageUrl,
      required String uuid}) {
    setState(() {
      debugPrint("@@ ${LocalSavedData.getImageStatus()}");
      createNewChat(
        message: imageUrl,
        senderId: currentUserId,
        receiverId: receiver.userId,
        isImage: true,
        messageId: uuid,
        status: LocalSavedData.getImageStatus(),
      ).then((messageId) {
        if (messageId != null) {
          LocalSavedData.saveImageMessageId(messageId);
          Provider.of<ChatProvider>(context, listen: false).addMessage(
              MessageModel(
                  message: imageUrl,
                  sender: currentUserId,
                  receiver: receiver.userId,
                  timestamp: DateTime.now().toIso8601String(),
                  isSeenByReceiver: false,
                  isImage: true,
                  status: LocalSavedData.getImageStatus(),
                  messageId: messageId),
              currentUserId,
              [UserData(phone: "", userId: currentUserId), receiver]);

          messageController.clear();
        }
      });
    });
  }

  void showImageDialog(String imageUrl) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          child: Container(
            height: 300,
            width: 300,
            decoration: BoxDecoration(
              shape: BoxShape.rectangle,
              borderRadius: BorderRadius.circular(16.0),
              border: Border.all(
                color: Colors.white,
                width: 2.0,
              ),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16.0),
              child: CachedNetworkImage(
                imageUrl: imageUrl,
                fit: BoxFit.cover,
                placeholder: (context, url) => Center(
                  child: CircularProgressIndicator(
                    strokeWidth: 4.0,
                    valueColor: AlwaysStoppedAnimation<Color>(
                        AppColors.backgroundColor),
                  ),
                ),
                errorWidget: (context, url, error) => Icon(Icons.error),
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    UserData receiver = ModalRoute.of(context)!.settings.arguments as UserData;
    debugPrint("Uid ${currentUserId}");

    return Consumer<ChatProvider>(
      builder: (context, value, child) {
        final userAndOtherChats = value.getAllChats[receiver.userId] ?? [];

        bool? otherUserOnline = userAndOtherChats.isNotEmpty
            ? userAndOtherChats[0].users[0].userId == receiver.userId
                ? userAndOtherChats[0].users[0].isOnline
                : userAndOtherChats[0].users[1].isOnline
            : false;

        List<String> receiverMsgList = [];

        for (var chat in userAndOtherChats) {
          if (chat.message.receiver == currentUserId) {
            if (chat.message.isSeenByReceiver == false) {
              debugPrint(
                  "Message id ${chat.message.messageId ?? "No message id"}");
              // receiverMsgList.add(chat.message.messageId!);
              if (chat.message.messageId != null) {
                receiverMsgList.add(chat.message.messageId!);
              } else {
                debugPrint(
                    "Message id is not available${chat.message.messageId}");
              }
            }
          }
        }
        updateIsSeen(chatsIds: receiverMsgList);
        return Scaffold(
          backgroundColor: AppColors.white,
          appBar: AppBar(
            leading: IconButton(
              icon: Icon(
                Icons.chevron_left,
                color: AppColors.backgroundColor,
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            leadingWidth: 40,
            scrolledUnderElevation: 0,
            elevation: 0,
            title: Row(
              children: [
                GestureDetector(
                  onTap: () {
                    if (receiver.profilePic != null &&
                        receiver.profilePic!.isNotEmpty) {
                      showImageDialog(receiver.profilePic!);
                    }
                  },
                  child: CircleAvatar(
                    backgroundImage: receiver.profilePic != null &&
                            receiver.profilePic!.isNotEmpty
                        ? NetworkImage(receiver.profilePic!)
                        : AssetImage("assets/images/user.png") as ImageProvider,
                    radius: 20,
                  ),
                ),
                SizedBox(
                  width: 10,
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      receiver.name!,
                      style: TextStyle(
                        color: AppColors.darkGray,
                        fontSize: 17,
                      ),
                    ),
                    Text(
                      otherUserOnline == true ? "Online" : "Offline",
                      style: TextStyle(
                        color: AppColors.backgroundColor,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          body: Column(
            children: [
              Expanded(
                child: Container(
                  padding: EdgeInsets.all(8),
                  child: ListView.builder(
                      reverse: true,
                      itemCount: userAndOtherChats.length,
                      itemBuilder: (context, index) {
                        final msg = userAndOtherChats[
                                userAndOtherChats.length - 1 - index]
                            .message;
                        print("user chats : ${userAndOtherChats.length}");
                        return GestureDetector(
                          onLongPress: () {
                            showDialog(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: msg.isImage == true
                                    ? Text(msg.sender == currentUserId
                                        ? "Select an option."
                                        : "This image cannot be modified")
                                    : Text(
                                        "${msg.message.length > 20 ? msg.message.substring(0, 20) : msg.message} ..."),
                                content: msg.isImage == true
                                    ? Text(msg.sender == currentUserId
                                        ? 'Delete image'
                                        : 'This image cannot be deleted')
                                    : Text(msg.sender == currentUserId
                                        ? 'Select an option.'
                                        : 'This message cannot be modified'),
                                actions: [
                                  TextButton(
                                      onPressed: () {
                                        Navigator.pop(context);
                                      },
                                      child: Text("Cancel")),
                                  msg.sender == currentUserId
                                      ? TextButton(
                                          onPressed: () {
                                            Navigator.pop(context);
                                            editmessageController.text =
                                                msg.message;
                
                                            showDialog(
                                                context: context,
                                                builder: (context) =>
                                                    AlertDialog(
                                                      title: Text(
                                                          "Edit this message"),
                                                      content: TextFormField(
                                                        controller:
                                                            editmessageController,
                                                        maxLines: 10,
                                                      ),
                                                      actions: [
                                                        TextButton(
                                                            onPressed: () {
                                                              editChat(
                                                                chatId: msg
                                                                    .messageId!,
                                                                message:
                                                                    editmessageController
                                                                        .text,
                                                              );
                                                              Navigator.pop(
                                                                  context);
                                                              editmessageController
                                                                  .text = "";
                                                            },
                                                            child: Text("Ok")),
                                                        TextButton(
                                                            onPressed: () {
                                                              Navigator.pop(
                                                                  context);
                                                            },
                                                            child:
                                                                Text("Cancel")),
                                                      ],
                                                    ));
                                          },
                                          child: Text("Edit"))
                                      : SizedBox(),
                                  msg.sender == currentUserId
                                      ? TextButton(
                                          onPressed: () {
                                            Provider.of<ChatProvider>(context,
                                                    listen: false)
                                                .deleteMessage(
                                                    msg, currentUserId);
                
                                            Navigator.pop(context);
                                          },
                                          child: Text("Delete"))
                                      : SizedBox(),
                                ],
                              ),
                            );
                          },
                          child: ChatMessages(
                            isImage: msg.isImage ?? false,
                            msg: msg,
                            currentUser: currentUserId,
                          ),
                        );
                      }),
                ),
              ),
              Container(
                margin: EdgeInsets.all(6),
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(20)),
                child: Row(
                  children: [
                    IconButton(
                        onPressed: () {
                          openImagePickerDialog(
                              context,
                              details: {
                                "receiverId": receiver.userId,
                                "userData": receiver,
                                "context": context
                              },
                              () {
                                _sendImageMessage(
                                  receiver: receiver,
                                  uuid: LocalSavedData.getImageMessageId(),
                                  imageUrl: LocalSavedData.getImageMessage(),
                                );
                                setState(() {});
                              },
                              updatingProfile: false,
                              imageCallBack: () {
                                setState(() {});
                              });
                        },
                        icon: const Icon(CupertinoIcons.paperclip,
                            color: AppColors.backgroundColor)),
                    Expanded(
                        child: TextField(
                      onSubmitted: (value) {
                        var uuid = const Uuid();
                        var messageId = uuid.v1();
                        debugPrint("Message id ${messageId}");
                        // _sendMessage(receiver: receiver,messageId: messageId);
                      },
                      controller: messageController,
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        hintText: 'Type a message...',
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                          borderSide: const BorderSide(
                            color: AppColors
                                .backgroundColor, // Border color when not focused
                            width: 1.4,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                          borderSide: const BorderSide(
                            color: AppColors
                                .backgroundColor, // Border color when focused
                            width: 1.4,
                          ),
                        ),
                      ),
                    )),
                    IconButton(
                        onPressed: _isSendButtonEnabled
                            ? () {
                                var uuid = const Uuid();
                                var messageId = uuid.v1();
                                debugPrint("Message id ${messageId}");
                                _sendMessage(
                                    receiver: receiver, messageId: messageId);
                              }
                            : null,
                        icon: Icon(
                          Icons.send,
                          color: _isSendButtonEnabled
                              ? AppColors.backgroundColor
                              : Colors.grey,
                        )),
                  ],
                ),
              )
            ],
          ),
        );
      },
    );
  }
}

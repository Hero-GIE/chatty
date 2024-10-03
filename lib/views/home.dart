import 'package:cached_network_image/cached_network_image.dart';
import 'package:chatty/controllers/fcm_controllers.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:chatty/constant/app_color.dart';
import 'package:chatty/model/chat_data_model.dart';
import 'package:chatty/model/user_data.dart';
import 'package:chatty/providers/chat_provider.dart';
import 'package:chatty/providers/user_data_provider.dart';
import '../controllers/appwrite_controllers.dart';
import '../controllers/local_saved_data.dart';
import '../widgets/avatar_widget.dart';
import 'package:jiffy/jiffy.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late String currentUserId = "";

  @override
  void initState() {
    currentUserId =
        Provider.of<UserDataProvider>(context, listen: false).getUserId;
    debugPrint("Uid ${currentUserId}");
    Provider.of<ChatProvider>(context, listen: false).loadChats(currentUserId);
    PushNotifications.getDeviceToken();
    subscribeToRealtime(userId: currentUserId);
    super.initState();
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
    updateOnlineStatus(status: true, userId: currentUserId);
    // Fetch and log user profile URL
    debugPrint("url ${LocalSavedData.getUserProfile()}");
    currentUserChats(LocalSavedData.getUserId());

    return Scaffold(
      backgroundColor: AppColors.white,
      extendBody: true,
      appBar: AppBar(
        scrolledUnderElevation: 0,
        elevation: 0,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Chats',
              style: TextStyle(
                color: AppColors.darkGray,
                fontWeight: FontWeight.w500,
              ),
            ),
            InkWell(
              onTap: () {
                Navigator.pushNamed(context, "/profile");
              },
              child: AvatarWidget(
                url: LocalSavedData.getUserProfile(),
                widthHeight: 40,
              ),
            ),
          ],
        ),
      ),
      body: Consumer<ChatProvider>(
        builder: (context, value, child) {
          // Display "Loading chats..." when chats are being loaded
          if (value.isLoading) {
            return const Center(
              child: CircularProgressIndicator(
                strokeWidth: 4.0,
                valueColor:
                    AlwaysStoppedAnimation<Color>(AppColors.backgroundColor),
              ),
            );
          }
          // Display "No Chats" when there are no chats
          else if (value.getAllChats.isEmpty) {
            return Center(
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // An empty widget to push the image down
                      SizedBox(
                          height: MediaQuery.of(context).size.height *
                              0.1), // Adjust the height as needed
                      Image.asset(
                        "assets/images/no_chat.png",
                        width: 170,
                        height: 150,
                      ),
                    ],
                  ),
  
                  Positioned(
                    bottom: MediaQuery.of(context).size.height *
                        0.3, // Adjust the bottom position as needed
                    child: const Text(
                      "No Chats",
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.darkGray,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }
          // Display chats when they are loaded
          else {
            List otherUsers = value.getAllChats.keys.toList();
            return ListView.builder(
              itemCount: otherUsers.length,
              itemBuilder: (context, index) {
                List<ChatDataModel> chatData =
                    value.getAllChats[otherUsers[index]]!;

                int totalChats = chatData.length;

                UserData otherUser =
                    chatData[0].users[0].userId == currentUserId
                        ? chatData[0].users[1]
                        : chatData[0].users[0];

                int unreadMsg = 0;

                chatData.fold(unreadMsg, (previousValue, element) {
                  if (element.message.isSeenByReceiver == false) {
                    unreadMsg++;
                  }
                  return unreadMsg;
                });
                return ListTile(
                  onTap: () => Navigator.pushNamed(context, "/chat",
                      arguments: otherUser),
                  leading: GestureDetector(
                    onTap: () {
                      if (otherUser.profilePic != null &&
                          otherUser.profilePic!.isNotEmpty) {
                        showImageDialog(otherUser.profilePic!);
                      }
                    },
                    child: Stack(
                      children: [
                        CircleAvatar(
                          backgroundImage: otherUser.profilePic != null &&
                                  otherUser.profilePic!.isNotEmpty
                              ? NetworkImage(otherUser.profilePic!)
                              : const AssetImage("assets/images/user.png")
                                  as ImageProvider,
                          radius: 20,
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: CircleAvatar(
                            radius: 6,
                            backgroundColor: Colors.white,
                            child: CircleAvatar(
                              radius: 5,
                              backgroundColor: otherUser.isOnline == true
                                  ? Colors.green
                                  : Colors.grey,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  title: Text(otherUser.name!),
                  subtitle: Text(
                    "${chatData[totalChats - 1].message.sender == currentUserId ? "You : " : ""}${chatData[totalChats - 1].message.isImage == true ? "Sent an image" : chatData[totalChats - 1].message.message}",
                    overflow: TextOverflow.ellipsis,
                  ),
                  trailing: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      chatData[totalChats - 1].message.sender != currentUserId
                          ? unreadMsg != 0
                              ? Stack(
                                  alignment: Alignment.center,
                                  children: [
                                    const Icon(
                                      Icons
                                          .notifications, // Flutter's notification icon
                                      size: 25, // Adjust size as needed
                                      color: Colors
                                          .orangeAccent, // Adjust color as needed
                                    ),
                                    Positioned(
                                      bottom: 0,
                                      right: 0,
                                      child: CircleAvatar(
                                        radius: 6,
                                        backgroundColor:
                                            AppColors.backgroundColor,
                                        child: Text(
                                          unreadMsg.toString(),
                                          style: const TextStyle(
                                            fontSize: 7,
                                            color: AppColors.white,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                )
                              : const SizedBox()
                          : const SizedBox(),
                      const SizedBox(height: 8),
                      // Text(formatDate(
                      //     chatData[totalChats - 1].message.timestamp)),
                       Text(Jiffy.parseFromDateTime(DateTime.parse(chatData[totalChats - 1].message.timestamp.toString())).jm),
                    ],
                  ),
                );
              },
            );
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, "/search");
        },
        child: Icon(Icons.add),
      ),
    );
  }
}

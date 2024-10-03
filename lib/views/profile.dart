import 'package:chatty/constant/app_color.dart';
import 'package:chatty/controllers/appwrite_controllers.dart';
import 'package:chatty/controllers/local_saved_data.dart';
import 'package:chatty/providers/chat_provider.dart';
import 'package:chatty/providers/user_data_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../widgets/avatar_widget.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  @override
  Widget build(BuildContext context) {
    return Consumer<UserDataProvider>(
      builder: (context, value, child) {
        return Scaffold(
          backgroundColor: AppColors.white,
          appBar: AppBar(
            leading: IconButton(
              icon: const Icon(
                Icons.chevron_left,
                color: AppColors.backgroundColor,
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            title: const Text(
              "Profile",
              style: TextStyle(color: AppColors.darkGray),
            ),
          ),
          body: ListView(
            children: [
              ListTile(
                onTap: () => Navigator.pushNamed(context, "/update",
                    arguments: {"title": "edit"}),
                leading: AvatarWidget(
                  url: LocalSavedData.getUserProfile(),
                  widthHeight: 50,
                ),
                title: Text(
                  value.getUserName,
                  style: const TextStyle(color: AppColors.darkGray),
                ),
                subtitle: Text(
                  value.getUserNumber,
                  style: const TextStyle(color: AppColors.darkGray),
                ),
                trailing: const Icon(
                  Icons.edit_outlined,
                  color: AppColors.darkGray,
                ),
              ),
              const Divider(
                color: AppColors.lightGray,
              ),
              ListTile(
                onTap: () {
                  Navigator.pushNamed(context, '/about');
                },
                leading: const Icon(
                  Icons.info_rounded,
                  color: AppColors.darkGray,
                ),
                title: const Text(
                  "About",
                  style: TextStyle(color: AppColors.darkGray),
                ),
              ),
              const Divider(
                color: AppColors.lightGray,
              ),
              ListTile(
                onTap: () => _showLogoutConfirmationDialog(context),
                leading: const Icon(
                  Icons.logout_outlined,
                  color: AppColors.backgroundColor,
                ),
                title: const Text(
                  "Logout",
                  style: TextStyle(color: AppColors.backgroundColor),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showLogoutConfirmationDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Confirm Logout',
                style: TextStyle(
                  color: AppColors.darkGray,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              const Text(
                'Are you sure you want to logout?',
                style: TextStyle(color: AppColors.darkGray),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    style: ButtonStyle(
                      backgroundColor:
                          WidgetStateProperty.all<Color>(Colors.orange),
                      foregroundColor:
                          WidgetStateProperty.all<Color>(Colors.white),
                    ),
                    onPressed: () {
                      Navigator.of(context).pop(); // Close the dialog
                    },
                    child: const Text('Cancel'),
                  ),
                  ElevatedButton(
                    style: ButtonStyle(
                      backgroundColor:
                          WidgetStateProperty.all<Color>(AppColors.redColor),
                      foregroundColor:
                          WidgetStateProperty.all<Color>(Colors.white),
                    ),
                    onPressed: () async {
                      await LocalSavedData.clearAllData();
                      updateOnlineStatus(
                          status: false,
                          userId: Provider.of<UserDataProvider>(context,
                                  listen: false)
                              .getUserId);
                      Provider.of<UserDataProvider>(context, listen: false)
                          .clearAllProvider();
                      Provider.of<ChatProvider>(context, listen: false)
                          .clearChats();
                      await logoutUser();
                      Navigator.pushNamedAndRemoveUntil(
                          context, "/login", (route) => false);
                    },
                    child: const Text('Logout'),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

import 'package:chatty/constant/app_color.dart';
import 'package:chatty/controllers/appwrite_controllers.dart';
import 'package:chatty/controllers/local_saved_data.dart';
import 'package:chatty/providers/user_data_provider.dart';
import 'package:chatty/widgets/avatar_widget.dart';
import 'package:chatty/widgets/image_dialog.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';

class UpdateProfile extends StatefulWidget {
  const UpdateProfile({super.key});

  @override
  State<UpdateProfile> createState() => _UpdateProfileState();
}

class _UpdateProfileState extends State<UpdateProfile> {
  TextEditingController _nameController = TextEditingController();
  TextEditingController _phoneController = TextEditingController();

  late String? userId = "";

  final _nameKey = GlobalKey<FormState>();

  @override
  void initState() {
    // try to load the data from local database
    Future.delayed(Duration.zero, () {
      userId = Provider.of<UserDataProvider>(context, listen: false).getUserId;
      Provider.of<UserDataProvider>(context, listen: false)
          .loadUserData(userId!);
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final Map<String, dynamic> datapassed =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    return Consumer<UserDataProvider>(
      builder: (context, value, child) {
        _nameController.text = value.getUserName;
        _phoneController.text = value.getUserNumber;
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
            title:
                Text(datapassed["title"] == "edit" ? "Update" : "Add Details"),
          ),
          body: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(18.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(
                    height: 40,
                  ),
                  GestureDetector(
                    onTap: () {
                      openImagePickerDialog(context, () {
                        setState(() {});
                      });
                    },
                    child: Stack(children: [
                      AvatarWidget(
                        url: LocalSavedData.getUserProfile(),
                        widthHeight: 250,
                      ),
                      Positioned(
                          bottom: 0,
                          right: 0,
                          child: Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                                color: AppColors.backgroundColor,
                                borderRadius: BorderRadius.circular(30)),
                            child: const Icon(
                              Icons.edit_rounded,
                              color: Colors.white,
                              size: 20,
                            ),
                          ))
                    ]),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  Container(
                    decoration: BoxDecoration(
                        color: AppColors.lighterGray,
                        borderRadius: BorderRadius.circular(10)),
                    margin: EdgeInsets.all(6),
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    child: Form(
                      key: _nameKey,
                      child: TextFormField(
                        validator: (value) {
                          if (value!.isEmpty) return "Cannot be empty";
                          return null;
                        },
                        controller: _nameController,
                        decoration: InputDecoration(
                            border: InputBorder.none,
                            hintText: "Enter your name"),
                      ),
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                        color: AppColors.lighterGray,
                        borderRadius: BorderRadius.circular(12)),
                    margin: EdgeInsets.all(6),
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    child: TextFormField(
                      controller: _phoneController,
                      enabled: false,
                      decoration: InputDecoration(
                          border: InputBorder.none, 
                          hintText: "Phone Number"),
                    ),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  SizedBox(
                    height: 50,
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () async {
                        print("current image  is ${value.getUserProfile}");
                        if (_nameKey.currentState!.validate()) {
                          await updateUserDetails(
                              userId: userId!, name: _nameController.text);

                          // navigate the user to the home route
                          Navigator.pushNamedAndRemoveUntil(
                              context, "/home", (route) => false);
                        }
                      },
                      style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.backgroundColor,
                          foregroundColor: Colors.white),
                      child: Text(datapassed["title"] == "edit"
                          ? "Update"
                          : "Continue"),
                    ),
                  )
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

import 'dart:io';
import 'package:appwrite/appwrite.dart';
import 'package:appwrite/models.dart' as model;
import 'package:chatty/controllers/local_saved_data.dart';
import 'package:chatty/widgets/app_dialogs.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../constant/app_color.dart';
import '../controllers/appwrite_controllers.dart';
import '../model/message_model.dart';
import '../providers/chat_provider.dart';

void openImagePickerDialog(BuildContext context, Function() callback,
    {bool updatingProfile = true,
    Function()? imageCallBack,
    Map<String, dynamic>? details}) {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      backgroundColor: AppColors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      titlePadding: const EdgeInsets.only(top: 10, left: 25, bottom: 10),
      actionsPadding: const EdgeInsets.all(0),
      buttonPadding: const EdgeInsets.all(0),
      contentPadding: const EdgeInsets.symmetric(horizontal: 25, vertical: 5),
      title: const Text(
        'Choose Option',
        style: TextStyle(
            color: AppColors.backgroundColor,
            fontSize: 18,
            fontWeight: FontWeight.w600,
            fontStyle: FontStyle.normal,
            fontFamily: 'Poppins'),
      ),
      content: SizedBox(
        height: 120,
        child: Column(
          children: [
            InkWell(
              onTap: () {
                getImage(ImageSource.camera, context, callback, updatingProfile,
                    imageCallBack, details);
              },
              child: Container(
                height: 50,
                width: double.infinity,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: AppColors.white),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    const SizedBox(
                      width: 10,
                    ),
                    const Icon(
                      Icons.camera,
                      size: 25,
                      color: AppColors.backgroundColor,
                      // color: Color.fromARGB(255, 15, 85, 142),
                    ),
                    const SizedBox(
                      width: 10,
                    ),
                    Text('Camera', style: kSelectImageOptionTextStyle),
                  ],
                ),
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            InkWell(
              onTap: () {
                getImage(ImageSource.gallery, context, callback,
                    updatingProfile, imageCallBack, details);
              },
              child: Container(
                height: 50,
                width: double.infinity,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: AppColors.white),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    const SizedBox(
                      width: 10,
                    ),
                    const Icon(
                      Icons.picture_in_picture_outlined,
                      size: 25,
                      // color: Color.fromARGB(255, 15, 85, 142),
                      color: AppColors.backgroundColor,
                    ),
                    const SizedBox(
                      width: 10,
                    ),
                    Text('Gallery', style: kSelectImageOptionTextStyle),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      actions: [
        Container(
          margin: const EdgeInsets.only(right: 15, bottom: 10),
          child: TextButton(
            style: const ButtonStyle(
                // backgroundColor: MaterialStateProperty.all(Colors.white),
                ),
            child: Text(
              "Close".toUpperCase(),
              style: const TextStyle(
                // color: Color.fromARGB(255, 15, 85, 142),
                color: AppColors.backgroundColor,
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
            onPressed: () => Navigator.pop(context),
          ),
        ),
      ],
    ),
  );
}

void getImage(
    ImageSource imageSource,
    BuildContext context,
    Function() callback,
    bool updatingProfile,
    Function()? imageCallBack,
    Map<String, dynamic>? details) async {
  final pickedFile = await ImagePicker().pickImage(source: imageSource);

  if (context.mounted) {
    Navigator.pop(context);
  }
  MessageModel tempMessage = MessageModel(
      message: '',
      sender: '',
      receiver: '',
      timestamp: DateTime.now().toIso8601String(),
      isSeenByReceiver: false,
      isImage: true);

  if (pickedFile != null) {
    if (updatingProfile == true) {
      AppDialogs.showLoading(msg: 'Uploading profile...');
    } else {
      AppDialogs.showLoading(msg: 'Sending image...');
      LocalSavedData.saveImageStatus("uploading");
      if (context.mounted) {
        tempMessage = MessageModel(
            message: "",
            sender: LocalSavedData.getUserId(),
            receiver: details!['receiverId'],
            timestamp: DateTime.now().toIso8601String(),
            isSeenByReceiver: false,
            isImage: true,
            status: LocalSavedData.getImageStatus(),
            messageId: LocalSavedData.getImageMessageId());
      }

      debugPrint("Temp message status ${tempMessage.status}");
      AppDialogs.dismissDialog();

      callback();
    }

    selectedImage = pickedFile.path;

    debugPrint("selectedImagePath $selectedImage");
    var extension = getImageExtension(selectedImage);
    debugPrint("ext $extension");
    // selectedImageSize.value =
    //     "${((File(selectedImagePath.value)).lengthSync() / 1024 / 1024).toStringAsFixed(2)}Mb";

    selectedImageFile = File(pickedFile.path);
    final fileByes = await File(pickedFile.path).readAsBytes();
    //  debugPrint("fileBytes $fileByes");
    final file =
        InputFile.fromBytes(bytes: fileByes, filename: pickedFile.name);

    var id = await uploadImageToBucket(
      inputFile: file,
    );
    debugPrint("Id $id");
    if (id != 'err') {
      var profileUrl = getFileUrl(id);

      debugPrint("profile url $profileUrl");

      if (updatingProfile) {
        model.Document? doc = await getUserDocument(
          profileUrl,
        );

        if (doc != null) {
          AppDialogs.showSuccess(
              msg: "Your profile image successfully updated");
          LocalSavedData.saveUserProfile(profileUrl);
          debugPrint("cached url ${LocalSavedData.getUserProfile()}");
          callback();
          callback;
          selectedImage = '';
        } else {
          AppDialogs.showError(msg: 'Failed to update profile image');
        }
      } else {
        //sending image

// ignore: use_build_context_synchronously
        // LocalSavedData.saveImageMessage(profileUrl);
        final status =
            await Provider.of<ChatProvider>(details!['context'], listen: false)
                .updateMessageStatus(
                    status: 'retrieved',
                    ctx: details['context'],
                    url: profileUrl);

        if (status) {
          LocalSavedData.saveImageMessage(profileUrl);
          // debugPrint("cached image message url ${LocalSavedData.saveImageMessage(profileUrl)}");

          imageCallBack!()!;

          AppDialogs.dismissDialog();
          // callback;
          selectedImage = '';
          sendingImage = false;
        } else {
          AppDialogs.showError(msg: 'Failed to send message');
        }
      }
    } else {
      AppDialogs.showError(msg: "No Image Selected");
    }
  } else {
    if (context.mounted) {
      Navigator.pop(context);
    }
    // AppDialogs.showError(msg: 'No image selected');
  }
}

Future<String> uploadImageToBucket({required InputFile inputFile}) async {
  try {
    final response = await storage.createFile(
        bucketId: storageBucket, fileId: ID.unique(), file: inputFile);

    debugPrint("Result ${response} ${response.$id}");
    return response.$id;
  } catch (e) {
    return "err";
  }
}

String getFileUrl(dynamic id) {
  return '$appWriteEndpoint/v1/storage/buckets/$storageBucket/files/$id/view?project=$projectID';
}

TextStyle kSelectImageOptionTextStyle = const TextStyle(
  color: AppColors.backgroundColor,
  fontSize: 18,
  fontWeight: FontWeight.w600,
);

String getImageExtension(String filePath) {
  // Find the last occurrence of "." to get the file extension
  int dotIndex = filePath.lastIndexOf('.');

  // If dotIndex is -1, it means there is no extension
  if (dotIndex == -1) {
    return '';
  }

  // Extract the extension by taking the substring after the last dot
  String extension = filePath.substring(dotIndex + 1).toLowerCase();

  // Return the extension
  return extension;
}

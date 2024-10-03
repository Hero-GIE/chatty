

// import 'dart:io';
// import 'package:appwrite/appwrite.dart';
// import 'package:chatty/controllers/appwrite_controllers.dart';
// import 'package:chatty/widgets/app_dialogs.dart';
// import 'package:flutter/material.dart';
// import 'package:image_picker/image_picker.dart';


// void openImageClipperDialog(BuildContext context, Function(String imageUrl) callback) {
//   final ImagePicker _picker = ImagePicker();

//   showDialog(
//     context: context,
//     builder: (context) => AlertDialog(
//       backgroundColor: Colors.white,
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
//       titlePadding: const EdgeInsets.only(top: 10, left: 25, bottom: 10),
//       actionsPadding: const EdgeInsets.all(0),
//       buttonPadding: const EdgeInsets.all(0),
//       contentPadding: const EdgeInsets.symmetric(horizontal: 25, vertical: 5),
//       title: const Text(
//         'Choose Option',
//         style: TextStyle(
//           color: Colors.orange,
//           fontSize: 18,
//           fontWeight: FontWeight.w600,
//           fontStyle: FontStyle.normal,
//           fontFamily: 'Poppins',
//         ),
//       ),
//       content: SizedBox(
//         height: 120,
//         child: Column(
//           children: [
//             InkWell(
//               onTap: () async {
//                 final pickedFile = await _picker.pickImage(source: ImageSource.camera);
//                 if (pickedFile != null) {
//                   await _handleImageUpload(pickedFile, callback);
//                 }
//                 Navigator.pop(context);
//               }, 
//               child: _buildOption(context, Icons.camera, 'Camera'),
//             ),
//             const SizedBox(height: 10),
//             InkWell(
//               onTap: () async {
//                 final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
//                 if (pickedFile != null) {
//                   await _handleImageUpload(pickedFile, callback);
//                 }
//                 Navigator.pop(context);
//               },
//               child: _buildOption(context, Icons.picture_in_picture_outlined, 'Gallery'),
//             ),
//           ],
//         ),
//       ),
//       actions: [
//         Container(
//           margin: const EdgeInsets.only(right: 15, bottom: 10),
//           child: TextButton(
//             child: Text(
//               "Close".toUpperCase(),
//               style: const TextStyle(
//                 color: Colors.orange,
//                 fontSize: 15,
//                 fontWeight: FontWeight.w600,
//               ),
//             ),
//             onPressed: () => Navigator.pop(context),
//           ),
//         ),
//       ],
//     ),
//   );
// }

// Widget _buildOption(BuildContext context, IconData icon, String label) {
//   return Container(
//     height: 50,
//     width: double.infinity,
//     decoration: BoxDecoration(
//       borderRadius: BorderRadius.circular(10),
//       color: Colors.white,
//     ),
//     child: Row(
//       mainAxisAlignment: MainAxisAlignment.start,
//       children: [
//         const SizedBox(width: 10),
//         Icon(
//           icon,
//           size: 25,
//           color: Colors.orange,
//         ),
//         const SizedBox(width: 10),
//         Text(
//           label,
//           style: const TextStyle(
//             color: Colors.orange,
//             fontSize: 16,
//             fontWeight: FontWeight.w600,
//           ),
//         ),
//       ],
//     ),
//   );
// }

// Future<void> _handleImageUpload(XFile pickedFile, Function(String imageUrl) callback) async {
//   AppDialogs.showLoading(msg: 'Uploading image...');

//   try {
//     final fileBytes = await File(pickedFile.path).readAsBytes();
//     final inputFile = InputFile.fromBytes(bytes: fileBytes, filename: pickedFile.name);

//     String fileId = await uploadImageToBucket(inputFile: inputFile);

//     if (fileId != 'err') {
//       String imageUrl = getFileUrl(fileId);
//       AppDialogs.showSuccess(msg: 'Image successfully uploaded');
//       callback(imageUrl);
//     } else {
//       AppDialogs.showError(msg: 'Failed to upload image');
//     }
//   } catch (e) {
//     AppDialogs.showError(msg: 'Error: ${e.toString()}');
//   } finally {
//     AppDialogs.dismissDialog();
//   }
// }

// Future<String> uploadImageToBucket({required InputFile inputFile}) async {
//   try {
//     final response = await storage.createFile(
//       bucketId: storageBucket,
//       fileId: ID.unique(),
//       file: inputFile,
//     );

//     return response.$id;
//   } catch (e) {
//     return "err";
//   }
// }

// String getFileUrl(String fileId) {
//   return '$appWriteEndpoint/v1/storage/buckets/$storageBucket/files/$fileId/view?project=$projectID';
// }

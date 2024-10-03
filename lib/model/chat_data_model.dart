import 'package:chatty/model/message_model.dart';
import 'package:chatty/model/user_data.dart';

class ChatDataModel {
  final MessageModel message;
  final List<UserData> users;

  ChatDataModel({required this.message, required this.users});
}

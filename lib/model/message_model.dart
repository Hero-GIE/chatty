class MessageModel {
  final String message;
  final String sender;
  final String receiver;
  final String? messageId;
  final String timestamp;
  final bool isSeenByReceiver;
  final bool? isImage;
  final String? status;

  MessageModel({
    required this.message,
    required this.sender,
    required this.receiver,
    this.messageId,
    required this.timestamp,
    required this.isSeenByReceiver,
    this.isImage,
    this.status,
  });

  // Add the copyWith method
  MessageModel copyWith({
    String? message,
    String? sender,
    String? receiver,
    String? messageId,
    String? timestamp,
    bool? isSeenByReceiver,
    bool? isImage,
    String? status,
  }) {
    return MessageModel(
      message: message ?? this.message,
      sender: sender ?? this.sender,
      receiver: receiver ?? this.receiver,
      messageId: messageId ?? this.messageId,
      timestamp: timestamp ?? this.timestamp,
      isSeenByReceiver: isSeenByReceiver ?? this.isSeenByReceiver,
      isImage: isImage ?? this.isImage,
      status: status ?? this.status,
    );
  }

  // that will convert Document model to message model
  factory MessageModel.fromMap(Map<String, dynamic> map) {
    return MessageModel(
        message: map["message"],
        sender: map["senderId"],
        status: map['status'],
        receiver: map["receiverId"],
        timestamp: map["timestamp"],
        isSeenByReceiver: map["isSeenbyReceiver"],
        messageId: map["messageId"],
        isImage: map["isImage"]);
  }
}

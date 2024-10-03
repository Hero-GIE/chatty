import 'package:cached_network_image/cached_network_image.dart';
import 'package:chatty/constant/app_color.dart';
import 'package:chatty/model/message_model.dart';
import 'package:chatty/views/image_preview.dart';
import 'package:flutter/material.dart';
import 'package:jiffy/jiffy.dart';

class ChatMessages extends StatefulWidget {
  final MessageModel msg;
  final String currentUser;
  final bool isImage;
  const ChatMessages({
    super.key,
    required this.msg,
    required this.currentUser,
    required this.isImage,
  });

  @override
  State<ChatMessages> createState() => _ChatMessagesState();
}

class _ChatMessagesState extends State<ChatMessages> {
  @override
  Widget build(BuildContext context) {
    debugPrint("isImage ${widget.isImage} ${widget.msg.status}");
    return widget.isImage
        ? Container(
            child: Row(
              mainAxisAlignment: widget.msg.sender == widget.currentUser
                  ? MainAxisAlignment.end
                  : MainAxisAlignment.start,
              children: [
                widget.msg.status == '' || widget.msg.status == 'uploading'
                    ? Column(
                        crossAxisAlignment:
                            widget.msg.sender == widget.currentUser
                                ? CrossAxisAlignment.end
                                : CrossAxisAlignment.start,
                        children: [
                          InkWell(
                              onTap: () {
                                // final url = widget.msg.message;
                                // Navigator.push(
                                //   context,
                                //   MaterialPageRoute<void>(
                                //       builder: (BuildContext context) =>
                                //           ImagePreview(url: url)),
                                // );
                              },
                              child: _buildImageContainer(widget.msg.status!)),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                margin:
                                    const EdgeInsets.symmetric(horizontal: 4),
                                child: Text(
                                  Jiffy.parseFromDateTime(DateTime.parse(widget.msg.timestamp.toString())).jm,
                                  style: TextStyle(
                                      fontSize: 11,
                                      color: Theme.of(context)
                                          .colorScheme
                                          .outline),
                                ),
                              ),
                              widget.msg.sender == widget.currentUser
                                  ? widget.msg.isSeenByReceiver
                                      ? const Icon(
                                          Icons.check_circle_outlined,
                                          size: 15,
                                          color: AppColors.backgroundColor,
                                        )
                                      : const Icon(
                                          Icons.check_circle_outlined,
                                          size: 15,
                                          color: Color.fromARGB(
                                              255, 205, 205, 205),
                                        )
                                  : const SizedBox()
                            ],
                          )
                        ],
                      )
                    : widget.msg.status == 'retrieved'
                        ? Column(
                            crossAxisAlignment:
                                widget.msg.sender == widget.currentUser
                                    ? CrossAxisAlignment.end
                                    : CrossAxisAlignment.start,
                            children: [
                              InkWell(
                                onTap: () {
                                  final url = widget.msg.message;
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute<void>(
                                        builder: (BuildContext context) =>
                                            ImagePreview(url: url)),
                                  );
                                },
                                child: Container(
                                    margin: const EdgeInsets.all(4),
                                    height: 250,
                                    width: 200,
                                    child: ClipRRect(
                                        borderRadius: BorderRadius.circular(15),
                                        child: CachedNetworkImage(
                                          imageUrl: widget.msg.message,
                                          fit: BoxFit.cover,
                                          height: 250,
                                          width: 200,
                                          progressIndicatorBuilder:
                                              (context, url, progress) {
                                            return _buildImageContainer(
                                                "Fetching..");
                                          },
                                        ))),
                              ),
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    margin: const EdgeInsets.symmetric(
                                        horizontal: 4),
                                    child: Text(
                                      Jiffy.parseFromDateTime(DateTime.parse(widget.msg.timestamp.toString())).jm,
                                      style: TextStyle(
                                          fontSize: 11,
                                          color: Theme.of(context)
                                              .colorScheme
                                              .outline),
                                    ),
                                  ),
                                  widget.msg.sender == widget.currentUser
                                      ? widget.msg.isSeenByReceiver
                                          ? const Icon(
                                              Icons.check_circle_outlined,
                                              size: 15,
                                              color: AppColors.backgroundColor,
                                            )
                                          : const Icon(
                                              Icons.check_circle_outlined,
                                              size: 15,
                                              color: Color.fromARGB(
                                                  255, 205, 205, 205),
                                            )
                                      : const SizedBox()
                                ],
                              )
                            ],
                          )
                        : const SizedBox()
              ],
            ),
          )
        : Container(
            padding: EdgeInsets.all(5),
            child: Row(
              mainAxisAlignment: widget.msg.sender == widget.currentUser
                  ? MainAxisAlignment.end
                  : MainAxisAlignment.start,
              children: [
                Column(
                  crossAxisAlignment: widget.msg.sender == widget.currentUser
                      ? CrossAxisAlignment.end
                      : CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: EdgeInsets.all(11),
                          margin: EdgeInsets.symmetric(horizontal: 4),
                          constraints: BoxConstraints(
                              maxWidth:
                                  MediaQuery.of(context).size.width * 0.75),
                          decoration: BoxDecoration(
                              color: widget.msg.sender == widget.currentUser
                                  ? AppColors.lighterbackgroundColor
                                  : AppColors.lighterblueColor,
                              borderRadius: BorderRadius.only(
                                  bottomLeft:
                                      widget.msg.sender == widget.currentUser
                                          ? Radius.circular(20)
                                          : Radius.circular(2),
                                  bottomRight:
                                      widget.msg.sender == widget.currentUser
                                          ? Radius.circular(2)
                                          : Radius.circular(20),
                                  topLeft: Radius.circular(20),
                                  topRight: Radius.circular(20))),
                          child: Text(
                            widget.msg.message,
                            style: TextStyle(
                                color: widget.msg.sender == widget.currentUser
                                    ? AppColors.white
                                    : AppColors.blackColor),
                          ),
                        )
                      ],
                    ),
                    Row(
                      children: [
                        Container(
                          margin: EdgeInsets.symmetric(horizontal: 3),
                          child: Text(
                           Jiffy.parseFromDateTime(DateTime.parse(widget.msg.timestamp.toString())).jm,
                            style: TextStyle(
                                fontSize: 11,
                                color: Theme.of(context).colorScheme.outline),
                          ),
                        ),
                        widget.msg.sender == widget.currentUser
                            ? widget.msg.isSeenByReceiver
                                ? Icon(
                                    Icons.check_circle_outlined,
                                    size: 15,
                                    color: AppColors.backgroundColor,
                                  )
                                : Icon(
                                    Icons.check_circle_outlined,
                                    size: 15,
                                    color: Color.fromARGB(255, 205, 205, 205),
                                  )
                            : SizedBox()
                      ],
                    )
                  ],
                )
              ],
            ),
          );
  }
}

_buildImageContainer(String status) {
  return Container(
    margin: const EdgeInsets.all(4),
    height: 250,
    width: 200,
    child: Stack(
      children: [
        Container(
          margin: const EdgeInsets.all(4),
          height: 250,
          width: 200,
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15),
              border: Border.all(color: Colors.black.withOpacity(0.2))),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(15),
            child: Image.asset(
              "assets/images/upload-image.png",
              fit: BoxFit.contain,
              height: 250,
              width: 200,
            ),
          ),
        ),
        // Centered Text with status
        Center(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.6),
              borderRadius: BorderRadius.circular(5),
            ),
            height: 30,
            width: 90,
            child: Column(
              children: [
                Row(
                  children: [
                    SizedBox(
                      height: 15,
                      width: 15,
                      child: Image.asset(
                        "assets/images/upload.png",
                        height: 10,
                        width: 10,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(
                      width: 4,
                    ),
                    Text(
                      status.toString() == 'uploading'
                          ? 'Uploading..'
                          : status.toString() == 'retrieved'
                              ? 'Retrieved'
                              : status, // Display the status or default text
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(
                  height: 4,
                ),
                const LinearProgressIndicator(
                  backgroundColor: Colors.black,
                  color: Colors.white,
                  minHeight: 1,
                )
              ],
            ),
          ),
        ),
      ],
    ),
  );
}

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;



class AvatarWidget extends StatelessWidget {
  const AvatarWidget({super.key, required this.url, this.widthHeight});

  final String? url;
  final double? widthHeight;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
          width: widthHeight,
          height: widthHeight,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(120),
            child: url!.isEmpty
                ? Image.asset(
                    'assets/images/user.png',
                    fit: BoxFit.contain,
                  )
                : kIsWeb
                    ? Image.network(
                        url!,
                        fit: BoxFit.cover,
                        height: widthHeight,
                        width: widthHeight,
                      )
                    : CachedNetworkImage(
                        imageUrl: url!,
                        fit: BoxFit.cover,
                        height: widthHeight,
                        width: widthHeight,
                        progressIndicatorBuilder:
                            (context, url, downloadProgress) => const Center(
                                  child: Text(
                                    'Loading',
                                    style: TextStyle(
                                      color: Colors.grey,
                                      fontSize: 10,
                                    ),
                                  ),
                                ),
                        errorWidget: (context, url, error) => Center(
                              child: Image.asset(
                                'assets/image/user.png',
                                fit: BoxFit.cover,
                              ),
                            )),
          ),
        );
  }
}
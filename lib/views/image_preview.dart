import 'package:cached_network_image/cached_network_image.dart';
import 'package:chatty/constant/app_color.dart';
import 'package:flutter/material.dart';

class ImagePreview extends StatelessWidget {
  const ImagePreview({super.key,required  this.url});
  final String url;
  @override
  Widget build(BuildContext context) {
    
    return Scaffold(
      appBar: AppBar(title: Text('Image'),),
      body:Container(
        // alignment: Alignment.center,
                        // margin: const EdgeInsets.all(4),
                              height:MediaQuery.of(context).size.height*0.8,
                            width: double.infinity, 
                        child: ClipRRect(
                          // borderRadius: BorderRadius.circular(15),
                          child: CachedNetworkImage(
                            imageUrl:url,
                            fit: BoxFit.cover,
                            height: 250,
                            width: 200,
                            progressIndicatorBuilder: (context, url, progress) {
                              return const Align(
                                alignment: Alignment.center,
                                child: SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    color: AppColors.backgroundColor,
                                    backgroundColor: Colors.black,
                                    strokeWidth: 3,
                                  ),
                                ),
                              );
                      
                          
                            },
                          ),
                        ),
                      ),
    );
  }
}
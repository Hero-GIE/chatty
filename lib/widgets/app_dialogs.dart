import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'dart:async';
import '../constant/app_color.dart';
import 'custom_animation.dart';

class AppDialogs {
  static Future showLoading({String? msg}) async {
    EasyLoading.instance
      ..indicatorType = EasyLoadingIndicatorType.fadingCircle
      ..loadingStyle = EasyLoadingStyle.custom
      ..indicatorSize = 45.0
      ..radius = 10.0
      ..backgroundColor = AppColors.backgroundColor 
      ..indicatorColor = Colors.white
      ..textColor = Colors.white
      ..textStyle = const TextStyle(
          fontFamily: 'Poppins', fontSize: 13, color: Colors.white)
      ..maskColor = Colors.black.withOpacity(0.5)
      ..userInteractions = false
      ..dismissOnTap = false
      ..customAnimation = CustomAnimation();

    return await EasyLoading.show(
      status: msg ?? 'Loading...',
      maskType: EasyLoadingMaskType.custom,
    );
  }

  static Future showSuccess({String? msg}) async {
    EasyLoading.instance
      ..displayDuration = const Duration(seconds: 4)
      ..indicatorType = EasyLoadingIndicatorType.fadingCircle
      ..loadingStyle = EasyLoadingStyle.custom
      ..indicatorSize = 45.0
      ..radius = 10.0
      ..backgroundColor = Colors.green
      ..indicatorColor = Colors.yellow
      ..maskColor = Colors.black.withOpacity(0.5)
      ..userInteractions = true
      ..successWidget = const Icon(
        Icons.check_circle_rounded,
        size: 45,
        color: Colors.white,
      )
      ..dismissOnTap = true
      ..customAnimation = CustomAnimation();

    return await EasyLoading.showSuccess(
      msg ?? 'Success!',
      maskType: EasyLoadingMaskType.custom,
    );
  }

  static Future showError({String? msg}) async {
    EasyLoading.instance
      ..displayDuration = const Duration(seconds: 5)
      ..indicatorType = EasyLoadingIndicatorType.fadingCircle
      ..loadingStyle = EasyLoadingStyle.custom
      ..indicatorSize = 45.0
      ..radius = 10.0
      ..backgroundColor = Colors.red
      ..indicatorColor = Colors.white
      ..textColor = Colors.white
      ..maskColor = Colors.black.withOpacity(0.5)
      ..userInteractions = true
      ..errorWidget = const Icon(
        Icons.close,
        size: 45,
        color: Colors.white,
      )
      ..dismissOnTap = true
      ..customAnimation = CustomAnimation();

    return await EasyLoading.showError(
      msg ?? 'Error!',
      maskType: EasyLoadingMaskType.custom,
    );
  }

  static Future showInfo({String? msg}) async {
    EasyLoading.instance
      ..displayDuration = const Duration(seconds: 4)
      ..indicatorType = EasyLoadingIndicatorType.fadingCircle
      ..loadingStyle = EasyLoadingStyle.custom
      ..indicatorSize = 45.0
      ..radius = 10.0
      ..backgroundColor = Colors.white
      ..indicatorColor = Colors.black
      ..textColor = Colors.black
      ..maskColor = Colors.black.withOpacity(0.5)
      ..userInteractions = true
      ..dismissOnTap = true
      ..textStyle = const TextStyle(
        fontFamily: 'Poppins',
        fontSize: 12,
        color: Colors.black,
      )
      ..infoWidget =
          //  Image.asset(
          //   Assets.info1,
          //   height: 40,
          //   width: 40,
          //   color: Colors.green,
          // )
          const Icon(
        Icons.info,
        size: 40,
        color: AppColors.backgroundColor,
      )
      ..customAnimation = CustomAnimation();

    return await EasyLoading.showInfo(
      msg ?? 'Notice !',
      maskType: EasyLoadingMaskType.custom,
    );
  }

  static dismissDialog() async {
    return await EasyLoading.dismiss();
  }
}

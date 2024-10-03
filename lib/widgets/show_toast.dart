import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

void showToast({
  required String msg,
  required Toast toastLength,
  required double fontSize,
  required Color textColor,
  required ToastGravity toastGravity,
  required Color backgroundColor,
}) {
  Fluttertoast.showToast(
    msg: msg,
    webShowClose: true,
    toastLength: toastLength,
    gravity: toastGravity,
    timeInSecForIosWeb: 5,
    backgroundColor: backgroundColor,
    textColor: textColor,
    fontSize: fontSize,
  );
}
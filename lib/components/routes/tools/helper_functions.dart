import 'dart:async';

import 'package:flutter/material.dart';

void displayMessageToUser(String message, BuildContext context) {
  showGeneralDialog(
    context: context,
    barrierDismissible: true,
    barrierLabel: '',
    transitionDuration: const Duration(milliseconds: 400),
    pageBuilder: (context, animation1, animation2) {
      return Container();
    },
    transitionBuilder: (context, a1, a2, widget) {
      return ScaleTransition(
        scale: Tween<double>(begin: 0.5, end: 1.0).animate(a1),
        child: AlertDialog(
          content: Text(message),
          shape: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16.0),
              borderSide: BorderSide.none),
        ),
      );
    },
  );
}

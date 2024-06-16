import 'package:flutter/material.dart';
import 'package:qr_assistant/style/global_colors.dart';

class MyTextField extends StatelessWidget {
  final String labelText;
  final bool obscureText;
  final TextEditingController controller;

  const MyTextField(
      {super.key,
      required this.labelText,
      required this.obscureText,
      required this.controller});

      

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        labelText: labelText,
        floatingLabelStyle: TextStyle(
            color: Theme.of(context).brightness == Brightness.light
                ? MyColor.deYork().color
                : MyColor.jungleGreen().color),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(
            color: Theme.of(context).brightness == Brightness.light
                ? MyColor.deYork().color
                : MyColor.jungleGreen().color,
          ),
          borderRadius: BorderRadius.circular(10),
        ),
        labelStyle: TextStyle(
          color: Theme.of(context).colorScheme.onSurface,
        ),
      ),
      obscureText: obscureText,
    );
  }
}
// ignore_for_file: unnecessary_null_comparison, use_build_context_synchronously, await_only_futures

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:qr_assistant/components/routes/log/login.dart';
import 'package:qr_assistant/components/routes/views/home.dart';
import 'package:qr_assistant/components/routes/views/home_uni.dart';
import 'package:qr_assistant/shared/prefe_users.dart';

class SplashView extends StatefulWidget {
  static const String routname = 'splash_view';
  const SplashView({super.key});

  @override
  State<SplashView> createState() => _SplashViewState();
}

class _SplashViewState extends State<SplashView> {
  @override
  void initState() {
    super.initState();
    PreferencesUser prefs = PreferencesUser();
    Future.delayed(Duration(milliseconds: (6720).round()), () async {
      final uid = await prefs.ultimateUid;
      if (uid != null && uid != '') {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) {
            return const HomeUni();
          }),
        );
      } else {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) {
            return const Login();
          }),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      body: Center(
        child: SizedBox(
          width: 120,
          height: 213.5,
          child: Lottie.asset('assets/splash_view.json'),
        ),
      ),
    );
  }
}
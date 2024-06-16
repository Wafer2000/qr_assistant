// ignore_for_file: unnecessary_null_comparison, use_build_context_synchronously, await_only_futures, non_constant_identifier_names

import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:qr_assistant/components/routes/log/login.dart';
import 'package:qr_assistant/tools/loading_indicator.dart';
import 'package:qr_assistant/components/routes/views/administrador/home_admi.dart';
import 'package:qr_assistant/components/routes/views/home.dart';
import 'package:qr_assistant/components/routes/views/scanner.dart';
import 'package:qr_assistant/components/routes/views/profesor/materias.dart';
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
    Redirect();
  }

  Future<void> Redirect() async {
    PreferencesUser pref = PreferencesUser();
    Future.delayed(Duration(milliseconds: (6720).round()), () async {
      final uid = await pref.uid;
      if (uid != null && uid != '') {
        final DocumentSnapshot tipeSnapshot =
            await FirebaseFirestore.instance.collection('Users').doc(uid).get();
        pref.ultimateTipe = tipeSnapshot['tipo'];
        LoadingScreen().hide();
        if (pref.ultimateTipe == 'Profesor') {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const Materias()),
          );
        } else if (pref.ultimateTipe == 'Administrador') {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const HomeAdmi()),
          );
        }
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

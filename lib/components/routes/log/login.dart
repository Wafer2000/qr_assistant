// ignore_for_file: non_constant_identifier_names, use_build_context_synchronously

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:qr_assistant/components/routes/log/register_uni.dart';
import 'package:qr_assistant/tools/helper_functions.dart';
import 'package:qr_assistant/tools/loading_indicator.dart';
import 'package:qr_assistant/tools/my_button.dart';
import 'package:qr_assistant/tools/my_textfield.dart';
import 'package:qr_assistant/components/routes/views/administrador/home_admi.dart';
import 'package:qr_assistant/components/routes/views/profesor/materias.dart';
import 'package:qr_assistant/shared/prefe_users.dart';

class Login extends StatefulWidget {
  static const String routname = '/login';
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  void Ingreso() async {
    var pref = PreferencesUser();
    LoadingScreen().show(context);

    try {
      UserCredential? userCredential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(
              email: emailController.text, password: passwordController.text);
      if (context.mounted) {
        var uid = userCredential.user?.uid;
        pref.uid = uid!;

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
      }
    } on FirebaseAuthException catch (e) {
      LoadingScreen().hide();
      displayMessageToUser(e.code, context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(25.0),
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  child: AspectRatio(
                    aspectRatio: 1,
                    child: Stack(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.5),
                                blurRadius: 8,
                                spreadRadius: 4,
                                offset: const Offset(0, 0),
                              ),
                            ],
                            border: Border.all(
                              color: Colors.white,
                              width: 4,
                            ),
                          ),
                        ),
                        Positioned.fill(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(20),
                            child: Image.asset(
                              'assets/profile.png',
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(
                  height: 30,
                ),
                MyTextField(
                    labelText: 'Correo',
                    obscureText: false,
                    controller: emailController),
                const SizedBox(
                  height: 10,
                ),
                MyTextField(
                    labelText: 'Contraseña',
                    obscureText: true,
                    controller: passwordController),
                const SizedBox(
                  height: 10,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(' ¿Se le olvido la contraseña?',
                        style: TextStyle(
                            color: Theme.of(context).colorScheme.secondary)),
                  ],
                ),
                const SizedBox(
                  height: 25,
                ),
                MyButton(text: 'Ingresar', onTap: () => Ingreso()),
                const SizedBox(
                  height: 25,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('¿No tienes una cuenta?',
                        style: TextStyle(
                            color: Theme.of(context).colorScheme.secondary)),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const RegisterUni()),
                        );
                      },
                      child: const Text(' Registrate aqui',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                          )),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

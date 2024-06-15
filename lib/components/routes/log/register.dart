// ignore_for_file: use_build_context_synchronously, non_constant_identifier_names

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:qr_assistant/components/routes/log/login.dart';
import 'package:qr_assistant/components/routes/tools/helper_functions.dart';
import 'package:qr_assistant/components/routes/tools/loading_indicator.dart';
import 'package:qr_assistant/components/routes/tools/my_button.dart';
import 'package:qr_assistant/components/routes/tools/my_textfield.dart';
import 'package:qr_assistant/components/routes/views/estudiante/guard/extra_data_estudiante.dart';
import 'package:qr_assistant/components/routes/views/profesor/guard/extra_data_profesor.dart';
import 'package:qr_assistant/shared/prefe_users.dart';
import 'package:qr_assistant/style/global_colors.dart';

class Register extends StatefulWidget {
  static const String routname = '/register';
  const Register({super.key});

  @override
  State<Register> createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  final TextEditingController firstnameController = TextEditingController();
  final TextEditingController lastnameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPassController = TextEditingController();
  final TextEditingController tipeController = TextEditingController();
  final TextEditingController semController = TextEditingController();

  String item1 = 'Estudiante';
  String item2 = 'Profesor';

  final List<String> _dropDownItems = [
    '1',
    '2',
    '3',
    '4',
    '5',
    '6',
    '7',
    '8',
    '9',
    '10'
  ];

  void RegistroEstudiante() async {
    var pref = PreferencesUser();
    LoadingScreen().show(context);

    if (passwordController.text != confirmPassController.text) {
      LoadingScreen().hide();
      displayMessageToUser('Las contraseñas no son iguales', context);
    } else if (passwordController.text.length < 8) {
      LoadingScreen().hide();
      displayMessageToUser(
          'La contraseña debe tener al menos 8 caracteres', context);
    } else if (!passwordController.text.contains(RegExp(r'[A-Z]'))) {
      LoadingScreen().hide();
      displayMessageToUser(
          'La contraseña debe contener al menos una letra mayúscula', context);
    } else if (!passwordController.text.contains(RegExp(r'[a-z]'))) {
      LoadingScreen().hide();
      displayMessageToUser(
          'La contraseña debe contener al menos una letra minúscula', context);
    } else if (!passwordController.text.contains(RegExp(r'[0-9]'))) {
      LoadingScreen().hide();
      displayMessageToUser(
          'La contraseña debe contener al menos un dígito', context);
    } else if (!passwordController.text
        .contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) {
      LoadingScreen().hide();
      displayMessageToUser(
          'La contraseña debe contener al menos un símbolo', context);
    } else if (!emailController.text.endsWith('@uniguajira.edu.co')) {
      LoadingScreen().hide();
      displayMessageToUser(
          'El correo debe ser de la Universidad de Guajira', context);
    } else if (semController.text == '') {
      LoadingScreen().hide();
      displayMessageToUser('Debe colocar su semestre', context);
    } else if (firstnameController.text == '') {
      LoadingScreen().hide();
      displayMessageToUser('Debe colocar su(s) nombre(s)', context);
    } else if (lastnameController.text == '') {
      LoadingScreen().hide();
      displayMessageToUser('Debe colocar sus apellidos', context);
    } else {
      try {
        UserCredential? userCredential = await FirebaseAuth.instance
            .createUserWithEmailAndPassword(
                email: emailController.text, password: passwordController.text);

        var uid = userCredential.user?.uid;
        pref.ultimateUid = uid!;
        FirebaseFirestore.instance.collection('Users').doc(uid).set({
          'uid': uid,
          'nombres': firstnameController.text,
          'apellidos': lastnameController.text,
          'email': emailController.text,
          'password': passwordController.text,
          'semestre': semController.text,
          'tipo': 'Estudiante',
          'cinstitucional': '',
          'fnacimiento': '',
          'celular': '',
          'fperfil': '',
          'sexo': '',
          'edad': ''
        });
        LoadingScreen().hide();
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const ExtraDataEstudiante()),
        );
      } on FirebaseAuthException catch (e) {
        LoadingScreen().hide();
        if (e.code == 'invalid-email') {
          displayMessageToUser('Email Invalido', context);
        } else if (e.code == 'weak-password') {
          displayMessageToUser('Contraseña Corta', context);
        } else if (e.code == 'email-already-in-use') {
          displayMessageToUser('Email en Uso', context);
        }
      }
    }
  }

  void RegistroProfesor() async {
    var pref = PreferencesUser();
    LoadingScreen().show(context);

    if (passwordController.text != confirmPassController.text) {
      LoadingScreen().hide();
      displayMessageToUser('Las contraseñas no son iguales', context);
    } else if (passwordController.text.length < 8) {
      LoadingScreen().hide();
      displayMessageToUser(
          'La contraseña debe tener al menos 8 caracteres', context);
    } else if (!passwordController.text.contains(RegExp(r'[A-Z]'))) {
      LoadingScreen().hide();
      displayMessageToUser(
          'La contraseña debe contener al menos una letra mayúscula', context);
    } else if (!passwordController.text.contains(RegExp(r'[a-z]'))) {
      LoadingScreen().hide();
      displayMessageToUser(
          'La contraseña debe contener al menos una letra minúscula', context);
    } else if (!passwordController.text.contains(RegExp(r'[0-9]'))) {
      LoadingScreen().hide();
      displayMessageToUser(
          'La contraseña debe contener al menos un dígito', context);
    } else if (!passwordController.text
        .contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) {
      LoadingScreen().hide();
      displayMessageToUser(
          'La contraseña debe contener al menos un símbolo', context);
    } else if (!emailController.text.endsWith('@uniguajira.edu.co')) {
      LoadingScreen().hide();
      displayMessageToUser(
          'El correo debe ser de la Universidad de Guajira', context);
    } else if (firstnameController.text == '') {
      LoadingScreen().hide();
      displayMessageToUser('Debe colocar su(s) nombre(s)', context);
    } else if (lastnameController.text == '') {
      LoadingScreen().hide();
      displayMessageToUser('Debe colocar sus apellidos', context);
    } else {
      try {
        UserCredential? userCredential = await FirebaseAuth.instance
            .createUserWithEmailAndPassword(
                email: emailController.text, password: passwordController.text);

        var uid = userCredential.user?.uid;
        pref.ultimateUid = uid!;
        FirebaseFirestore.instance.collection('Users').doc(uid).set({
          'uid': uid,
          'nombres': firstnameController.text,
          'apellidos': lastnameController.text,
          'email': emailController.text,
          'password': passwordController.text,
          'tipo': 'Profesor',
          'fnacimiento': '',
          'celular': '',
          'fperfil': '',
          'sexo': '',
        });
        LoadingScreen().hide();
        if (pref.ultimateUid == uid) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const ExtraDataProfesor()),
          );
        }
      } on FirebaseAuthException catch (e) {
        LoadingScreen().hide();
        if (e.code == 'invalid-email') {
          displayMessageToUser('Email Invalido', context);
        } else if (e.code == 'weak-password') {
          displayMessageToUser('Contraseña Corta', context);
        } else if (e.code == 'email-already-in-use') {
          displayMessageToUser('Email en Uso', context);
        }
      }
    }
  }

  String profesorTag = 'profesorTag';
  String estudianteTag = 'estudianteTag';
  String user = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(25, 25, 25, 0),
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 200,
                  padding: const EdgeInsets.all(4),
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
                                blurRadius: 4,
                                spreadRadius: 5,
                                offset: const Offset(0, 0),
                              ),
                            ],
                            border: Border.all(
                              color: Colors.white,
                              width: 1,
                            ),
                          ),
                        ),
                        Positioned.fill(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(5),
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
                  height: 20,
                ),
                Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  Container(
                    padding: const EdgeInsets.fromLTRB(2.5, 0, 2.5, 10),
                    height: 55,
                    width: 95,
                    child: FloatingActionButton(
                      mini: true,
                      heroTag: profesorTag,
                      onPressed: () {
                        setState(() {
                          user = 'Profesor';
                        });
                      },
                      backgroundColor: user == 'Profesor'
                          ? MyColor.crail().color
                          : MyColor.naturalGray().color,
                      child: const Text('Profesor'),
                    ),
                  ),
                  const SizedBox(
                    width: 50,
                  ),
                  Container(
                    padding: const EdgeInsets.fromLTRB(2.5, 0, 2.5, 10),
                    height: 55,
                    width: 95,
                    child: FloatingActionButton(
                      mini: true,
                      heroTag: estudianteTag,
                      onPressed: () {
                        setState(() {
                          user = 'Estudiante';
                        });
                      },
                      backgroundColor: user == 'Estudiante'
                          ? MyColor.crail().color
                          : MyColor.naturalGray().color,
                      child: const Text('Estudiante'),
                    ),
                  ),
                ]),
                const SizedBox(
                  height: 15,
                ),
                if (user == 'Estudiante')
                  Column(
                    children: [
                      Center(
                        child: Column(
                          children: [
                            DropdownButtonFormField(
                              value: semController.text.isNotEmpty
                                  ? semController.text
                                  : null,
                              items: _dropDownItems.map((String item) {
                                return DropdownMenuItem(
                                    value: item, child: Text(item));
                              }).toList(),
                              onChanged: (String? value) {
                                setState(() {
                                  semController.text = value!;
                                });
                              },
                              icon: const Icon(Icons.arrow_drop_down),
                              decoration: InputDecoration(
                                labelText: 'Semestre',
                                border: const OutlineInputBorder(
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(12))),
                                floatingLabelStyle: TextStyle(
                                    color: Theme.of(context).brightness ==
                                            Brightness.light
                                        ? MyColor.deYork().color
                                        : MyColor.jungleGreen().color),
                                focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                    color: Theme.of(context).brightness ==
                                            Brightness.light
                                        ? MyColor.deYork().color
                                        : MyColor.jungleGreen().color,
                                  ),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                labelStyle: TextStyle(
                                  color:
                                      Theme.of(context).colorScheme.onSurface,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      MyTextField(
                          labelText: 'Nombres',
                          obscureText: false,
                          controller: firstnameController),
                      const SizedBox(
                        height: 10,
                      ),
                      MyTextField(
                          labelText: 'Apellidos',
                          obscureText: false,
                          controller: lastnameController),
                      const SizedBox(
                        height: 10,
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
                      MyTextField(
                          labelText: 'Confirmar Contraseña',
                          obscureText: true,
                          controller: confirmPassController),
                      const SizedBox(
                        height: 10,
                      ),
                      MyButton(
                          text: 'Registrar', onTap: () => RegistroEstudiante()),
                      const SizedBox(
                        height: 25,
                      ),
                    ],
                  ),
                if (user == 'Profesor')
                  Column(
                    children: [
                      MyTextField(
                          labelText: 'Nombres',
                          obscureText: false,
                          controller: firstnameController),
                      const SizedBox(
                        height: 10,
                      ),
                      MyTextField(
                          labelText: 'Apellidos',
                          obscureText: false,
                          controller: lastnameController),
                      const SizedBox(
                        height: 10,
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
                      MyTextField(
                          labelText: 'Confirmar Contraseña',
                          obscureText: true,
                          controller: confirmPassController),
                      const SizedBox(
                        height: 10,
                      ),
                      MyButton(
                          text: 'Registrar', onTap: () => RegistroProfesor()),
                      const SizedBox(
                        height: 25,
                      ),
                    ],
                  ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('¿Tienes una cuenta?',
                        style: TextStyle(
                            color: Theme.of(context).colorScheme.secondary)),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const Login()),
                        );
                      },
                      child: const Text('Ingresa aqui',
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

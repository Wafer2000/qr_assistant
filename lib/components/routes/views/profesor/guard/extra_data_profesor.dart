// ignore_for_file: non_constant_identifier_names

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:qr_assistant/components/routes/tools/helper_functions.dart';
import 'package:qr_assistant/components/routes/tools/input_photo.dart';
import 'package:qr_assistant/components/routes/tools/loading_indicator.dart';
import 'package:qr_assistant/components/routes/tools/my_button.dart';
import 'package:qr_assistant/components/routes/tools/my_numberfield.dart';
import 'package:qr_assistant/components/routes/tools/my_textfield.dart';
import 'package:qr_assistant/components/routes/views/home.dart';
import 'package:qr_assistant/components/routes/views/home_uni.dart';
import 'package:qr_assistant/components/routes/views/profesor/materias.dart';
import 'package:qr_assistant/shared/prefe_users.dart';
import 'package:qr_assistant/style/global_colors.dart';

class ExtraDataProfesor extends StatefulWidget {
  static const String routname = '/extra_data_profesor';
  const ExtraDataProfesor({super.key});

  @override
  State<ExtraDataProfesor> createState() => _ExtraDataProfesorState();
}

class _ExtraDataProfesorState extends State<ExtraDataProfesor> {
  final _pref = PreferencesUser();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      body: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
        stream: FirebaseFirestore.instance
            .collection('Users')
            .doc(_pref.ultimateUid)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const AlertDialog(
              title: Text('Algo salio mal'),
            );
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
          if (snapshot.data == null) {
            return const Text('No hay datos');
          }
          final user = snapshot.data!;

          final TextEditingController fotoPerfilController =
              TextEditingController(text: user['fperfil']);
          final TextEditingController sexController =
              TextEditingController(text: user['sexo']);
          final TextEditingController phoneController =
              TextEditingController(text: user['celular']);
          final TextEditingController ageController =
              TextEditingController(text: user['fnacimiento']);

          void Guardar() async {
            LoadingScreen().show(context);

            if (sexController.text == '') {
              LoadingScreen().hide();
              displayMessageToUser('Debe colocar su sexo', context);
            } else if (phoneController.text == '') {
              LoadingScreen().hide();
              displayMessageToUser('Debe colocar su numero celular', context);
            } else if (ageController.text == '') {
              LoadingScreen().hide();
              displayMessageToUser(
                  'Debe colocar su fecha de nacimiento', context);
            } else {
              try {
                FirebaseFirestore.instance
                    .collection('Users')
                    .doc(_pref.ultimateUid)
                    .update({
                  'fnacimiento': ageController.text,
                  'celular': phoneController.text,
                  'fperfil': fotoPerfilController.text,
                  'sexo': sexController.text,
                });
                LoadingScreen().hide();
                displayMessageToUser('Datos Guardados', context);
                _pref.ultimateTipe = 'Profesor';
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const Materias()),
                );
              } on FirebaseAuthException catch (e) {
                LoadingScreen().hide();
                displayMessageToUser(e.code, context);
              }
            }
          }

          return Center(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(25, 25, 25, 0),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const InputFotoPerfil(),
                    const SizedBox(
                      height: 30,
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    MyTextField(
                        labelText: 'Sexo',
                        obscureText: false,
                        controller: sexController),
                    const SizedBox(
                      height: 10,
                    ),
                    MyNumberField(
                        labelText: 'Numero Celular',
                        obscureText: false,
                        controller: phoneController),
                    const SizedBox(
                      height: 10,
                    ),
                    TextField(
                      controller: ageController,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12)),
                        labelText: 'Fecha de Nacimiento',
                        floatingLabelStyle: TextStyle(
                            color:
                                Theme.of(context).brightness == Brightness.light
                                    ? MyColor.deYork().color
                                    : MyColor.jungleGreen().color),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            color:
                                Theme.of(context).brightness == Brightness.light
                                    ? MyColor.deYork().color
                                    : MyColor.jungleGreen().color,
                          ),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        labelStyle: TextStyle(
                          color: Theme.of(context).brightness == Brightness.light
                                    ? MyColor.black().color
                                    : MyColor.white().color,
                        ),
                      ),
                      onTap: () async {
                        DateTime? datetime = await showDatePicker(
                          context: context,
                          initialDate: DateTime.now(),
                          firstDate: DateTime(1900),
                          lastDate: DateTime(2100),
                          cancelText: 'Cancelar',
                          confirmText: 'Confirmar',
                          builder: (BuildContext context, Widget? child) {
                            return Theme(
                              data: Theme.of(context).brightness ==
                                      Brightness.light
                                  ? ThemeData.light().copyWith(
                                      colorScheme: ColorScheme.light(
                                        background: Colors.grey.shade300,
                                        primary: Colors.grey.shade500,
                                        secondary: Colors.grey.shade400,
                                        inversePrimary: Colors.grey.shade500,
                                      ),
                                    )
                                  : ThemeData.dark().copyWith(
                                      colorScheme: ColorScheme.dark(
                                        background: Colors.grey.shade300,
                                        primary: Colors.grey.shade500,
                                        secondary: Colors.grey.shade400,
                                        inversePrimary: Colors.grey.shade500,
                                      ),
                                    ),
                              child: child!,
                            );
                          },
                        );
                        if (datetime != null) {
                          String formattedDate =
                              DateFormat('dd/MM/yyyy').format(datetime);
                          ageController.text = formattedDate;
                        }
                      },
                      obscureText: false,
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    MyButton(text: 'Guardar', onTap: () => Guardar()),
                    const SizedBox(
                      height: 25,
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

// ignore_for_file: use_build_context_synchronously, avoid_print, no_leading_underscores_for_local_identifiers, non_constant_identifier_names

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:intl/intl.dart';
import 'package:qr_assistant/tools/helper_functions.dart';
import 'package:qr_assistant/tools/loading_indicator.dart';
import 'package:qr_assistant/tools/my_button.dart';
import 'package:qr_assistant/tools/my_drawer.dart';
import 'package:qr_assistant/shared/prefe_users.dart';
import 'package:qr_assistant/style/global_colors.dart';
import 'package:qr_flutter/qr_flutter.dart';

class Home extends StatefulWidget {
  static const String routname = '/home';
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final pref = PreferencesUser();
  final TextEditingController materiaController = TextEditingController();
  String qrResult = '';
  final TextEditingController materiaIdController = TextEditingController();

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> scanQR() async {
    try {
      final qrCode = await FlutterBarcodeScanner.scanBarcode(
          '#ff6666', 'Cancel', true, ScanMode.QR);
      if (!mounted) return;
      qrResult = qrCode.toString();

      List<String>? _dropDownItems = [];

      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('Llene todos los campos'),
            icon: const Icon(Icons.book),
            shadowColor: MyColor.naturalGray().color,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            content: Padding(
              padding: const EdgeInsets.all(16.0),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                      stream: FirebaseFirestore.instance
                          .collection('Materias${pref.uid}')
                          .snapshots(),
                      builder: (BuildContext context,
                          AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>>
                              snapshot) {
                        if (snapshot.hasError) {
                          print('Error: ${snapshot.error}');
                          return const CircularProgressIndicator();
                        }

                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const CircularProgressIndicator();
                        }

                        _dropDownItems = snapshot.data!.docs
                            .map((doc) => doc['materia'])
                            .cast<String>()
                            .toList();

                        return DropdownButtonFormField<String>(
                          value: materiaController.text.isNotEmpty
                              ? materiaController.text
                              : null,
                          items: _dropDownItems?.map((String item) {
                            return DropdownMenuItem<String>(
                              value: item,
                              child: Text(item),
                            );
                          }).toList(),
                          onChanged: (String? value) {
                            final DocumentSnapshot<Map<String, dynamic>> doc =
                                snapshot.data!.docs.firstWhere(
                                    (doc) => doc['materia'] == value);
                            final String docId = doc.id;
                            setState(() {
                              materiaIdController.text = docId;
                              materiaController.text = value!;
                            });
                          },
                          icon: const Icon(Icons.arrow_drop_down),
                          decoration: InputDecoration(
                            labelText: 'Materia',
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
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    Container(
                      padding: const EdgeInsets.fromLTRB(16, 5, 16, 0),
                      child: AspectRatio(
                        aspectRatio: 1,
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
            actions: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Container(
                    width: 100,
                    height: 50,
                    decoration: BoxDecoration(
                      color: const Color(0xFF8B897F),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: TextButton(
                      onPressed: () {
                        materiaController.clear();
                        Navigator.pop(context);
                      },
                      child: const Text('Cancelar',
                          style: TextStyle(color: Colors.white)),
                    ),
                  ),
                  Container(
                    width: 100,
                    height: 50,
                    decoration: BoxDecoration(
                      color: const Color(0xFFBD5E3B),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: TextButton(
                      onPressed: () async {
                        LoadingScreen().show(context);

                        if (materiaController.text == '') {
                          LoadingScreen().hide();
                          displayMessageToUser(
                              'Debe colocar el nombre a su materia', context);
                        } else {
                          final DocumentSnapshot documentSnapshot =
                              await FirebaseFirestore.instance
                                  .collection('Users')
                                  .doc(qrResult)
                                  .get();

                          String name = documentSnapshot['nombres'];
                          String apellidos = documentSnapshot['apellidos'];
                          String cinstitucional =
                              documentSnapshot['cinstitucional'];

                          final DocumentSnapshot materiaSnapshot =
                              await FirebaseFirestore.instance
                                  .collection('Materias${pref.uid}')
                                  .doc(materiaIdController.text)
                                  .get();
                          String asistencia = materiaSnapshot['inicio'];

                          final DateFormat inputFormat = DateFormat('hh:mm a');
                          final DateFormat outputFormat =
                              DateFormat('HH:mm:ss');
                          final DateTime inicio = inputFormat.parse(asistencia);

                          final DateTime quinceMinutosDespues =
                              inicio.add(const Duration(minutes: 15));

                          final now = DateTime.now();
                          final DateTime asistenciaDateTime =
                              inputFormat.parse(asistencia);
                          final String hllegada =
                              outputFormat.format(asistenciaDateTime);
                          final String fllegada =
                              DateFormat('dd/MM/yyyy').format(now);

                          if (quinceMinutosDespues.isAfter(now)) {
                            // quinceMinutosDespues is after hllegada
                            await FirebaseFirestore.instance
                                .collection('Materias${pref.uid}')
                                .doc(materiaIdController.text)
                                .collection('Asistencias')
                                .doc()
                                .set({
                              'estudiante': qrResult,
                              'nombres': name,
                              'apellidos': apellidos,
                              'cinstitucional': cinstitucional,
                              'hllegada': hllegada,
                              'fllegada': fllegada,
                              'asistencia': 'Llego Tarde'
                            });
                          } else {
                            // quinceMinutosDespues is before or equal to hllegada
                            await FirebaseFirestore.instance
                                .collection('Materias${pref.uid}')
                                .doc(materiaIdController.text)
                                .collection('Asistencias')
                                .doc()
                                .set({
                              'estudiante': qrResult,
                              'nombres': name,
                              'apellidos': apellidos,
                              'cinstitucional': cinstitucional,
                              'hllegada': hllegada,
                              'fllegada': fllegada,
                              'asistencia': 'Llego a Tiempo'
                            });
                          }
                          LoadingScreen().hide();
                        }
                        displayMessageToUser('Datos Guardados', context);
                        materiaController.clear();
                        Navigator.pop(context);
                        Navigator.pop(context);
                      },
                      child: const Text('Guardar',
                          style: TextStyle(color: Colors.white)),
                    ),
                  ),
                ],
              ),
            ],
          );
        },
        barrierDismissible: false,
      );
    } on PlatformException {
      print('OCURRIO UN ERROR');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        title: const Center(child: Text('Inicio')),
        actions: const [
          SizedBox(
            width: 48,
          )
        ],
        backgroundColor: Theme.of(context).brightness == Brightness.light
            ? MyColor.jungleGreen().color
            : MyColor.spectra().color,
      ),
      drawer: const MyDrawer(),
      backgroundColor: Theme.of(context).colorScheme.background,
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (pref.ultimateTipe == 'Estudiante')
                SizedBox(
                  width: MediaQuery.of(context).size.width - 3,
                  child: QrImageView(
                    data: pref.uid,
                    size: MediaQuery.of(context).size.width - 3,
                  ),
                ),
              if (pref.ultimateTipe == 'Profesor')
                SizedBox(
                  width: 320,
                  child: MyButton(text: 'Registrar Asistencia', onTap: scanQR),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

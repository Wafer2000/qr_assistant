// ignore_for_file: avoid_print, use_build_context_synchronously, avoid_function_literals_in_foreach_calls, no_leading_underscores_for_local_identifiers

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:intl/intl.dart';
import 'package:qr_assistant/components/routes/tools/helper_functions.dart';
import 'package:qr_assistant/components/routes/tools/loading_indicator.dart';
import 'package:qr_assistant/components/routes/tools/my_button.dart';
import 'package:qr_assistant/components/routes/tools/my_drawer.dart';
import 'package:qr_assistant/shared/prefe_users.dart';
import 'package:qr_assistant/style/global_colors.dart';

class HomeUni extends StatefulWidget {
  static const String routname = '/home_uni';
  const HomeUni({super.key});

  @override
  State<HomeUni> createState() => _HomeUniState();
}

class _HomeUniState extends State<HomeUni> {
  final pref = PreferencesUser();
  final TextEditingController materiaController = TextEditingController();
  String materiaId = '';
  List<String>? _dropDownItems = [];
  String qrResult = '';
  String codigoIns = '';

  @override
  void dispose() {
    super.dispose();
  }

  scanQR() async {
    try {
      final qrCode = await FlutterBarcodeScanner.scanBarcode(
          '#ff6666', 'Cancel', true, ScanMode.QR);
      if (!mounted) return;

      if (qrCode == '-1') {
        // El usuario canceló la operación
        return;
      }

      qrResult = qrCode.toString();

      final url = qrResult;
      final uri = Uri.parse(url);
      final pathSegments = uri.pathSegments;
      final lastSegment = pathSegments.last;
      final parts = lastSegment.split('|');

      if (parts.length >= 2) {
        setState(() {
          codigoIns = parts[1];
        });
      } else {
        // Manejar el caso en que no hay suficientes partes
        displayMessageToUser(
            'No se encontró el código de inscripción', context);
      }

      print(codigoIns);
      if (materiaController.text == '') {
        LoadingScreen().show(context);
        displayMessageToUser('Debe colocar el nombre a su materia', context);
        LoadingScreen().hide();
      } else {
        final DocumentSnapshot normalSnapshot = await FirebaseFirestore.instance
            .collection('Estudiantes')
            .doc(codigoIns)
            .get();
        final DocumentSnapshot materiaSnapshot = await FirebaseFirestore
            .instance
            .collection('Materias${pref.ultimateUid}')
            .doc(materiaId)
            .get();
        String asistencia = materiaSnapshot['inicio'];
        final DateTime inicioClase = DateFormat("hh:mm a").parse(asistencia);

        bool isQMDGreaterThanHLlegada(String qMD, String hLlegada) {
          DateTime qMDDateTime = DateFormat("hh:mm a").parse(qMD);
          DateTime hLlegadaDateTime = DateFormat("hh:mm a").parse(hLlegada);
          return qMDDateTime.isAfter(hLlegadaDateTime);
        }

        DateTime quinceMinutosDespues = DateFormat("hh:mm a")
            .parse(asistencia)
            .add(const Duration(minutes: 15));

        final now = DateTime.now();

        int weekday = now.weekday;

        final String qMD = DateFormat('hh:mm a').format(quinceMinutosDespues);

        final String hllegada = DateFormat('hh:mm a').format(now);
        final String fllegada = DateFormat('dd/MM/yyyy').format(now);

        bool isQMDGreater = isQMDGreaterThanHLlegada(qMD, hllegada);

        if (materiaSnapshot[weekday.toString()] == true) {
          if (now.isBefore(inicioClase)) {
            LoadingScreen().show(context);
            displayMessageToUser(
                'No puedes tomar asistencia antes de la hora de inicio de la clase',
                context);
          } else {
            if (normalSnapshot.exists) {
              final Map<String, dynamic> _data =
                  normalSnapshot.data()! as Map<String, dynamic>;

              String nombres = _data['nombres'];
              String apellidos = _data['apellidos'];
              String correo = _data['correo'];
              String programa = _data['programa'];
              String cedula = _data['cedula'];
              String cinstitucional = normalSnapshot['cinstitucional'];

              if (_data.containsKey(materiaId)) {
                if (materiaSnapshot[weekday.toString()] == true) {
                  if (isQMDGreater) {
                    LoadingScreen().show(context);
                    await FirebaseFirestore.instance
                        .collection('Materias'
                            '$materiaId'
                            'Asistencias')
                        .doc()
                        .set({
                      'nombres': nombres,
                      'apellidos': apellidos,
                      'cinstitucional': cinstitucional,
                      'correo': correo,
                      'cedula': cedula,
                      'programa': programa,
                      'hllegada': hllegada,
                      'fllegada': fllegada,
                      'asistencia': 'Llego a Tiempo'
                    });

                    displayMessageToUser('Asistencia Añadida', context);

                    setState(() {
                      codigoIns = '';
                    });
                    LoadingScreen().hide();
                  } else if (!isQMDGreater) {
                    await FirebaseFirestore.instance
                        .collection('Materias'
                            '$materiaId'
                            'Asistencias')
                        .doc()
                        .set({
                      'nombres': nombres,
                      'apellidos': apellidos,
                      'cinstitucional': cinstitucional,
                      'correo': correo,
                      'cedula': cedula,
                      'programa': programa,
                      'hllegada': hllegada,
                      'fllegada': fllegada,
                      'asistencia': 'Llego Tarde'
                    });

                    await FirebaseFirestore.instance
                        .collection('Inasistencias')
                        .doc()
                        .update({
                      'materia': materiaController.text,
                      'materiaId': materiaId,
                      'docente': pref.ultimateUid,
                      'nombres': nombres,
                      'apellidos': apellidos,
                      'cinstitucional': cinstitucional,
                      'correo': correo,
                      'cedula': cedula,
                      'programa': programa,
                      'hllegada': hllegada,
                      'fllegada': fllegada,
                      'asistencia': 'Llego Tarde'
                    });

                    displayMessageToUser('Asistencia Añadida', context);

                    setState(() {
                      codigoIns = '';
                    });
                    LoadingScreen().hide();
                  } else {
                    displayMessageToUser('El estudiante no existe', context);

                    setState(() {
                      codigoIns = '';
                    });
                    LoadingScreen().hide();
                  }
                } else {
                  displayMessageToUser('Hoy no toca esta clase', context);

                  setState(() {
                    codigoIns = '';
                  });
                  LoadingScreen().hide();
                }
              } else {
                LoadingScreen().show(context);
                displayMessageToUser(
                    'El Estudiante $nombres $apellidos no pertenece a esta clase',
                    context);
                LoadingScreen().hide();
              }
            } else {
              LoadingScreen().show(context);
              print('Codigo: $codigoIns');
              final QuerySnapshot _cedulaSnapshot = await FirebaseFirestore
                  .instance
                  .collection('Estudiantes')
                  .where('cedula', isEqualTo: codigoIns)
                  .get();

              if (_cedulaSnapshot.docs.isEmpty) {
                LoadingScreen().show(context);
                displayMessageToUser(
                    'El estudiante no existe en la base de datos', context);
                LoadingScreen().hide();
              } else if (_cedulaSnapshot.docs.isNotEmpty) {
                final DocumentSnapshot _documentSnapshot =
                    _cedulaSnapshot.docs.first;

                final Map<String, dynamic> _data =
                    _documentSnapshot.data()! as Map<String, dynamic>;

                String nombres = _data['nombres'];
                String apellidos = _data['apellidos'];
                String correo = _data['correo'];
                String programa = _data['programa'];
                String cedula = _data['cedula'];
                String cinstitucional = _data['cinstitucional'];

                if (_data.containsKey(materiaId)) {
                  if (isQMDGreater) {
                    LoadingScreen().show(context);
                    await FirebaseFirestore.instance
                        .collection('Materias'
                            '$materiaId'
                            'Asistencias')
                        .doc()
                        .set({
                      'nombres': nombres,
                      'apellidos': apellidos,
                      'cinstitucional': cinstitucional,
                      'correo': correo,
                      'cedula': cedula,
                      'programa': programa,
                      'hllegada': hllegada,
                      'fllegada': fllegada,
                      'asistencia': 'Llego a Tiempo'
                    });

                    displayMessageToUser('Asistencia Añadida', context);

                    setState(() {
                      codigoIns = '';
                    });
                    LoadingScreen().hide();
                  } else if (!isQMDGreater) {
                    await FirebaseFirestore.instance
                        .collection('Materias'
                            '$materiaId'
                            'Asistencias')
                        .doc()
                        .set({
                      'nombres': nombres,
                      'apellidos': apellidos,
                      'cinstitucional': cinstitucional,
                      'correo': correo,
                      'cedula': cedula,
                      'programa': programa,
                      'hllegada': hllegada,
                      'fllegada': fllegada,
                      'asistencia': 'Llego Tarde'
                    });

                    await FirebaseFirestore.instance
                        .collection('Inasistencias')
                        .doc()
                        .set({
                      'materia': materiaController.text,
                      'materiaId': materiaId,
                      'docente': pref.ultimateUid,
                      'nombres': nombres,
                      'apellidos': apellidos,
                      'cinstitucional': cinstitucional,
                      'correo': correo,
                      'cedula': cedula,
                      'programa': programa,
                      'hllegada': hllegada,
                      'fllegada': fllegada,
                      'asistencia': 'Llego Tarde'
                    });

                    displayMessageToUser('Asistencia Añadida', context);

                    setState(() {
                      codigoIns = '';
                    });
                    LoadingScreen().hide();
                  }
                } else {
                  LoadingScreen().show(context);
                  displayMessageToUser(
                      'El Estudiante $nombres $apellidos no pertenece a esta clase',
                      context);
                  setState(() {
                    codigoIns = '';
                  });
                  LoadingScreen().hide();
                }
              } else {
                LoadingScreen().show(context);
                displayMessageToUser(
                    'La cedula del estudiante no se a podido encontrar en la base de datos',
                    context);
                setState(() {
                  codigoIns = '';
                });
                LoadingScreen().hide();
              }
              setState(() {
                codigoIns = '';
              });
              LoadingScreen().hide();
            }
          }
        } else {
          LoadingScreen().show(context);
          displayMessageToUser('Hoy no toca esta materia', context);
        }
      }
    } on PlatformException {
      qrResult = 'HUBO UN ERROR';
      displayMessageToUser('HUBO UN ERROR', context);
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
              if (codigoIns != '')
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'Estudiante: ',
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                    ),
                    Text(
                      codigoIns,
                      style: const TextStyle(fontSize: 20),
                    ),
                  ],
                ),
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
                height: 20,
              ),
              StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                stream: FirebaseFirestore.instance
                    .collection('Materias${pref.ultimateUid}')
                    .snapshots(),
                builder: (BuildContext context,
                    AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>>
                        snapshot) {
                  if (snapshot.hasError) {
                    print('Error: ${snapshot.error}');
                    return const CircularProgressIndicator();
                  }

                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const CircularProgressIndicator();
                  }

                  _dropDownItems = snapshot.data!.docs
                      .map((doc) => doc['materia'])
                      .cast<String>()
                      .toList();

                  return Padding(
                    padding: const EdgeInsets.only(left: 10, right: 10),
                    child: DropdownButtonFormField<String>(
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
                            snapshot.data!.docs
                                .firstWhere((doc) => doc['materia'] == value);
                        final String docId = doc.id;
                        setState(() {
                          materiaId = docId;
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
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(
                height: 20,
              ),
              if (materiaController.text != '')
                Padding(
                  padding: const EdgeInsets.only(left: 30, right: 30),
                  child: SizedBox(
                    child: MyButton(text: 'Buscar Estudiante', onTap: scanQR),
                  ),
                ),
              if (codigoIns != '')
                const SizedBox(
                  height: 20,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

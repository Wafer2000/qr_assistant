// ignore_for_file: avoid_print, use_build_context_synchronously, avoid_function_literals_in_foreach_calls, no_leading_underscores_for_local_identifiers, unnecessary_brace_in_string_interps, unnecessary_brace_in_string_interps, unnecessary_brace_in_string_interps, unnecessary_brace_in_string_interps

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:intl/intl.dart';
import 'package:qr_assistant/tools/helper_functions.dart';
import 'package:qr_assistant/tools/loading_indicator.dart';
import 'package:qr_assistant/tools/my_button.dart';
import 'package:qr_assistant/shared/prefe_users.dart';
import 'package:qr_assistant/style/global_colors.dart';

class Scanner extends StatefulWidget {
  static const String routname = '/scanner';
  const Scanner({super.key});

  @override
  State<Scanner> createState() => _HomeUniState();
}

class _HomeUniState extends State<Scanner> {
  final pref = PreferencesUser();
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
      LoadingScreen().show(context);
      final DocumentSnapshot materiaSnapshot = await FirebaseFirestore.instance
          .collection('Materias${pref.uid}')
          .doc(pref.listId)
          .get();
      final DocumentSnapshot profeSnapshot = await FirebaseFirestore.instance
          .collection('Users')
          .doc(pref.uid)
          .get();
      final QuerySnapshot countNormalSnapshot = await FirebaseFirestore.instance
          .collection('Estudiantes${pref.listId}')
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

      DateTime cincuentaMinutosDespues = DateFormat("hh:mm a")
          .parse(asistencia)
          .add(const Duration(minutes: 15));

      final now = DateTime.now();

      int weekday = now.weekday;

      final String qMD = DateFormat('hh:mm a').format(quinceMinutosDespues);

      final String cMD = DateFormat('hh:mm a').format(cincuentaMinutosDespues);

      final String hllegada = DateFormat('hh:mm a').format(now);
      final String fhoy = DateFormat('dd-MM-yyyy').format(now);

      bool isQMDGreater = isQMDGreaterThanHLlegada(qMD, hllegada);

      bool isCMDGreater = isQMDGreaterThanHLlegada(cMD, hllegada);

      if (materiaSnapshot[weekday.toString()]) {
        if (now.isBefore(inicioClase)) {
          LoadingScreen().hide();
          displayMessageToUser(
              'No puedes tomar asistencia antes de la hora de inicio de la clase',
              context);
        } else {
          print('Codigo: $codigoIns');
          final QuerySnapshot _cedulaSnapshot = await FirebaseFirestore.instance
              .collection('Estudiantes${pref.listId}')
              .where('cedula', isEqualTo: codigoIns)
              .get();

          if (_cedulaSnapshot.docs.isEmpty) {
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
            String programa = _data['programa'];
            String cinstitucional = _data['cinstitucional'];

            final DocumentSnapshot saveDocu = await FirebaseFirestore.instance
                .collection('AsistenciasProfesores')
                .doc('${fhoy}${pref.uid}')
                .get();

            if (_data.containsKey(pref.listId)) {
              if (isQMDGreater && isCMDGreater) {
                final String fllegada = DateFormat('dd/MM/yyyy').format(now);
                final String hllegada = DateFormat('hh:mm a').format(now);

                final DocumentSnapshot asistenciaSnapshot =
                    await FirebaseFirestore.instance
                        .collection('MateriasAsistencias')
                        .doc('${fhoy}${cinstitucional}')
                        .get();
                final DocumentSnapshot asistenciaCountSnapshot =
                    await FirebaseFirestore.instance
                        .collection('Historial-FTP-Estudiante')
                        .doc('$cinstitucional${pref.listId}')
                        .get();
                if (asistenciaSnapshot.exists) {
                  if (asistenciaSnapshot[fhoy] == false) {
                    await FirebaseFirestore.instance
                        .collection('MateriasAsistencias')
                        .doc('${fhoy}${cinstitucional}')
                        .update({
                      fhoy: true,
                      'hllegada': hllegada,
                      'asistencia': 'Llego a Tiempo'
                    });
                    if (asistenciaCountSnapshot.exists) {
                      int puntual = asistenciaCountSnapshot['puntual'] + 1;
                      int fallo = asistenciaCountSnapshot['fallo'] - 1;
                      if (asistenciaCountSnapshot[fhoy] == false) {
                        await FirebaseFirestore.instance
                            .collection('Historial-FTP-Estudiante')
                            .doc('$cinstitucional${pref.listId}')
                            .update({
                          'puntual': puntual,
                        });
                        if (fllegada == asistenciaCountSnapshot['ultiasis']) {
                          await FirebaseFirestore.instance
                              .collection('Historial-FTP-Estudiante')
                              .doc('$cinstitucional${pref.listId}')
                              .update({
                            'fallo': fallo,
                          });
                        }
                      }
                    }
                  }
                } else {
                  Future<void> uploadData(
                    DocumentReference docRef1,
                    DocumentReference docRef2,
                    DocumentReference docRef3,
                    String cInstitucional,
                    String nombres,
                    String apellidos,
                    String correo,
                    String cedula,
                    String programa,
                  ) async {
                    final doc1 = await docRef1.get();
                    final doc2 = await docRef2.get();
                    final doc3 = await docRef3.get();

                    if (!doc1.exists) {
                      final String fllegada =
                          DateFormat('dd/MM/yyyy').format(now);
                      if (cInstitucional != cinstitucional) {
                        await docRef1.set({
                          'nombres': nombres,
                          'apellidos': apellidos,
                          'cinstitucional': cInstitucional,
                          'correo': correo,
                          'cedula': cedula,
                          'programa': programa,
                          'hllegada': '',
                          'fllegada': fllegada,
                          'asistencia': 'No LLego',
                          'materia': pref.listId,
                          fhoy: false,
                        });
                        if (!doc2.exists) {
                          await docRef2.set({
                            'materia': materiaSnapshot['materia'],
                            'materiaId': pref.listId,
                            'docenteName': '${profeSnapshot['nombres']}',
                            'docentelast': '${profeSnapshot['apellidos']}',
                            'docenteId': pref.uid,
                            'nombres': nombres,
                            'apellidos': apellidos,
                            'cinstitucional': cinstitucional,
                            'tarde': 0,
                            'fallo': 1,
                            'puntual': 0,
                            'correo': correo,
                            'cedula': cedula,
                            'programa': programa,
                            'ultiasis': fllegada,
                            fhoy: false,
                          });
                        } else {
                          int fallo2 = doc2['fallo'] + 1;
                          if (doc2['ultiasis'] != hllegada) {
                            await docRef2.update({
                              'fallo': fallo2,
                            });
                          } else {
                            displayMessageToUser('Ya tomo asistencia', context);
                          }
                        }
                      } else if (cInstitucional == cinstitucional) {
                        await docRef1.set({
                          'nombres': nombres,
                          'apellidos': apellidos,
                          'cinstitucional': cInstitucional,
                          'correo': correo,
                          'cedula': cedula,
                          'programa': programa,
                          'hllegada': hllegada,
                          'fllegada': fllegada,
                          'asistencia': 'Llego a Tiempo',
                          'materia': pref.listId,
                          fhoy: true,
                        });
                        if (!doc2.exists) {
                          await docRef2.set({
                            'materia': materiaSnapshot['materia'],
                            'materiaId': pref.listId,
                            'docenteName': '${profeSnapshot['nombres']}',
                            'docentelast': '${profeSnapshot['apellidos']}',
                            'docenteId': pref.uid,
                            'nombres': nombres,
                            'apellidos': apellidos,
                            'cinstitucional': cinstitucional,
                            'tarde': 0,
                            'fallo': 0,
                            'puntual': 1,
                            'correo': correo,
                            'cedula': cedula,
                            'programa': programa,
                            'ultiasis': fllegada,
                            fhoy: true
                          });
                        } else {
                          int puntual2 = doc2['puntual'] + 1;
                          if (doc2['ultiasis'] != hllegada) {
                            await docRef2.update({
                              'puntual': puntual2,
                            });
                          } else {
                            displayMessageToUser('Ya tomo asistencia', context);
                          }
                        }
                        if (doc3.exists) {
                          final puntual3 = doc3['puntual'] + 1;
                          if (doc3['ultiasis']) {
                            await docRef3.update({
                              'puntual': puntual3,
                            });

                            displayMessageToUser('Asistencia Añadida', context);

                            await docRef3.set({
                              'docenteId': pref.uid,
                              'nombres': profeSnapshot['nombres'],
                              'apellidos': profeSnapshot['apellidos'],
                              'materiaId': pref.listId,
                              'materia': materiaSnapshot['materia'],
                              'facultad': programa,
                              'hasistencia': hllegada,
                              'fasistencia': fllegada,
                              'asistencia': 'Llego a Tiempo',
                              fhoy: true,
                            });
                          }

                          setState(() {
                            codigoIns = '';
                          });
                          LoadingScreen().hide();
                        } else if (!doc3.exists) {
                          await docRef3.set({
                            'materia': materiaSnapshot['materia'],
                            'materiaId': pref.listId,
                            'docenteName': '${profeSnapshot['nombres']}',
                            'docentelast': '${profeSnapshot['apellidos']}',
                            'docenteId': pref.uid,
                            'fallo': 0,
                            'tarde': 0,
                            'puntual': 1,
                            'programa': programa,
                            'ultiasis': fllegada,
                            fhoy: true
                          });

                          displayMessageToUser('Asistencia Añadida', context);

                          setState(() {
                            codigoIns = '';
                          });
                          LoadingScreen().hide();

                          await docRef3.set({
                            'materia': materiaSnapshot['materia'],
                            'materiaId': pref.listId,
                            'docenteName': '${profeSnapshot['nombres']}',
                            'docentelast': '${profeSnapshot['apellidos']}',
                            'docenteId': pref.uid,
                            'fallo': 0,
                            'tarde': 0,
                            'puntual': 1,
                            'programa': programa,
                            'ultiasis': fllegada,
                            fhoy: true,
                          });
                        }
                      }
                    }
                  }

                  countNormalSnapshot.docs.forEach((document) async {
                    final cInstitucional = document.id;
                    final nombres = document.get('nombres');
                    final apellidos = document.get('apellidos');
                    final correo = document.get('correo');
                    final cedula = document.get('cedula');
                    final programa = document.get('programa');
                    final cinstitucional = document.get('cinstitucional');

                    final docRef1 = FirebaseFirestore.instance
                        .collection('MateriasAsistencias')
                        .doc('${fhoy}${cInstitucional}');

                    final docRef2 = FirebaseFirestore.instance
                        .collection('Historial-FTP-Estudiante')
                        .doc('$cInstitucional${pref.listId}');

                    final docRef3 = FirebaseFirestore.instance
                        .collection('Historial-FTP-Profesor')
                        .doc('${pref.uid}${pref.listId}');

                    await uploadData(docRef1, docRef2, docRef3, cinstitucional,
                        nombres, apellidos, correo, cedula, programa);
                  });
                }

                displayMessageToUser('Asistencia Añadida', context);

                setState(() {
                  codigoIns = '';
                });
                LoadingScreen().hide();
              } else if (!isQMDGreater && isCMDGreater) {
                final String fllegada = DateFormat('dd/MM/yyyy').format(now);
                final String hllegada = DateFormat('hh:mm a').format(now);

                final DocumentSnapshot asistenciaSnapshot =
                    await FirebaseFirestore.instance
                        .collection('MateriasAsistencias')
                        .doc('${fhoy}$cinstitucional')
                        .get();
                final DocumentSnapshot asistenciaCountSnapshot =
                    await FirebaseFirestore.instance
                        .collection('Historial-FTP-Estudiante')
                        .doc('$cinstitucional${pref.listId}')
                        .get();
                if (asistenciaSnapshot.exists) {
                  if (asistenciaSnapshot[fhoy] == false) {
                    FirebaseFirestore.instance
                        .collection('MateriasAsistencias')
                        .doc('${fhoy}${cinstitucional}')
                        .update({
                      fhoy: true,
                      'hllegada': hllegada,
                      'asistencia': 'Llego Tarde'
                    });
                    if (asistenciaCountSnapshot.exists) {
                      int tarde = asistenciaCountSnapshot['tarde'] + 1;
                      int fallo = asistenciaCountSnapshot['fallo'] - 1;
                      if (asistenciaCountSnapshot[fhoy] == false) {
                        await FirebaseFirestore.instance
                            .collection('Historial-FTP-Estudiante')
                            .doc('$cinstitucional${pref.listId}')
                            .update({
                          'tarde': tarde,
                        });
                        if (fllegada == asistenciaCountSnapshot['ultiasis']) {
                          await FirebaseFirestore.instance
                              .collection('Historial-FTP-Estudiante')
                              .doc('$cinstitucional${pref.listId}')
                              .update({
                            'fallo': fallo,
                          });
                        }
                      }
                    }
                  }
                } else {
                  Future<void> uploadData(
                    DocumentReference docRef1,
                    DocumentReference docRef2,
                    DocumentReference docRef3,
                    String cInstitucional,
                    String nombres,
                    String apellidos,
                    String correo,
                    String cedula,
                    String programa,
                  ) async {
                    final doc1 = await docRef1.get();
                    final doc2 = await docRef2.get();
                    final doc3 = await docRef3.get();

                    if (!doc1.exists) {
                      final String fllegada =
                          DateFormat('dd/MM/yyyy').format(now);
                      if (cInstitucional != cinstitucional) {
                        await docRef1.set({
                          'nombres': nombres,
                          'apellidos': apellidos,
                          'cinstitucional': cInstitucional,
                          'correo': correo,
                          'cedula': cedula,
                          'programa': programa,
                          'hllegada': '',
                          'fllegada': fllegada,
                          'asistencia': 'No LLego',
                          'materia': pref.listId,
                          fhoy: false,
                        });
                        if (!doc2.exists) {
                          await docRef2.set({
                            'materia': materiaSnapshot['materia'],
                            'materiaId': pref.listId,
                            'docenteName': '${profeSnapshot['nombres']}',
                            'docentelast': '${profeSnapshot['apellidos']}',
                            'docenteId': pref.uid,
                            'nombres': nombres,
                            'apellidos': apellidos,
                            'cinstitucional': cinstitucional,
                            'tarde': 0,
                            'fallo': 1,
                            'puntual': 0,
                            'correo': correo,
                            'cedula': cedula,
                            'programa': programa,
                            'ultiasis': fllegada,
                            fhoy: false,
                          });
                        } else {
                          int fallo2 = doc2['fallo'] + 1;
                          if (doc2['ultiasis'] != hllegada) {
                            await docRef2.update({
                              'fallo': fallo2,
                            });
                          } else {
                            displayMessageToUser('Ya tomo asistencia', context);
                          }
                        }
                      } else if (cInstitucional == cinstitucional) {
                        await docRef1.set({
                          'nombres': nombres,
                          'apellidos': apellidos,
                          'cinstitucional': cInstitucional,
                          'correo': correo,
                          'cedula': cedula,
                          'programa': programa,
                          'hllegada': hllegada,
                          'fllegada': fllegada,
                          'asistencia': 'Llego Tarde',
                          'materia': pref.listId,
                          fhoy: true,
                        });
                        if (!doc2.exists) {
                          await docRef2.set({
                            'materia': materiaSnapshot['materia'],
                            'materiaId': pref.listId,
                            'docenteName': '${profeSnapshot['nombres']}',
                            'docentelast': '${profeSnapshot['apellidos']}',
                            'docenteId': pref.uid,
                            'nombres': nombres,
                            'apellidos': apellidos,
                            'cinstitucional': cinstitucional,
                            'tarde': 1,
                            'fallo': 0,
                            'puntual': 0,
                            'correo': correo,
                            'cedula': cedula,
                            'programa': programa,
                            'ultiasis': fllegada,
                            fhoy: true,
                          });
                        } else {
                          int tarde2 = doc2['tarde'] + 1;
                          if (doc2['ultiasis'] != hllegada) {
                            await docRef2.update({
                              'tarde': tarde2,
                            });
                          } else {
                            displayMessageToUser('Ya tomo asistencia', context);
                          }
                        }
                        if (doc3.exists) {
                          final puntual3 = doc3['puntual'] + 1;
                          if (doc3['ultiasis']) {
                            await docRef3.update({
                              'puntual': puntual3,
                            });

                            displayMessageToUser('Asistencia Añadida', context);

                            await docRef3.set({
                            'materia': materiaSnapshot['materia'],
                            'materiaId': pref.listId,
                            'docenteName': '${profeSnapshot['nombres']}',
                            'docentelast': '${profeSnapshot['apellidos']}',
                            'docenteId': pref.uid,
                            'fallo': 0,
                            'tarde': 0,
                            'puntual': 1,
                            'programa': programa,
                            'ultiasis': fllegada,
                              fhoy: true,
                            });
                          }

                          setState(() {
                            codigoIns = '';
                          });
                          LoadingScreen().hide();
                        } else if (!doc3.exists) {
                          await docRef3.set({
                            'materia': materiaSnapshot['materia'],
                            'materiaId': pref.listId,
                            'docenteName': '${profeSnapshot['nombres']}',
                            'docentelast': '${profeSnapshot['apellidos']}',
                            'docenteId': pref.uid,
                            'fallo': 0,
                            'tarde': 0,
                            'puntual': 1,
                            'programa': programa,
                            'ultiasis': fllegada,
                            fhoy: true,
                          });

                          displayMessageToUser('Asistencia Añadida', context);

                          setState(() {
                            codigoIns = '';
                          });
                          LoadingScreen().hide();

                          await docRef3.set({
                            'materia': materiaSnapshot['materia'],
                            'materiaId': pref.listId,
                            'docenteName': '${profeSnapshot['nombres']}',
                            'docentelast': '${profeSnapshot['apellidos']}',
                            'docenteId': pref.uid,
                            'fallo': 0,
                            'tarde': 0,
                            'puntual': 1,
                            'programa': programa,
                            'ultiasis': fllegada,
                            fhoy: true,
                          });
                        }
                      }
                    }
                  }

                  countNormalSnapshot.docs.forEach((document) async {
                    final cInstitucional = document.id;
                    final nombres = document.get('nombres');
                    final apellidos = document.get('apellidos');
                    final correo = document.get('correo');
                    final cedula = document.get('cedula');
                    final programa = document.get('programa');
                    final cinstitucional = document.get('cinstitucional');

                    final docRef1 = FirebaseFirestore.instance
                        .collection('MateriasAsistencias')
                        .doc('${fhoy}${cInstitucional}');

                    final docRef2 = FirebaseFirestore.instance
                        .collection('Historial-FTP-Estudiante')
                        .doc('$cInstitucional${pref.listId}');

                    final docRef3 = FirebaseFirestore.instance
                        .collection('Historial-FTP-Profesor')
                        .doc('${pref.uid}${pref.listId}');

                    await uploadData(docRef1, docRef2, docRef3, cinstitucional,
                        nombres, apellidos, correo, cedula, programa);
                  });
                }
              } else if (!isCMDGreater) {
                final String fllegada = DateFormat('dd/MM/yyyy').format(now);
                final String hllegada = DateFormat('hh:mm a').format(now);
                final DocumentSnapshot inaprofSnapshot = await FirebaseFirestore
                    .instance
                    .collection('Historial-FTP-Profesor')
                    .doc('${pref.uid}${pref.listId}')
                    .get();

                if (inaprofSnapshot.exists) {
                  if (inaprofSnapshot[fhoy] == false) {
                    displayMessageToUser(
                        'Ya tomaste tu asistencia antes', context);
                    setState(() {
                      codigoIns = '';
                    });
                    LoadingScreen().hide();
                  } else {
                    if (inaprofSnapshot.exists) {
                      final tarde = inaprofSnapshot['tarde'] + 1;
                      if (inaprofSnapshot['ultiasis'] == fllegada) {
                        await FirebaseFirestore.instance
                            .collection('Historial-FTP-Profesor')
                            .doc('${pref.uid}${pref.listId}')
                            .update({
                          'tarde': tarde,
                        });

                        displayMessageToUser('Asistencia Añadida', context);

                        await FirebaseFirestore.instance
                            .collection('AsistenciasProfesores')
                            .doc('${fhoy}${pref.uid}')
                            .set({
                          'docenteId': pref.uid,
                          'nombres': profeSnapshot['nombres'],
                          'apellidos': profeSnapshot['apellidos'],
                          'materiaId': pref.listId,
                          'materia': materiaSnapshot['materia'],
                          'facultad': programa,
                          'hasistencia': hllegada,
                          'fasistencia': fllegada,
                          'asistencia': 'Llego Tarde',
                          fhoy: true,
                        });
                      }

                      setState(() {
                        codigoIns = '';
                      });
                      LoadingScreen().hide();
                    } else if (!inaprofSnapshot.exists) {
                      await FirebaseFirestore.instance
                          .collection('Historial-FTP-Profesor')
                          .doc('$cinstitucional${pref.listId}')
                          .set({
                        'materia': materiaSnapshot['materia'],
                        'materiaId': pref.listId,
                        'docenteName': '${profeSnapshot['nombres']}',
                        'docentelast': '${profeSnapshot['apellidos']}',
                        'docenteId': pref.uid,
                        'fallo': 0,
                        'tarde': 1,
                        'puntual': 0,
                        'programa': programa,
                        'ultiasis': fllegada,
                        fhoy: true,
                      });

                      displayMessageToUser('Asistencia Añadida', context);

                      setState(() {
                        codigoIns = '';
                      });
                      LoadingScreen().hide();

                      await FirebaseFirestore.instance
                          .collection('AsistenciasProfesores')
                          .doc('${fhoy}${pref.uid}')
                          .set({
                        'docenteId': pref.uid,
                        'nombres': profeSnapshot['nombres'],
                        'apellidos': profeSnapshot['apellidos'],
                        'materiaId': pref.listId,
                        'materia': materiaSnapshot['materia'],
                        'facultad': programa,
                        'hasistencia': hllegada,
                        'fasistencia': fllegada,
                        'asistencia': 'Llego Tarde',
                        fhoy: true,
                      });
                    }
                  }
                }
              } else if (!isCMDGreater &&
                  saveDocu['asistencia'] == 'Llego a Tiempo') {
                displayMessageToUser('Ya tomaste tu asistencia antes', context);
                setState(() {
                  codigoIns = '';
                });
                LoadingScreen().hide();
              }
            } else {
              displayMessageToUser(
                  'El Estudiante $nombres $apellidos no pertenece a esta clase',
                  context);
              setState(() {
                codigoIns = '';
              });
              LoadingScreen().hide();
            }
          } else {
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
      } else {
        LoadingScreen().hide();
        displayMessageToUser('Hoy no toca esta materia', context);
      }
    } on PlatformException {
      qrResult = 'HUBO UN ERROR';
      LoadingScreen().hide();
      displayMessageToUser('HUBO UN ERROR', context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        title: const Center(child: Text('E s c a n e r')),
        actions: const [
          SizedBox(
            width: 56,
          )
        ],
        backgroundColor: Theme.of(context).brightness == Brightness.light
            ? MyColor.jungleGreen().color
            : MyColor.spectra().color,
      ),
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

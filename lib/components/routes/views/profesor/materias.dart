// ignore_for_file: non_constant_identifier_names, use_build_context_synchronously, unused_element, avoid_print, unnecessary_new, unnecessary_null_comparison

import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:qr_assistant/components/routes/views/scanner.dart';
import 'package:qr_assistant/tools/helper_functions.dart';
import 'package:qr_assistant/tools/loading_indicator.dart';
import 'package:qr_assistant/tools/my_drawer.dart';
import 'package:qr_assistant/components/routes/views/profesor/list_class.dart';
import 'package:qr_assistant/components/routes/views/profesor/new_materia.dart';
import 'package:qr_assistant/shared/prefe_users.dart';
import 'package:qr_assistant/style/global_colors.dart';
import 'package:spreadsheet_decoder/spreadsheet_decoder.dart';
import 'dart:io';

class Materias extends StatefulWidget {
  static const String routname = '/materias';
  const Materias({super.key});

  @override
  State<Materias> createState() => _MateriasState();
}

class _MateriasState extends State<Materias> {
  final TextEditingController materiaController = TextEditingController();
  final TextEditingController inicioController = TextEditingController();
  final TextEditingController salidaController = TextEditingController();
  final TextEditingController weekController = TextEditingController();
  final _pref = PreferencesUser();

  String mantenimientoTag = 'mantenimientoTag';

  @override
  void dispose() {
    materiaController.dispose();
    inicioController.dispose();
    salidaController.dispose();
    super.dispose();
  }

  void _inasistenciasfile(materiaId, materia) {
    showDialog(
        context: context,
        builder: (context) {
          final now = DateTime.now();
          final String fhoy = DateFormat('dd/MM/yyyy').format(now);
          List<QueryDocumentSnapshot>? service1;
          int rowNumber3 = 0;

          return AlertDialog(
            title: const Text(
              'Ausencias',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 35),
            ),
            icon: Icon(
              Icons.list,
              color: Theme.of(context).brightness == Brightness.light
                  ? MyColor.black().color
                  : MyColor.naturalGray().color,
            ),
            backgroundColor: Theme.of(context).colorScheme.background,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            content: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection("Historial-FTP-Estudiante")
                    .orderBy('ultiasis', descending: true)
                    .where('materiaId', isEqualTo: materiaId)
                    .where('programa', isNotEqualTo: 'Programa')
                    .where('fallo', isGreaterThan: 0)
                    .snapshots(),
                builder: (context, snapshot) {
                  final service1 = snapshot.data?.docs;

                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(
                      child: CircularProgressIndicator(
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    );
                  }
                  if (snapshot.hasError) {
                    print('StreamBuilder error: ${snapshot.error}');
                    return const Center(
                      child: Text('Ocurrio un error'),
                    );
                  }
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }
                  if (snapshot.data == null) {
                    return const Center(
                      child: Text(
                        'No hay Datos',
                        style: TextStyle(fontSize: 30),
                      ),
                    );
                  }
                  return SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        ElevatedButton(
                          onPressed: () async {
                            final DocumentSnapshot materiaSnapshot =
                                await FirebaseFirestore.instance
                                    .collection('Materias${_pref.uid}')
                                    .doc(materiaId)
                                    .get();
                            final DocumentSnapshot docenteSnapshot =
                                await FirebaseFirestore.instance
                                    .collection('Users')
                                    .doc(_pref.uid)
                                    .get();

                            print(service1);

                            if (service1 != null) {
                              int rowNumber4 = 0;
                              final csvData = [
                                'NUMERO DE INASISTENCIAS',
                                'Materia: ${materiaSnapshot['materia'].replaceAll(',', ',')}',
                                'Docente: ${docenteSnapshot['nombres']} ${docenteSnapshot['apellidos'].replaceAll(',', ',')}',
                                'Nº,Nombres y Apellidos,Codigo Instucional,Nº de Inasistencias',
                                ...service1.asMap().entries.where((entry) {
                                  Map<String, dynamic> data = entry.value.data()
                                      as Map<String, dynamic>;
                                  return data['programa'] != 'Programa';
                                }).map((entry) {
                                  Map<String, dynamic> data = entry.value.data()
                                      as Map<String, dynamic>;
                                  rowNumber4++;
                                  return [
                                    '$rowNumber4',
                                    '${data['nombres'].replaceAll(',', ',')} ${data['apellidos'].replaceAll(',', ',')}',
                                    '${data['cinstitucional'].replaceAll(',', ',')}',
                                    '${data['fallo']}'
                                  ].join(',');
                                }),
                              ].join('\n');

                              final now = DateTime.now();
                              final hcreacion =
                                  DateFormat('HH:mm:ss').format(now);
                              final fcreacion =
                                  DateFormat('dd-MM-yyyy').format(now);

                              final directory =
                                  await getExternalStorageDirectory();
                              final appDocumentsDir = Directory(
                                  '${directory!.path}/Documents/Inasistencias_QrAssistant');
                              if (!appDocumentsDir.existsSync()) {
                                appDocumentsDir.createSync(recursive: true);
                              }

                              final file = File(
                                  '${appDocumentsDir.path}/Inasistencias_${hcreacion}_${fcreacion}_${materiaSnapshot['materia']}.csv');
                              await file.writeAsString(csvData, encoding: utf8);

                              Navigator.of(context).pop();
                              LoadingScreen().hide();
                              displayMessageToUser(
                                  'CSV file saved to ${file.path}', context);
                              print(file.path);
                            } else {
                              Navigator.of(context).pop();
                              LoadingScreen().hide();
                              displayMessageToUser(
                                  'No data to export', context);
                            }
                          },
                          child: Text(
                            'Exportar a CSV',
                            style: TextStyle(
                              color: Theme.of(context).brightness ==
                                      Brightness.light
                                  ? MyColor.black().color
                                  : MyColor.white().color,
                            ),
                          ),
                        ),
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: DataTable(
                            columns: const <DataColumn>[
                              DataColumn(
                                label: Text(
                                  'ID',
                                  style: TextStyle(
                                    fontStyle: FontStyle.italic,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              DataColumn(
                                label: Text(
                                  'Nombres y Apellidos',
                                  style: TextStyle(
                                    fontStyle: FontStyle.italic,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              DataColumn(
                                label: Text(
                                  'Codigo Institucional',
                                  style: TextStyle(
                                    fontStyle: FontStyle.italic,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              DataColumn(
                                label: Text(
                                  'Nº de Inasistencias',
                                  style: TextStyle(
                                    fontStyle: FontStyle.italic,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                            rows: service1!.map((entry) {
                              Map<String, dynamic> data =
                                  entry.data() as Map<String, dynamic>;
                              rowNumber3++;
                              return DataRow(
                                cells: <DataCell>[
                                  DataCell(Text('$rowNumber3')),
                                  DataCell(Text(
                                      '${data['nombres']} ${data['apellidos']}')),
                                  DataCell(Text('${data['cinstitucional']}')),
                                  DataCell(Text('${data['fallo']}')),
                                ],
                              );
                            }).toList(),
                          ),
                        ),
                      ],
                    ),
                  );
                }),
          );
        });
  }

  void asistencias(materiaId) {
    List<QueryDocumentSnapshot>? service;
    int rowNumber = 0;

    showDialog(
      context: context,
      builder: (context) {
        final now = DateTime.now();
        final fhoy = DateFormat('dd/MM/yyyy').format(now);

        return AlertDialog(
          title: const Text(
            'Asistencias',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 35),
          ),
          icon: Icon(
            Icons.list,
            color: Theme.of(context).brightness == Brightness.light
                ? MyColor.black().color
                : MyColor.naturalGray().color,
          ),
          backgroundColor: Theme.of(context).colorScheme.background,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ElevatedButton(
                  onPressed: () async {
                    final DocumentSnapshot materiaSnapshot =
                        await FirebaseFirestore.instance
                            .collection('Materias${_pref.uid}')
                            .doc(materiaId)
                            .get();
                    final DocumentSnapshot docenteSnapshot =
                        await FirebaseFirestore.instance
                            .collection('Users')
                            .doc(_pref.uid)
                            .get();

                    if (service != null) {
                      int rowNumber2 = 0;
                      final csvData = [
                        'ASISTENCIA',
                        'Materia: ${materiaSnapshot['materia'].replaceAll(',', ',')}',
                        'Docente: ${docenteSnapshot['nombres']} ${docenteSnapshot['apellidos'].replaceAll(',', ',')}',
                        'Nº,Nombres y Apellidos,Codigo Instucional,Fecha de Llegada,Hora de Llegada',
                        ...service!.asMap().entries.where((entry) {
                          Map<String, dynamic> data =
                              entry.value.data() as Map<String, dynamic>;
                          return data['programa'] != 'Programa';
                        }).map((entry) {
                          Map<String, dynamic> data =
                              entry.value.data() as Map<String, dynamic>;
                          rowNumber2++;
                          return [
                            '$rowNumber2',
                            '${data['nombres'].replaceAll(',', ',')} ${data['apellidos'].replaceAll(',', ',')}',
                            '${data['cinstitucional'].replaceAll(',', ',')}',
                            '${data['fllegada'].replaceAll(',', ',')}',
                            data['hllegada'] == ''
                                ? 'No Asistio'
                                : '${data['hllegada'].replaceAll(',', ',')}',
                          ].join(',');
                        }),
                      ].join('\n');

                      final now = DateTime.now();
                      final hcreacion = DateFormat('HH:mm:ss').format(now);
                      final fcreacion = DateFormat('dd-MM-yyyy').format(now);

                      final directory = await getExternalStorageDirectory();
                      final appDocumentsDir = Directory(
                          '${directory!.path}/Documents/Asistencias_QrAssistant');
                      if (!appDocumentsDir.existsSync()) {
                        appDocumentsDir.createSync(recursive: true);
                      }
                      final file = File(
                          '${appDocumentsDir.path}/Asistencias_${hcreacion}_${fcreacion}_${materiaSnapshot['materia']}.csv');
                      await file.writeAsString(csvData);

                      Navigator.of(context).pop();
                      LoadingScreen().hide();
                      displayMessageToUser(
                          'CSV file saved to ${file.path}', context);
                      print(file.path);
                    } else {
                      Navigator.of(context).pop();
                      LoadingScreen().hide();
                      displayMessageToUser('No data to export', context);
                    }
                  },
                  child: Text(
                    'Exportar a CSV',
                    style: TextStyle(
                      color: Theme.of(context).brightness == Brightness.light
                          ? MyColor.black().color
                          : MyColor.white().color,
                    ),
                  ),
                ),
                StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('MateriasAsistencias')
                      .where('materia', isEqualTo: materiaId)
                      .orderBy('hllegada', descending: true)
                      .snapshots(),
                  builder: (context, snapshot) {
                    service = snapshot.data?.docs;

                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(
                        child: CircularProgressIndicator(
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      );
                    }
                    if (snapshot.data == null) {
                      return const Center(
                        child: Text(
                          'No hay Datos',
                          style: TextStyle(fontSize: 30),
                        ),
                      );
                    }
                    return SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: DataTable(
                        columns: const <DataColumn>[
                          DataColumn(
                            label: Text(
                              'ID',
                              style: TextStyle(
                                fontStyle: FontStyle.italic,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          DataColumn(
                            label: Text(
                              'Nombres y Apellidos',
                              style: TextStyle(
                                fontStyle: FontStyle.italic,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          DataColumn(
                            label: Text(
                              'Codigo Institucional',
                              style: TextStyle(
                                fontStyle: FontStyle.italic,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          DataColumn(
                            label: Text(
                              'Fecha',
                              style: TextStyle(
                                fontStyle: FontStyle.italic,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          DataColumn(
                            label: Text(
                              'Hora',
                              style: TextStyle(
                                fontStyle: FontStyle.italic,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                        rows: service!.asMap().entries.where((entry) {
                          Map<String, dynamic> data =
                              entry.value.data() as Map<String, dynamic>;
                          return data['programa'] != 'Programa';
                        }).map((entry) {
                          Map<String, dynamic> data =
                              entry.value.data() as Map<String, dynamic>;
                          rowNumber++;
                          return DataRow(
                            cells: <DataCell>[
                              DataCell(Text('$rowNumber')),
                              DataCell(Text(
                                  '${data['nombres']} ${data['apellidos']}')),
                              DataCell(Text('${data['cinstitucional']}')),
                              DataCell(Text('${data['fllegada']}')),
                              DataCell(Text(data['hllegada'] == ''
                                  ? 'No Asistio'
                                  : '${data['hllegada']}')),
                            ],
                          );
                        }).toList(),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void delete_Materia(materia) {
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('¿Estas Seguro?'),
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
                    const Center(
                        child: Text(
                            'Se eliminiran los datos de asistencias y estudiantes tambien')),
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
                        inicioController.clear();
                        salidaController.clear();
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

                        await FirebaseFirestore.instance
                            .collection('Materias${_pref.uid}'
                                '$materia'
                                'Asistencias')
                            .get()
                            .then((querySnapshot) {
                          for (var result in querySnapshot.docs) {
                            result.reference.delete();
                          }
                        });

                        try {
                          QuerySnapshot querySnapshot = await FirebaseFirestore
                              .instance
                              .collection('Estudiantes')
                              .where(materia, isEqualTo: true)
                              .get();

                          for (var es in querySnapshot.docs) {
                            await FirebaseFirestore.instance
                                .collection('Estudiantes')
                                .doc(es.id)
                                .update({
                              materia: FieldValue.delete(),
                            });
                          }

                          print(
                              'Se han eliminado a los estudiantes de tu clase');
                        } catch (error) {
                          print('Ocurrio el siguiente error: $error');
                        }

                        await FirebaseFirestore.instance
                            .collection('Materias${_pref.uid}')
                            .doc(materia)
                            .delete();

                        displayMessageToUser('Datos Eliminados', context);
                        LoadingScreen().hide();
                        Navigator.pop(context);
                        Navigator.pop(context);
                      },
                      child: const Text('Eliminar',
                          style: TextStyle(color: Colors.white)),
                    ),
                  ),
                ],
              ),
            ],
          );
        });
  }

  String text = "";
  int count = 0;
  int countpro = 0;
  final db = FirebaseFirestore.instance;
  final WriteBatch batch = FirebaseFirestore.instance.batch();

  Future<void> createDataGene(
      List excel, String materia, WriteBatch batch) async {
    count++;
    batch.set(db.collection('Estudiantes').doc('${excel[1]}'), {
      'cinstitucional': '${excel[1]}',
      'nombres': '${excel[2]}',
      'apellidos': '${excel[3]}',
      'nprograma': '${excel[4]}',
      'programa': '${excel[5]}',
      'correo': '${excel[6]}',
      'cedula': '',
      materia: true
    });
  }

  Future<void> updateDataGene(
      List excel, String materia, WriteBatch batch) async {
    final DocumentSnapshot studentSnapshot = await FirebaseFirestore.instance
        .collection('Estudiantes')
        .doc('${excel[1]}')
        .get();
    final DocumentSnapshot studentproSnapshot = await FirebaseFirestore.instance
        .collection('Estudiantes$materia')
        .doc('${excel[1]}')
        .get();
    if (studentSnapshot.exists) {
      count++;
      WriteBatch batch1 = db.batch();
      batch1.update(
          db.collection('Estudiantes').doc('${excel[1]}'), {materia: true});

      batch1.commit().then((value) {
        print('Batch updated successfully.');
      });
      WriteBatch batch2 = db.batch();
      
      batch2.update(db.collection('Estudiantes$materia').doc('${excel[1]}'), {
        'cedula': studentSnapshot['cedula'],
      });
      batch2.commit().then((value) {
        print('Batch updated successfully.');
      });
    } else if (studentSnapshot['cedula'] != '' && studentproSnapshot.exists) {
      batch.set(db.collection('Estudiantes$materia').doc('${excel[1]}'), {
        'cinstitucional': '${excel[1]}',
        'nombres': '${excel[2]}',
        'apellidos': '${excel[3]}',
        'nprograma': '${excel[4]}',
        'programa': '${excel[5]}',
        'correo': '${excel[6]}',
        'cedula': studentSnapshot['cedula'],
        materia: true
      });
    }
  }

  Future<void> createDataProf(
      List excel, String materia, WriteBatch batch) async {
    countpro++;
    batch.set(db.collection('Estudiantes$materia').doc('${excel[1]}'), {
      'cinstitucional': '${excel[1]}',
      'nombres': '${excel[2]}',
      'apellidos': '${excel[3]}',
      'nprograma': '${excel[4]}',
      'programa': '${excel[5]}',
      'correo': '${excel[6]}',
      'cedula': '',
      materia: true
    });
  }

  void _openfile(materia) async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['xlsx'],
    );

    if (result == null) return;

    final pickedFile = result.files.first;
    final path = pickedFile.path!;

    if (path.endsWith('.csv')) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No se permiten archivos CSV'),
          backgroundColor: Colors.red,
        ),
      );
      Navigator.of(context).pop();
      return;
    }

    var bytes = File(path).readAsBytesSync();
    var decoder = new SpreadsheetDecoder.decodeBytes(bytes, update: true);

    // Create a new batch for each XLSX file
    final WriteBatch batch = FirebaseFirestore.instance.batch();
    LoadingScreen().show(context);

    for (var table in decoder.tables.keys) {
      print(table);
      print(decoder.tables[table]?.maxCols);
      print(decoder.tables[table]?.maxRows);
      print(decoder.tables[table]?.rows);
      setState(() {
        text = decoder.tables[table]!.rows.toString();
      });
      for (var row in decoder.tables[table]!.rows) {
        final DocumentSnapshot studentSnapshot = await FirebaseFirestore
            .instance
            .collection('Estudiantes')
            .doc('${row[1]}')
            .get();
        final DocumentSnapshot studentprofSnapshot = await FirebaseFirestore
            .instance
            .collection('Estudiantes$materia')
            .doc('${row[1]}')
            .get();
        if (!studentSnapshot.exists) {
          row[1] == "id" ? print("") : createDataGene(row, materia, batch);
        } else {
          row[1] == "id" ? print("") : updateDataGene(row, materia, batch);
        }
        if (!studentprofSnapshot.exists) {
          row[1] == "id" ? print("") : createDataProf(row, materia, batch);
        }
      }

      // Commit the batch after adding all the documents for the current file
      await batch.commit();
    }
    final int fcount = count - 1;
    print(fcount);
    final DocumentSnapshot materiaSnapshot = await FirebaseFirestore.instance
        .collection('Materias${_pref.uid}')
        .doc(materia)
        .get();
    if (!materiaSnapshot.exists && fcount != -1) {
      await FirebaseFirestore.instance
          .collection('Materias${_pref.uid}')
          .doc(materia)
          .update({
        'numStu': fcount,
      });
    } else if (fcount > 0 && materiaSnapshot.exists && fcount != -1) {
      if (materiaSnapshot['numStu'] != fcount && fcount != -1) {
        await FirebaseFirestore.instance
            .collection('Materias${_pref.uid}')
            .doc(materia)
            .update({
          'numStu': materiaSnapshot['numStu'] + fcount,
        });
      }
    } else if (fcount < 0 && materiaSnapshot.exists && fcount != -1) {
      if (materiaSnapshot['numStu'] != fcount && fcount != -1) {
        await FirebaseFirestore.instance
            .collection('Materias${_pref.uid}')
            .doc(materia)
            .update({
          'numStu': materiaSnapshot['numStu'] + fcount,
        });
      }
    }
    LoadingScreen().hide();
    displayMessageToUser('Se han subido los estudiantes', context);
    count = 0;
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('Materias${_pref.uid}')
            .snapshots(),
        builder: (context, snapshot) {
          final service = snapshot.data?.docs;

          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(
                color: Theme.of(context).colorScheme.primary,
              ),
            );
          }
          if (snapshot.data == null) {
            return Scaffold(
              appBar: AppBar(
                elevation: 0,
                title: const Center(child: Text('Materias')),
                actions: [
                  IconButton(
                    icon: const Icon(Icons.add),
                    onPressed: () {
                      Navigator.pushNamed(context, NewMateria.routname);
                    },
                    tooltip: 'Add',
                    alignment: Alignment.center,
                  ),
                ],
                backgroundColor:
                    Theme.of(context).brightness == Brightness.light
                        ? MyColor.jungleGreen().color
                        : MyColor.spectra().color,
              ),
              drawer: const MyDrawer(),
              backgroundColor: Theme.of(context).colorScheme.background,
              body: const Stack(
                children: [
                  Positioned.fill(
                    child: Center(
                      child: Text(
                        'No hay Datos',
                        style: TextStyle(fontSize: 30),
                      ),
                    ),
                  ),
                ],
              ),
            );
          }

          return Scaffold(
            appBar: AppBar(
              elevation: 0,
              title: const Center(child: Text('Materias')),
              actions: [
                IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: () {
                    Navigator.pushNamed(context, NewMateria.routname);
                  },
                  tooltip: 'Add',
                  alignment: Alignment.center,
                ),
              ],
              backgroundColor: Theme.of(context).brightness == Brightness.light
                  ? MyColor.jungleGreen().color
                  : MyColor.spectra().color,
            ),
            drawer: const MyDrawer(),
            backgroundColor: Theme.of(context).colorScheme.background,
            body: ListView.builder(
              itemCount: service?.length,
              itemBuilder: (context, index) {
                DocumentSnapshot document = service![index];
                Map<String, dynamic> data =
                    document.data() as Map<String, dynamic>;
                String docID = document.id;

                final now = DateTime.now();
                final fhoy = DateFormat('dd/MM/yyyy').format(now);

                bool isCMDGreaterThanHLlegada(String cMD, String hLlegada) {
                  DateTime cMDDateTime = DateFormat("hh:mm a").parse(cMD);
                  DateTime hLlegadaDateTime =
                      DateFormat("hh:mm a").parse(hLlegada);
                  return cMDDateTime.isAfter(hLlegadaDateTime);
                }

                return Padding(
                  padding: const EdgeInsets.fromLTRB(10, 20, 10, 0),
                  child: Container(
                    width: MediaQuery.of(context).size.height * 0.8,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      color: Theme.of(context).brightness == Brightness.light
                          ? MyColor.grayChateau().color
                          : MyColor.bunker().color,
                    ),
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(10, 0, 10, 10),
                      child: Stack(
                        children: [
                          Column(
                            children: [
                              Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(
                                        top: 10, right: 10),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Flexible(
                                          flex: 1,
                                          child: Text(
                                            '${data['materia']}',
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 27,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(
                                height: 10,
                              ),
                              Padding(
                                padding:
                                    const EdgeInsets.only(left: 10, right: 10),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          'Dias a la semana en que da clases: ',
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 15),
                                        ),
                                      ],
                                    ),
                                    if (data['1'] == true)
                                      const Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Text(
                                            'Lunes ',
                                            style: TextStyle(fontSize: 15),
                                          ),
                                        ],
                                      ),
                                    if (data['2'] == true)
                                      const Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Text(
                                            'Martes ',
                                            style: TextStyle(fontSize: 15),
                                          ),
                                        ],
                                      ),
                                    if (data['3'] == true)
                                      const Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Text(
                                            'Miercoles ',
                                            style: TextStyle(fontSize: 15),
                                          ),
                                        ],
                                      ),
                                    if (data['4'] == true)
                                      const Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Text(
                                            'Jueves ',
                                            style: TextStyle(fontSize: 15),
                                          ),
                                        ],
                                      ),
                                    if (data['5'] == true)
                                      const Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Text(
                                            'Viernes',
                                            style: TextStyle(fontSize: 15),
                                          ),
                                        ],
                                      ),
                                  ],
                                ),
                              ),
                              const SizedBox(
                                height: 10,
                              ),
                              Padding(
                                padding:
                                    const EdgeInsets.only(left: 10, right: 10),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        const Text(
                                          'Inicio: ',
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 15),
                                        ),
                                        Text(
                                          '${data['inicio']}',
                                          style: const TextStyle(fontSize: 15),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(
                                      width: 20,
                                    ),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        const Text(
                                          'Salida: ',
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 15),
                                        ),
                                        Text(
                                          '${data['salida']}',
                                          style: const TextStyle(fontSize: 15),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              Divider(
                                height: 10, // The height of the divider
                                thickness: 1, // The thickness of the divider
                                color: Theme.of(context).brightness ==
                                        Brightness.light
                                    ? MyColor.black().color
                                    : MyColor.white()
                                        .color, // The color of the divider
                              ),
                              SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.list_sharp),
                                      onPressed: () {
                                        asistencias(docID);
                                      },
                                      iconSize: 35,
                                      tooltip: 'Asistencias',
                                      color: Theme.of(context).brightness ==
                                              Brightness.light
                                          ? MyColor.black().color
                                          : MyColor.naturalGray().color,
                                      alignment: Alignment.center,
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.group),
                                      onPressed: () {
                                        _pref.listId = docID;
                                        Navigator.pushNamed(
                                            context, ListClass.routname);
                                      },
                                      iconSize: 35,
                                      tooltip: 'Estudiantes',
                                      color: Theme.of(context).brightness ==
                                              Brightness.light
                                          ? MyColor.black().color
                                          : MyColor.naturalGray().color,
                                      alignment: Alignment.center,
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.file_upload),
                                      onPressed: () {
                                        _openfile(docID);
                                      },
                                      iconSize: 35,
                                      tooltip: 'Subir',
                                      color: Theme.of(context).brightness ==
                                              Brightness.light
                                          ? MyColor.black().color
                                          : MyColor.naturalGray().color,
                                      alignment: Alignment.center,
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.cancel),
                                      onPressed: () {
                                        _inasistenciasfile(
                                            docID, data['materia']);
                                      },
                                      iconSize: 35,
                                      tooltip: 'Ausencias',
                                      color: Theme.of(context).brightness ==
                                              Brightness.light
                                          ? MyColor.black().color
                                          : MyColor.naturalGray().color,
                                      alignment: Alignment.center,
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.delete),
                                      onPressed: () {
                                        delete_Materia(docID);
                                      },
                                      iconSize: 35,
                                      tooltip: 'Borrar',
                                      color: Theme.of(context).brightness ==
                                              Brightness.light
                                          ? MyColor.black().color
                                          : MyColor.naturalGray().color,
                                      alignment: Alignment.center,
                                    ),
                                    if (fhoy == data['proxClass'])
                                      IconButton(
                                        icon: const Icon(Icons.qr_code_scanner),
                                        onPressed: () {
                                          _pref.listId = docID;
                                          Navigator.pushNamed(
                                              context, Scanner.routname);
                                        },
                                        iconSize: 35,
                                        tooltip: 'Subir',
                                        color: Theme.of(context).brightness ==
                                                Brightness.light
                                            ? MyColor.black().color
                                            : MyColor.naturalGray().color,
                                        alignment: Alignment.center,
                                      ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          );
        });
  }
}

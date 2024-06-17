// ignore_for_file: use_build_context_synchronously

import 'dart:convert';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:qr_assistant/shared/prefe_users.dart';
import 'package:qr_assistant/style/global_colors.dart';
import 'package:qr_assistant/tools/helper_functions.dart';
import 'package:qr_assistant/tools/loading_indicator.dart';

class Ausencias extends StatefulWidget {
  static const String routname = '/ausencias';
  const Ausencias({super.key});

  @override
  State<Ausencias> createState() => _AusenciasState();
}

class _AusenciasState extends State<Ausencias> {
  final _pref = PreferencesUser();
  int selectedIndex = 1;
  String imageUrl = '';
  List<QueryDocumentSnapshot>? service;
  int rowNumber = 0;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection("AsistenciasProfesores")
            .orderBy('hasistencia', descending: false)
            .where('asistencia', isEqualTo: 'Llego Tarde')
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
            backgroundColor: Theme.of(context).colorScheme.background,
            body: Padding(
              padding: const EdgeInsets.fromLTRB(8, 20, 8, 0),
              child: Column(
                children: [
                  const SizedBox(
                    height: 40,
                  ),
                  ElevatedButton(
                    onPressed: () async {
                      final DocumentSnapshot docenteSnapshot =
                          await FirebaseFirestore.instance
                              .collection('Users')
                              .doc(_pref.uid)
                              .get();

                      if (service != null) {
                        int rowNumber1 = 0;
                        final csvData = [
                          'INASISTENCIAS',
                          'Coordinador: ${docenteSnapshot['nombres']} ${docenteSnapshot['apellidos'].replaceAll(',', ',')}',
                          'Nº,Nombres y Apellidos,Fecha de Inasistencia,Asignatura,Facultad',
                          ...service.asMap().entries.where((entry) {
                            Map<String, dynamic> data =
                                entry.value.data() as Map<String, dynamic>;
                            return data['programa'] != 'Programa';
                          }).map((entry) {
                            Map<String, dynamic> data =
                                entry.value.data() as Map<String, dynamic>;
                            rowNumber1++;
                            return [
                              '$rowNumber1',
                              '${data['nombres'].replaceAll(',', ',')} ${data['apellidos'].replaceAll(',', ',')}',
                              '${data['fasistencia'].replaceAll(',', ',')}',
                              '${data['materia'].replaceAll(',', ',')}',
                              '${data['facultad'].replaceAll(',', ',')}',
                            ].join(',');
                          }),
                        ].join('\n');

                        final now = DateTime.now();
                        final hcreacion = DateFormat('HH:mm:ss').format(now);
                        final fcreacion = DateFormat('dd-MM-yyyy').format(now);

                        final directory = await getExternalStorageDirectory();
                        final appDocumentsDir = Directory(
                            '${directory!.path}/Documents/Inasistencias_QrAssistant');
                        if (!appDocumentsDir.existsSync()) {
                          appDocumentsDir.createSync(recursive: true);
                        }

                        final file = File(
                            '${appDocumentsDir.path}/Inasistencias_${hcreacion}_$fcreacion.csv');
                        await file.writeAsString(csvData, encoding: utf8);

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
                            'Docente',
                            style: TextStyle(
                              fontStyle: FontStyle.italic,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        DataColumn(
                          label: Text(
                            'Fecha de Inasistencia',
                            style: TextStyle(
                              fontStyle: FontStyle.italic,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        DataColumn(
                          label: Text(
                            'Materia',
                            style: TextStyle(
                              fontStyle: FontStyle.italic,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        DataColumn(
                          label: Text(
                            'Facultad',
                            style: TextStyle(
                              fontStyle: FontStyle.italic,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                      rows: service!.asMap().entries.map((entry) {
                        Map<String, dynamic> data =
                            entry.value.data() as Map<String, dynamic>;
                        String docId = entry.value.id;
                        return DataRow(
                          cells: <DataCell>[
                            DataCell(Text('${entry.key + 1}')),
                            DataCell(Text(
                                '${data['nombres']} ${data['apellidos']}')),
                            DataCell(Text('${data['fasistencia']}')),
                            DataCell(Text('${data['materia']}')),
                            DataCell(Text('${data['facultad']}')),
                          ],
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ),
            ),
          );
        });
  }
}

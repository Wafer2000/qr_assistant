import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class Ausencias extends StatefulWidget {
  static const String routname = '/ausencias';
  const Ausencias({super.key});

  @override
  State<Ausencias> createState() => _AusenciasState();
}

class _AusenciasState extends State<Ausencias> {
  int selectedIndex = 1;
  String imageUrl = '';
  List<QueryDocumentSnapshot>? service;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('Inasistencias')
            .orderBy('hllegada', descending: false)
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
                            'Materia',
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
                            'Estudiante',
                            style: TextStyle(
                              fontStyle: FontStyle.italic,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        DataColumn(
                          label: Text(
                            'Codigo Institucional - Estudiante',
                            style: TextStyle(
                              fontStyle: FontStyle.italic,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        DataColumn(
                          label: Text(
                            'Nº de Ausencias',
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
                      rows: service!.asMap().entries.map((entry) {
                        Map<String, dynamic> data =
                            entry.value.data() as Map<String, dynamic>;
                        String docId = entry.value.id;
                        return DataRow(
                          cells: <DataCell>[
                            DataCell(Text('${entry.key + 1}')),
                            DataCell(Text('${data['materia']}')),
                            DataCell(Text('${data['docente']}')),
                            DataCell(Text(
                                '${data['nombres']} ${data['apellidos']}')),
                            DataCell(Text('${data['cinstitucional']}')),
                            DataCell(Text('${data['fallo']}')),
                            DataCell(Text('${data['fllegada']}')),
                            DataCell(Text('${data['hllegada']}')),
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

// ignore_for_file: use_build_context_synchronously, non_constant_identifier_names

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:qr_assistant/tools/helper_functions.dart';
import 'package:qr_assistant/tools/loading_indicator.dart';
import 'package:qr_assistant/tools/my_textfield.dart';
import 'package:qr_assistant/shared/prefe_users.dart';
import 'package:qr_assistant/style/global_colors.dart';

class ListClass extends StatefulWidget {
  static const String routname = '/list_class';
  const ListClass({super.key});

  @override
  State<ListClass> createState() => _ListClassState();
}

class _ListClassState extends State<ListClass> {
  final TextEditingController cedulaController = TextEditingController();
  final TextEditingController cinstitucionalController =
      TextEditingController();
  final _pref = PreferencesUser();

  @override
  void dispose() {
    super.dispose();
  }

  void delete_student(docID) {
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
                        child:
                            Text('Se eliminira este estudiante de tu clase')),
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
                        cedulaController.clear();
                        cinstitucionalController.clear();
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
                            .collection('Estudiantes')
                            .doc(docID)
                            .update({
                          _pref.listId: FieldValue.delete(),
                        });

                        LoadingScreen().hide();
                        Navigator.pop(context);
                        displayMessageToUser(
                            'Estudiante eliminado de la clase', context);
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

  void edit_student(student) {
    showDialog(
      context: context,
      builder: (context) {
        return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
            stream: FirebaseFirestore.instance
                .collection('Estudiantes')
                .doc(student)
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

              TextEditingController cedulaController =
                  TextEditingController(text: user['cedula']);
              final TextEditingController cinstitucionalController =
                  TextEditingController(text: user['cinstitucional']);

              return AlertDialog(
                title: const Text('Llene todos los campos'),
                icon: const Icon(Icons.book),
                shadowColor: MyColor.naturalGray().color,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20)),
                content: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        MyTextField(
                          labelText: 'Cedula',
                          obscureText: false,
                          controller: cedulaController,
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        MyTextField(
                          labelText: 'Codigo Institucional',
                          obscureText: false,
                          controller: cinstitucionalController,
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
                            cedulaController.clear();
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

                            if (cedulaController.text == '') {
                              LoadingScreen().hide();
                              displayMessageToUser(
                                  'Debe colocar la Cedula del Estudiante',
                                  context);
                            } else if (cinstitucionalController.text == '') {
                              LoadingScreen().hide();
                              displayMessageToUser(
                                  'Debe colocar el Codigo Institucional del Estudiante',
                                  context);
                            } else {
                              await FirebaseFirestore.instance
                                  .collection('Estudiantes')
                                  .doc(student)
                                  .update({
                                'cinstitucional': cinstitucionalController.text,
                                'cedula': cedulaController.text,
                              });
                              await FirebaseFirestore.instance
                                  .collection(
                                      'Estudiantes${_pref.ultimateTipe}')
                                  .doc(student)
                                  .set({
                                'cinstitucional': cinstitucionalController.text,
                                'cedula': cedulaController.text,
                              });
                            }
                            cinstitucionalController.clear();
                            cedulaController.clear();
                            LoadingScreen().hide();
                            Navigator.pop(context);
                            displayMessageToUser('Datos Actualizados', context);
                          },
                          child: const Text('Guardar',
                              style: TextStyle(color: Colors.white)),
                        ),
                      ),
                    ],
                  ),
                ],
              );
            });
      },
      barrierDismissible: false,
    );
  }

  void new_student() {
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
                  MyTextField(
                    labelText: 'Codigo Institucional',
                    obscureText: false,
                    controller: cinstitucionalController,
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
                      cinstitucionalController.clear();
                      cedulaController.clear();
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

                      if (cinstitucionalController.text == '') {
                        LoadingScreen().hide();
                        displayMessageToUser(
                            'Debe colocar el Codigo Institucional', context);
                      } else {
                        final DocumentSnapshot studentSnapshot =
                            await FirebaseFirestore.instance
                                .collection('Estudiantes')
                                .doc(cinstitucionalController.text)
                                .get();

                        if (studentSnapshot.exists) {
                          await FirebaseFirestore.instance
                              .collection('Estudiantes')
                              .doc(cinstitucionalController.text)
                              .update({
                            _pref.listId: true,
                          });
                          cinstitucionalController.clear();
                          cedulaController.clear();
                          LoadingScreen().hide();
                          Navigator.pop(context);
                          Navigator.pop(context);
                          displayMessageToUser('Estudiante Agregado', context);
                        } else {
                          cinstitucionalController.clear();
                          cedulaController.clear();
                          LoadingScreen().hide();
                          Navigator.pop(context);
                          Navigator.pop(context);
                          displayMessageToUser(
                              'El estudiante no existe en la base de datos',
                              context);
                        }
                      }
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
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('Estudiantes')
            .where(_pref.listId, isEqualTo: true)
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
                      //new_student();
                    },
                    tooltip: 'Add',
                    alignment: Alignment.center,
                  ),
                ],
                backgroundColor:
                    Theme.of(context).brightness == Brightness.light
                        ? MyColor.wheat().color
                        : MyColor.spectra().color,
              ),
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
              title: const Center(child: Text('Estudiantes de La Materia')),
              backgroundColor: Theme.of(context).brightness == Brightness.light
                  ? MyColor.jungleGreen().color
                  : MyColor.spectra().color,
              actions: [
                IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: () {
                    new_student();
                  },
                  tooltip: 'Add',
                  alignment: Alignment.center,
                ),
              ],
            ),
            backgroundColor: Theme.of(context).colorScheme.background,
            body: ListView.builder(
              itemCount: service?.length,
              itemBuilder: (context, index) {
                DocumentSnapshot document = service![index];
                Map<String, dynamic> data =
                    document.data() as Map<String, dynamic>;
                String docID = document.id;

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
                    child: Stack(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                alignment: Alignment.centerLeft,
                                child: const Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  mainAxisSize:
                                      MainAxisSize.min, // Add this line
                                  children: [
                                    Text(
                                      'Codigo Institucional: ',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 20),
                                      textAlign:
                                          TextAlign.center, // Add this line
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                alignment: Alignment.centerLeft,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  mainAxisSize:
                                      MainAxisSize.min, // Add this line
                                  children: [
                                    Flexible(
                                      child: Text(
                                        '${data['cinstitucional']}',
                                        style: const TextStyle(fontSize: 20),
                                        textAlign:
                                            TextAlign.center, // Add this line
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(
                                height: 10,
                              ),
                              Container(
                                alignment: Alignment.centerLeft,
                                child: const Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  mainAxisSize:
                                      MainAxisSize.min, // Add this line
                                  children: [
                                    Text(
                                      'Cedula: ',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 20),
                                      textAlign:
                                          TextAlign.center, // Add this line
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                alignment: Alignment.centerLeft,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  mainAxisSize:
                                      MainAxisSize.min, // Add this line
                                  children: [
                                    Flexible(
                                      child: Text(
                                        data['cedula'] == ''
                                            ? 'No se le a agregado'
                                            : '${data['cedula']}',
                                        style: const TextStyle(fontSize: 20),
                                        textAlign:
                                            TextAlign.center, // Add this line
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(
                                height: 10,
                              ),
                              Container(
                                alignment: Alignment.centerLeft,
                                child: const Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  mainAxisSize:
                                      MainAxisSize.min, // Add this line
                                  children: [
                                    Text(
                                      'Nombres: ',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 20),
                                      textAlign:
                                          TextAlign.center, // Add this line
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                alignment: Alignment.centerLeft,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  mainAxisSize:
                                      MainAxisSize.min, // Add this line
                                  children: [
                                    Flexible(
                                      child: Text(
                                        '${data['nombres']}',
                                        style: const TextStyle(fontSize: 20),
                                        textAlign:
                                            TextAlign.center, // Add this line
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(
                                height: 10,
                              ),
                              Container(
                                alignment: Alignment.centerLeft,
                                child: const Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  mainAxisSize:
                                      MainAxisSize.min, // Add this line
                                  children: [
                                    Text(
                                      'Apellidos: ',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 20),
                                      textAlign:
                                          TextAlign.center, // Add this line
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                alignment: Alignment.centerLeft,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  mainAxisSize:
                                      MainAxisSize.min, // Add this line
                                  children: [
                                    Flexible(
                                      child: Text(
                                        '${data['apellidos']}',
                                        style: const TextStyle(fontSize: 20),
                                        textAlign:
                                            TextAlign.center, // Add this line
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(
                                height: 10,
                              ),
                              Container(
                                alignment: Alignment.centerLeft,
                                child: const Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  mainAxisSize:
                                      MainAxisSize.min, // Add this line
                                  children: [
                                    Text(
                                      'Correo: ',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 20),
                                      textAlign:
                                          TextAlign.start, // Add this line
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                alignment: Alignment.centerLeft,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  mainAxisSize:
                                      MainAxisSize.min, // Add this line
                                  children: [
                                    Flexible(
                                      child: Text(
                                        '${data['correo']}',
                                        style: const TextStyle(fontSize: 20),
                                        textAlign:
                                            TextAlign.center, // Add this line
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(
                                height: 10,
                              ),
                            ],
                          ),
                        ),
                        Align(
                          alignment: Alignment.bottomRight,
                          child: Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.delete),
                                  onPressed: () {
                                    delete_student(docID);
                                  },
                                  iconSize: 50,
                                  tooltip: 'delete',
                                  color: Theme.of(context).brightness ==
                                          Brightness.light
                                      ? MyColor.wheat().color
                                      : MyColor.spectra().color,
                                ),
                                IconButton(
                                  icon: const Icon(Icons.edit),
                                  onPressed: () {
                                    edit_student(docID);
                                  },
                                  iconSize: 50,
                                  tooltip: 'edit',
                                  color: Theme.of(context).brightness ==
                                          Brightness.light
                                      ? MyColor.wheat().color
                                      : MyColor.spectra().color,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          );
        });
  }
}

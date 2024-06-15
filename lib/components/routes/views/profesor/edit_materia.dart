// ignore_for_file: use_build_context_synchronously

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:qr_assistant/components/routes/tools/helper_functions.dart';
import 'package:qr_assistant/components/routes/tools/loading_indicator.dart';
import 'package:qr_assistant/components/routes/tools/my_textfield.dart';
import 'package:qr_assistant/shared/prefe_users.dart';
import 'package:qr_assistant/style/global_colors.dart';

class EditMateria extends StatefulWidget {
  static const String routname = '/edit_materia';
  const EditMateria({super.key});

  @override
  State<EditMateria> createState() => _EditMateriaState();
}

class _EditMateriaState extends State<EditMateria> {
  final _pref = PreferencesUser();
  TextEditingController inicioController = TextEditingController();
  TextEditingController materiaController = TextEditingController();
  TextEditingController salidaController = TextEditingController();
  bool _lunes = false;
  bool _martes = false;
  bool _miercoles = false;
  bool _jueves = false;
  bool _viernes = false;

  @override
  void initState() {
    super.initState();
    Materia();
  }

  Future<void> Materia() async {
    final DocumentSnapshot materiaSnapshot = await FirebaseFirestore.instance
        .collection('Materias${_pref.ultimateUid}')
        .doc(_pref.subjectId)
        .get();

    if (mounted) {
      setState(() {
        inicioController =
            TextEditingController(text: materiaSnapshot['inicio']);
        materiaController =
            TextEditingController(text: materiaSnapshot['materia']);
        salidaController =
            TextEditingController(text: materiaSnapshot['salida']);
        _lunes = materiaSnapshot['1'];
        _martes = materiaSnapshot['2'];
        _miercoles = materiaSnapshot['3'];
        _jueves = materiaSnapshot['4'];
        _viernes = materiaSnapshot['5'];
      });
    }
  }

  @override
  void dispose() {
    inicioController.dispose();
    materiaController.dispose();
    salidaController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        title: const Center(child: Text('Materias')),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {},
            tooltip: 'Add',
            alignment: Alignment.center,
          ),
        ],
        backgroundColor: Theme.of(context).brightness == Brightness.light
            ? MyColor.jungleGreen().color
            : MyColor.spectra().color,
      ),
      backgroundColor: Theme.of(context).colorScheme.background,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            mainAxisSize: MainAxisSize.min,
            children: [
              MyTextField(
                labelText: 'Nombre de Materia',
                obscureText: false,
                controller: materiaController,
              ),
              const SizedBox(
                height: 10,
              ),
              Container(
                decoration: BoxDecoration(
                    border: Border.all(
                      width: 1,
                      color: Theme.of(context).brightness == Brightness.light
                          ? MyColor.black().color
                          : MyColor.white().color,
                    ),
                    borderRadius: BorderRadius.circular(12)),
                padding: const EdgeInsets.all(25),
                child: Column(
                  children: [
                    const Text('¿Que dias a la semana esta dando tal clase?'),
                    const SizedBox(
                      height: 10,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              _lunes = !_lunes;
                            });
                          },
                          child: CircleAvatar(
                            radius: 20,
                            backgroundColor: _lunes ? Colors.blue : Colors.grey,
                            child: const Text('L',
                                style: TextStyle(
                                    fontSize: 18, fontWeight: FontWeight.bold)),
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              _martes = !_martes;
                            });
                          },
                          child: CircleAvatar(
                            radius: 20,
                            backgroundColor:
                                _martes ? Colors.blue : Colors.grey,
                            child: const Text('Ma',
                                style: TextStyle(
                                    fontSize: 18, fontWeight: FontWeight.bold)),
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              _miercoles = !_miercoles;
                            });
                          },
                          child: CircleAvatar(
                            radius: 20,
                            backgroundColor:
                                _miercoles ? Colors.blue : Colors.grey,
                            child: const Text('Mi',
                                style: TextStyle(
                                    fontSize: 18, fontWeight: FontWeight.bold)),
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              _jueves = !_jueves;
                            });
                          },
                          child: CircleAvatar(
                            radius: 20,
                            backgroundColor:
                                _jueves ? Colors.blue : Colors.grey,
                            child: const Text('J',
                                style: TextStyle(
                                    fontSize: 18, fontWeight: FontWeight.bold)),
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              _viernes = !_viernes;
                            });
                          },
                          child: CircleAvatar(
                            radius: 20,
                            backgroundColor:
                                _viernes ? Colors.blue : Colors.grey,
                            child: const Text('V',
                                style: TextStyle(
                                    fontSize: 18, fontWeight: FontWeight.bold)),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              TextField(
                controller: inicioController,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12)),
                  labelText: 'Inicio de Clases',
                  floatingLabelStyle: TextStyle(
                      color: Theme.of(context).brightness == Brightness.light
                          ? MyColor.deYork().color
                          : MyColor.jungleGreen().color),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: Theme.of(context).brightness == Brightness.light
                          ? MyColor.deYork().color
                          : MyColor.jungleGreen().color,
                    ),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  labelStyle: TextStyle(
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                onTap: () async {
                  var time = await showTimePicker(
                      context: context, initialTime: TimeOfDay.now());
                  if (time != null && mounted) {
                    setState(() {
                      inicioController.text = time.format(context);
                    });
                  }
                },
                obscureText: false,
              ),
              const SizedBox(
                height: 10,
              ),
              TextField(
                controller: salidaController,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12)),
                  labelText: 'Salida de Clases',
                  floatingLabelStyle: TextStyle(
                      color: Theme.of(context).brightness == Brightness.light
                          ? MyColor.deYork().color
                          : MyColor.jungleGreen().color),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: Theme.of(context).brightness == Brightness.light
                          ? MyColor.deYork().color
                          : MyColor.jungleGreen().color,
                    ),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  labelStyle: TextStyle(
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                onTap: () async {
                  var time = await showTimePicker(
                      context: context, initialTime: TimeOfDay.now());
                  if (time != null) {
                    setState(() {
                      salidaController.text = time.format(context);
                    });
                  }
                },
                obscureText: false,
              ),
              const SizedBox(
                height: 10,
              ),
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

                        final now = DateTime.now();
                        final hcreacion = DateFormat('HH:mm:ss').format(now);
                        final fcreacion = DateFormat('dd/MM/yyyy').format(now);

                        if (materiaController.text == '') {
                          LoadingScreen().hide();
                          displayMessageToUser(
                              'Debe colocar el nombre a su materia', context);
                        } else if (inicioController.text == '') {
                          LoadingScreen().hide();
                          displayMessageToUser(
                              'Debe colocar la hora de entrada', context);
                        } else if (salidaController.text == '') {
                          LoadingScreen().hide();
                          displayMessageToUser(
                              'Debe colocar la hora de salida', context);
                        } else {
                          final DocumentSnapshot documentSnapshot =
                              await FirebaseFirestore.instance
                                  .collection('Users')
                                  .doc(_pref.ultimateUid)
                                  .get();

                          String name = documentSnapshot['nombres'];
                          String apellidos = documentSnapshot['apellidos'];

                          await FirebaseFirestore.instance
                              .collection('Materias${_pref.ultimateUid}')
                              .doc(_pref.subjectId)
                              .set({
                            'profesor': _pref.ultimateUid,
                            'nombres': name,
                            'apellidos': apellidos,
                            'materia': materiaController.text,
                            '1': _lunes,
                            '2': _martes,
                            '3': _miercoles,
                            '4': _jueves,
                            '5': _viernes,
                            'inicio': inicioController.text,
                            'salida': salidaController.text,
                            'fcreacion': hcreacion,
                            'hcreacion': fcreacion,
                          });
                        }
                        displayMessageToUser('Datos Guardados', context);
                        materiaController.clear();
                        inicioController.clear();
                        salidaController.clear();
                        LoadingScreen().hide();
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
          ),
        ),
      ),
    );
  }
}

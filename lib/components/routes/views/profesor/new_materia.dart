// ignore_for_file: use_build_context_synchronously

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:qr_assistant/components/routes/views/profesor/materias.dart';
import 'package:qr_assistant/tools/helper_functions.dart';
import 'package:qr_assistant/tools/loading_indicator.dart';
import 'package:qr_assistant/tools/my_textfield.dart';
import 'package:qr_assistant/shared/prefe_users.dart';
import 'package:qr_assistant/style/global_colors.dart';

class NewMateria extends StatefulWidget {
  static const String routname = '/new_materia';
  const NewMateria({super.key});

  @override
  State<NewMateria> createState() => _NewMateriaState();
}

class _NewMateriaState extends State<NewMateria> {
  final TextEditingController materiaController = TextEditingController();
  final TextEditingController inicioController = TextEditingController();
  final TextEditingController salidaController = TextEditingController();
  final TextEditingController weekController = TextEditingController();
  final _pref = PreferencesUser();
  bool _lunes = false;
  bool _martes = false;
  bool _miercoles = false;
  bool _jueves = false;
  bool _viernes = false;
  bool _sabado = false;
  bool _domingo = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        title: const Center(child: Text('Crear Materias')),
        actions: const [
          SizedBox(
            width: 56,
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
                            backgroundColor:
                                _lunes ? MyColor.deYork().color : Colors.grey,
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
                                _martes ? MyColor.deYork().color : Colors.grey,
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
                            backgroundColor: _miercoles
                                ? MyColor.deYork().color
                                : Colors.grey,
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
                                _jueves ? MyColor.deYork().color : Colors.grey,
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
                                _viernes ? MyColor.deYork().color : Colors.grey,
                            child: const Text('V',
                                style: TextStyle(
                                    fontSize: 18, fontWeight: FontWeight.bold)),
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              _sabado = !_sabado;
                            });
                          },
                          child: CircleAvatar(
                            radius: 20,
                            backgroundColor:
                                _sabado ? MyColor.deYork().color : Colors.grey,
                            child: const Text('S',
                                style: TextStyle(
                                    fontSize: 18, fontWeight: FontWeight.bold)),
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              _domingo = !_domingo;
                            });
                          },
                          child: CircleAvatar(
                            radius: 20,
                            backgroundColor:
                                _domingo ? MyColor.deYork().color : Colors.grey,
                            child: const Text('D',
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
                height: 40,
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
                        weekController.clear();
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
                                  .doc(_pref.uid)
                                  .get();

                          String name = documentSnapshot['nombres'];
                          String apellidos = documentSnapshot['apellidos'];

                          DateTime proximoDiaClase = now;
                          List<int> diasSeleccionados = [];

                          if (_lunes) diasSeleccionados.add(DateTime.monday);
                          if (_martes) diasSeleccionados.add(DateTime.tuesday);
                          if (_miercoles) {
                            diasSeleccionados.add(DateTime.wednesday);
                          }
                          if (_jueves) diasSeleccionados.add(DateTime.thursday);
                          if (_viernes) diasSeleccionados.add(DateTime.friday);
                          if (_sabado) diasSeleccionados.add(DateTime.saturday);
                          if (_domingo) diasSeleccionados.add(DateTime.sunday);

                          while (true) {
                            bool encontrado = false;
                            for (int dia in diasSeleccionados) {
                              if (proximoDiaClase.weekday == dia) {
                                encontrado = true;
                                break;
                              }
                            }
                            if (encontrado) break;
                            proximoDiaClase =
                                proximoDiaClase.add(const Duration(days: 1));
                          }

                          String proxClass =
                              DateFormat('dd/MM/yyyy').format(proximoDiaClase);

                          await FirebaseFirestore.instance
                              .collection('Materias${_pref.uid}')
                              .doc()
                              .set({
                            'profesor': _pref.uid,
                            'nombres': name,
                            'apellidos': apellidos,
                            'materia': materiaController.text,
                            '1': _lunes,
                            '2': _martes,
                            '3': _miercoles,
                            '4': _jueves,
                            '5': _viernes,
                            '6': _sabado,
                            '7': _domingo,
                            'numStu': 0,
                            'proxClass': proxClass,
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
                        Navigator.pushNamed(context, Materias.routname);
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

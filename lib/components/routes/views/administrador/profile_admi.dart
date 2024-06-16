// ignore_for_file: avoid_print, use_build_context_synchronously, unused_element

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:qr_assistant/components/routes/log/login.dart';
import 'package:qr_assistant/tools/loading_indicator.dart';
import 'package:qr_assistant/components/routes/views/administrador/guard/extra_data_admi.dart';
import 'package:qr_assistant/shared/prefe_users.dart';
import 'package:qr_assistant/style/global_colors.dart';

class ProfileAdmi extends StatefulWidget {
  static const String routname = '/profile_admi';
  const ProfileAdmi({super.key});

  @override
  State<ProfileAdmi> createState() => _ProfileAdmiState();
}

class _ProfileAdmiState extends State<ProfileAdmi> {
  final _pref = PreferencesUser();

  @override
  void initState() {
    super.initState();
  }

  Future<void> _signOut() async {
    var pref = PreferencesUser();
    LoadingScreen().show(context);

    try {
      await FirebaseAuth.instance.signOut();
      pref.uid = '';
      LoadingScreen().hide();
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const Login()),
      );
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Theme.of(context).colorScheme.background,
        body: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
          stream: FirebaseFirestore.instance
              .collection('Users')
              .doc(_pref.uid)
              .snapshots(),
          builder: (context, snapshot) {
            String imageUrl = '';
            if (snapshot.hasError) {
              return const AlertDialog(
                title: Text('Algo salio mal'),
              );
            }
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(
                child: CircularProgressIndicator(
                  color: Theme.of(context).colorScheme.primary,
                ),
              );
            }
            if (snapshot.data == null) {
              return const Text('No hay datos');
            }
            final user = snapshot.data!;

            int edadf = 0;

            if (user['fnacimiento'] != '') {
              final DateFormat formatter = DateFormat('dd/MM/yyyy');
              final DateTime fechaNacimiento =
                  formatter.parse(user['fnacimiento']);
              final DateTime now = DateTime.now();
              final int years = now.year - fechaNacimiento.year;
              int edad;
              if (now.month < fechaNacimiento.month ||
                  (now.month == fechaNacimiento.month &&
                      now.day < fechaNacimiento.day)) {
                edad = years - 1;
              } else {
                edad = years;
              }
              edadf = edad;
            }

            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    children: [
                      const SizedBox(
                        height: 25,
                      ),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(200),
                        child: Image.network(
                          user['fperfil'] == '' ? imageUrl : user['fperfil'],
                          fit: BoxFit.cover,
                          width: 250,
                          height: 250,
                          errorBuilder: (context, error, stackTrace) {
                            return IconButton(
                              highlightColor: Colors.transparent,
                              onPressed: () {},
                              icon: Image.asset(
                                'assets/user.png',
                                width: 121.8,
                                height: 121.8,
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(
                        height: 25,
                      ),
                      Text(
                        '${user['nombres'].split(' ')[0]} ${user['apellidos'].split(' ')[0]}',
                        style: const TextStyle(
                            fontSize: 24, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        user['email'],
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                      const SizedBox(
                        height: 30,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            'Celular: ',
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 20),
                          ),
                          Text(
                            '${user['celular']}',
                            style: const TextStyle(fontSize: 20),
                          ),
                        ],
                      ),
                      const SizedBox(
                        height: 5,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            'Edad: ',
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 20),
                          ),
                          Text(
                            edadf == 0
                                ? 'Dato vacio'
                                : '${edadf.toString()} Años',
                            style: const TextStyle(fontSize: 20),
                          ),
                        ],
                      ),
                      const SizedBox(
                        height: 5,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            'Sexo: ',
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 20),
                          ),
                          Text(
                            '${user['sexo']}',
                            style: const TextStyle(fontSize: 20),
                          ),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            'Sexo: ',
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 20),
                          ),
                          Text(
                            '${user['sexo']}',
                            style: const TextStyle(fontSize: 20),
                          ),
                        ],
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
                                _signOut();
                              },
                              child: const Text('Cerrar Sesion',
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
                              onPressed: () {
                                Navigator.pushNamed(
                                    context, ExtraDataAdmi.routname);
                              },
                              child: const Text('Editar Perfil',
                                  style: TextStyle(color: Colors.white)),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        ));
  }
}

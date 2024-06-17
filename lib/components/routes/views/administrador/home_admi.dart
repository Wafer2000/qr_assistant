// ignore_for_file: library_private_types_in_public_api

import 'package:animate_do/animate_do.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:qr_assistant/components/routes/views/administrador/profile_admi.dart';
import 'package:qr_assistant/components/routes/views/administrador/services/ausencias.dart';
import 'package:qr_assistant/components/routes/views/administrador/services/num_inasistencias.dart';
import 'package:qr_assistant/shared/prefe_users.dart';
import 'package:qr_assistant/style/global_colors.dart';

class HomeAdmi extends StatefulWidget {
  static const String routname = '/home_admi';
  const HomeAdmi({super.key});

  @override
  State<HomeAdmi> createState() => _HomeAdmiState();
}

class _HomeAdmiState extends State<HomeAdmi> {
  final _pref = PreferencesUser();
  int selectedIndex = 1;
  String imageUrl = '';

  @override
  Widget build(BuildContext context) {
    final screens = [
      const Ausencias(),
      const ProfileAdmi(),
      const NumInasistencias(),
    ];
    return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
        stream: FirebaseFirestore.instance
            .collection('Users')
            .doc(_pref.uid)
            .snapshots(),
        builder: (context, snapshot) {
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
          return Scaffold(
            body: FadeIn(
              child: IndexedStack(
                index: selectedIndex,
                children: screens,
              ),
            ),
            bottomNavigationBar: BottomNavigationBar(
              currentIndex: selectedIndex,
              type: BottomNavigationBarType.shifting,
              backgroundColor: Theme.of(context).brightness == Brightness.light
                  ? MyColor.jungleGreen().color
                  : MyColor.spectra().color,
              onTap: (value) {
                setState(() {
                  selectedIndex = value;
                });
              },
              elevation: 0,
              items: [
                BottomNavigationBarItem(
                  icon: const Icon(Icons.person_off),
                  label: 'Ausencias',
                  backgroundColor:
                      Theme.of(context).brightness == Brightness.light
                          ? MyColor.jungleGreen().color
                          : MyColor.spectra().color,
                ),
                BottomNavigationBarItem(
                  icon: ClipRRect(
                    borderRadius: BorderRadius.circular(200),
                    child: Image.network(
                      user['fperfil'] == '' ? imageUrl : user['fperfil'],
                      width: 24,
                      height: 24,
                      errorBuilder: (context, error, stackTrace) {
                        return IconButton(
                          highlightColor: Colors.transparent,
                          onPressed: () {},
                          icon: Image.asset(
                            'assets/user.png',
                            width: 24,
                            height: 24,
                          ),
                        );
                      },
                    ),
                  ),
                  label: 'Perfil',
                  backgroundColor:
                      Theme.of(context).brightness == Brightness.light
                          ? MyColor.jungleGreen().color
                          : MyColor.spectra().color,
                ),
                BottomNavigationBarItem(
                  icon: const Icon(Icons.remove_circle),
                  label: 'Nº Insistencias',
                  backgroundColor:
                      Theme.of(context).brightness == Brightness.light
                          ? MyColor.jungleGreen().color
                          : MyColor.spectra().color,
                ),
              ],
            ),
          );
        });
  }
}

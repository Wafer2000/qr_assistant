// ignore_for_file: use_build_context_synchronously, avoid_print

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:qr_assistant/components/routes/log/login.dart';
import 'package:qr_assistant/tools/loading_indicator.dart';
import 'package:qr_assistant/components/routes/views/home.dart';
import 'package:qr_assistant/components/routes/views/estudiante/profile_estudiante.dart';
import 'package:qr_assistant/components/routes/views/scanner.dart';
import 'package:qr_assistant/components/routes/views/profesor/materias.dart';
import 'package:qr_assistant/components/routes/views/profesor/profile_profesor.dart';
import 'package:qr_assistant/shared/prefe_users.dart';

class MyDrawer extends StatefulWidget {
  const MyDrawer({super.key});

  @override
  State<MyDrawer> createState() => _MyDrawerState();
}

class _MyDrawerState extends State<MyDrawer> {
  final pref = PreferencesUser();

  final TextEditingController _textController = TextEditingController();

  

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
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
final dayOfWeek = now.weekday;
print(dayOfWeek);
    return Drawer(
      backgroundColor: Theme.of(context).colorScheme.background,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            children: [
              DrawerHeader(
                child: Image.asset(
                  'assets/profile.png',
                  fit: BoxFit.cover,
                ),
              ),
              /*Padding(
                padding: const EdgeInsets.only(left: 25.0),
                child: ListTile(
                  leading: Icon(
                    Icons.qr_code_scanner,
                    color: Theme.of(context).colorScheme.inversePrimary,
                  ),
                  title: const Text('E S C A N E R'),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.pushNamed(context, Scanner.routname);
                  },
                ),
              ),*/
              if (pref.ultimateTipe == 'Estudiante')
                Padding(
                  padding: const EdgeInsets.only(left: 25.0),
                  child: ListTile(
                    leading: Icon(
                      Icons.person,
                      color: Theme.of(context).colorScheme.inversePrimary,
                    ),
                    title: const Text('P E R F I L'),
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.pushNamed(context, ProfileEstudiante.routname);
                    },
                  ),
                ),
              if (pref.ultimateTipe == 'Profesor')
                Padding(
                  padding: const EdgeInsets.only(left: 25.0),
                  child: ListTile(
                    leading: Icon(
                      Icons.book,
                      color: Theme.of(context).colorScheme.inversePrimary,
                    ),
                    title: const Text('M A T E R I A S'),
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.pushNamed(context, Materias.routname);
                    },
                  ),
                ),
              if (pref.ultimateTipe == 'Profesor')
                Padding(
                  padding: const EdgeInsets.only(left: 25.0),
                  child: ListTile(
                    leading: Icon(
                      Icons.person,
                      color: Theme.of(context).colorScheme.inversePrimary,
                    ),
                    title: const Text('P E R F I L'),
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.pushNamed(context, ProfileProfesor.routname);
                    },
                  ),
                ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(left: 25.0, bottom: 25),
            child: ListTile(
              leading: Icon(
                Icons.exit_to_app,
                color: Theme.of(context).colorScheme.inversePrimary,
              ),
              title: const Text('C E R R A R  S E S I O N'),
              onTap: () {
                _signOut();
              },
            ),
          )
        ],
      ),
    );
  }
}

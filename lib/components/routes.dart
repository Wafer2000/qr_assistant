// ignore_for_file: unnecessary_null_comparison


import 'package:flutter/material.dart';
import 'package:qr_assistant/components/routes/log/login.dart';
import 'package:qr_assistant/components/routes/log/register.dart';
import 'package:qr_assistant/components/routes/log/register_uni.dart';
import 'package:qr_assistant/components/routes/views/administrador/guard/extra_data_admi.dart';
import 'package:qr_assistant/components/routes/views/administrador/home_admi.dart';
import 'package:qr_assistant/components/routes/views/administrador/services/ausencias.dart';
import 'package:qr_assistant/components/routes/views/administrador/services/num_inasistencias.dart';
import 'package:qr_assistant/components/routes/views/estudiante/guard/extra_data_estudiante.dart';
import 'package:qr_assistant/components/routes/views/home.dart';
import 'package:qr_assistant/components/routes/views/estudiante/profile_estudiante.dart';
import 'package:qr_assistant/components/routes/views/scanner.dart';
import 'package:qr_assistant/components/routes/views/profesor/edit_materia.dart';
import 'package:qr_assistant/components/routes/views/profesor/list_class.dart';
import 'package:qr_assistant/components/routes/views/profesor/materias.dart';
import 'package:qr_assistant/components/routes/views/profesor/new_materia.dart';
import 'package:qr_assistant/components/splash_view.dart';
import 'package:qr_assistant/shared/prefe_users.dart';
import 'package:qr_assistant/style/theme/dark.dart';
import 'package:qr_assistant/style/theme/light.dart';
import 'routes/views/profesor/guard/extra_data_profesor.dart';
import 'routes/views/profesor/profile_profesor.dart';

class Routes extends StatefulWidget {
  const Routes({super.key});

  @override
  State<Routes> createState() => _RoutesState();
}

class _RoutesState extends State<Routes> {
  final prefs = PreferencesUser();
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: SplashView.routname,
      routes: {
        Home.routname: (context) => const Home(),
        Login.routname: (context) => const Login(),
        Scanner.routname: (context) => const Scanner(),
        HomeAdmi.routname: (context) => const HomeAdmi(),
        Register.routname: (context) => const Register(),
        Materias.routname: (context) => const Materias(),
        ListClass.routname: (context) => const ListClass(),
        Ausencias.routname: (context) => const Ausencias(),
        NewMateria.routname: (context) => const NewMateria(),
        SplashView.routname: (context) => const SplashView(),
        RegisterUni.routname: (context) => const RegisterUni(),
        EditMateria.routname: (context) => const EditMateria(),
        ExtraDataAdmi.routname: (context) => const ExtraDataAdmi(),
        ProfileProfesor.routname: (context) => const ProfileProfesor(),
        NumInasistencias.routname: (context) => const NumInasistencias(),
        ProfileEstudiante.routname: (context) => const ProfileEstudiante(),
        ExtraDataProfesor.routname: (context) => const ExtraDataProfesor(),
        ExtraDataEstudiante.routname: (context) => const ExtraDataEstudiante(),
      },
      theme: lightMode,
      darkTheme: darkMode,
    );
  }
}
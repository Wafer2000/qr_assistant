import 'package:flutter/material.dart';
import 'package:qr_assistant/components/routes/views/administrador/profile_admi.dart';
import 'package:qr_assistant/style/global_colors.dart';

class HomeAdmi extends StatefulWidget {
  static const String routname = '/home_admi';
  const HomeAdmi({super.key});

  @override
  State<HomeAdmi> createState() => _HomeAdmiState();
}

class _HomeAdmiState extends State<HomeAdmi> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        title: const Center(child: Text('Inicio')),
        backgroundColor: Theme.of(context).brightness == Brightness.light
            ? MyColor.jungleGreen().color
            : MyColor.spectra().color,
      ),
      body: const Center(
        child: Text('Home Admi'),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, ProfileAdmi.routname);
        },
        tooltip: 'Perfil',
        shape: const CircleBorder(),
        backgroundColor: Theme.of(context).brightness == Brightness.light
            ? MyColor.jungleGreen().color
            : MyColor.spectra().color,
        child: const Icon(Icons.person),
      ),
    );
  }
}

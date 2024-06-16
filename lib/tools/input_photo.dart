// ignore_for_file: use_build_context_synchronously, unused_element, unused_local_variable, unnecessary_null_comparison, avoid_print

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:file_picker/file_picker.dart';
import 'package:qr_assistant/shared/prefe_users.dart';
import 'package:qr_assistant/style/global_colors.dart';

class InputFotoPerfil extends StatefulWidget {
  const InputFotoPerfil({
    super.key,
  });

  @override
  State<InputFotoPerfil> createState() => _InputFotoPerfilState();
}

class _InputFotoPerfilState extends State<InputFotoPerfil> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String _imageUrl = '';
  PlatformFile? _pickedFile;
  UploadTask? _uploadTask;
  final _pref = PreferencesUser();

  @override
  void initState() {
    super.initState();
    _getImageUrl();
  }

  Future _getImageUrl() async {
    final DocumentSnapshot documentSnapshot = await FirebaseFirestore.instance
        .collection('Users')
        .doc(_pref.uid)
        .get();

    setState(() {
      _imageUrl = documentSnapshot['fperfil'];
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future uploadFile() async {
    setState(() {});

    final path = 'Fotos de Perfil/${_pref.uid}/Foto de Perfil';
    final file = File(_pickedFile!.path!);
    final ref = FirebaseStorage.instance.ref().child(path);

    final metadata = SettableMetadata(contentType: 'image/jpeg');

    setState(() {
      _uploadTask = ref.putFile(file, metadata);
    });

    final snapshot = await _uploadTask!.whenComplete(() {});

    final urlDowload = await snapshot.ref.getDownloadURL();
    print('Dowload link: $urlDowload');

    if (urlDowload != null) {
      final result =
          _firestore.collection('Users').doc(_pref.uid).update({
        'fperfil': urlDowload,
      });

      if (result != null) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Se subio correctamente la imagen'),
          duration: Duration(seconds: 1),
        ));
        setState(() {
          _imageUrl = urlDowload;
        });
      } else {
        setState(() {});
        Future.delayed(const Duration(seconds: 1), () {
          setState(() {});
        });
      }
    }
    setState(() {
      _uploadTask = null;
    });
  }

  Future<void> _selectFile([DocumentSnapshot? documentSnapshot]) async {
    final result = await FilePicker.platform.pickFiles();
    if (result == null) return;

    if (result.files.single.path != null &&
        // ignore: unnecessary_cast
        (result.files.single.path! as String).endsWith('.svg')) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No se permiten archivos SVG'),
          backgroundColor: Colors.red,
        ),
      );
      Navigator.of(context).pop();
      return;
    }

    setState(() {
      _pickedFile = result.files.first;
    });

    uploadFile();
  }

  Future<void> _deleteImage() async {
    final path = 'Fotos de Perfil/${_pref.uid}/Foto de Perfil';
    final ref = FirebaseStorage.instance.ref().child(path);
    await ref.delete();

    final firestore = FirebaseFirestore.instance;
    await firestore.collection('Users').doc(_pref.uid).update({
      'fperfil': '',
    });

    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
      content: Text('Se elimino correctamente la imagen'),
      duration: Duration(seconds: 1),
    ));

    setState(() {
      _pickedFile = null;
      _imageUrl = '';
    });
  }

  @override
  Widget build(BuildContext context) {
    var prefs = PreferencesUser();

    return Column(
      children: [
        InkWell(
          onTap: () async {
            _selectFile();
          },
          child: Stack(
            alignment: Alignment.center,
            children: [
              _pickedFile != null
                  ? SizedBox(
                      width: 250,
                      height: 250,
                      child: CircleAvatar(
                        backgroundImage: FileImage(File(_pickedFile!.path!)),
                        radius: 15,
                      ),
                    )
                  : ClipRRect(
                      borderRadius: BorderRadius.circular(200),
                      child: Image.network(
                        _imageUrl,
                        width: 250,
                        height: 250,
                        errorBuilder: (context, error, stackTrace) {
                          return const Icon(
                            Icons.account_circle,
                            size: 80,
                          );
                        },
                      ),
                    ),
              Positioned(
                child: Container(
                  width: 250,
                  height: 250,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color:
                        const Color.fromARGB(19, 70, 70, 70).withOpacity(0.7),
                  ),
                  child: IconButton(
                    iconSize: 60,
                    icon: Icon(
                      _imageUrl != '' ? Icons.delete : Icons.edit,
                      color: Theme.of(context).brightness == Brightness.light
                          ? MyColor.deYork().color
                          : MyColor.jungleGreen().color,
                    ),
                    onPressed: () {
                      if (_imageUrl != '') {
                        _deleteImage();
                      } else {
                        _selectFile();
                      }
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

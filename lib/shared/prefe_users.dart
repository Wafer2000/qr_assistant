import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:qr_assistant/firebase/firebase_options.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PreferencesUser {
  static late SharedPreferences _prefs;

  static Future init() async {
    WidgetsFlutterBinding.ensureInitialized();
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    _prefs = await SharedPreferences.getInstance();
  }

  String get ultimateUid {
    return _prefs.getString('ultimateUid') ?? '';
  }

  set ultimateUid(String value) {
    _prefs.setString('ultimateUid', value);
  }

  String get ultimateTipe {
    return _prefs.getString('ultimateTipe') ?? '';
  }

  set ultimateTipe(String value) {
    _prefs.setString('ultimateTipe', value);
  }

  String get listId {
    return _prefs.getString('listId') ?? '';
  }

  set listId(String value) {
    _prefs.setString('listId', value);
  }

  String get subjectId {
    return _prefs.getString('subjectId') ?? '';
  }

  set subjectId(String value) {
    _prefs.setString('subjectId', value);
  }
}
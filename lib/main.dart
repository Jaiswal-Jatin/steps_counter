import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:steps_counter_app/src/app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const StepGoApp());
}

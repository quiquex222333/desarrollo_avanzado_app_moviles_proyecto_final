import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/services.dart';
import 'firebase_dev_options.dart' as dev;
import 'firebase_prod_options.dart' as prod;

Future<void> initializeFirebaseApp() async {
  final firebaseOptions = switch (appFlavor) {
    'prod' => prod.DefaultFirebaseOptions.currentPlatform,
    'dev' => dev.DefaultFirebaseOptions.currentPlatform,
    _ => throw UnsupportedError('Invalid flavor: $appFlavor'),
  };
  await Firebase.initializeApp(options: firebaseOptions);
}
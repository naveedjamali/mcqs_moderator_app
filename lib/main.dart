import 'dart:io';

import 'package:flutter/material.dart';
import 'package:mcqs_moderator_app/widgets/homepage.dart';
import 'package:window_manager/window_manager.dart';

void main()async {
  WidgetsFlutterBinding.ensureInitialized();
  await windowManager.ensureInitialized();
  if (Platform.isWindows) {
    WindowManager.instance.setMinimumSize(const Size(1200, 800));
  }
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Examiter MCQs Moderator',
      theme: ThemeData(

        colorScheme: ColorScheme.fromSeed(seedColor: Colors.purple),
        useMaterial3: true,
      ),
      home: const Homepage(),
    );
  }
}

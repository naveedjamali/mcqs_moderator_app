import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:mcqs_moderator_app/widgets/homepage.dart';
import 'package:window_manager/window_manager.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (!kIsWeb) {
    if (Platform.isWindows) {
      await windowManager.ensureInitialized();
      WindowManager.instance.setMinimumSize(const Size(1200, 800));
    }
  }
  await Supabase.initialize(
    url: 'https://fnqsxdzlbfaejgfoyvan.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImZucXN4ZHpsYmZhZWpnZm95dmFuIiwicm9sZSI6ImFub24iLCJpYXQiOjE3Mjk2OTA2NDIsImV4cCI6MjA0NTI2NjY0Mn0.09ndI5Tl-obEMO6nLuEPZEB7Xi90VjNTmFJD1NQFSfM',
  );

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
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
        useMaterial3: true,
      ),
      home: const Homepage(),
    );
  }
}

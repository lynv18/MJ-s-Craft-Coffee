import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'screens/welcome_screen.dart'; // <-- I-import ang WelcomeScreen

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://mlvoucophtkogulvwbnw.supabase.co',
    anonKey: 'sb_publishable_3LRGGfbj-KG0_v67AMLwiA_UvLISijH',
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'MJ\'s Craft Coffee',
      theme: ThemeData(
        brightness: Brightness.dark,
        primarySwatch: Colors.brown,
      ),
      home: const WelcomeScreen(), // <-- Dito magsisimula ang app
    );
  }
}
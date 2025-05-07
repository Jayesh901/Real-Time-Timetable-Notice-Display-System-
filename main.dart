import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:supabase/supabase.dart';  // For Supabase integration
import 'package:supabase_flutter/supabase_flutter.dart';
import 'screens/home_screen.dart';
import 'screens/signup_screen.dart';
import 'screens/notice_upload_screen.dart';
import 'screens/timetable_form_screen.dart';
import 'screens/login_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await Supabase.initialize(url: 'https://whxapfzbyveacqdpzbor.supabase.co',
      anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6IndoeGFwZnpieXZlYWNxZHB6Ym9yIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDQ4MjY0MzksImV4cCI6MjA2MDQwMjQzOX0.OSpJuuVZUqGXhxqtDGILi1KC4-Uld6SvrGp-Mi_wWhw');
  runApp(const CollegeAdminApp());
}

class CollegeAdminApp extends StatelessWidget {
  const CollegeAdminApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'College Admin App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.deepPurple),
      initialRoute: '/login',
      routes: {
        '/home': (context) => const HomeScreen(),
        '/signup': (context) => const SignupScreen(),
        '/login': (context) => const LoginScreen(),
        '/notice': (context) => const NoticeUploadScreen(),
        '/timetable': (context) => const TimetableFormPage(),
      },
    );
  }
}



















/*import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'screens/home_screen.dart';
import 'screens/signup_screen.dart';
import 'screens/notice_upload_screen.dart';
import 'screens/timetable_form_screen.dart';
import 'screens/login_screen.dart'; // already imported
import 'package:college_app_fixed/screens/notice_upload_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const CollegeAdminApp());
}

class CollegeAdminApp extends StatelessWidget {
  const CollegeAdminApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'College Admin App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.deepPurple),
      initialRoute: '/login',
      routes: {
        '/home': (context) => const HomeScreen(),
        '/signup': (context) => const SignupScreen(),
        '/login': (context) => const LoginScreen(),
        '/notice': (context) => NoticeUploadScreen(),
        '/timetable': (context) => TimetableFormPage(),
       
      },
    );
  }
}*/

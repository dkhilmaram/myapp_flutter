import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'service/auth_service.dart';
import 'providers/contact_provider.dart';
import 'database/db_helper.dart'; // <-- Add this import

// Screens
import 'screens/login_page.dart';
import 'screens/register_page.dart';
import 'screens/home_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Debug: print database content
  await debugDatabase();

  runApp(const MyApp());
}

// Debug function to see SQLite content in console
Future<void> debugDatabase() async {
  final db = await DBHelper.instance.database;

  // Get all users
  final users = await db.query('users');
  print('=== USERS IN DB ===');
  if (users.isEmpty) {
    print('No users found');
  } else {
    for (var u in users) {
      print(u);
    }
  }

  // Get all contacts
  final contacts = await db.query('contacts');
  print('=== CONTACTS IN DB ===');
  if (contacts.isEmpty) {
    print('No contacts found');
  } else {
    for (var c in contacts) {
      print(c);
    }
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<AuthService>(create: (_) => AuthService()),
        ChangeNotifierProvider<ContactProvider>(create: (_) => ContactProvider()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Contacts (Local App)',
        
        // First screen
        initialRoute: '/login',

        // App routes
        routes: {
          '/login': (context) => const LoginPage(),
          '/register': (context) => const RegisterPage(),
          '/home': (context) => const HomePage(),
        },

        theme: ThemeData(
          primarySwatch: Colors.teal,
        ),
      ),
    );
  }
}

// lib/database/db_helper.dart
import 'dart:io';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';

class DBHelper {
  DBHelper._privateConstructor();
  static final DBHelper instance = DBHelper._privateConstructor();

  static Database? _database;
  Future<Database> get database async => _database ??= await _initDatabase();

  Future<Database> _initDatabase() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    final path = join(documentsDirectory.path, 'app_contacts.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
      // onUpgrade: (db, oldV, newV) { /* handle migrations */ },
    );
  }

  Future _onCreate(Database db, int version) async {
    // Users table (example)
    await db.execute('''
      CREATE TABLE users(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT,
        email TEXT UNIQUE,
        phone TEXT,
        password TEXT
      );
    ''');

    // Contacts table including photoPath and whatsapp columns
    await db.execute('''
      CREATE TABLE contacts(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        userId INTEGER,
        name TEXT,
        phone TEXT,
        email TEXT,
        address TEXT,
        photoPath TEXT,
        whatsapp TEXT,
        FOREIGN KEY(userId) REFERENCES users(id)
      );
    ''');
  }
}

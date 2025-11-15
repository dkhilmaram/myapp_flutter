import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import '../database/db_helper.dart';
import '../models/user_model.dart';

class AuthService with ChangeNotifier {
  UserModel? _currentUser;
  UserModel? get currentUser => _currentUser;

  // REGISTER
  Future<UserModel?> register({
    required String name,
    required String email,
    required String phone,
    required String password,
  }) async {
    final db = await DBHelper.instance.database;

    try {
      final id = await db.insert('users', {
        'name': name,
        'email': email,
        'phone': phone,
        'password': password,
      });

      _currentUser = UserModel(
        id: id,
        name: name,
        email: email,
        phone: phone,
      );
      notifyListeners();
      return _currentUser;
    } catch (e) {
      print("REGISTER ERROR: $e");
      return null;
    }
  }

  // LOGIN
  Future<UserModel?> login({
    required String email,
    required String password,
  }) async {
    final db = await DBHelper.instance.database;

    final rows = await db.query(
      'users',
      where: 'email = ? AND password = ?',
      whereArgs: [email, password],
    );

    if (rows.isNotEmpty) {
      final u = rows.first;
      _currentUser = UserModel(
        id: u['id'] as int,
        name: u['name'] as String,
        email: u['email'] as String,
        phone: u['phone'] as String,
      );
      notifyListeners();
      return _currentUser;
    }

    return null;
  }

  // LOGOUT
  void logout() {
    _currentUser = null;
    notifyListeners();
  }
}

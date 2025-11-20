// lib/providers/contact_provider.dart
import 'package:flutter/material.dart';
import '../database/db_helper.dart';
import '../models/contact.dart';

class ContactProvider extends ChangeNotifier {
  List<Contact> _contacts = [];
  List<Contact> get contacts => _contacts;

  Future<void> loadContacts(int userId) async {
    final db = await DBHelper.instance.database;
    final rows = await db.query(
      'contacts',
      where: 'userId = ?',
      whereArgs: [userId],
      orderBy: 'name',
    );
    _contacts = rows.map((row) => Contact.fromMap(row)).toList();
    notifyListeners();
  }

  Future<void> addContact(Contact contact) async {
    final db = await DBHelper.instance.database;
    final id = await db.insert('contacts', contact.toMap());
    _contacts.add(Contact(
      id: id,
      userId: contact.userId,
      name: contact.name,
      phone: contact.phone,
      email: contact.email,
      address: contact.address,
      photoPath: contact.photoPath,
      whatsapp: contact.whatsapp,
    ));
    notifyListeners();
  }

  Future<void> updateContact(Contact contact) async {
    if (contact.id == null) return;
    final db = await DBHelper.instance.database;
    await db.update(
      'contacts',
      contact.toMap(),
      where: 'id = ?',
      whereArgs: [contact.id],
    );
    final index = _contacts.indexWhere((c) => c.id == contact.id);
    if (index != -1) {
      _contacts[index] = contact;
      notifyListeners();
    }
  }

  Future<void> deleteContact(int id) async {
    final db = await DBHelper.instance.database;
    await db.delete('contacts', where: 'id = ?', whereArgs: [id]);
    _contacts.removeWhere((c) => c.id == id);
    notifyListeners();
  }

  void clearContacts() {
    _contacts = [];
    notifyListeners();
  }
}

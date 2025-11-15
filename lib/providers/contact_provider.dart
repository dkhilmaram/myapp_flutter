// lib/providers/contact_provider.dart
import 'package:flutter/material.dart';
import '../database/db_helper.dart';
import '../models/contact.dart';

class ContactProvider extends ChangeNotifier {
  List<Contact> _contacts = [];
  List<Contact> get contacts => _contacts;

  // Load contacts for a given user
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

  // Add new contact
  Future<void> addContact(Contact contact) async {
    final db = await DBHelper.instance.database;
    final id = await db.insert('contacts', contact.toMap());
    // Add contact locally with assigned id
    _contacts.add(Contact(
      id: id,
      userId: contact.userId,
      name: contact.name,
      phone: contact.phone,
      email: contact.email,
      address: contact.address,
    ));
    notifyListeners();
  }

  // Update existing contact
  Future<void> updateContact(Contact contact) async {
    if (contact.id == null) return;
    final db = await DBHelper.instance.database;
    await db.update(
      'contacts',
      contact.toMap(),
      where: 'id = ?',
      whereArgs: [contact.id],
    );

    // Update locally
    final index = _contacts.indexWhere((c) => c.id == contact.id);
    if (index != -1) {
      _contacts[index] = contact;
      notifyListeners();
    }
  }

  // Delete a contact
  Future<void> deleteContact(int id) async {
    final db = await DBHelper.instance.database;
    await db.delete(
      'contacts',
      where: 'id = ?',
      whereArgs: [id],
    );
    _contacts.removeWhere((c) => c.id == id);
    notifyListeners();
  }

  // Clear contacts (for logout)
  void clearContacts() {
    _contacts = [];
    notifyListeners();
  }
}

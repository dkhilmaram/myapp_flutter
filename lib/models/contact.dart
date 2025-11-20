// lib/models/contact.dart
import 'package:flutter/foundation.dart';

class Contact {
  final int? id;             // local DB id
  final int? userId;         // owner user id
  final String name;         // contact name
  final String phone;        // phone number (primary)
  final String email;        // email
  final String address;      // address (optional)
  final String? photoPath;   // local filesystem path to contact photo (nullable)
  final String? whatsapp;    // whatsapp phone number in international format, e.g. +21612345678

  Contact({
    this.id,
    this.userId,
    required this.name,
    required this.phone,
    required this.email,
    this.address = '',
    this.photoPath,
    this.whatsapp,
  });

  // Convert model -> map for SQLite insert/update
  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{
      'userId': userId,
      'name': name,
      'phone': phone,
      'email': email,
      'address': address,
      'photoPath': photoPath,
      'whatsapp': whatsapp,
    };
    if (id != null) map['id'] = id;
    return map;
  }

  // Create a Contact from a DB row map
  factory Contact.fromMap(Map<String, dynamic> map) => Contact(
        id: map['id'] as int?,
        userId: map['userId'] as int?,
        name: map['name'] ?? '',
        phone: map['phone'] ?? '',
        email: map['email'] ?? '',
        address: map['address'] ?? '',
        photoPath: map['photoPath'] as String?,
        whatsapp: map['whatsapp'] as String?,
      );
}

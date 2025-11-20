// lib/screens/add_edit_contact_page.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../models/contact.dart';
import '../providers/contact_provider.dart';
import '../service/auth_service.dart';

class AddEditContactPage extends StatefulWidget {
  final Contact? contact;
  const AddEditContactPage({super.key, this.contact});

  @override
  State<AddEditContactPage> createState() => _AddEditContactPageState();
}

class _AddEditContactPageState extends State<AddEditContactPage> {
  late TextEditingController _name;
  late TextEditingController _phone;
  late TextEditingController _email;
  late TextEditingController _address;
  late TextEditingController _whatsapp;

  String? _photoPath;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _name = TextEditingController(text: widget.contact?.name ?? '');
    _phone = TextEditingController(text: widget.contact?.phone ?? '');
    _email = TextEditingController(text: widget.contact?.email ?? '');
    _address = TextEditingController(text: widget.contact?.address ?? '');
    _whatsapp = TextEditingController(text: widget.contact?.whatsapp ?? '');
    _photoPath = widget.contact?.photoPath;
  }

  Future<void> _pickPhoto() async {
    final picker = ImagePicker();
    final XFile? picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) setState(() => _photoPath = picked.path);
  }

  Future<void> _save() async {
    if (_name.text.isEmpty || _phone.text.isEmpty) return;

    setState(() => _loading = true);

    final provider = Provider.of<ContactProvider>(context, listen: false);
    final userId = Provider.of<AuthService>(context, listen: false).currentUser!.id;

    final newContact = Contact(
      id: widget.contact?.id,
      userId: userId,
      name: _name.text.trim(),
      phone: _phone.text.trim(),
      email: _email.text.trim(),
      address: _address.text.trim(),
      photoPath: _photoPath,
      whatsapp: _whatsapp.text.trim(),
    );

    if (widget.contact == null) {
      await provider.addContact(newContact);
    } else {
      await provider.updateContact(newContact);
    }

    if (!mounted) return;
    Navigator.pop(context);
  }

  InputDecoration fieldDecoration(String label, Widget icon) {
    return InputDecoration(
      labelText: label,
      prefixIcon: icon,
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.green.shade50,
      appBar: AppBar(
        title: Text(widget.contact == null ? "Add Contact" : "Edit Contact"),
        backgroundColor: Colors.green,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            GestureDetector(
              onTap: _pickPhoto,
              child: CircleAvatar(
                radius: 45,
                backgroundImage: _photoPath != null ? FileImage(File(_photoPath!)) : null,
                child: _photoPath == null ? const Icon(Icons.person, size: 45) : null,
              ),
            ),
            const SizedBox(height: 15),

            TextField(
              controller: _name,
              decoration: fieldDecoration("Name", const Icon(Icons.person, color: Colors.green)),
            ),
            const SizedBox(height: 10),

            TextField(
              controller: _phone,
              decoration: fieldDecoration("Phone", const Icon(Icons.phone, color: Colors.green)),
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 10),

            TextField(
              controller: _email,
              decoration: fieldDecoration("Email", const Icon(Icons.email, color: Colors.green)),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 10),

            TextField(
              controller: _address,
              decoration: fieldDecoration("Address", const Icon(Icons.home, color: Colors.green)),
            ),
            const SizedBox(height: 10),

            TextField(
              controller: _whatsapp,
              decoration: fieldDecoration(
                "WhatsApp (+countrycode)",
                const FaIcon(FontAwesomeIcons.whatsapp, color: Colors.green),
              ),
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 20),

            ElevatedButton(
              onPressed: _loading ? null : _save,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                minimumSize: const Size.fromHeight(50),
              ),
              child: _loading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : Text(
                      widget.contact == null ? "Add Contact" : "Save Contact",
                      style: const TextStyle(fontSize: 18),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

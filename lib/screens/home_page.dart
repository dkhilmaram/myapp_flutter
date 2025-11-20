// lib/screens/home_page.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../service/auth_service.dart';
import '../providers/contact_provider.dart';
import 'add_edit_contact_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();
    final auth = Provider.of<AuthService>(context, listen: false);
    final provider = Provider.of<ContactProvider>(context, listen: false);
    if (auth.currentUser != null) provider.loadContacts(auth.currentUser!.id);
  }

  Future<void> _openWhatsApp(String number) async {
    final clean = number.replaceAll(RegExp(r'[^0-9]'), '');
    final url = Uri.parse("https://wa.me/$clean");

    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Cannot open WhatsApp.")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthService>(context, listen: false);
    final provider = Provider.of<ContactProvider>(context);

    return Scaffold(
      backgroundColor: Colors.green.shade50,
      appBar: AppBar(
        title: const Text("My Contacts"),
        backgroundColor: Colors.green,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              auth.logout();
              provider.clearContacts();
              Navigator.pushReplacementNamed(context, '/login');
            },
          )
        ],
      ),
      body: provider.contacts.isEmpty
          ? const Center(child: Text("No contacts yet", style: TextStyle(fontSize: 18)))
          : ListView.builder(
              itemCount: provider.contacts.length,
              itemBuilder: (context, index) {
                final c = provider.contacts[index];
                return Card(
                  color: Colors.green.shade100,
                  margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                  child: ListTile(
                    leading: c.photoPath != null && c.photoPath!.isNotEmpty
                        ? CircleAvatar(
                            radius: 24,
                            backgroundImage: FileImage(File(c.photoPath!)),
                          )
                        : CircleAvatar(
                            radius: 24,
                            child: Text(
                              c.name.isNotEmpty ? c.name[0].toUpperCase() : '?',
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                    title: Text(c.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text(c.phone),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (c.whatsapp != null && c.whatsapp!.isNotEmpty)
                          IconButton(
                            icon: const FaIcon(FontAwesomeIcons.whatsapp, color: Colors.green),
                            onPressed: () => _openWhatsApp(c.whatsapp!),
                          ),
                        IconButton(
                          icon: const Icon(Icons.edit, color: Colors.blue),
                          onPressed: () async {
                            await Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => AddEditContactPage(contact: c)),
                            );
                            final authUser = Provider.of<AuthService>(context, listen: false).currentUser;
                            if (authUser != null) provider.loadContacts(authUser.id);
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () async {
                            if (c.id != null) {
                              await provider.deleteContact(c.id!);
                              final authUser = Provider.of<AuthService>(context, listen: false).currentUser;
                              if (authUser != null) provider.loadContacts(authUser.id);
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.green,
        child: const Icon(Icons.add),
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddEditContactPage()),
          );
          final authUser = Provider.of<AuthService>(context, listen: false).currentUser;
          if (authUser != null) provider.loadContacts(authUser.id);
        },
      ),
    );
  }
}

// lib/screens/home_page.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
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
    // Load contacts for the current user
    final auth = Provider.of<AuthService>(context, listen: false);
    final provider = Provider.of<ContactProvider>(context, listen: false);
    if (auth.currentUser != null) {
      provider.loadContacts(auth.currentUser!.id);
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
          ? const Center(
              child: Text(
                "No contacts yet",
                style: TextStyle(fontSize: 18),
              ),
            )
          : ListView.builder(
              itemCount: provider.contacts.length,
              itemBuilder: (context, index) {
                final c = provider.contacts[index];
                return Card(
                  color: Colors.green.shade100,
                  margin:
                      const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                  child: ListTile(
                    title: Text(c.name,
                        style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text(c.phone),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit, color: Colors.blue),
                          onPressed: () async {
                            await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    AddEditContactPage(contact: c),
                              ),
                            );
                            if (auth.currentUser != null) {
                              provider.loadContacts(auth.currentUser!.id);
                            }
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () async {
                            if (c.id != null) {
                              await provider.deleteContact(c.id!);
                              if (auth.currentUser != null) {
                                provider.loadContacts(auth.currentUser!.id);
                              }
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
            MaterialPageRoute(
              builder: (_) => const AddEditContactPage(),
            ),
          );
          if (auth.currentUser != null) {
            provider.loadContacts(auth.currentUser!.id);
          }
        },
      ),
    );
  }
}

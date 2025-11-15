import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../service/auth_service.dart';
import '../providers/contact_provider.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _phone = TextEditingController();
  final _password = TextEditingController();
  final _confirmPassword = TextEditingController();
  bool _loading = false;

  InputDecoration field(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, color: Colors.pinkAccent),
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
    );
  }

  Future<void> _register() async {
    if (_password.text != _confirmPassword.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Passwords do not match")),
      );
      return;
    }

    setState(() => _loading = true);
    final auth = Provider.of<AuthService>(context, listen: false);
    final contactProvider = Provider.of<ContactProvider>(context, listen: false);

    final user = await auth.register(
      name: _name.text.trim(),
      email: _email.text.trim(),
      phone: _phone.text.trim(),
      password: _password.text.trim(),
    );

    if (user != null) {
      await contactProvider.loadContacts(user.id); // prepare empty contacts
      if (!mounted) return;
      Navigator.pushReplacementNamed(context, '/home');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Email already used")),
      );
    }

    if (mounted) setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.pink.shade50,
      appBar: AppBar(
        title: const Text("Create Account"),
        backgroundColor: Colors.pinkAccent,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(controller: _name, decoration: field("Full Name", Icons.person)),
            const SizedBox(height: 15),
            TextField(controller: _email, decoration: field("Email", Icons.email)),
            const SizedBox(height: 15),
            TextField(controller: _phone, decoration: field("Phone Number", Icons.phone)),
            const SizedBox(height: 15),
            TextField(controller: _password, obscureText: true, decoration: field("Password", Icons.lock)),
            const SizedBox(height: 15),
            TextField(controller: _confirmPassword, obscureText: true, decoration: field("Confirm Password", Icons.lock_outline)),
            const SizedBox(height: 25),
            ElevatedButton(
              onPressed: _loading ? null : _register,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.pinkAccent,
                minimumSize: const Size.fromHeight(50),
              ),
              child: _loading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text("Register", style: TextStyle(fontSize: 18)),
            ),
            TextButton(
              onPressed: () => Navigator.pushReplacementNamed(context, "/login"),
              child: const Text("Already have an account? Login"),
            )
          ],
        ),
      ),
    );
  }
}

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

  final _formKey = GlobalKey<FormState>();
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

  String? _validateName(String? v) {
    if (v == null || v.trim().isEmpty) return "Name is required";
    if (v.trim().length < 3) return "Name too short";
    return null;
  }

  String? _validateEmail(String? v) {
    if (v == null || v.trim().isEmpty) return "Email is required";
    final reg = RegExp(r'^[^@]+@[^@]+\.[^@]+$');
    if (!reg.hasMatch(v.trim())) return "Invalid email format";
    return null;
  }

  String? _validatePhone(String? v) {
    if (v == null || v.trim().isEmpty) return "Phone number is required";
    final reg = RegExp(r'^[0-9]+$');
    if (!reg.hasMatch(v)) return "Phone must contain only digits";
    if (v.trim().length < 8) return "Phone too short";
    return null;
  }

  String? _validatePassword(String? v) {
    if (v == null || v.isEmpty) return "Password required";
    if (v.length < 6) return "Password must be at least 6 characters";
    return null;
  }

  String? _validateConfirmPassword(String? v) {
    if (v != _password.text) return "Passwords do not match";
    return null;
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _loading = true);

    final auth = Provider.of<AuthService>(context, listen: false);
    final contactProvider = Provider.of<ContactProvider>(context, listen: false);

    final user = await auth.register(
      name: _name.text.trim(),
      email: _email.text.trim(),
      phone: _phone.text.trim(),
      password: _password.text.trim(),
    );

    if (!mounted) return;

    if (user != null) {
      await contactProvider.loadContacts(user.id);
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
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(controller: _name, validator: _validateName, decoration: field("Full Name", Icons.person)),
              const SizedBox(height: 15),

              TextFormField(controller: _email, validator: _validateEmail, decoration: field("Email", Icons.email)),
              const SizedBox(height: 15),

              TextFormField(controller: _phone, validator: _validatePhone, decoration: field("Phone Number", Icons.phone)),
              const SizedBox(height: 15),

              TextFormField(
                controller: _password,
                obscureText: true,
                validator: _validatePassword,
                decoration: field("Password", Icons.lock),
              ),
              const SizedBox(height: 15),

              TextFormField(
                controller: _confirmPassword,
                obscureText: true,
                validator: _validateConfirmPassword,
                decoration: field("Confirm Password", Icons.lock_outline),
              ),
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
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:kutubu_app/main.dart';
import 'package:kutubu_app/pages/login_page.dart';
import '../services/api_service.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      await ApiService().register(
        _usernameController.text.trim(),
        _passwordController.text,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Register berhasil! Silakan login.')),
        );
        Navigator.pop(context); // kembali ke halaman login
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Register gagal: $e')));
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: Center(
          child: Image.asset(
            'assets/kutubu-logo-transparent.png',
            width: 24,
            fit: BoxFit.fitWidth,
          ),
        ),
        title: const Text(
          'Daftar',
          style: TextStyle(color: Color.fromRGBO(255, 255, 255, 1)),
        ),
        backgroundColor: primaryColor,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _usernameController,
                decoration: const InputDecoration(labelText: 'Username'),
                validator:
                    (val) =>
                        val == null || val.isEmpty
                            ? 'Username wajib diisi'
                            : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _passwordController,
                decoration: const InputDecoration(labelText: 'Password'),
                obscureText: true,
                validator:
                    (val) =>
                        val != null && val.length < 6
                            ? 'Minimal 6 karakter'
                            : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _confirmPasswordController,
                decoration: const InputDecoration(
                  labelText: 'Confirm Password',
                ),
                obscureText: true,
                validator:
                    (val) =>
                        val != _passwordController.text
                            ? 'Password tidak sama'
                            : null,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _isLoading ? null : _register,
                child:
                    _isLoading
                        ? const CircularProgressIndicator()
                        : const Text('Register'),
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (_) => const LoginPage()),
                  );
                },
                child: const Text('Sudah punya akun? Masuk'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import '../../services/auth_service.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();
  
  String _selectedRole = 'customer';
  final List<String> _roles = ['Customer', 'Restaurant', 'Driver'];
  
  bool _isLoading = false;
  final AuthService _authService = AuthService();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      await _authService.signUp(
        email: _emailController.text.trim(),
        password: _passwordController.text,
        role: _selectedRole.toLowerCase(),
        name: _nameController.text.trim(),
      );
      
      // Navigation will be handled by the stream wrapper in main.dart
      if (mounted) {
         Navigator.of(context).popUntil((route) => route.isFirst);
      }

    } catch (e) {
      _showError('Registration failed: ${e.toString()}');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Join Usage')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 20),
                const Icon(Icons.delivery_dining, size: 80, color: Colors.blue),
                const SizedBox(height: 20),
                const Text(
                  'Create Account',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 30),
                
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Full Name / Restaurant Name',
                    prefixIcon: Icon(Icons.person),
                    border: OutlineInputBorder(),
                  ),
                  validator: (v) => v!.isEmpty ? 'Required' : null,
                ),
                const SizedBox(height: 16),
                
                DropdownButtonFormField<String>(
                  value: _roles.firstWhere((r) => r.toLowerCase() == _selectedRole, orElse: () => 'Customer'),
                  decoration: const InputDecoration(
                    labelText: 'I am a...',
                    prefixIcon: Icon(Icons.work),
                    border: OutlineInputBorder(),
                  ),
                  items: _roles.map((role) {
                    return DropdownMenuItem(
                      value: role,
                      child: Text(role),
                      onTap: () {
                         setState(() {
                           _selectedRole = role.toLowerCase();
                         });
                      },
                    );
                  }).toList(),
                  onChanged: (val) {},
                ),
                const SizedBox(height: 16),
                
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    prefixIcon: Icon(Icons.email),
                    border: OutlineInputBorder(),
                  ),
                  validator: (v) => v!.contains('@') ? null : 'Invalid email',
                ),
                const SizedBox(height: 16),
                
                TextFormField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: 'Password',
                    prefixIcon: Icon(Icons.lock),
                    border: OutlineInputBorder(),
                  ),
                  validator: (v) => v!.length < 6 ? 'Min 6 chars' : null,
                ),
                const SizedBox(height: 24),
                
                ElevatedButton(
                  onPressed: _isLoading ? null : _register,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator()
                      : const Text('Register', style: TextStyle(fontSize: 16)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

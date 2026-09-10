import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../theme/app_colors.dart';
import '../widgets/common_widgets.dart';

class RegisterScreen extends StatefulWidget {
  final VoidCallback onRegistered;
  final VoidCallback onGoToLogin;
  const RegisterScreen({super.key, required this.onRegistered, required this.onGoToLogin});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final nameCtl = TextEditingController();
  final emailCtl = TextEditingController();
  final passwordCtl = TextEditingController();
  bool loading = false;
  String? error;

  Future<void> _submit() async {
    if (nameCtl.text.trim().isEmpty || emailCtl.text.trim().isEmpty || passwordCtl.text.isEmpty) {
      setState(() => error = 'Fill in your name, email, and password.');
      return;
    }
    if (passwordCtl.text.length < 8) {
      setState(() => error = 'Password needs to be at least 8 characters.');
      return;
    }
    setState(() {
      loading = true;
      error = null;
    });
    try {
      await ApiService.register(emailCtl.text.trim(), passwordCtl.text, nameCtl.text.trim());
      widget.onRegistered();
    } catch (e) {
      setState(() => error = e.toString());
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = Theme.of(context).extension<AppColors>()!;
    return Scaffold(
      backgroundColor: c.paper,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text('Create your account', style: displayFont(size: 26, color: c.ink)),
                const SizedBox(height: 4),
                Text('Sets up your own private StudentOS', style: bodyFont(size: 13, color: c.inkSoft)),
                const SizedBox(height: 28),
                LabeledTextField(label: 'Name', controller: nameCtl),
                LabeledTextField(label: 'Email', controller: emailCtl, keyboardType: TextInputType.emailAddress),
                LabeledTextField(label: 'Password', controller: passwordCtl, hint: 'At least 8 characters', obscureText: true),
                if (error != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Text(error!, style: bodyFont(size: 12.5, color: coral)),
                  ),
                PrimaryButton(label: loading ? 'Creating account…' : 'Create account', onPressed: loading ? null : _submit),
                const SizedBox(height: 14),
                Center(
                  child: TextButton(
                    onPressed: widget.onGoToLogin,
                    child: Text('Already have an account? Sign in', style: bodyFont(size: 13, weight: FontWeight.w600, color: teal)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

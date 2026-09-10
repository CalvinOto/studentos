import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../theme/app_colors.dart';
import '../widgets/common_widgets.dart';

class LoginScreen extends StatefulWidget {
  final VoidCallback onLoggedIn;
  final VoidCallback onGoToRegister;
  const LoginScreen({super.key, required this.onLoggedIn, required this.onGoToRegister});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final emailCtl = TextEditingController();
  final passwordCtl = TextEditingController();
  bool loading = false;
  String? error;

  Future<void> _submit() async {
    if (emailCtl.text.trim().isEmpty || passwordCtl.text.isEmpty) {
      setState(() => error = 'Enter your email and password.');
      return;
    }
    setState(() {
      loading = true;
      error = null;
    });
    try {
      await ApiService.login(emailCtl.text.trim(), passwordCtl.text);
      widget.onLoggedIn();
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
                Text('StudentOS', style: displayFont(size: 30, color: c.ink)),
                const SizedBox(height: 4),
                Text('Sign in to continue', style: bodyFont(size: 13, color: c.inkSoft)),
                const SizedBox(height: 28),
                LabeledTextField(label: 'Email', controller: emailCtl, keyboardType: TextInputType.emailAddress),
                LabeledTextField(label: 'Password', controller: passwordCtl, hint: '••••••••', obscureText: true),
                if (error != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Text(error!, style: bodyFont(size: 12.5, color: coral)),
                  ),
                PrimaryButton(label: loading ? 'Signing in…' : 'Sign in', onPressed: loading ? null : _submit),
                const SizedBox(height: 14),
                Center(
                  child: TextButton(
                    onPressed: widget.onGoToRegister,
                    child: Text("Don't have an account? Create one", style: bodyFont(size: 13, weight: FontWeight.w600, color: teal)),
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

import 'package:flutter/material.dart';
import 'login_screen.dart';
import 'register_screen.dart';

class AuthFlow extends StatefulWidget {
  final VoidCallback onAuthenticated;
  const AuthFlow({super.key, required this.onAuthenticated});

  @override
  State<AuthFlow> createState() => _AuthFlowState();
}

class _AuthFlowState extends State<AuthFlow> {
  bool showRegister = false;

  @override
  Widget build(BuildContext context) {
    return showRegister
        ? RegisterScreen(
            onRegistered: widget.onAuthenticated,
            onGoToLogin: () => setState(() => showRegister = false),
          )
        : LoginScreen(
            onLoggedIn: widget.onAuthenticated,
            onGoToRegister: () => setState(() => showRegister = true),
          );
  }
}

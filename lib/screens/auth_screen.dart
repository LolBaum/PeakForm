import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';

class AuthScreen extends StatelessWidget {
  const AuthScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    return Scaffold(
      body: Center(
        child: ElevatedButton(
          onPressed: () => auth.signIn(),
          child: const Text('Anmelden mit Logto'),
        ),
      ),
    );
  }
}

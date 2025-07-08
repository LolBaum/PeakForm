import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: SizedBox(
          width: 404,
          height: 874,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              // Login Button
              SizedBox(
                width: 332.23,
                height: 53.16,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF256F5D),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16.61),
                    ),
                  ),
                  onPressed: () => auth.signIn(),
                  child: const Text(
                    'Login',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 17.72,
                      fontFamily: 'Hamon',
                      fontWeight: FontWeight.w700,
                      height: 0.87,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              // Sign up Link
              // 'or' Text
              const Text(
                'or',
                style: TextStyle(
                  color: Color(0xFF989898),
                  fontSize: 15.50,
                  fontFamily: 'LeagueSpartan',
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 24),
              // Google Button
              SizedBox(
                width: 332.23,
                height: 53.16,
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    backgroundColor: const Color(0xFFFCFCFC),
                    side:
                        const BorderSide(width: 1.11, color: Color(0xFFCAA7A7)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16.61),
                    ),
                  ),
                  onPressed: () => auth.signIn(),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(width: 10),
                      Text(
                        'Continue with Google',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 15.50,
                          fontFamily: 'LeagueSpartan',
                          fontWeight: FontWeight.w400,
                          height: 1,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

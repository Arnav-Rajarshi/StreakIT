import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:frontend/models/auth_models.dart';
import 'package:frontend/screens/today_home_page.dart';
import 'package:frontend/services/auth_service.dart';
import 'package:frontend/theme/app_theme.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  bool obscurePassword = true;
  final usernameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).extension<AppTheme>()!;

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: theme.pageGradient,
        ),
        child: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 560),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(30),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
                    child: Container(
                      decoration: BoxDecoration(
                        color: theme.glassSurface.withValues(alpha: .9),
                        borderRadius: BorderRadius.circular(30),
                        border: Border.all(color: theme.glassBorder),
                        boxShadow: [
                          ...theme.softShadow,
                          BoxShadow(color: const Color(0x1AFFFFFF), blurRadius: 18, offset: const Offset(-4, -4)),
                        ],
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
                        child: SingleChildScrollView(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(colors: [theme.accent.withValues(alpha: .16), theme.accent.withValues(alpha: .08)]),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Icon(Icons.person_add_alt_1_rounded, color: theme.accent, size: 30),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'Create your account',
                                textAlign: TextAlign.center,
                                style: TextStyle(fontSize: 25, fontWeight: FontWeight.w800, color: theme.ink, letterSpacing: -.3),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Start building your streak today.',
                                textAlign: TextAlign.center,
                                style: TextStyle(color: theme.mutedInk, fontSize: 13.5, fontWeight: FontWeight.w600),
                              ),
                              const SizedBox(height: 24),
                              TextField(
                                controller: usernameController,
                                decoration: InputDecoration(
                                  labelText: 'Username',
                                  prefixIcon: Icon(Icons.account_circle_outlined),
                                ),
                              ),
                              const SizedBox(height: 16),
                              TextField(
                                controller: emailController,
                                keyboardType: TextInputType.emailAddress,
                                decoration: InputDecoration(
                                  labelText: 'Email',
                                  prefixIcon: Icon(Icons.email_outlined),
                                ),
                              ),
                              const SizedBox(height: 16),
                              TextField(
                                obscureText: obscurePassword,
                                controller: passwordController,
                                decoration: InputDecoration(
                                  labelText: 'Password',
                                  prefixIcon: const Icon(Icons.lock_outline_rounded),
                                  suffixIcon: InkWell(
                                    borderRadius: BorderRadius.circular(24),
                                    onTap: () => setState(() => obscurePassword = !obscurePassword),
                                    child: Icon(
                                      obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                                      color: theme.mutedInk,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 24),
                              SizedBox(
                                height: 52,
                                child: ElevatedButton(
                                  onPressed: () async {
                                    final user = UserCreate(
                                      user_name: usernameController.text,
                                      email: emailController.text,
                                      password: passwordController.text,
                                    );

                                    await AuthService().signup(user);
                                    if (!mounted) return;
                                    Navigator.of(context).pushReplacement(
                                      MaterialPageRoute(builder: (_) => const HomePage()),
                                    );
                                  },
                                  child: const Text('Sign Up', style: TextStyle(fontSize: 15.5, fontWeight: FontWeight.w700)),
                                ),
                              ),
                              const SizedBox(height: 14),
                              TextButton(
                                onPressed: () => Navigator.of(context).pop(),
                                child: Text('Already have an account? Sign In', style: TextStyle(color: theme.accent, fontWeight: FontWeight.w700)),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

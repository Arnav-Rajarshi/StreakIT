import 'package:flutter/material.dart';
import 'package:frontend/main.dart';
import 'package:frontend/models/auth_models.dart';
import 'package:frontend/services/auth_service.dart';


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
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: Theme.of(context).extension<AppTheme>()!.pageGradient,
        ),
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              return Center(
                child: FractionallySizedBox(
                  widthFactor: 0.60,
                  heightFactor: 0.80,
                  child: Card(
                    elevation: 12,
                    shadowColor: const Color(0xFF6B5B95).withValues(alpha: 0.25),
                    color: Colors.white.withValues(alpha: 0.88),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 22),
                      child: Center(
                        child: SingleChildScrollView(
                          child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          
                          const Text('Create your account', textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 26, fontWeight: FontWeight.w700, color: Color(0xFF403757))),
                          
                          const SizedBox(height: 8),
                          
                          const Text('Start building your streak today.', textAlign: TextAlign.center,
                            style: TextStyle(color: Color(0xFF746B88))),
                          
                          const SizedBox(height: 26),
                          
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
                                  color: const Color(0xFF746B88),
                                ),
                              ),
                            ),
                          ),
                          
                          const SizedBox(height: 26),
                          
                          SizedBox(
                            height: 52,
                            child: ElevatedButton(
                              onPressed: () async{ 
                                ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Sign up submitted')),
                                );

                                final user = UserCreate(
                                  user_name: usernameController.text, 
                                  email: emailController.text, 
                                  password: passwordController.text);

                                await AuthService().signup(user);

                              },

                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF6C5A91),
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                              ),
                              child: const Text('Sign Up', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                            ),
                          ),
                          
                          const SizedBox(height: 16),
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(),
                            child: const Text('Already have an account? Sign In'),
                          ),
                        ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

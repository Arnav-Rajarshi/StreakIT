import 'package:flutter/material.dart';
import 'package:frontend/main.dart';
import 'package:frontend/models/auth_models.dart';
import 'package:frontend/screens/signup_page.dart';
import 'package:frontend/services/auth_service.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => LoginPageState();
}

class LoginPageState extends State<LoginPage> {
  bool obscurePassword = true;
  final userdetailsController = TextEditingController();
  final passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,

        // Heres the way to apply the page theme
        decoration: BoxDecoration(
          gradient: Theme.of(context).extension<AppTheme>()!.pageGradient,
        ),

        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              return Center(
                child: FractionallySizedBox(
                  widthFactor: 0.60,
                  heightFactor: 0.68,

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
                          const Text('Welcome back', textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 26, fontWeight: FontWeight.w700, color: Color(0xFF403757))),
                          
                          const SizedBox(height: 8),
                          
                          const Text('Sign in to continue your streak.', textAlign: TextAlign.center,
                            style: TextStyle(color: Color(0xFF746B88))),
                          
                          const SizedBox(height: 26),
                          
                          TextField(
                            keyboardType: TextInputType.emailAddress,
                            controller: userdetailsController,
                            decoration: const InputDecoration(
                              labelText: 'Username or email',
                              prefixIcon: Icon(Icons.account_circle_outlined),
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
                                
                                onTap: () => setState(() => obscurePassword = !obscurePassword), // calling setState to re-render the UI
                                
                                child: Icon(
                                  obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                                  color: const Color(0xFF746B88),
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 26),

                          // The submit button
                          SizedBox(
                            height: 52,
                            child: ElevatedButton(
                              onPressed: () async { 
                                ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Login submitted')),
                                );

                                final request = LoginRequest(
                                      userDetails: userdetailsController.text,
                                      password: passwordController.text,
                                  );
                                await AuthService().login(request);
                              },

                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF6C5A91),
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                              ),
                              child: const Text('Submit', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                            ),

                          ),
                          const SizedBox(height: 16),
                          TextButton(
                            onPressed: () => Navigator.of(context).push(
                              MaterialPageRoute(builder: (_) => const SignUpPage()),
                            ),
                            child: const Text('New user? Go to Sign Up'),
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


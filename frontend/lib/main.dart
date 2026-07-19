import 'package:flutter/material.dart';

void main(){
  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,

    theme: ThemeData(
      extensions: const [
        
        AppTheme(
          pageGradient: LinearGradient(
            begin: Alignment.bottomCenter,
            end: Alignment.topCenter,
            colors: [
              Color(0xFFDAD4EC),
              Color(0xFFDAD4EC),
              Color(0xFFF3E7E9),
            ],
            stops: [0.0, 0.01, 1.0],
          ),
        ),
      ],


      inputDecorationTheme: InputDecorationTheme(
        labelStyle: const TextStyle(color: Color(0xFF746B88)),
        prefixIconColor: const Color(0xFF6C5A91),
        filled: true,
        fillColor: Colors.white.withValues(alpha: 0.65),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(color: Color(0xFF6C5A91), width: 1.5),
        ),
      ),
    ),

    home: LoginPage(),
  ));
}

class AppTheme extends ThemeExtension<AppTheme> {
  final LinearGradient pageGradient;

  const AppTheme({required this.pageGradient});

  @override
  AppTheme copyWith({LinearGradient? pageGradient}) {
    return AppTheme(pageGradient: pageGradient ?? this.pageGradient);
  }

  @override
  AppTheme lerp(covariant ThemeExtension<AppTheme>? other, double t) {
    if (other is! AppTheme) {
      return this;
    }

    return AppTheme(
      pageGradient: LinearGradient.lerp(pageGradient, other.pageGradient, t)!,
    );
  }
}

class HomePage extends StatefulWidget{

  const HomePage ({super.key});

  @override
  State<StatefulWidget> createState() {
    return HomePageState();
  }
}

class HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Text("Hello World"),
    );
  }
}

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => LoginPageState();
}

class LoginPageState extends State<LoginPage> {
  bool obscurePassword = true;

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
                            decoration: const InputDecoration(
                              labelText: 'Username or email',
                              prefixIcon: Icon(Icons.account_circle_outlined),
                            ),
                          ),

                          const SizedBox(height: 16),
                          
                          TextField(
                            obscureText: obscurePassword,
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
                              onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Login submitted')),
                              ),

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

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  bool obscurePassword = true;

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
                          const TextField(
                            decoration: InputDecoration(
                              labelText: 'Username',
                              prefixIcon: Icon(Icons.account_circle_outlined),
                            ),
                          ),
                          const SizedBox(height: 16),
                          const TextField(
                            keyboardType: TextInputType.emailAddress,
                            decoration: InputDecoration(
                              labelText: 'Email',
                              prefixIcon: Icon(Icons.email_outlined),
                            ),
                          ),
                          const SizedBox(height: 16),
                          TextField(
                            obscureText: obscurePassword,
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
                              onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Sign up submitted')),
                              ),
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

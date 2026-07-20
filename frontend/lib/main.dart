import 'package:flutter/material.dart';
import 'package:frontend/screens/login_page.dart'; 

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


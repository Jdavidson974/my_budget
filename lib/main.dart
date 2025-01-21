import 'package:flutter/material.dart';
import 'app_routes.dart';
import 'screens/home_screen.dart';

void main() {
  runApp(MyBudgetApp());
}

class MyBudgetApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'My-Budget',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: HomeScreen(), // Écran initial
      onGenerateRoute: AppRoutes.generateRoute, // Gestionnaire de routes
    );
  }
}

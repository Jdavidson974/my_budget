import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart'; // Ajout de cet import
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
      locale: Locale('fr', 'FR'), // Définit la locale en français
      supportedLocales: [
        Locale('en', 'US'),
        Locale('fr', 'FR'),
        // Ajoute d'autres langues si nécessaire
      ],
      localizationsDelegates: [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate, // Ajoute cette ligne pour iOS
      ],
    );
  }
}

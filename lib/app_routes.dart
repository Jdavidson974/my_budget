import 'package:flutter/material.dart';
import 'package:my_budget/screens/home_screen.dart';
import 'screens/add_transaction_screen.dart';
import 'screens/history_screen.dart';

class AppRoutes {
  static const addTransaction = '/add-transaction';
  static const history = '/history';
  static const home = '/home';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case addTransaction:
        return MaterialPageRoute(builder: (_) => AddTransactionScreen());
      case history:
        return MaterialPageRoute(builder: (_) => HistoryScreen());
      case home:
        return MaterialPageRoute(builder: (_) => HomeScreen());
      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(child: Text('Écran non trouvé')),
          ),
        );
    }
  }
}

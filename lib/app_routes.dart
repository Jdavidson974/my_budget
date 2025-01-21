import 'package:flutter/material.dart';
import 'screens/add_transaction_screen.dart';
import 'screens/history_screen.dart';

class AppRoutes {
  static const addTransaction = '/add-transaction';
  static const history = '/history';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case addTransaction:
        return MaterialPageRoute(builder: (_) => AddTransactionScreen());
      case history:
        return MaterialPageRoute(builder: (_) => HistoryScreen());
      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(child: Text('Écran non trouvé')),
          ),
        );
    }
  }
}

import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DBHelper {
  static Database? _db;

  // Nom et version de la base de données
  static const String dbName = 'my_budget.db';
  static const int dbVersion = 1;

  // Nom de la table
  static const String tableName = 'transactions';

  // Colonnes de la table
  static const String colId = 'id';
  static const String colAmount = 'amount';
  static const String colType = 'type'; // "gain" ou "dépense"
  static const String colComment = 'comment';
  static const String colDate = 'date';

  // Initialisation de la base de données
  static Future<Database> initDB() async {
    if (_db != null) {
      return _db!;
    }

    String path = join(await getDatabasesPath(), dbName);
    _db = await openDatabase(
      path,
      version: dbVersion,
      onCreate: _onCreate,
    );
    return _db!;
  }

  // Création de la table
  static Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE $tableName (
        $colId INTEGER PRIMARY KEY AUTOINCREMENT,
        $colAmount REAL NOT NULL,
        $colType TEXT NOT NULL,
        $colComment TEXT,
        $colDate TEXT NOT NULL
      )
    ''');
  }

  // Ajouter une transaction
  static Future<int> addTransaction(Map<String, dynamic> transaction) async {
    final db = await initDB();
    return await db.insert(tableName, transaction);
  }

  // Récupérer toutes les transactions
  static Future<List<Map<String, dynamic>>> getTransactions() async {
    final db = await initDB();
    return await db.query(tableName, orderBy: '$colDate DESC');
  }

  // Filtrer les transactions par type (gain ou dépense)
  static Future<List<Map<String, dynamic>>> getTransactionsByType(
      String type) async {
    final db = await initDB();
    return await db.query(tableName,
        where: '$colType = ?', whereArgs: [type], orderBy: '$colDate DESC');
  }

  // Filtrer par mois (année et mois donnés)
  static Future<List<Map<String, dynamic>>> getTransactionsByMonth(
      int year, int month) async {
    final db = await initDB();
    String startDate = '$year-${month.toString().padLeft(2, '0')}-01';
    String endDate = '$year-${month.toString().padLeft(2, '0')}-31';
    return await db.query(
      tableName,
      where: '$colDate BETWEEN ? AND ?',
      whereArgs: [startDate, endDate],
      orderBy: '$colDate DESC',
    );
  }

  // Filtrer les transactions par type et mois
  static Future<List<Map<String, dynamic>>> getTransactionsByTypeAndMonth(
      String type, int year, int month) async {
    final db = await initDB();
    String startDate = '$year-${month.toString().padLeft(2, '0')}-01';
    String endDate = '$year-${month.toString().padLeft(2, '0')}-31';
    return await db.query(
      tableName,
      where: '$colType = ? AND $colDate BETWEEN ? AND ?',
      whereArgs: [type, startDate, endDate],
      orderBy: '$colDate DESC',
    );
  }
}

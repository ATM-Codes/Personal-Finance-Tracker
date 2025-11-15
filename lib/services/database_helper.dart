import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/category.dart';
import '../models/expense.dart';

class DatabaseHelper {
  //singleton pattern - only one instance
  static final DatabaseHelper instance = DatabaseHelper.init();
  static Database? _database;

  DatabaseHelper.init();

  //GET DATABASE INSTANCE
  Future<Database> get getDatabase async {
    if (_database != null) return _database!;
    _database = await _initDB('expenses.db');
    return _database!;
  }

  //INITIALISE DB
  Future<Database> _initDB(String filepath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filepath);

    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  //create the db
  Future _createDB(Database db, int version) async {
    await db.execute(
      '''CREATE TABLE categories (id INTEGER PRIMARY KEY AUTOINCREMENT, name TEXT NOT NULL, color TEXT NOT NULL, icon TEXT NOT NULL)''',
    );

    await db.execute(
      '''CREATE TABLE expenses (id INTEGER PRIMARY KEY AUTOINCREMENT, amount REAL NOT NULL, catId INTEGER NOT NULL, desc TEXT NOT NULL, date TEXT NOT NULL, createdAt TEXT NOT NULL, FOREIGN KEY(catId) REFERENCES categories(id))''',
    );

    await _insertDefaultCategories(db);
  }

  Future _insertDefaultCategories(Database db) async {
    final categories = [
      {'name': 'Food & Dining', 'icon': 'restaurant', 'color': 'FF4CAF50'},
      {'name': 'Transport', 'icon': 'directions_car', 'color': 'FF2196F3'},
      {'name': 'Shopping', 'icon': 'shopping_cart', 'color': 'FFFF9800'},
      {'name': 'Bills & Utilities', 'icon': 'receipt', 'color': 'FFF44336'},
      {'name': 'Entertainment', 'icon': 'movie', 'color': 'FF9C27B0'},
      {
        'name': 'Health & Fitness',
        'icon': 'fitness_center',
        'color': 'FFE91E63',
      },
      {'name': 'Education', 'icon': 'school', 'color': 'FF3F51B5'},
      {'name': 'Other', 'icon': 'more_horiz', 'color': 'FF607D8B'},
    ];

    for (var category in categories) {
      await db.insert('categories', category);
    }
  }

  Future closeDB() async {
    final db = await instance.getDatabase;
    db.close();
  }
}

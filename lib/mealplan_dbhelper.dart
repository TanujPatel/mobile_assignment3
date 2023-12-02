import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class mealplan_dbhelper {
  static final mealplan_dbhelper _instance = mealplan_dbhelper._();
  static Database? _database;

  mealplan_dbhelper._();
  factory mealplan_dbhelper() => _instance;

  Future<Database> get database async{
    if(_database != null) return _database!;

    _database = await initDatabase();
    return _database!;
  }
  Future<Database> initDatabase() async{
    String path = join(await getDatabasesPath(), 'mealplan_db.db');
    return openDatabase(path, version: 1, onCreate: _createDb);
  }

  Future<void> _createDb(Database db, int version) async{
    await db.execute('''
      CREATE TABLE mealplan(
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      food_name TEXT,
      date TEXT,
      target_calories INTEGER,     
      selected_calories INTEGER
      )
    ''');
  }

  Future<void> insertMealPlan({
    required String foodName,
    required String date,
    required int targetCalories,
    required int selectedCalories,
}) async{
    final Database db= await database;
    await db.insert('mealplan',
        {
      'food_name': foodName,
          'date' : date,
          'target_calories' : targetCalories,
          'selected_calories' : selectedCalories,
    },
    conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Map<String, dynamic>>> getMealPlans() async{
    final Database db = await database;
    return await db.query('mealplan');
  }
}
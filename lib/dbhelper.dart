import 'dart:async';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class dbHelper {
  static final dbHelper _instance = dbHelper._();
  static Database? _database;

  dbHelper._();
  factory dbHelper() => _instance;

  Future<Database> get database async{
    if(_database != null) return _database!;

    _database=await initDatabase();
    return _database! ;
  }

  Future<Database> initDatabase() async{
    String path = join(await getDatabasesPath(), 'calories_db.db');
    return openDatabase(path,version: 1,onCreate: _createDatabase);
  }

  Future<void> _createDatabase(Database db, int version) async{
    await db.execute('''
      CREATE TABLE food_calories(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        food_name TEXT,
        calories INTEGER
      )
    ''');
  }

  Future<void> insertEntry(String food, int calories) async{
    final Database db = await database;
    await db.insert(
        'food_calories',
        {'food_name':food, 'calories':calories},
        conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Map<String, dynamic>>> getEntry() async{
    final Database db = await database;
    return await db.query('food_calories');
  }

  Future<List<Map<String, dynamic>>> getAllFoods() async {
    final Database db = await database;
    return await db.query('food_calories');
  }

}

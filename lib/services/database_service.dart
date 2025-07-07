import 'dart:async';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/step_data.dart';

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  static DatabaseService get instance => _instance;
  DatabaseService._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'step_counter.db');
    return await openDatabase(path, version: 1, onCreate: _onCreate);
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE step_data(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        date TEXT NOT NULL UNIQUE,
        steps INTEGER NOT NULL,
        calories REAL NOT NULL,
        distance REAL NOT NULL,
        activeTimeMinutes INTEGER NOT NULL,
        goalAchieved INTEGER NOT NULL
      )
    ''');
  }

  Future<int> insertOrUpdateStepData(StepData stepData) async {
    final db = await database;
    final dateString = stepData.date.toIso8601String().split('T')[0];

    // Check if data for this date already exists
    final existing = await db.query(
      'step_data',
      where: 'date = ?',
      whereArgs: [dateString],
    );

    final data = stepData.toMap();
    data['date'] = dateString; // Store only date part

    if (existing.isNotEmpty) {
      // Update existing record
      return await db.update(
        'step_data',
        data,
        where: 'date = ?',
        whereArgs: [dateString],
      );
    } else {
      // Insert new record
      return await db.insert('step_data', data);
    }
  }

  Future<List<StepData>> getWeeklyData() async {
    final db = await database;
    final weekAgo = DateTime.now().subtract(const Duration(days: 7));
    final weekAgoString = weekAgo.toIso8601String().split('T')[0];

    final List<Map<String, dynamic>> maps = await db.query(
      'step_data',
      where: 'date >= ?',
      whereArgs: [weekAgoString],
      orderBy: 'date ASC',
    );

    return List.generate(maps.length, (i) {
      return StepData.fromMap(maps[i]);
    });
  }

  Future<List<StepData>> getMonthlyData() async {
    final db = await database;
    final monthAgo = DateTime.now().subtract(const Duration(days: 30));
    final monthAgoString = monthAgo.toIso8601String().split('T')[0];

    final List<Map<String, dynamic>> maps = await db.query(
      'step_data',
      where: 'date >= ?',
      whereArgs: [monthAgoString],
      orderBy: 'date ASC',
    );

    return List.generate(maps.length, (i) {
      return StepData.fromMap(maps[i]);
    });
  }

  Future<List<StepData>> getDataForDateRange(
    DateTime start,
    DateTime end,
  ) async {
    final db = await database;
    final startString = start.toIso8601String().split('T')[0];
    final endString = end.toIso8601String().split('T')[0];

    final List<Map<String, dynamic>> maps = await db.query(
      'step_data',
      where: 'date >= ? AND date <= ?',
      whereArgs: [startString, endString],
      orderBy: 'date ASC',
    );

    return List.generate(maps.length, (i) {
      return StepData.fromMap(maps[i]);
    });
  }

  Future<StepData?> getDataForDate(DateTime date) async {
    final db = await database;
    final dateString = date.toIso8601String().split('T')[0];

    final List<Map<String, dynamic>> maps = await db.query(
      'step_data',
      where: 'date = ?',
      whereArgs: [dateString],
    );

    if (maps.isNotEmpty) {
      return StepData.fromMap(maps.first);
    }
    return null;
  }

  Future<int> getTotalSteps() async {
    final db = await database;
    final result = await db.rawQuery(
      'SELECT SUM(steps) as total FROM step_data',
    );
    return result.first['total'] as int? ?? 0;
  }

  Future<int> getAverageSteps() async {
    final db = await database;
    final result = await db.rawQuery(
      'SELECT AVG(steps) as average FROM step_data',
    );
    return (result.first['average'] as double?)?.round() ?? 0;
  }

  Future<int> getStreakDays() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'step_data',
      orderBy: 'date DESC',
    );

    int streak = 0;
    DateTime currentDate = DateTime.now();

    for (final map in maps) {
      final stepData = StepData.fromMap(map);
      final dateString = currentDate.toIso8601String().split('T')[0];
      final dataDateString = stepData.date.toIso8601String().split('T')[0];

      if (dateString == dataDateString && stepData.goalAchieved) {
        streak++;
        currentDate = currentDate.subtract(const Duration(days: 1));
      } else {
        break;
      }
    }

    return streak;
  }

  Future<void> deleteOldData({int daysToKeep = 90}) async {
    final db = await database;
    final cutoffDate = DateTime.now().subtract(Duration(days: daysToKeep));
    final cutoffString = cutoffDate.toIso8601String().split('T')[0];

    await db.delete('step_data', where: 'date < ?', whereArgs: [cutoffString]);
  }

  Future<void> close() async {
    final db = await database;
    await db.close();
  }
}

import 'dart:async';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/history.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  static Database? _database;

  // Database configuration
  static const String _databaseName = 'chat_history.db';
  static const int _databaseVersion = 1;
  static const String _tableName = 'history';

  // Column names
  static const String _columnId = 'id';
  static const String _columnMessages = 'messages';
  static const String _columnCreatedAt = 'created_at';
  static const String _columnUpdatedAt = 'updated_at';

  // Get database instance
  Future<Database> get database async {
    _database ??= await _initDatabase();
    return _database!;
  }

  // Initialize database
  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), _databaseName);
    
    return await openDatabase(
      path,
      version: _databaseVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  // Create tables
  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE $_tableName (
        $_columnId INTEGER PRIMARY KEY AUTOINCREMENT,
        $_columnMessages TEXT NOT NULL,
        $_columnCreatedAt TEXT NOT NULL,
        $_columnUpdatedAt TEXT NOT NULL
      )
    ''');
  }

  // Handle database upgrades
  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    // Handle future database migrations here
    if (oldVersion < newVersion) {
      // Example migration logic
      // await db.execute('ALTER TABLE $_tableName ADD COLUMN new_column TEXT');
    }
  }

  // Insert a new history record
  Future<int> insertHistory(History history) async {
    final db = await database;
    final historyWithTimestamp = history.copyWith(
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    
    return await db.insert(
      _tableName,
      historyWithTimestamp.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // Get all history records
  Future<List<History>> getAllHistory() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      _tableName,
      orderBy: '$_columnUpdatedAt DESC',
    );

    return List.generate(maps.length, (i) {
      return History.fromMap(maps[i]);
    });
  }

  // Get a specific history record by ID
  Future<History?> getHistory(int id) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      _tableName,
      where: '$_columnId = ?',
      whereArgs: [id],
      limit: 1,
    );

    if (maps.isNotEmpty) {
      return History.fromMap(maps.first);
    }
    return null;
  }

  // Update an existing history record
  Future<int> updateHistory(History history) async {
    final db = await database;
    final updatedHistory = history.copyWith(updatedAt: DateTime.now());
    
    return await db.update(
      _tableName,
      updatedHistory.toMap(),
      where: '$_columnId = ?',
      whereArgs: [history.id],
    );
  }

  // Delete a history record
  Future<int> deleteHistory(int id) async {
    final db = await database;
    return await db.delete(
      _tableName,
      where: '$_columnId = ?',
      whereArgs: [id],
    );
  }

  // Delete all history records
  Future<int> deleteAllHistory() async {
    final db = await database;
    return await db.delete(_tableName);
  }

  // Get the count of history records
  Future<int> getHistoryCount() async {
    final db = await database;
    final count = Sqflite.firstIntValue(
      await db.rawQuery('SELECT COUNT(*) FROM $_tableName'),
    );
    return count ?? 0;
  }

  // Search history records by text content
  Future<List<History>> searchHistory(String searchTerm) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      _tableName,
      where: '$_columnMessages LIKE ?',
      whereArgs: ['%$searchTerm%'],
      orderBy: '$_columnUpdatedAt DESC',
    );

    return List.generate(maps.length, (i) {
      return History.fromMap(maps[i]);
    });
  }

  // Get recent history records (last n records)
  Future<List<History>> getRecentHistory(int limit) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      _tableName,
      orderBy: '$_columnUpdatedAt DESC',
      limit: limit,
    );

    return List.generate(maps.length, (i) {
      return History.fromMap(maps[i]);
    });
  }

  // Close database
  Future<void> closeDatabase() async {
    final db = await database;
    await db.close();
    _database = null;
  }

  // Delete database file (for testing or reset purposes)
  Future<void> deleteDatabaseFile() async {
    String path = join(await getDatabasesPath(), _databaseName);
    await deleteDatabase(path);
    _database = null;
  }
}
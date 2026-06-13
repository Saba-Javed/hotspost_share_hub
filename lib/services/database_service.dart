import 'dart:async';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import '../models/session_model.dart';

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  factory DatabaseService() => _instance;
  DatabaseService._internal();

  Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB();
    return _database!;
  }

  Future<Database> _initDB() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'smart_share_hub.db');

    return openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future<void> _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE sessions (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        wifiName TEXT NOT NULL,
        wifiPassword TEXT NOT NULL,
        startTime TEXT NOT NULL,
        endTime TEXT,
        durationMinutes INTEGER NOT NULL,
        dataUsageMB REAL NOT NULL DEFAULT 0,
        connectedDevicesCount INTEGER NOT NULL DEFAULT 0,
        isActive INTEGER NOT NULL DEFAULT 1
      )
    ''');

    await db.execute('''
      CREATE TABLE connected_devices (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        sessionId INTEGER NOT NULL,
        deviceName TEXT NOT NULL,
        connectedAt TEXT NOT NULL,
        disconnectedAt TEXT,
        dataUsedMB REAL NOT NULL DEFAULT 0,
        FOREIGN KEY (sessionId) REFERENCES sessions (id) ON DELETE CASCADE
      )
    ''');
  }

  // ---------------- SESSION CRUD ----------------

  Future<int> insertSession(HotspotSession session) async {
    final db = await database;
    return await db.insert('sessions', session.toMap()
      ..remove('id'));
  }

  Future<int> updateSession(HotspotSession session) async {
    final db = await database;
    return await db.update(
      'sessions',
      session.toMap(),
      where: 'id = ?',
      whereArgs: [session.id],
    );
  }

  Future<HotspotSession?> getActiveSession() async {
    final db = await database;
    final maps = await db.query(
      'sessions',
      where: 'isActive = ?',
      whereArgs: [1],
      orderBy: 'id DESC',
      limit: 1,
    );
    if (maps.isEmpty) return null;
    return HotspotSession.fromMap(maps.first);
  }

  Future<List<HotspotSession>> getAllSessions() async {
    final db = await database;
    final maps = await db.query('sessions', orderBy: 'startTime DESC');
    return maps.map((m) => HotspotSession.fromMap(m)).toList();
  }

  Future<List<HotspotSession>> getCompletedSessions() async {
    final db = await database;
    final maps = await db.query(
      'sessions',
      where: 'isActive = ?',
      whereArgs: [0],
      orderBy: 'startTime DESC',
    );
    return maps.map((m) => HotspotSession.fromMap(m)).toList();
  }

  Future<int> deleteSession(int id) async {
    final db = await database;
    await db.delete('connected_devices', where: 'sessionId = ?', whereArgs: [id]);
    return await db.delete('sessions', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> clearAllHistory() async {
    final db = await database;
    await db.delete('connected_devices');
    await db.delete('sessions');
  }

  // ---------------- CONNECTED DEVICES CRUD ----------------

  Future<int> insertDevice(ConnectedDevice device) async {
    final db = await database;
    return await db.insert('connected_devices', device.toMap()..remove('id'));
  }

  Future<int> updateDevice(ConnectedDevice device) async {
    final db = await database;
    return await db.update(
      'connected_devices',
      device.toMap(),
      where: 'id = ?',
      whereArgs: [device.id],
    );
  }

  Future<List<ConnectedDevice>> getDevicesForSession(int sessionId) async {
    final db = await database;
    final maps = await db.query(
      'connected_devices',
      where: 'sessionId = ?',
      whereArgs: [sessionId],
      orderBy: 'connectedAt DESC',
    );
    return maps.map((m) => ConnectedDevice.fromMap(m)).toList();
  }

  // ---------------- ANALYTICS ----------------

  Future<double> getTotalUsage() async {
    final db = await database;
    final result = await db.rawQuery(
      'SELECT SUM(dataUsageMB) as total FROM sessions',
    );
    final total = result.first['total'];
    if (total == null) return 0.0;
    return (total as num).toDouble();
  }

  Future<double> getUsageSince(DateTime since) async {
    final db = await database;
    final result = await db.rawQuery(
      'SELECT SUM(dataUsageMB) as total FROM sessions WHERE startTime >= ?',
      [since.toIso8601String()],
    );
    final total = result.first['total'];
    if (total == null) return 0.0;
    return (total as num).toDouble();
  }

  Future<Map<String, double>> getDailyUsage(int days) async {
    final db = await database;
    final Map<String, double> result = {};
    final now = DateTime.now();

    for (int i = days - 1; i >= 0; i--) {
      final day = DateTime(now.year, now.month, now.day).subtract(Duration(days: i));
      final nextDay = day.add(const Duration(days: 1));

      final rows = await db.rawQuery(
        'SELECT SUM(dataUsageMB) as total FROM sessions WHERE startTime >= ? AND startTime < ?',
        [day.toIso8601String(), nextDay.toIso8601String()],
      );

      final total = rows.first['total'];
      final key = '${day.month}/${day.day}';
      result[key] = total == null ? 0.0 : (total as num).toDouble();
    }
    return result;
  }
}

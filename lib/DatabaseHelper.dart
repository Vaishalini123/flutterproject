import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'dart:async';

import 'Item.dart';

class DatabaseHelper {

  static const String DATABASE_NAME = 'NotificationReceived.db';
  static const int DATABASE_VERSION = 1;
  static const String TABLE_NAME = 'items';
  static const String COLUMN_ID = 'id';
  static const String COLUMN_TITLE = 'Notification_header';
  static const String COLUMN_MESSAGE = 'Notification_message';
  static const String COLUMN_TIME = 'Notification_send_time';
  static const String COLUMN_IS_READ = 'COLUMN_IS_READ';

  static const String TABLE_CREATE = '''
    CREATE TABLE $TABLE_NAME (
      $COLUMN_ID INTEGER PRIMARY KEY AUTOINCREMENT,
      $COLUMN_TITLE TEXT,
      $COLUMN_MESSAGE TEXT,
      $COLUMN_IS_READ INT,
      $COLUMN_TIME TEXT
    );
  ''';

  static Database? _database;

  static Future<Database> get database async {
    if (_database != null) {
      return _database!;
    }
    _database = await initDatabase();
    return _database!;
  }

  static Future<Database> initDatabase() async {
    String path = await getDatabasesPath();
    return openDatabase(
      join(path, DATABASE_NAME),
      onCreate: (db, version) async {
        await db.execute(TABLE_CREATE);
        String timestamp = DateTime.now().toString();

        await db.insert(
          TABLE_NAME,
          {
            COLUMN_TITLE: 'Welcome',
            COLUMN_MESSAGE:
            'You have successfully installed the CeGov mobile application.',
            COLUMN_IS_READ: 0,
            COLUMN_TIME: timestamp,
          },
        );
      },
      version: DATABASE_VERSION,
    );
  }

  static Future<void> insertNotification(
      String title, String message, String timestamp) async {
    Database db = await database;
    await db.insert(
      TABLE_NAME,
      {
        COLUMN_TITLE: title,
        COLUMN_MESSAGE: message,
        COLUMN_TIME: timestamp,
        COLUMN_IS_READ: 0,
      },
    );
  }

  static Future<void> markAllNotificationsAsRead() async {
    Database db = await database;
    await db.update(
      TABLE_NAME,
      {COLUMN_IS_READ: 1},
      where: '$COLUMN_IS_READ = ?',
      whereArgs: [0],
    );
  }

  static Future<void> deleteItemFromDatabase(int itemId) async {
    Database db = await database;
    await db.delete(
      TABLE_NAME,
      where: '$COLUMN_ID = ?',
      whereArgs: [itemId],
    );
  }


  Future<List<Item>> getItems() async {
    try {
      Database db = await initDatabase();
      List<Map<String, dynamic>> result = await db.query(TABLE_NAME, orderBy: '$COLUMN_TIME DESC');
      List<Item> items = result.map((item) => Item.fromMap(item)).toList();

      return items;
    } catch (e) {
      print("Error getting items: $e");
      return [];
    }
  }



}

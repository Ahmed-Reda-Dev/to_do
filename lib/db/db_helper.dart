import 'package:flutter/cupertino.dart';
import 'package:sqflite/sqflite.dart';

import '../models/task.dart';

class DBHelper
{
  static Database? _db;
  static const int version = 1;
  static const String tableName = "tasks";

  static Future<void> initDb() async
  {
    if (_db != null) {
      debugPrint("DBHelper: DB already initialized");

      return;
    }else{
      try {
        String path = await getDatabasesPath()+"task.db";
        _db = await openDatabase(path, version: version, onCreate: (Database db, int version) async {
          debugPrint("DBHelper: Creating table $tableName");
          await db.execute(
              'CREATE TABLE $tableName ('
              'id INTEGER PRIMARY KEY AUTOINCREMENT, '
              'title STRING, note TEXT,isCompleted INTEGER, '
                  'date STRING, '
              'startTime STRING, endTime STRING, '
              'remind INTEGER, repeat STRING, '
              'color INTEGER)'
          );
        });
      } catch (e) {
        debugPrint("DBHelper: Error opening DB: $e");
      }
    }
  }

  static Future<int> insert(Task task) async
  {
    debugPrint("DBHelper: Inserting task: $task");
    return await _db!.insert(tableName, task.toJson());
  }

  static Future<List<Map<String, dynamic>>> query() async
  {
    debugPrint("DBHelper: Querying tasks");
    return await _db!.query(tableName);
  }

  static Future<int> delete(Task task) async
  {
    debugPrint("DBHelper: Deleting task: $task");
    return await _db!.delete(tableName, where: "id = ?", whereArgs: [task.id]);
  }

  static Future<int> deleteAll() async
  {
    return await _db!.delete(tableName);
  }

  static Future<int> update(int id) async
  {
    debugPrint("DBHelper: Updating task");
    return await _db!.rawUpdate("UPDATE tasks SET isCompleted = ? WHERE id = ?", [1, id]);
  }
}

// ignore_for_file: avoid_print, file_names
import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart' as sql;

class Sql{
  static Future<void> createTodos(sql.Database database) async {
    await database.execute(
        """
        CREATE TABLE todos(
        id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
        title TEXT,
        description TEXT, 
        dateCreated TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
        )
        """
    );
  }

  static Future<sql.Database> createMethod() async{
    return sql.openDatabase(
        'todosDB.db',
        version: 1,
        onCreate: (sql.Database database, int version) async {
          print('Creating a Table');
          await createTodos(database);
        }
    );
  }

  static Future<int> createItem(String title, String? description) async {
    final database = await Sql.createMethod();
    final data = {
      'title': title,
      'description': description
    };
    final id = await database.insert(
        'todos',
        data,
        conflictAlgorithm: sql.ConflictAlgorithm.replace //helps prevent duplicate entries
    );
    return id;
  }

  static Future<List<Map<String, dynamic>>> getTodos() async {
    final database = await Sql.createMethod();
    return database.query(
        'todos',
        orderBy: 'id'
    );
  }

  static Future<List<Map<String, dynamic>>> getTodo(int id) async {
    final database = await Sql.createMethod();
    return database.query(
        'todos',
        where: 'id = ?',
        whereArgs: [id],
        limit: 1
    );
  }

  static Future<int> updateTodo(int id, String title, String? description) async {
    final database = await Sql.createMethod();
    final data = {
      'title': title,
      'description': description,
      'dateCreated': DateTime.now().toString()
    };
    final result = await database.update(
        'todos',
        data,
        where: 'id = ?',
        whereArgs: [id]
    );
    return result;
  }

  static Future<void> deleteTodo(int id) async {
    final database = await Sql.createMethod();
    try {
      await database.delete(
          'todos',
          where: 'id = ?',
          whereArgs: [id]
      );
    } catch (error){
      debugPrint('Deletion Failed: $error');
    }
  }
}
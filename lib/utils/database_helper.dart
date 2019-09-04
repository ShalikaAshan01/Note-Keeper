import 'dart:core';
import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:second_flutter/models/Note.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelper {
  static DatabaseHelper _databaseHelper; //singleton
  static Database _database; //singleton

  String noteTable = 'note_table';
  String colId = "id";
  String colTitle = "title";
  String colDescription = "description";
  String colPriority = "priority";
  String colDate = "date";

  DatabaseHelper.createInstance(); //MNamed constructor to create instance of Database Helper

  factory DatabaseHelper() {
    if (_databaseHelper == null)
      _databaseHelper = DatabaseHelper.createInstance(); //singleton object
    return _databaseHelper;
  }

  Future<Database> get database async {
    if (_database == null) {
      _database = await initializeDatabase();
    }
    return _database;
  }

  Future<Database> initializeDatabase() async {
    //get the directory path for store db
    Directory directory = await getApplicationDocumentsDirectory();
    String path = directory.path + "notes.db";

    //open,create the db
    return await openDatabase(path, version: 1, onCreate: _createDb);
  }

  void _createDb(Database db, int newVersion) async {
    await db.execute(""
        "CREATE TABLE $noteTable ("
        "$colId INTEGER PRIMARY kEY AUTOINCREMENT,"
        "$colTitle TEXT,"
        "$colDescription TEXT,"
        "$colPriority INTEGER,"
        "$colDate TEXT"
        ")");
  }

  //fetch notes
  Future<List<Map<String, dynamic>>> getNoteListMap() async {
    Database db = await this.database;
    return await db.rawQuery(
        "SELECT * FROM $noteTable order by $colPriority ASC");
  }

  //insert
  Future<int> insertNote(Note note) async {
    Database db = await this.database;
    return await db.insert(noteTable, note.toMap());
  }

  //update
  Future<int> updateNOtes(Note note) async {
    Database db = await this.database;
    return await db.update(
        noteTable, note.toMap(), where: '$colId = ?', whereArgs: [note.id]);
  }

  //delete
  Future<int> deleteNote(int id) async {
    Database db = await this.database;
    return await db.rawDelete("DElETE FROM $noteTable WHERE $colId = $id");
  }

  //get number of notes in db
  Future<int> getCount() async{
    Database db = await this.database;
    List<Map<String, dynamic>> x = await db.rawQuery("SELECT COUNT(*) FROM $noteTable");
    return   Sqflite.firstIntValue(x);
  }
  //  map list to list
  Future<List<Note>> getNoteList() async{
    var noteMapList = await getNoteListMap();
    List<Note> noteList = List<Note>();

    for (int i=0; i < noteMapList.length; i++){
      noteList.add(Note.fromMapObject(noteMapList[i]));
    }
    return noteList;
  }
}
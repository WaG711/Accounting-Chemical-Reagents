import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelper {
  Future<Database> initDatabase() async {
    return openDatabase(join(await getDatabasesPath(), 'chemical_reagents_database.db'),
      onCreate: (db, version) async {
        await db.execute(
            'CREATE TABLE reagents (id INTEGER PRIMARY KEY, name TEXT NOT NULL, formula TEXT NOT NULL)');
        await db.execute(
            'CREATE TABLE reagent_warehouse (id INTEGER PRIMARY KEY, reagent_id INTEGER NOT NULL, quantity INTEGER NOT NULL, FOREIGN KEY (reagent_id) REFERENCES reagents(id) ON DELETE CASCADE)');
          await db.execute(
            'CREATE TABLE warehouse (id INTEGER PRIMARY KEY, reagent_id INTEGER NOT NULL, quantity INTEGER NOT NULL, FOREIGN KEY (reagent_id) REFERENCES reagents(id) ON DELETE CASCADE)');
        await db.execute(
            'CREATE TABLE recipes (id INTEGER PRIMARY KEY, status INTEGER NOT NULL)');
        await db.execute(
            'CREATE TABLE ready_recipes (id INTEGER PRIMARY KEY)');
      },
      version: 1,
    );
  }
}

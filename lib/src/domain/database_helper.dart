import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelper {
  Future<Database> initDatabase() async {
    return openDatabase(
      join(await getDatabasesPath(), 'chemical_reagents_database.db'),
      onCreate: (db, version) async {
        await db.execute(
            'CREATE TABLE reagents (id INTEGER PRIMARY KEY, name TEXT NOT NULL, formula TEXT NOT NULL)');
        await db.execute(
            'CREATE TABLE warehouse (id INTEGER PRIMARY KEY, reagent_id INTEGER NOT NULL, quantity INTEGER NOT NULL, FOREIGN KEY (reagent_id) REFERENCES reagents(id))');
        await db.execute(
            'CREATE TABLE recipes (id INTEGER PRIMARY KEY, isAccepted INTEGER NOT NULL, isEnough INTEGER NOT NULL)');
        await db.execute(
            'CREATE TABLE recipe_reagent (recipe_id INTEGER, reagent_id INTEGER, quantity INTEGER NOT NULL, FOREIGN KEY (recipe_id) REFERENCES recipes(id), FOREIGN KEY (reagent_id) REFERENCES reagents(id), PRIMARY KEY (recipe_id, reagent_id))');
        await db.execute(
          'CREATE TABLE ready_recipes (id INTEGER PRIMARY KEY, name TEXT NOT NULL)');
        await db.execute(
            'CREATE TABLE ready_recipe_reagent (ready_recipe_id INTEGER, reagent_id INTEGER, quantity INTEGER NOT NULL, FOREIGN KEY (ready_recipe_id) REFERENCES ready_recipes(id), FOREIGN KEY (reagent_id) REFERENCES reagents(id), PRIMARY KEY (ready_recipe_id, reagent_id))');
      },
      version: 1,
    );
  }
}

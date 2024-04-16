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
            'CREATE TABLE warehouse (reagent_id INTEGER PRIMARY KEY,quantity INTEGER NOT NULL,FOREIGN KEY (reagent_id) REFERENCES reagents(id) ON DELETE CASCADE)');
        await db.execute(
            'CREATE TABLE recipes (id INTEGER PRIMARY KEY, status INTEGER NOT NULL)');
        await db.execute(
            'CREATE TABLE recipe_reagents (recipe_id INTEGER NOT NULL, reagent_id INTEGER NOT NULL, FOREIGN KEY (recipe_id) REFERENCES recipes(id) ON DELETE CASCADE, FOREIGN KEY (reagent_id) REFERENCES reagents(id) ON DELETE CASCADE, PRIMARY KEY (recipe_id, reagent_id))');
        await db.execute(
            'CREATE TABLE ready_recipes (id INTEGER PRIMARY KEY)');
        await db.execute(
            'CREATE TABLE ready_recipe_reagents (ready_recipe_id INTEGER, reagent_id INTEGER, FOREIGN KEY (ready_recipe_id) REFERENCES ready_recipes(id) ON DELETE CASCADE, FOREIGN KEY (reagent_id) REFERENCES reagents(id) ON DELETE CASCADE, PRIMARY KEY (ready_recipe_id, reagent_id))');
      },
      version: 1,
    );
  }
}

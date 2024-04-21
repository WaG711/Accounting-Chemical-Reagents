import 'package:accounting_chemical_reagents/src/domain/model/ready_recipe_reagent.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class ReadyRecipeReagentRepository {
  final String nameTable = 'ready_recipe_reagent';

  Future<Database> _getDatabase() async {
    return openDatabase(
        join(await getDatabasesPath(), 'chemical_reagents_database.db'));
  }

  Future<int> insertReadyRecipeReagent(ReadyRecipeReagent recipeReagent) async {
    final database = await _getDatabase();
    return await database.insert(nameTable, recipeReagent.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<ReadyRecipeReagent>> getReadyRecipeReagents() async {
    final database = await _getDatabase();
    final List<Map<String, dynamic>> maps = await database.query(nameTable);
    return List.generate(maps.length, (index) {
      return ReadyRecipeReagent.fromMap(maps[index]);
    });
  }

  Future<List<Map<String, dynamic>>> getReagentsForReadyRecipe(
      int readyRecipeId) async {
    final database = await _getDatabase();
    final List<Map<String, dynamic>> reagents = await database.query(
      nameTable,
      columns: ['reagent_id', 'quantity'],
      where: 'ready_recipe_id = ?',
      whereArgs: [readyRecipeId],
    );
    return reagents;
  }

  Future<void> deleteReadyRecipeReagent(int id) async {
    final database = await _getDatabase();
    await database.delete(
      nameTable,
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}

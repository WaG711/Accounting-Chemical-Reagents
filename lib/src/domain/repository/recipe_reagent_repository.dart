import 'package:accounting_chemical_reagents/src/domain/model/recipe_reagent.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class RecipeReagentRepository {
  final String nameTable = 'recipe_reagent';

  Future<Database> _getDatabase() async {
    return openDatabase(
        join(await getDatabasesPath(), 'chemical_reagents_database.db'));
  }

  Future<int> insertRecipeReagent(RecipeReagent recipeReagent) async {
    final database = await _getDatabase();
    return await database.insert(nameTable, recipeReagent.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<RecipeReagent>> getRecipeReagents() async {
    final database = await _getDatabase();
    final List<Map<String, dynamic>> maps = await database.query(nameTable);
    return List.generate(maps.length, (index) {
      return RecipeReagent.fromMap(maps[index]);
    });
  }

  Future<List<int>> getReagentIdsForRecipe(int recipeId) async {
    final database = await _getDatabase();
    final List<Map<String, dynamic>> maps = await database.query(
      nameTable,
      columns: ['reagent_id'],
      where: 'recipe_id = ?',
      whereArgs: [recipeId],
    );
    return List.generate(maps.length, (index) {
      return maps[index]['reagent_id'] as int;
    });
  }

  Future<void> deleteRecipeReagent(int id) async {
    final database = await _getDatabase();
    await database.delete(
      nameTable,
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}

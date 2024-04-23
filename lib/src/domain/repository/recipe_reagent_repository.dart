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

  Future<List<Map<String, dynamic>>> getReagentsForRecipe(int recipeId) async {
    final database = await _getDatabase();
    final List<Map<String, dynamic>> reagents = await database.query(
      nameTable,
      columns: ['reagent_id', 'quantity'],
      where: 'recipe_id = ?',
      whereArgs: [recipeId],
    );
    return reagents;
  }

  Future<void> deleteRecipeReagents(int recipeId) async {
    final database = await _getDatabase();
    await database.delete(
      nameTable,
      where: 'recipe_id = ?',
      whereArgs: [recipeId],
    );
  }
}

import 'package:accounting_chemical_reagents/src/domain/model/recipe.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class RecipeRepository {
  final String nameTable = 'recipes';

  Future<Database> _getDatabase() async {
    return openDatabase(
        join(await getDatabasesPath(), 'chemical_reagents_database.db'));
  }

  Future<int> insertRecipe(RecipeModel recipe) async {
    final database = await _getDatabase();
    return await database.insert(nameTable, recipe.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<RecipeModel>> getRecipesAcceptedFalse() async {
    final database = await _getDatabase();
    final List<Map<String, dynamic>> maps = await database.query(
      nameTable,
      where: 'isAccepted = ? AND isEnough = ?',
      whereArgs: [false, true],
    );
    return List.generate(maps.length, (index) {
      return RecipeModel.fromMap(maps[index]);
    });
  }

  Future<List<RecipeModel>> getRecipesFalse() async {
    final database = await _getDatabase();
    final List<Map<String, dynamic>> maps = await database.query(
      nameTable,
      where: 'isEnough = ?',
      whereArgs: [false],
    );
    return List.generate(maps.length, (index) {
      return RecipeModel.fromMap(maps[index]);
    });
  }

  Future<List<RecipeModel>> getRecipesTrue() async {
    final database = await _getDatabase();
    final List<Map<String, dynamic>> maps = await database.query(
      nameTable,
      where: 'isAccepted = ?',
      whereArgs: [true],
    );
    return List.generate(maps.length, (index) {
      return RecipeModel.fromMap(maps[index]);
    });
  }

  Future<void> updateRecipe(RecipeModel updatedRecipe) async {
    final database = await _getDatabase();
    await database.update(
      nameTable,
      updatedRecipe.toMap(),
      where: 'id = ?',
      whereArgs: [updatedRecipe.id],
    );
  }

  Future<void> deleteRecipe(int id) async {
    final database = await _getDatabase();
    await database.delete(
      nameTable,
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}

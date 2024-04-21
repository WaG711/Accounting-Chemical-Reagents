import 'package:accounting_chemical_reagents/src/domain/model/ready_recipe.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class ReadyRecipeRepository {
  final String nameTable = 'ready_recipes';

  Future<Database> _getDatabase() async {
    return openDatabase(
        join(await getDatabasesPath(), 'chemical_reagents_database.db'));
  }

  Future<int> insertReadyRecipe(ReadyRecipeModel readyRecipe) async {
    final database = await _getDatabase();
    return await database.insert(nameTable, readyRecipe.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<ReadyRecipeModel>> getReadyRecipes() async {
    final database = await _getDatabase();
    final List<Map<String, dynamic>> maps = await database.query(nameTable);
    return List.generate(
      maps.length,
      (index) {
        return ReadyRecipeModel.fromMap(maps[index]);
      },
    );
  }

  Future<void> deleteReadyRecipe(int id) async {
    final database = await _getDatabase();
    await database.delete(
      nameTable,
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}

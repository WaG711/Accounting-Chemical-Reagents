import 'package:accounting_chemical_reagents/src/domain/model/recipe.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class RecipeRepository {
  final String nameTable = 'recipes';

  Future<Database> _getDatabase() async {
    return openDatabase(join(await getDatabasesPath(), 'chemical_reagents_database.db'));
  }

  Future<int> insertRecipe(RecipeModel recipe) async {
    final database = await _getDatabase();
    return await database.insert(nameTable, recipe.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<RecipeModel>> getRecipes() async {
    final database = await _getDatabase();
    final List<Map<String, dynamic>> maps = await database.query(nameTable);
    return List.generate(maps.length, (index) {
      return RecipeModel.fromMap(maps[index]);
    });
  }
}

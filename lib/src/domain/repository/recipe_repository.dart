import 'package:accounting_chemical_reagents/src/domain/model/recipe.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class RecipeRepository {
  Future<int> insertRecipe(Recipe recipe) async {
    final database = await openDatabase(join(await getDatabasesPath(), 'chemical_reagents_database.db'));
    return await database.insert('recipes', recipe.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<Recipe>> getRecipes() async {
    final database = await openDatabase(join(await getDatabasesPath(), 'chemical_reagents_database.db'));
    final List<Map<String, dynamic>> maps = await database.query('recipes');
    return List.generate(maps.length, (index) {
      return Recipe.fromMap(maps[index]);
    });
  }
}

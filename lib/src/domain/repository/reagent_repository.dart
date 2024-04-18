import 'package:accounting_chemical_reagents/src/domain/model/reagent.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class ReagentRepository {
  Future<int> insertReagent(Reagent reagent) async {
    final database = await openDatabase(join(await getDatabasesPath(), 'chemical_reagents_database.db'));
    return await database.insert('reagents', reagent.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<Reagent>> getReagents() async {
    final database = await openDatabase(join(await getDatabasesPath(), 'chemical_reagents_database.db'));
    final List<Map<String, dynamic>> maps = await database.query('reagents');
    return List.generate(maps.length, (index) {
        return Reagent.fromMap(maps[index]);
      },
    );
  }

  Future<void> deleteReagent(int id) async {
    final database = await openDatabase(join(await getDatabasesPath(), 'chemical_reagents_database.db'));
    await database.delete(
      'reagents',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}

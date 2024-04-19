import 'package:accounting_chemical_reagents/src/domain/model/reagent.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class ReagentRepository {
  final String nameTable = 'reagents';

  Future<Database> _getDatabase() async {
    return openDatabase(
        join(await getDatabasesPath(), 'chemical_reagents_database.db'));
  }

  Future<int> insertReagent(Reagent reagent) async {
    final database = await _getDatabase();
    return await database.insert(nameTable, reagent.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<Reagent>> getReagents() async {
    final database = await _getDatabase();
    final List<Map<String, dynamic>> maps = await database.query(nameTable);
    return List.generate(
      maps.length,
      (index) {
        return Reagent.fromMap(maps[index]);
      },
    );
  }

  Future<Reagent> getReagentById(int reagentId) async {
    final database = await _getDatabase();
    final List<Map<String, dynamic>> maps = await database
        .query(nameTable, where: 'id = ?', whereArgs: [reagentId]);
    return Reagent.fromMap(maps.first);
  }

  Future<void> deleteReagent(int id) async {
    final database = await _getDatabase();
    await database.delete(
      nameTable,
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}

import 'package:accounting_chemical_reagents/src/domain/model/warehouse.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class WarehouseRepository {
  Future<int> insertElement(WarehouseModel warehouse) async {
    final database = await openDatabase(join(await getDatabasesPath(), 'chemical_reagents_database.db'));
    return await database.insert('warehouse', warehouse.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<WarehouseModel>> getElements() async {
    final database = await openDatabase(join(await getDatabasesPath(), 'chemical_reagents_database.db'));
    final List<Map<String, dynamic>> maps = await database.query('warehouse');
    return List.generate(maps.length, (index) {
        return WarehouseModel.fromMap(maps[index]);
      },
    );
  }

  Future<void> deleteElement(int id) async {
    final database = await openDatabase(join(await getDatabasesPath(), 'chemical_reagents_database.db'));
    await database.delete(
      'warehouse',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
import 'package:accounting_chemical_reagents/src/domain/model/warehouse.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class WarehouseRepository {
  final String nameTable = 'warehouse';

  Future<Database> _getDatabase() async {
    return openDatabase(
        join(await getDatabasesPath(), 'chemical_reagents_database.db'));
  }

  Future<int> insertElement(WarehouseModel warehouse) async {
    final database = await _getDatabase();
    return await database.insert(nameTable, warehouse.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<WarehouseModel>> getElements() async {
    final database = await _getDatabase();
    final List<Map<String, dynamic>> maps = await database.query(nameTable);
    return List.generate(
      maps.length,
      (index) {
        return WarehouseModel.fromMap(maps[index]);
      },
    );
  }

  Future<WarehouseModel?> getElementByReagentId(int reagentId) async {
    final database = await _getDatabase();
    final List<Map<String, dynamic>> maps = await database.query(
      nameTable,
      where: 'reagent_id = ?',
      whereArgs: [reagentId],
      limit: 1,
    );
    if (maps.isNotEmpty) {
      return WarehouseModel.fromMap(maps.first);
    } else {
      return null;
    }
  }

  Future<void> updateElement(WarehouseModel updatedWarehouse) async {
    final database = await _getDatabase();
    await database.update(
      nameTable,
      updatedWarehouse.toMap(),
      where: 'id = ?',
      whereArgs: [updatedWarehouse.id],
    );
  }

  Future<void> deleteElement(int id) async {
    final database = await _getDatabase();
    await database.delete(
      nameTable,
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}

import 'package:dio/dio.dart';
import 'package:get/get.dart';
import 'package:pos/Dio/client_dio.dart';
import 'package:pos/table/models/table.dart';
import '../../constants.dart';

class TableController extends GetxController {
  RxList<Table> tableList = <Table>[].obs;
  final ClientDio _clientDio = ClientDio();

  Future<void> addTable(Table table) async {
    try {
      final response = await _clientDio.dio.post(
        Constants.addTableUrl(),
        data: table.toJson(),
        options: Options(
          headers: {
            'Content-Type': 'application/json',
          },
        ),
      );

      if (response.statusCode == 200) {
        print('Table added successfully');
        await getTableList();
      } else {
        print('Failed to add table: ${response.statusCode}');
      }
    } catch (e) {
      print('Error adding table: $e');
    }
  }

  Future<void> getTableList() async {
    try {
      final response = await _clientDio.dio.get(
        Constants.getTableUrl(),
        options: Options(
          headers: {
            'Content-Type': 'application/json',
          },
        ),
      );
      if (response.statusCode == 200) {
        final List<dynamic> tablesJson = response.data;
        final List<Table> tables = tablesJson.map((tableJson) => Table.fromJson(tableJson)).toList();
        tableList.assignAll(tables);
        print(tableList);
      } else {
        print('Failed to get table list: ${response.statusCode}');
      }
    } catch (e) {
      print('$e');
    }
  }

  Future<void> updateTable(Table updatedTable) async {
    try {
      final response = await _clientDio.dio.patch(
        '${Constants.tableEndpoint}/${updatedTable.id}',
        data: updatedTable.toJson(),
        options: Options(
          headers: {
            'Content-Type': 'application/json',
          },
        ),
      );

      if (response.statusCode == 200) {
        print('Table updated successfully');
        int index = tableList.indexWhere((table) => table.id == updatedTable.id);
        if (index != -1) {
          tableList[index] = updatedTable;
        }
      } else {
        print('Failed to update table: ${response.statusCode}');
      }
    } catch (e) {
      print('Error updating table: $e');
    }
  }
}

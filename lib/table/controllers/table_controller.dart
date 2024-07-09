import 'package:dio/dio.dart';
import 'package:get/get.dart';
import 'package:pos/Dio/client_dio.dart';
import 'package:pos/constants.dart';
import 'package:pos/room/controllers/room_controller.dart';
import 'package:pos/table/models/table.dart';

class TableController extends GetxController {
  RxList<Table> tablesList = <Table>[].obs;
  RxBool isLoading = false.obs;
  RxDouble occupiedPercentage = 0.0.obs;
  RxDouble availablePercentage = 0.0.obs;
  final RoomController roomController = Get.put(RoomController());

  final ClientDio _clientDio = ClientDio();

  @override
  void onInit() {
    super.onInit();

    getTables();
    calculateTableOccupancy();
  }

  Future<List<Table>> getTables() async {
    try {
      isLoading.value = true;
      final response = await _clientDio.dio.get(
        Constants.getTableUrl(),
        options: Options(
          headers: {
            'Content-Type': 'application/json',
          },
        ),
      );
      isLoading.value = false;
      if (response.statusCode == 200) {
        final List<dynamic> tablesJson = response.data;
        final List<Table> tables =
            tablesJson.map((tableJson) => Table.fromJson(tableJson)).toList();

        tablesList.assignAll(tables);
        calculateTableOccupancy();
      } else {
        print('Échec du chargement des tables: ${response.statusCode}');
      }
    } catch (e) {
      isLoading.value = false;
      print('Erreur lors du chargement des tables: $e');
    }
    return tablesList;
  }

  void calculateTableOccupancy() {
    final totalTables = tablesList.length;
    final occupiedTables =
        tablesList.where((table) => table.active == true).length;
    final availableTables = totalTables - occupiedTables;

    occupiedPercentage.value =
        totalTables == 0 ? 0 : (occupiedTables / totalTables) * 100;
    availablePercentage.value =
        totalTables == 0 ? 0 : (availableTables / totalTables) * 100;
  }

  Future<Table?> updateTable(String id) async {
    try {
      final dio = Dio();
      final url = Constants.updateTableUrl(id);
      final requestData = {
        'active': true,
      };

      final response = await dio.patch(
        url,
        data: requestData,
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = response.data;
        final updatedTable = Table.fromJson(responseData);
        tablesList.refresh();
        calculateTableOccupancy();
        return updatedTable;
      } else {
        print('Échec de la mise à jour: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Erreur lors de la mise à jour: $e');
      return null;
    }
  }
}

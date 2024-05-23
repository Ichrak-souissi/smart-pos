import 'package:dio/dio.dart';
import 'package:get/get.dart';
import 'package:pos/Dio/client_dio.dart';
import 'package:pos/constants.dart';
import 'package:pos/room/models/room.dart';
import 'package:pos/table/models/table.dart';


class TableController extends GetxController {
  RxList<Room> roomList = <Room>[].obs;
  RxList<Table> tablesList = <Table>[].obs;

  RxList<Table> roomTables = <Table>[].obs;
  RxBool isLoading = false.obs;

  final ClientDio _clientDio = ClientDio();

  Future<List<Table>> getTableList() async {
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
    if (response.statusCode == 200) {
      final List<dynamic> tablesJson = response.data;
      final List<Table> tables = tablesJson
          .map((tableJson) => Table.fromJson(tableJson))
          .toList();

      tablesList.assignAll(tables); 
      isLoading.value = false; 
      return tablesList; 
    } else {
      isLoading.value = false; 
      return [];
    }
  } catch (e) {
    isLoading.value = false; 
    rethrow;
  }
  }
 
 Future<Table?> updateTable(String id) async {
  try {
    // ignore: avoid_print
    print('ID sélectionné pour la mise à jour : $id'); 
    
    final dio = Dio();
    final url = Constants.updateTableUrl(id);
    final requestData = {
      'active': true,
    };
    // ignore: avoid_print
    print('Données envoyées au backend : $requestData'); 

    final response = await dio.patch(
      url,
      data: requestData,
    );
    
    print('Réponse du backend : ${response.data}'); 

    if (response.statusCode == 200) {
      final Map<String, dynamic> responseData = response.data;
      final updatedTable = Table.fromJson(responseData); 
      print('Mise à jour réussie ! Nouvelle table : $updatedTable');
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
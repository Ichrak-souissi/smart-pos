import 'package:dio/dio.dart';
import 'package:get/get.dart';
import 'package:pos/Dio/client_dio.dart';
import 'package:pos/constants.dart';
import 'package:pos/room/models/room.dart';
import 'package:pos/table/models/table.dart';


class RoomController extends GetxController {
  RxList<Room> roomList = <Room>[].obs;
  RxList<Table> tableList = <Table>[].obs;

  RxList<Table> roomTables = <Table>[].obs;
  RxBool isLoading = false.obs;

  final ClientDio _clientDio = ClientDio();

  Future<List<Room>> getRoomList() async {
    try {
      isLoading.value = true;
      final response = await _clientDio.dio.get(
        Constants.getRoomUrl(),
        options: Options(
          headers: {
            'Content-Type': 'application/json',
          },
        ),
      );
      if (response.statusCode == 200) {
        final List<dynamic> roomsJson = response.data;
        final List<Room> rooms = roomsJson
            .map((roomJson) => Room.fromJson(roomJson))
            .toList();
        isLoading.value = false;
        roomList.assignAll(rooms);
        print('List of rooms: $rooms'); // Ajout de la ligne pour imprimer la liste des salles
        return roomList;
      } else {
        isLoading.value = false;
        return [];
      }
    } catch (e) {
      isLoading.value = false;
      print('Error getting room list: $e'); // Ajout de la ligne pour imprimer l'erreur
      rethrow;
    }
  }

  Future<List<Table>> getTablesByRoomId(int roomId) async {
    try {
      isLoading.value = true;
      final response = await _clientDio.dio.get(
        Constants.getTablesByRoomIdUrl(roomId.toString()),
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
        isLoading.value = false;
        tables.sort((a, b) => a.position.compareTo(b.position));
        tableList.assignAll(tables);
        print('List of tables for room ID $roomId: $tables'); 
        return tableList;
      } else {
        isLoading.value = false;
        return [];
      }
    } catch (e) {
      isLoading.value = false;
      print('Error getting tables for room ID $roomId: $e'); 
      rethrow;
    }
  }
}

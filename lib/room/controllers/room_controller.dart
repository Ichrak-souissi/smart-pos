import 'package:get/get.dart';
import 'package:dio/dio.dart';
import 'package:pos/Dio/client_dio.dart';
import 'package:pos/constants.dart';
import 'package:pos/room/models/room.dart';
import 'package:pos/table/models/table.dart';

class RoomController extends GetxController {
  RxList<Room> roomList = <Room>[].obs;
  RxList<Table> tableList = <Table>[].obs;
  RxBool isLoading = false.obs;

  final ClientDio _clientDio = ClientDio();

  @override
  void onInit() {
    super.onInit();
    getRoomList();
  }

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
        final List<Room> rooms =
            roomsJson.map((roomJson) => Room.fromJson(roomJson)).toList();
        roomList.assignAll(rooms);
        print('List of rooms: $rooms');
      } else {
        print('Failed to get rooms. Status code: ${response.statusCode}');
        roomList.clear();
      }
    } catch (e) {
      print('Error getting room list: $e');
    } finally {
      isLoading.value = false;
    }
    return roomList;
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
        final List<Table> tables =
            tablesJson.map((tableJson) => Table.fromJson(tableJson)).toList();
        tables.sort((a, b) => a.position.compareTo(b.position));
        tableList.assignAll(tables);
        print('List of tables for room ID $roomId: $tables');
      } else {
        print(
            'Failed to get tables for room ID $roomId. Status code: ${response.statusCode}');
        tableList.clear();
      }
    } catch (e) {
      print('Error getting tables for room ID $roomId: $e');
    } finally {
      isLoading.value = false;
    }
    return tableList;
  }

  void addRoom(Room room) async {
    try {
      isLoading.value = true;
      final response = await _clientDio.dio.post(
        Constants.addRoomUrl(),
        data: room.toJson(),
        options: Options(
          headers: {
            'Content-Type': 'application/json',
          },
        ),
      );
      if (response.statusCode == 200) {
        roomList.insert(0, room);
        print('Room added successfully: ${response.data}');
      } else {
        print('Failed to add room. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error adding room: $e');
    } finally {
      isLoading.value = false;
    }
  }

  void addTable(Table table) async {
    try {
      isLoading.value = true;
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
        tableList.add(table);
        print('Table added successfully: ${response.data}');
      } else {
        print('Failed to add table. Status code: ${response.statusCode}');
        if (response.statusCode == 409) {
          print('A table already exists at this position in the same room.');
        }
      }
    } catch (e) {
      print('Error adding table: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> deleteRoom(Room room) async {
    try {
      isLoading.value = true;
      final response = await _clientDio.dio.delete(
        Constants.deleteRoomUrl(room.id.toString()),
        options: Options(
          headers: {
            'Content-Type': 'application/json',
          },
        ),
      );
      if (response.statusCode == 200) {
        roomList.remove(room);
        print('Room deleted successfully');
      } else {
        print('Failed to delete room. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error deleting room: $e');
    } finally {
      isLoading.value = false;
    }
  }
}

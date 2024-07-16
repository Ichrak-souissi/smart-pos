import 'package:dio/dio.dart';
import 'package:pos/supplement/models/supplement.dart';
import 'package:pos/constants.dart';
import 'package:get/get.dart';

class SupplementController {
  final Dio _clientDio = Dio();
  final RxBool isLoading =
      false.obs; // Utilisation de RxBool pour le state management

  Future<List<Supplement>> getSupplementsByItemId(int itemId) async {
    try {
      final response = await _clientDio.get(
        Constants.getSupplementByItemIdUrl(itemId.toString()),
        options: Options(
          headers: {
            'Content-Type': 'application/json',
          },
        ),
      );
      if (response.statusCode == 200) {
        final List<dynamic> supplementsJson = response.data;
        final List<Supplement> supplements = supplementsJson
            .map((supplementJson) => Supplement.fromJson(supplementJson))
            .toList();
        return supplements;
      } else {
        throw Exception('Failed to get supplements by item ID');
      }
    } catch (e) {
      throw Exception(
          'Error occurred while fetching supplements by item ID: $e');
    }
  }

  Future<void> addSupplementToItem(Supplement supplement) async {
    try {
      isLoading.value = true;
      final response = await _clientDio.post(
        Constants.addSupplementUrl(),
        data: supplement.toJson(),
        options: Options(
          headers: {
            'Content-Type': 'application/json',
          },
        ),
      );
      print('Response status code: ${response.statusCode}');
      print('Response data: ${response.data}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        print('Supplement added to item successfully');
      } else {
        throw Exception('Failed to add supplement to item');
      }
    } catch (e) {
      print('Error occurred while adding supplement to item: $e');
      throw Exception('Error occurred while adding supplement to item: $e');
    } finally {
      isLoading.value = false;
    }
  }
}

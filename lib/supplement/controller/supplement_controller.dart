import 'package:dio/dio.dart';
import 'package:pos/constants.dart';
import 'package:pos/supplement/models/supplement.dart';

class SupplementController {
  final Dio _clientDio = Dio();

  Future<Supplement> updateSupplement(int supplementId, bool active) async {
    try {
      final response = await _clientDio.patch(
        Constants.getUpdateSupplementUrl(supplementId.toString()),
        data: {'active': active},
        options: Options(
          headers: {
            'Content-Type': 'application/json',
          },
        ),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = response.data;
        return Supplement.fromJson(responseData['supplement']);
      } else {
        print('Failed to update supplement. Status code: ${response.statusCode}');
        throw Exception('Failed to update supplement: ${response.statusCode}');
      }
    } catch (e) {
      print('Error during update supplement request: $e');
      throw Exception('Error during update supplement request: $e');
    }
  }

  Future<List<Supplement>> getSuppelmentsByItemId(int itemId) async {
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
        final List<Supplement> supplements =
            supplementsJson.map((supplementsJson) => Supplement.fromJson(supplementsJson)).toList();

        if (supplements.isEmpty) {
          print('List of supplements is empty');
        } else {
          print('List of supplements:');
          supplements.forEach((supplement) {
            print(supplement);
          });
        }
        return supplements;
      } else {
        print('Failed to get supplements by item ID. Status code: ${response.statusCode}');
        throw Exception('Failed to get supplements by item ID');
      }
    } catch (e) {
      print('Error occurred while fetching supplements by item ID: $e');
      throw Exception('Error occurred while fetching supplements by item ID: $e');
    }
  }
}

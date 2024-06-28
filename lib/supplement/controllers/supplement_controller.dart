import 'package:dio/dio.dart';
import 'package:pos/supplement/models/supplement.dart';
import 'package:pos/constants.dart'; 

class SupplementController {
  final Dio _clientDio = Dio();

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
        final List<Supplement> supplements = supplementsJson.map((supplementJson) => Supplement.fromJson(supplementJson)).toList();
        return supplements;
      } else {
        throw Exception('Failed to get supplements by item ID');
      }
    } catch (e) {
      throw Exception('Error occurred while fetching supplements by item ID: $e');
    }
  }
}

import 'package:dio/dio.dart';
import 'package:pos/constants.dart';
import 'package:pos/ingredient/models/ingredient.dart';
class IngredientController {
  final Dio _clientDio = Dio();
  
  Future<Ingredient> updateIngredient(int ingredientId, bool active) async {
    try {
      final response = await _clientDio.patch(
        Constants.getUpdateIngredientUrl(ingredientId.toString()),
        data: {'active': active},
        options: Options(
          headers: {
            'Content-Type': 'application/json',
          },
        ),
      );
      
      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = response.data;
        return Ingredient.fromJson(responseData['ingredient']);
      } else {
        throw Exception('Failed to update ingredient: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error : $e');
    }
  }


}

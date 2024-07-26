import 'package:dio/dio.dart';
import 'package:get/get.dart';
import 'package:pos/constants.dart';
import 'package:pos/supplement/models/supplement.dart';

class SupplementController extends GetxController {
  final Dio _clientDio = Dio();
  var isLoading = false.obs;
  var supplements = <Supplement>[].obs;

  @override
  void onInit() {
    super.onInit();
  }

  Future<List<Supplement>> getSupplementsByItemId(int itemId) async {
    isLoading.value = true;
    try {
      final response = await _clientDio.get(
        Constants.getSupplementByItemIdUrl(itemId.toString()),
        options: Options(
          headers: {'Content-Type': 'application/json'},
        ),
      );
      if (response.statusCode == 200) {
        final List<dynamic> supplementsJson = response.data;
        final List<Supplement> loadedSupplements =
            supplementsJson.map((json) => Supplement.fromJson(json)).toList();
        supplements.value = loadedSupplements;

        return loadedSupplements; // Return the list of supplements
      } else {
        Get.snackbar('Error', 'Failed to get supplements by item ID');
        return []; // Return an empty list in case of failure
      }
    } on DioError catch (e) {
      Get.snackbar('Error', 'Dio error: ${e.message}');
      return []; // Return an empty list in case of Dio error
    } catch (e) {
      Get.snackbar('Error', 'Unexpected error: $e');
      return []; // Return an empty list in case of unexpected error
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> updateSupplement(Supplement updatedSupplement) async {
    isLoading.value = true;
    try {
      final String url =
          Constants.updateSupplementUrl(updatedSupplement.id.toString());
      final response = await _clientDio.patch(
        url,
        data: updatedSupplement.toJson(),
        options: Options(
          headers: {'Content-Type': 'application/json'},
        ),
      );
      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = response.data;
        final updated = Supplement.fromJson(responseData);
        final index = supplements.indexWhere((s) => s.id == updated.id);
        if (index != -1) {
          supplements[index] = updated;
          supplements.refresh();
        }
      } else {
        Get.snackbar('Error', 'Failed to update supplement');
      }
    } on DioError catch (e) {
      Get.snackbar('Error', 'Dio error: ${e.message}');
    } catch (e) {
      Get.snackbar('Error', 'Unexpected error: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> addSupplementToItem(Supplement supplement) async {
    isLoading.value = true;
    try {
      final response = await _clientDio.post(
        Constants.addSupplementUrl(),
        data: supplement.toJson(),
        options: Options(
          headers: {'Content-Type': 'application/json'},
        ),
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        supplements.add(supplement);
        supplements.refresh();
      } else {
        Get.snackbar('Error', 'Failed to add supplement to item');
      }
    } on DioError catch (e) {
      Get.snackbar('Error', 'Dio error: ${e.message}');
    } catch (e) {
      Get.snackbar('Error', 'Unexpected error: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> deleteSupplement(int id) async {
    isLoading.value = true;
    try {
      final String url = Constants.deleteSupplementUrl(id.toString());
      final response = await _clientDio.delete(
        url,
        options: Options(
          headers: {'Content-Type': 'application/json'},
        ),
      );
      if (response.statusCode == 200) {
        supplements.removeWhere((s) => s.id == id);
        supplements.refresh();
      } else {
        Get.snackbar('Error', 'Failed to delete supplement');
      }
    } on DioError catch (e) {
      Get.snackbar('Error', 'Dio error: ${e.message}');
    } catch (e) {
      Get.snackbar('Error', 'Unexpected error: $e');
    } finally {
      isLoading.value = false;
    }
  }
}

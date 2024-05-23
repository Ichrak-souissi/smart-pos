import 'package:get/get_rx/src/rx_types/rx_types.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';
import 'package:pos/Dio/client_dio.dart';
import 'package:pos/constants.dart';
import 'package:pos/reservation/models/reservation.dart';

class ReservationController extends GetxController {
  RxBool isLoading = false.obs;
  final ClientDio _clientDio = ClientDio();
  RxList<Reservation> reservations = <Reservation>[].obs;

  Future<List<Reservation>> fetchReservations() async {
    try {
      isLoading.value = true;
      final response = await _clientDio.dio.get(Constants.getReservationsUrl());
      if (response.statusCode == 200) {
        var reservationList = (response.data as List).map((item) => Reservation.fromJson(item)).toList();
        reservations.assignAll(reservationList);
        return reservationList;
      } else {
        throw Exception('Failed to load reservations');
      }
    } catch (e) {
      print('Erreur lors de la récupération des réservations: $e');
      rethrow;
    } finally {
      isLoading.value = false;
    }
  }

  Future<Reservation> addReservation(Reservation reservation) async {
    try {
      isLoading.value = true;
      final response = await _clientDio.dio.post(
        Constants.addReservationUrl(),
        data: reservation.toJson(),
      );
      if (response != null ) {
        reservations.add(reservation);
        return reservation;
      } else {
        throw Exception('Failed to add reservation');
      }
    } catch (e) {
      print('Erreur lors de l\'ajout de la réservation: $e');
      rethrow;
    } finally {
      isLoading.value = false;
    }
  }
}

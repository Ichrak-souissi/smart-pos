import 'dart:convert';
Reservation reservationFromJson(String str) => Reservation.fromJson(json.decode(str));

String reservationToJson(Reservation data) => json.encode(data.toJson());
class Reservation {
  final int? id; 
  final int numberOfGuests; 
  final String client;
  final String date;
  final String hour;
  final int foodtableId;

  Reservation({
    this.id,
    required this.numberOfGuests,
    required this.client,
    required this.date,
    required this.hour,
    required this.foodtableId,
  });

  factory Reservation.fromJson(Map<String, dynamic> json) {
    return Reservation(
      id: json['id']?? 0,
      numberOfGuests: json['numberOfGuests']?? 0,
      client: json['client']?? '',
      date: json['date']?? '',
      hour: json['hour']?? '',
      foodtableId: json['foodtableId']?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'numberOfGuests': numberOfGuests,
      'client': client,
      'date': date,
      'hour': hour,
      'foodtableId': foodtableId,
    };
  }
}

import 'dart:convert';

Table tableFromJson(String str) => Table.fromJson(json.decode(str));

String tableToJson(Table data) => json.encode(data.toJson());

class Table {
  int id;
  int capacity;
  bool active;
  bool reserved;
  int position;
  int roomId;

  Table({
    required this.id,
    required this.capacity,
    required this.active,
    required this.reserved,
    required this.position,
    required this.roomId, 
  });

  factory Table.fromJson(Map<String, dynamic> json) => Table(
    id: json["id"],
    capacity: json["capacity"],
    active: json["active"],
    reserved: json["reserved"],
    position: json["position"],
    roomId: json["roomId"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "capacity": capacity,
    "active": active,
    "reserved": reserved,
    "position": position,
    "roomId": roomId,
  };
}
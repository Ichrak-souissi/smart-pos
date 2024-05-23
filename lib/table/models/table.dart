import 'dart:convert';

Table tableFromJson(String str) => Table.fromJson(json.decode(str));

String tableToJson(Table data) => json.encode(data.toJson());

class Table {
  int id;
  int capacity;
  bool active;
  //bool reserved;
  int position;
  int roomId;

  Table({
    required this.id,
    required this.capacity,
    required this.active,
    //required this.reserved,
    required this.position,
    required this.roomId, 
  });
factory Table.fromJson(Map<String, dynamic> json) {
  return Table(
    id: json["id"] ?? 0, 
    capacity: json["capacity"] ?? 0, 
    active: json["active"] ?? false, 
    //reserved: json["reserved"] ?? false,
    position: json["position"] ?? 0, 
    roomId: json["roomId"] ?? 0,
  );
}

  Map<String, dynamic> toJson() => {
    "id": id,
    "capacity": capacity,
    "active": active,
   // "reserved": reserved,
    "position": position,
    "roomId": roomId,
  };
}
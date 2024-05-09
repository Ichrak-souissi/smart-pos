import 'package:pos/table/models/table.dart';

class Room {
  int id;
  String name;
  int numberOfTables; 
  List<Table> tables;

  Room({
    required this.id,
    required this.name,
    required this.numberOfTables,
    required this.tables,
  });

  factory Room.fromJson(Map<String, dynamic> json) => Room(
        id: json["id"] ?? 0, 
        name: json["name"] ?? "",
        numberOfTables: json["numberoftables"] ?? 0, 
        tables: json["tables"] != null
            ? List<Table>.from(json["tables"].map((x) => Table.fromJson(x)))
            : [], 
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "numberoftables": numberOfTables,
        "tables": List<dynamic>.from(tables.map((x) => x.toJson())),
      };
}

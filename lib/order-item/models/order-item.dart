class OrderItem {
  int id;
  int orderId;
  String name;
  double price;
  int quantity;
  String note;
  String imageUrl;
  int categoryId;

  List<Map<String, dynamic>> selectedSupplements;

  OrderItem({
    required this.id,
    required this.orderId,
    required this.name,
    required this.price,
    required this.quantity,
    required this.note,
    required this.selectedSupplements,
    required this.imageUrl,
    required this.categoryId,
  });

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    return OrderItem(
      imageUrl: json["imageUrl"] ?? '',
      orderId: json['orderId'] ?? 0,
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      price: (json['price'] ?? 0).toDouble(),
      quantity: json['quantity'] ?? 0,
      note: json['note'] ?? '',
      selectedSupplements: (json['selectedSupplements'] ?? [])
          .map<Map<String, dynamic>>((item) => {
                'name': item['name'] ?? '',
                'price': (item['price'] ?? 0).toDouble(),
              })
          .toList(),
      categoryId: json["categoryId"] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'orderId': orderId,
      'id': id,
      'name': name,
      'price': price,
      'quantity': quantity,
      'note': note,
      'selectedSupplements': selectedSupplements,
      "imageUrl": imageUrl,
      "categoryId": categoryId,
    };
  }
}

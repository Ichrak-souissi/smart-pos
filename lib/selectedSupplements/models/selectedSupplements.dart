class SelectedSupplement {
  final int id;
  final String name;
  final double price;

  SelectedSupplement({
    required this.id,
    required this.name,
    required this.price,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'price': price,
    };
  }

  factory SelectedSupplement.fromJson(Map<String, dynamic> json) {
    return SelectedSupplement(
      id: json['id'],
      name: json['name'],
      price: json['price'].toDouble(),
    );
  }
}

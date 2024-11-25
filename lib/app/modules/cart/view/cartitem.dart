class CartItem {
  final String id;
  final String itemId;
  final String name;
  final double price;
  final String image;
  final int quantity;

  CartItem({
    required this.id,
    required this.itemId,
    required this.name,
    required this.price,
    required this.image,
    required this.quantity,
  });
}

class PromoCode {
  final int id;
  final String codeName;
  final String title;
  final double discount;
  final String type;
  final bool status;

  PromoCode({
    required this.id,
    required this.codeName,
    required this.title,
    required this.discount,
    required this.type,
    required this.status,
  });

  factory PromoCode.fromJson(Map<String, dynamic> json) {
    return PromoCode(
      id: json['id'],
      codeName: json['code_name'],
      title: json['title'],
      discount: double.parse(json['discount'].toString()),
      type: json['type'],
      status: json['status'] == 1,
    );
  }
}
/// Backend'dan keladigan ma'lumotlarning Dart modellari.

class Category {
  final int id;
  final String name;
  final String? icon;
  Category({required this.id, required this.name, this.icon});
  factory Category.fromJson(Map<String, dynamic> j) =>
      Category(id: j['id'], name: j['name'], icon: j['icon']);
}

class Brand {
  final int id;
  final String name;
  final String? logo;
  final bool isOfficial;
  Brand({required this.id, required this.name, this.logo, this.isOfficial = false});
  factory Brand.fromJson(Map<String, dynamic> j) => Brand(
        id: j['id'],
        name: j['name'],
        logo: j['logo'],
        isOfficial: j['is_official'] ?? false,
      );
}

class Product {
  final int id;
  final String name;
  final String? categoryName;
  final double price;
  final String unit;
  final String? image;
  final bool inStock;
  final bool isNew;
  final bool isPromo;
  // Tafsilotda keladiganlar (ro'yxatda bo'lmasligi mumkin)
  final String? description;
  final int? stock;

  Product({
    required this.id,
    required this.name,
    this.categoryName,
    required this.price,
    required this.unit,
    this.image,
    this.inStock = true,
    this.isNew = false,
    this.isPromo = false,
    this.description,
    this.stock,
  });

  factory Product.fromJson(Map<String, dynamic> j) => Product(
        id: j['id'],
        name: j['name'],
        categoryName: j['category_name'],
        price: double.parse(j['price'].toString()),
        unit: j['unit'] ?? 'dona',
        image: j['image'],
        inStock: j['in_stock'] ?? true,
        isNew: j['is_new'] ?? false,
        isPromo: j['is_promo'] ?? false,
        description: j['description'],
        stock: j['stock'],
      );
}

class CartItem {
  final int id;
  final int product;
  final String productName;
  final double price;
  final String unit;
  final int quantity;
  final double lineTotal;
  CartItem({
    required this.id,
    required this.product,
    required this.productName,
    required this.price,
    required this.unit,
    required this.quantity,
    required this.lineTotal,
  });
  factory CartItem.fromJson(Map<String, dynamic> j) => CartItem(
        id: j['id'],
        product: j['product'],
        productName: j['product_name'],
        price: double.parse(j['price'].toString()),
        unit: j['unit'] ?? 'dona',
        quantity: j['quantity'],
        lineTotal: double.parse(j['line_total'].toString()),
      );
}

class OrderItem {
  final String productName;
  final double unitPrice;
  final int quantity;
  final String unit;
  final double lineTotal;
  OrderItem({
    required this.productName,
    required this.unitPrice,
    required this.quantity,
    required this.unit,
    required this.lineTotal,
  });
  factory OrderItem.fromJson(Map<String, dynamic> j) => OrderItem(
        productName: j['product_name'],
        unitPrice: double.parse(j['unit_price'].toString()),
        quantity: j['quantity'],
        unit: j['unit'] ?? '',
        lineTotal: double.parse(j['line_total'].toString()),
      );
}

class Order {
  final int id;
  final String receiptNumber;
  final String status;
  final String statusDisplay;
  final double total;
  final double itemsTotal;
  final double deliveryFee;
  final String createdAt;
  final List<OrderItem> items;
  final String? shopName;

  Order({
    required this.id,
    required this.receiptNumber,
    required this.status,
    required this.statusDisplay,
    required this.total,
    this.itemsTotal = 0,
    this.deliveryFee = 0,
    required this.createdAt,
    this.items = const [],
    this.shopName,
  });

  factory Order.fromJson(Map<String, dynamic> j) => Order(
        id: j['id'],
        receiptNumber: j['receipt_number'],
        status: j['status'],
        statusDisplay: j['status_display'],
        total: double.parse(j['total'].toString()),
        itemsTotal: double.parse((j['items_total'] ?? 0).toString()),
        deliveryFee: double.parse((j['delivery_fee'] ?? 0).toString()),
        createdAt: j['created_at'],
        shopName: j['shop_name'],
        items: (j['items'] as List?)
                ?.map((e) => OrderItem.fromJson(e))
                .toList() ??
            [],
      );
}

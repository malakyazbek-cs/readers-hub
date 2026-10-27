class UserModel {
  final int? id;
  final String username;
  final String email;
  final String password;

  UserModel({
    this.id,
    required this.username,
    required this.email,
    required this.password,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'username': username,
      'email': email,
      'password': password,
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['id'],
      username: map['username'],
      email: map['email'],
      password: map['password'],
    );
  }
}

class ProductModel {
  final int? id;
  final String title;
  final String category;
  final double price;
  final String options;
  final String imageUrl;

  ProductModel({
    this.id,
    required this.title,
    required this.category,
    required this.price,
    required this.options,
    required this.imageUrl,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'category': category,
      'price': price,
      'options': options,
      'imageUrl': imageUrl,
    };
  }

  factory ProductModel.fromMap(Map<String, dynamic> map) {
    return ProductModel(
      id: map['id'],
      title: map['title'],
      category: map['category'],
      price: map['price'],
      options: map['options'],
      imageUrl: map['imageUrl'],
    );
  }
}

class OrderHeaderModel {
  final int? id;
  final int userId;
  final String orderDate;
  final double total;
  final String status;

  OrderHeaderModel({
    this.id,
    required this.userId,
    required this.orderDate,
    required this.total,
    required this.status,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'orderDate': orderDate,
      'total': total,
      'status': status,
    };
  }

  Map<String, dynamic> toMapWithoutId() {
    return {
      'userId': userId,
      'orderDate': orderDate,
      'total': total,
      'status': status,
    };
  }

  factory OrderHeaderModel.fromMap(Map<String, dynamic> map) {
    return OrderHeaderModel(
      id: map['id'],
      userId: map['userId'],
      orderDate: map['orderDate'],
      total: map['total'],
      status: map['status'],
    );
  }
}

class OrderItemModel {
  final int? id;
  final int orderId;
  final int productId;
  final int quantity;
  final double priceAtPurchase;
  final String selectedOptions;

  OrderItemModel({
    this.id,
    required this.orderId,
    required this.productId,
    required this.quantity,
    required this.priceAtPurchase,
    required this.selectedOptions,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'orderId': orderId,
      'productId': productId,
      'quantity': quantity,
      'priceAtPurchase': priceAtPurchase,
      'selectedOptions': selectedOptions,
    };
  }

  Map<String, dynamic> toMapWithoutId() {
    return {
      'orderId': orderId,
      'productId': productId,
      'quantity': quantity,
      'priceAtPurchase': priceAtPurchase,
      'selectedOptions': selectedOptions,
    };
  }

  factory OrderItemModel.fromMap(Map<String, dynamic> map) {
    return OrderItemModel(
      id: map['id'],
      orderId: map['orderId'],
      productId: map['productId'],
      quantity: map['quantity'],
      priceAtPurchase: map['priceAtPurchase'],
      selectedOptions: map['selectedOptions'],
    );
  }
}

class CartItemModel {
  final int? id;
  final int userId;
  final int productId;
  final int quantity;
  final String selectedOptions;
  final double priceAtAddition;

  CartItemModel({
    this.id,
    required this.userId,
    required this.productId,
    required this.quantity,
    required this.selectedOptions,
    required this.priceAtAddition,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'productId': productId,
      'quantity': quantity,
      'selectedOptions': selectedOptions,
      'priceAtAddition': priceAtAddition,
    };
  }

  factory CartItemModel.fromMap(Map<String, dynamic> map) {
    return CartItemModel(
      id: map['id'],
      userId: map['userId'],
      productId: map['productId'],
      quantity: map['quantity'],
      selectedOptions: map['selectedOptions'],
      priceAtAddition: map['priceAtAddition'],
    );
  }
}

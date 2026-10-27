import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'models.dart';

class DBHelper {
  static final DBHelper instance = DBHelper._internal();
  static Database? _database;

  DBHelper._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB();
    return _database!;
  }

  Future<Database> _initDB() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'readershub.db');
    return await openDatabase(path, version: 1, onCreate: _onCreate);
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
    CREATE TABLE users (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      username TEXT,
      email TEXT,
      password TEXT
    )
  ''');

    await db.execute('''
    CREATE TABLE products (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      title TEXT,
      category TEXT,
      price REAL,
      options TEXT,
      imageUrl TEXT
    )
  ''');

    await db.execute('''
    CREATE TABLE orders (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      userId INTEGER NOT NULL,
      orderDate TEXT NOT NULL,
      total REAL NOT NULL,
      status TEXT NOT NULL
    )
  ''');

    await db.execute('''
    CREATE TABLE order_items (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      orderId INTEGER NOT NULL,
      productId INTEGER NOT NULL,
      quantity INTEGER NOT NULL,
      priceAtPurchase REAL NOT NULL,
      selectedOptions TEXT
    )
  ''');

    await db.execute('''
    CREATE TABLE cart (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      userId INTEGER NOT NULL,
      productId INTEGER NOT NULL,
      quantity INTEGER NOT NULL,
      selectedOptions TEXT,
      priceAtAddition REAL NOT NULL
    )
  ''');

    await _insertSampleData(db);
  }

  Future<List<Map<String, dynamic>>> getCartDetailsForCheckout(int userId) async {
    final db = await database;
    return await db.rawQuery('''
      SELECT 
        C.id AS cartId, 
        C.userId, 
        C.productId, 
        C.quantity, 
        C.selectedOptions, 
        C.priceAtAddition,
        P.title AS productTitle,
        P.imageUrl AS productImageUrl
      FROM cart C
      JOIN products P ON C.productId = P.id
      WHERE C.userId = ?
    ''', [userId]);
  }

  Future<int> createOrder(OrderHeaderModel orderHeader, List<Map<String, dynamic>> cartDetails) async {
    final db = await database;
    int orderId = -1;

    await db.transaction((txn) async {
      orderId = await txn.insert('orders', orderHeader.toMapWithoutId());

      for (var cartItem in cartDetails) {
        final orderItem = OrderItemModel(
          orderId: orderId,
          productId: cartItem['productId'] as int,
          quantity: cartItem['quantity'] as int,
          priceAtPurchase: cartItem['priceAtAddition'] as double,
          selectedOptions: cartItem['selectedOptions'] as String,
        );
        await txn.insert('order_items', orderItem.toMapWithoutId());
      }

      await txn.delete('cart', where: 'userId = ?', whereArgs: [orderHeader.userId]);
    });

    return orderId;
  }

  Future<int> insertUser(UserModel user) async {
    final db = await database;
    return await db.insert('users', user.toMap());
  }

  Future<UserModel?> loginUser(String email, String password) async {
    final db = await database;
    final result = await db.query('users', where: 'email = ? AND password = ?', whereArgs: [email, password]);
    return result.isNotEmpty ? UserModel.fromMap(result.first) : null;
  }

  Future<int> insertProduct(ProductModel product) async {
    final db = await database;
    return await db.insert('products', product.toMap());
  }

  Future<List<ProductModel>> getProducts() async {
    final db = await database;
    final result = await db.query('products');
    return result.map((e) => ProductModel.fromMap(e)).toList();
  }

  Future<ProductModel?> getProductById(int id) async {
    final db = await database;
    final result = await db.query('products', where: 'id = ?', whereArgs: [id]);
    return result.isNotEmpty ? ProductModel.fromMap(result.first) : null;
  }

  Future<int> deleteProduct(int id) async {
    final db = await database;
    return await db.delete('products', where: 'id = ?', whereArgs: [id]);
  }

  Future<int> insertOrderHeader(OrderHeaderModel orderHeader) async {
    final db = await database;
    return await db.insert('orders', orderHeader.toMap());
  }

  Future<int> insertOrderItem(OrderItemModel orderItem) async {
    final db = await database;
    return await db.insert('order_items', orderItem.toMap());
  }

  Future<List<Map<String, dynamic>>> getOrdersDetail() async {
    final db = await database;
    return await db.rawQuery('''
    SELECT
      O.id AS orderId,
      O.orderDate,
      O.total,
      O.status,
      U.username,
      P.title AS productTitle,
      OI.quantity,
      OI.priceAtPurchase,
      OI.selectedOptions
    FROM orders O
    JOIN users U ON O.userId = U.id
    JOIN order_items OI ON O.id = OI.orderId
    JOIN products P ON OI.productId = P.id
    ORDER BY O.orderDate DESC
  ''');
  }

  Future<List<OrderHeaderModel>> getOrdersByUserId(int userId) async {
    final db = await database;
    final result = await db.query(
      'orders',
      where: 'userId = ?',
      whereArgs: [userId],
      orderBy: 'orderDate DESC',
    );
    return result.map((e) => OrderHeaderModel.fromMap(e)).toList();
  }

  Future<List<OrderItemModel>> getOrderItemsByOrderId(int orderId) async {
    final db = await database;
    final result = await db.query(
      'order_items',
      where: 'orderId = ?',
      whereArgs: [orderId],
    );
    return result.map((e) => OrderItemModel.fromMap(e)).toList();
  }

  Future<int> insertCartItem(CartItemModel cartItem) async {
    final db = await database;
    return await db.insert('cart', cartItem.toMap());
  }

  Future<List<CartItemModel>> getCartItems(int userId) async {
    final db = await database;
    final result = await db.query('cart', where: 'userId = ?', whereArgs: [userId]);
    return result.map((e) => CartItemModel.fromMap(e)).toList();
  }

  Future<int> deleteCartItem(int cartItemId) async {
    final db = await database;
    return await db.delete('cart', where: 'id = ?', whereArgs: [cartItemId]);
  }

  Future<int> clearCart(int userId) async {
    final db = await database;
    return await db.delete('cart', where: 'userId = ?', whereArgs: [userId]);
  }

  Future<void> _insertSampleData(Database db) async {
    await db.insert('users', UserModel(username: 'Layla', email: 'layla@gmail.com', password: 'layla123').toMap());
    await db.insert('users', UserModel(username: 'Haneen', email: 'haneen@gmail.com', password: 'haneen123').toMap());
    await db.insert('users', UserModel(username: 'Nour', email: 'nour@gmail.com', password: 'nour123').toMap());

    List<ProductModel> products = [
      ProductModel(title: 'Harry Potter and the Chamber of Secrets', category: 'Book', price: 6.99, options: 'Paperback, Hardcover, Illustrated Edition', imageUrl: 'harry.jpg'),
      ProductModel(title: 'The Hobbit', category: 'Book', price: 9.50, options: 'Paperback, Hardcover, Illustrated Edition', imageUrl: 'hobbit.jpg'),
      ProductModel(title: 'LED Reading Lamp', category: 'Accessory', price: 4.99, options: 'Adjustable', imageUrl: 'led.jpg'),
      ProductModel(title: 'The Lord of the Rings: The Fellowship of the Ring', category: 'Book', price: 7.00, options: 'Paperback, Hardcover, Box Set', imageUrl: 'lord.jpg'),
      ProductModel(title: 'Manga: Jujutsu Kaisen Vol.1', category: 'Book', price: 8.99, options: 'Paperback', imageUrl: 'jujutsu.jpg'),
      ProductModel(title: 'Wonder Woman: Dead Earth', category: 'Comic', price: 10.50, options: 'Paperback, Hardcover', imageUrl: 'wonder.jpg'),
      ProductModel(title: 'The Midnight Library', category: 'Book', price: 12.50, options: 'Paperback', imageUrl: 'midnight.jpg'),
      ProductModel(title: 'Bookmarks Pack', category: 'Accessory', price: 4.99, options: 'Set of 5', imageUrl: 'bookmarks.jpg'),
      ProductModel(title: 'The Umbrella Academy Vol. 1', category: 'Comic', price: 13.99, options: 'Paperback, Hardcover, Box Set', imageUrl: 'umbrella.jpg'),
      ProductModel(title: 'Spider-Man: Miles Morales', category: 'Comic', price: 12.99, options: 'Paperback, Hardcover', imageUrl: 'spiderman.jpg'),
      ProductModel(title: 'A Game of Thrones', category: 'Book', price: 7.99, options: 'Paperback, Hardcover, Deluxe Edition', imageUrl: 'game.jpg'),
      ProductModel(title: 'The Lion, the Witch and the Wardrobe', category: 'Book', price: 9.99, options: 'Paperback, Illustrated Edition', imageUrl: 'lion.jpg'),
      ProductModel(title: 'The Cruel Prince', category: 'Book', price: 11.99, options: 'Paperback, Hardcover, Special Edition', imageUrl: 'cruel.jpg'),
      ProductModel(title: 'Book Light Clip-On', category: 'Accessory', price: 5.50, options: 'LED, Rechargeable', imageUrl: 'light.jpg'),
      ProductModel(title: 'The Housemaid', category: 'Book', price: 11.50, options: 'Paperback, Hardcover', imageUrl: 'housemaid.jpg'),
    ];

    for (var product in products) {
      await db.insert('products', product.toMap());
    }

    int order1Id = await db.insert('orders', OrderHeaderModel(
        userId: 1,
        orderDate: DateTime.now().subtract(const Duration(days: 5)).toIso8601String(),
        total: 16.97,
        status: 'Shipped'
    ).toMap());

    await db.insert('order_items', OrderItemModel(
        orderId: order1Id, productId: 1, quantity: 1,
        priceAtPurchase: 6.99, selectedOptions: 'Hardcover'
    ).toMap());

    await db.insert('order_items', OrderItemModel(
        orderId: order1Id, productId: 8, quantity: 2,
        priceAtPurchase: 4.99, selectedOptions: 'Set of 5'
    ).toMap());

    int order2Id = await db.insert('orders', OrderHeaderModel(
        userId: 2,
        orderDate: DateTime.now().subtract(const Duration(days: 3)).toIso8601String(),
        total: 4.99,
        status: 'Delivered'
    ).toMap());

    await db.insert('order_items', OrderItemModel(
        orderId: order2Id, productId: 3, quantity: 1,
        priceAtPurchase: 4.99, selectedOptions: 'Adjustable'
    ).toMap());

    int order3Id = await db.insert('orders', OrderHeaderModel(
        userId: 3,
        orderDate: DateTime.now().toIso8601String(),
        total: 34.99,
        status: 'Pending'
    ).toMap());

    await db.insert('order_items', OrderItemModel(
        orderId: order3Id, productId: 6, quantity: 2,
        priceAtPurchase: 10.50, selectedOptions: 'Hardcover'
    ).toMap());

    await db.insert('order_items', OrderItemModel(
        orderId: order3Id, productId: 9, quantity: 1,
        priceAtPurchase: 13.99, selectedOptions: 'Paperback'
    ).toMap());
  }
}

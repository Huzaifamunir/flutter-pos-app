import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/product.dart';
import '../models/order.dart';
import '../models/expense.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'pos_database.db');
    return await openDatabase(
      path,
      version: 3,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    // Create categories table
    await db.execute('''
      CREATE TABLE categories(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT UNIQUE NOT NULL
      )
    ''');

    // Create products table
    await db.execute('''
      CREATE TABLE products(
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        price REAL NOT NULL,
        category TEXT NOT NULL,
        description TEXT,
        created_at DATETIME DEFAULT CURRENT_TIMESTAMP
      )
    ''');

    // Create orders table
    await db.execute('''
      CREATE TABLE orders(
        id TEXT PRIMARY KEY,
        created_at DATETIME NOT NULL,
        payment_method TEXT NOT NULL,
        total_amount REAL NOT NULL
      )
    ''');

    // Create order_items table
    await db.execute('''
      CREATE TABLE order_items(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        order_id TEXT NOT NULL,
        product_id TEXT NOT NULL,
        product_name TEXT NOT NULL,
        price REAL NOT NULL,
        quantity INTEGER NOT NULL,
        category TEXT NOT NULL,
        FOREIGN KEY (order_id) REFERENCES orders (id)
      )
    ''');

    // Create expenses table
    await db.execute('''
      CREATE TABLE expenses(
        id TEXT PRIMARY KEY,
        description TEXT NOT NULL,
        amount REAL NOT NULL,
        category TEXT NOT NULL,
        created_at DATETIME NOT NULL,
        notes TEXT
      )
    ''');

    // Create expense_categories table
    await db.execute('''
      CREATE TABLE expense_categories(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT UNIQUE NOT NULL
      )
    ''');

    // Insert default categories
    await _insertDefaultCategories(db);
    
    // Insert default products
    await _insertDefaultProducts(db);

    // Insert default expense categories
    await _insertDefaultExpenseCategories(db);
  }

  Future<void> _insertDefaultCategories(Database db) async {
    final defaultCategories = ['Beverages', 'Pastries', 'Food', 'Desserts'];
    
    for (String category in defaultCategories) {
      await db.insert(
        'categories',
        {'name': category},
        conflictAlgorithm: ConflictAlgorithm.ignore,
      );
    }
  }

  Future<void> _insertDefaultProducts(Database db) async {
    final defaultProducts = [
      {'id': '1', 'name': 'Coffee', 'price': 350.0, 'category': 'Beverages', 'description': 'Freshly brewed coffee'},
      {'id': '2', 'name': 'Cappuccino', 'price': 425.0, 'category': 'Beverages', 'description': 'Espresso with steamed milk foam'},
      {'id': '3', 'name': 'Latte', 'price': 450.0, 'category': 'Beverages', 'description': 'Espresso with steamed milk'},
      {'id': '4', 'name': 'Muffin', 'price': 275.0, 'category': 'Pastries', 'description': 'Fresh baked blueberry muffin'},
      {'id': '5', 'name': 'Croissant', 'price': 325.0, 'category': 'Pastries', 'description': 'Buttery French croissant'},
      {'id': '6', 'name': 'Sandwich', 'price': 750.0, 'category': 'Food', 'description': 'Turkey and cheese sandwich'},
      {'id': '7', 'name': 'Salad', 'price': 825.0, 'category': 'Food', 'description': 'Fresh garden salad'},
      {'id': '8', 'name': 'Cookie', 'price': 150.0, 'category': 'Desserts', 'description': 'Chocolate chip cookie'},
      {'id': '9', 'name': 'Tea', 'price': 250.0, 'category': 'Beverages', 'description': 'Hot tea selection'},
      {'id': '10', 'name': 'Smoothie', 'price': 575.0, 'category': 'Beverages', 'description': 'Fresh fruit smoothie'},
      {'id': '11', 'name': 'Bagel', 'price': 225.0, 'category': 'Pastries', 'description': 'Fresh bagel with cream cheese'},
      {'id': '12', 'name': 'Soup', 'price': 475.0, 'category': 'Food', 'description': 'Daily soup special'},
    ];

    for (Map<String, dynamic> product in defaultProducts) {
      await db.insert(
        'products',
        product,
        conflictAlgorithm: ConflictAlgorithm.ignore,
      );
    }
  }

  Future<void> _insertDefaultExpenseCategories(Database db) async {
    final defaultExpenseCategories = [
      'Rent',
      'Utilities',
      'Supplies',
      'Equipment',
      'Marketing',
      'Staff',
      'Maintenance',
      'Other'
    ];
    
    for (String category in defaultExpenseCategories) {
      await db.insert(
        'expense_categories',
        {'name': category},
        conflictAlgorithm: ConflictAlgorithm.ignore,
      );
    }
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      // Create orders table
      await db.execute('''
        CREATE TABLE orders(
          id TEXT PRIMARY KEY,
          created_at DATETIME NOT NULL,
          payment_method TEXT NOT NULL,
          total_amount REAL NOT NULL
        )
      ''');

      // Create order_items table
      await db.execute('''
        CREATE TABLE order_items(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          order_id TEXT NOT NULL,
          product_id TEXT NOT NULL,
          product_name TEXT NOT NULL,
          price REAL NOT NULL,
          quantity INTEGER NOT NULL,
          category TEXT NOT NULL,
          FOREIGN KEY (order_id) REFERENCES orders (id)
        )
      ''');
    }
    
    if (oldVersion < 3) {
      // Create expenses table
      await db.execute('''
        CREATE TABLE expenses(
          id TEXT PRIMARY KEY,
          description TEXT NOT NULL,
          amount REAL NOT NULL,
          category TEXT NOT NULL,
          created_at DATETIME NOT NULL,
          notes TEXT
        )
      ''');

      // Create expense_categories table
      await db.execute('''
        CREATE TABLE expense_categories(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          name TEXT UNIQUE NOT NULL
        )
      ''');

      // Insert default expense categories
      await _insertDefaultExpenseCategories(db);
    }
  }

  // Category operations
  Future<List<String>> getCategories() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('categories', orderBy: 'name');
    return ['All'] + maps.map((map) => map['name'] as String).toList();
  }

  Future<int> addCategory(String name) async {
    final db = await database;
    return await db.insert(
      'categories',
      {'name': name},
      conflictAlgorithm: ConflictAlgorithm.ignore,
    );
  }

  Future<int> removeCategory(String name) async {
    final db = await database;
    // First remove all products in this category
    await db.delete('products', where: 'category = ?', whereArgs: [name]);
    // Then remove the category
    return await db.delete('categories', where: 'name = ?', whereArgs: [name]);
  }

  // Product operations
  Future<List<Product>> getProducts() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('products', orderBy: 'name');
    return maps.map((map) => Product.fromMap(map)).toList();
  }

  Future<int> addProduct(Product product) async {
    final db = await database;
    return await db.insert(
      'products',
      product.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<int> removeProduct(String productId) async {
    final db = await database;
    return await db.delete('products', where: 'id = ?', whereArgs: [productId]);
  }

  Future<List<Product>> getProductsByCategory(String category) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'products',
      where: 'category = ?',
      whereArgs: [category],
      orderBy: 'name',
    );
    return maps.map((map) => Product.fromMap(map)).toList();
  }

  // Order operations
  Future<String> addOrder(Order order) async {
    final db = await database;
    
    // Insert order
    await db.insert('orders', order.toMap());
    
    // Insert order items
    for (OrderItem item in order.items) {
      await db.insert('order_items', {
        'order_id': order.id,
        'product_id': item.productId,
        'product_name': item.productName,
        'price': item.price,
        'quantity': item.quantity,
        'category': item.category,
      });
    }
    
    return order.id;
  }

  Future<List<Order>> getOrders() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'orders',
      orderBy: 'created_at DESC',
    );
    
    List<Order> orders = [];
    for (Map<String, dynamic> map in maps) {
      final order = Order.fromMap(map);
      final items = await getOrderItems(order.id);
      orders.add(Order(
        id: order.id,
        createdAt: order.createdAt,
        paymentMethod: order.paymentMethod,
        totalAmount: order.totalAmount,
        items: items,
      ));
    }
    
    return orders;
  }

  Future<List<OrderItem>> getOrderItems(String orderId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'order_items',
      where: 'order_id = ?',
      whereArgs: [orderId],
    );
    return maps.map((map) => OrderItem.fromMap(map)).toList();
  }

  Future<List<Order>> getOrdersByDateRange(DateTime startDate, DateTime endDate) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'orders',
      where: 'created_at BETWEEN ? AND ?',
      whereArgs: [startDate.toIso8601String(), endDate.toIso8601String()],
      orderBy: 'created_at DESC',
    );
    
    List<Order> orders = [];
    for (Map<String, dynamic> map in maps) {
      final order = Order.fromMap(map);
      final items = await getOrderItems(order.id);
      orders.add(Order(
        id: order.id,
        createdAt: order.createdAt,
        paymentMethod: order.paymentMethod,
        totalAmount: order.totalAmount,
        items: items,
      ));
    }
    
    return orders;
  }

  Future<double> getTotalSales() async {
    final db = await database;
    final result = await db.rawQuery('SELECT SUM(total_amount) as total FROM orders');
    final total = result.first['total'];
    return total != null ? (total as num).toDouble() : 0.0;
  }

  Future<int> getTotalOrders() async {
    final db = await database;
    final result = await db.rawQuery('SELECT COUNT(*) as count FROM orders');
    return result.first['count'] as int;
  }

  // Expense operations
  Future<List<String>> getExpenseCategories() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('expense_categories', orderBy: 'name');
    return maps.map((map) => map['name'] as String).toList();
  }

  Future<int> addExpenseCategory(String name) async {
    final db = await database;
    return await db.insert(
      'expense_categories',
      {'name': name},
      conflictAlgorithm: ConflictAlgorithm.ignore,
    );
  }

  Future<int> removeExpenseCategory(String name) async {
    final db = await database;
    // First remove all expenses in this category
    await db.delete('expenses', where: 'category = ?', whereArgs: [name]);
    // Then remove the category
    return await db.delete('expense_categories', where: 'name = ?', whereArgs: [name]);
  }

  Future<int> addExpense(Expense expense) async {
    final db = await database;
    return await db.insert(
      'expenses',
      expense.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Expense>> getExpenses() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'expenses',
      orderBy: 'created_at DESC',
    );
    return maps.map((map) => Expense.fromMap(map)).toList();
  }

  Future<int> removeExpense(String expenseId) async {
    final db = await database;
    return await db.delete('expenses', where: 'id = ?', whereArgs: [expenseId]);
  }

  Future<List<Expense>> getExpensesByCategory(String category) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'expenses',
      where: 'category = ?',
      whereArgs: [category],
      orderBy: 'created_at DESC',
    );
    return maps.map((map) => Expense.fromMap(map)).toList();
  }

  Future<List<Expense>> getExpensesByDateRange(DateTime startDate, DateTime endDate) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'expenses',
      where: 'created_at BETWEEN ? AND ?',
      whereArgs: [startDate.toIso8601String(), endDate.toIso8601String()],
      orderBy: 'created_at DESC',
    );
    return maps.map((map) => Expense.fromMap(map)).toList();
  }

  Future<double> getTotalExpenses() async {
    final db = await database;
    final result = await db.rawQuery('SELECT SUM(amount) as total FROM expenses');
    final total = result.first['total'];
    return total != null ? (total as num).toDouble() : 0.0;
  }

  Future<double> getNetProfit() async {
    final sales = await getTotalSales();
    final expenses = await getTotalExpenses();
    return sales - expenses;
  }
}

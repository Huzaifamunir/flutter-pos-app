import '../models/product.dart';
import '../database/database_helper.dart';

class SampleProducts {
  static final DatabaseHelper _dbHelper = DatabaseHelper();

  static Future<List<Product>> getProducts() async {
    return await _dbHelper.getProducts();
  }

  static Future<List<String>> getCategories() async {
    return await _dbHelper.getCategories();
  }

  static Future<int> addProduct(Product product) async {
    return await _dbHelper.addProduct(product);
  }

  static Future<int> addCategory(String category) async {
    return await _dbHelper.addCategory(category);
  }

  static Future<int> removeCategory(String category) async {
    return await _dbHelper.removeCategory(category);
  }

  static Future<int> removeProduct(String productId) async {
    return await _dbHelper.removeProduct(productId);
  }

  static Future<List<Product>> getProductsByCategory(String category) async {
    return await _dbHelper.getProductsByCategory(category);
  }
}

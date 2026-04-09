import 'package:hive_flutter/hive_flutter.dart';
import '../models/product_model.dart';

class HiveService {
  static const String _boxName = 'products';
  static Box<Product>? _box;

  static Future<void> init() async {
    await Hive.initFlutter();
    Hive.registerAdapter(ProductAdapter());
    _box = await Hive.openBox<Product>(_boxName);
  }

  static Box<Product> get box {
    if (_box == null || !_box!.isOpen) {
      throw Exception('Hive box not initialized');
    }
    return _box!;
  }

  static Future<void> addProduct(Product product) async {
    await box.add(product);
  }

  static List<Product> getAllProducts() {
    return box.values.toList();
  }

  static Future<void> togglePurchased(int index) async {
    final product = box.getAt(index);
    if (product != null) {
      product.isPurchased = !product.isPurchased;
      await product.save();
    }
  }

  static Future<void> deleteProduct(int index) async {
    await box.deleteAt(index);
  }

  static Future<void> clearAll() async {
    await box.clear();
  }
}
import 'package:hive_flutter/hive_flutter.dart';
import '../models/product_model.dart';

class HiveService {
  static const String _boxName = 'products';
  static Box<Product>? _box;

  static Future<void> init() async {
    await Hive.initFlutter();
    // Fix APK release: evita registro doble del adapter
    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(ProductAdapter());
    }
    _box = await Hive.openBox<Product>(_boxName);
  }

  static Box<Product> get box {
    if (_box == null || !_box!.isOpen) {
      throw Exception('Hive box not initialized. Llama HiveService.init() primero.');
    }
    return _box!;
  }

  static Future<void> addProduct(Product product) async {
    await box.add(product);
  }

  static List<Product> getAllProducts() {
    return box.values.toList();
  }

  /// Fix #1 y #2: usa la KEY real de Hive, no el índice posicional.
  /// box.keyAt(i) puede desfasarse cuando hay eliminaciones.
  /// Siempre pasa product.key as int desde la UI.
  static Future<void> togglePurchased(int key) async {
    final product = box.get(key); // ← get(key), no getAt(index)
    if (product != null) {
      product.isPurchased = !product.isPurchased;
      await product.save();
    }
  }

  /// Fix #2: box.delete(key) borra por key real, no por posición.
  /// box.deleteAt(index) era la causa del Dismissible error.
  static Future<void> deleteProduct(int key) async {
    await box.delete(key); // ← delete(key), no deleteAt(index)
  }

  static Future<void> clearAll() async {
    await box.clear();
  }

  static int getPendingCount() {
    return box.values.where((p) => !p.isPurchased).length;
  }
}
import 'package:hive/hive.dart';

part 'product_model.g.dart';

@HiveType(typeId: 0)
class Product extends HiveObject {
  @HiveField(0)
  String name;

  @HiveField(1)
  String quantity;

  @HiveField(2)
  bool isPurchased;

  @HiveField(3)
  String category;

  @HiveField(4)
  DateTime createdAt;

  Product({
    required this.name,
    required this.quantity,
    this.isPurchased = false,
    this.category = 'General',
    required this.createdAt,
  });
}
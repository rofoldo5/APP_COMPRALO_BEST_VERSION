import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../models/product_model.dart';

class ProductTile extends StatelessWidget {
  final Product product;
  final int index;
  final VoidCallback onToggle;
  final VoidCallback onDelete;

  const ProductTile({
    super.key,
    required this.product,
    required this.index,
    required this.onToggle,
    required this.onDelete,
  });

  Color _categoryColor(String category) {
    switch (category) {
      case 'Lácteos': return const Color(0xFF667eea);
      case 'Carnes': return const Color(0xFFf5576c);
      case 'Granos': return const Color(0xFFffa000);
      case 'Frutas': return const Color(0xFF43e97b);
      case 'Aseo': return const Color(0xFF38f9d7);
      case 'Personal': return const Color.fromARGB(0, 1, 1, 244);
    default: return const Color(0xFF764ba2);

    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _categoryColor(product.category);
    return Animate(
      effects: [FadeEffect(duration: 300.ms), SlideEffect(begin: const Offset(-0.1, 0))],
      child: Dismissible(
        key: Key(product.key.toString()),
        direction: DismissDirection.endToStart,
        background: Container(
          alignment: Alignment.centerRight,
          padding: const EdgeInsets.only(right: 20),
          decoration: BoxDecoration(
            color: Colors.red.shade100,
            borderRadius: BorderRadius.circular(16),
          ),
          child: const Icon(Icons.delete_outline, color: Colors.red),
        ),
        onDismissed: (_) => onDelete(),
        child: GestureDetector(
          onTap: onToggle,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            margin: const EdgeInsets.symmetric(vertical: 4),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: product.isPurchased
                  ? Colors.grey.shade100
                  : color.withOpacity(0.07),
              borderRadius: BorderRadius.circular(16),
              border: Border(
                left: BorderSide(color: color, width: 4),
              ),
            ),
            child: Row(
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: product.isPurchased ? color : Colors.transparent,
                    border: Border.all(color: color, width: 2),
                    shape: BoxShape.circle,
                  ),
                  child: product.isPurchased
                      ? const Icon(Icons.check, color: Colors.white, size: 14)
                      : null,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        product.name,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: product.isPurchased
                              ? Colors.grey
                              : const Color(0xFF2d2d2d),
                          decoration: product.isPurchased
                              ? TextDecoration.lineThrough
                              : null,
                        ),
                      ),
                      if (product.quantity.isNotEmpty)
                        Text(
                          '${product.quantity} • ${product.category}',
                          style: const TextStyle(
                              fontSize: 12, color: Colors.grey),
                        ),
                    ],
                  ),
                ),
                if (product.isPurchased)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: Colors.green.shade50,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text('Comprado',
                        style: TextStyle(
                            fontSize: 10, color: Colors.green.shade700)),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../models/product_model.dart';

class ProductTile extends StatelessWidget {
  final Product product;
  final int index; // este es la KEY real de Hive, no el índice posicional
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
      case 'Lácteos':
        return const Color(0xFF667eea);
      case 'Carnes':
        return const Color(0xFFf5576c);
      case 'Granos':
        return const Color(0xFFffa000);
      case 'Frutas':
        return const Color(0xFF43e97b);
      case 'Aseo':
        return const Color(0xFF38f9d7);
      default:
        return const Color(0xFF764ba2);
    }
  }

  /// Fix #2: muestra un diálogo de confirmación antes de eliminar.
  /// Esto evita el error "A dismissed Dismissible widget is still part of the tree"
  /// porque onDismissed solo se ejecuta cuando confirmDismiss retorna true,
  /// momento en que Hive ya tiene el dato listo para borrar.
  Future<bool?> _confirmDelete(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Eliminar producto'),
        content: Text('¿Eliminar "${product.name}" de tu lista?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar', style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text(
              'Eliminar',
              style: TextStyle(
                color: Colors.red,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final color = _categoryColor(product.category);

    return Animate(
      effects: [
        FadeEffect(duration: 300.ms),
        SlideEffect(
          begin: const Offset(-0.1, 0),
          duration: 300.ms,
        ),
      ],
      child: Dismissible(
        // Fix #2: ValueKey con la key real de Hive — estable y única.
        // Nunca uses Key(index.toString()) con índices posicionales.
        key: ValueKey('product_${product.key}'),
        direction: DismissDirection.endToStart,

        // Fix #2: confirmDismiss bloquea la animación de dismiss hasta
        // que el usuario confirme. Si cancela, el widget vuelve a su lugar.
        confirmDismiss: (_) => _confirmDelete(context),

        // onDismissed solo corre si confirmDismiss retornó true.
        // Para ese momento Flutter ya sabe que el widget debe salir del árbol.
        onDismissed: (_) => onDelete(),

        background: Container(
          alignment: Alignment.centerRight,
          padding: const EdgeInsets.only(right: 20),
          margin: const EdgeInsets.symmetric(vertical: 4),
          decoration: BoxDecoration(
            color: Colors.red.shade100,
            borderRadius: BorderRadius.circular(16),
          ),
          child: const Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.delete_outline, color: Colors.red, size: 22),
              SizedBox(height: 2),
              Text('Eliminar',
                  style: TextStyle(color: Colors.red, fontSize: 10)),
            ],
          ),
        ),

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
                // Checkbox circular animado
                AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  width: 26,
                  height: 26,
                  decoration: BoxDecoration(
                    color: product.isPurchased ? color : Colors.transparent,
                    border: Border.all(color: color, width: 2),
                    shape: BoxShape.circle,
                  ),
                  child: product.isPurchased
                      ? const Icon(Icons.check, color: Colors.white, size: 15)
                      : null,
                ),
                const SizedBox(width: 12),

                // Nombre y detalles
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
                          '${product.quantity}  •  ${product.category}',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                    ],
                  ),
                ),

                // Badge "Comprado"
                if (product.isPurchased)
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: Colors.green.shade50,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                          color: Colors.green.shade200, width: 1),
                    ),
                    child: Text(
                      '✓ Listo',
                      style: TextStyle(
                        fontSize: 10,
                        color: Colors.green.shade700,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/product_model.dart';
import '../services/hive_service.dart';
import '../services/notification_service.dart';
import '../widgets/info_header.dart';
import '../widgets/product_tile.dart';
import 'ai_chat_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _nameController = TextEditingController();
  final _qtyController = TextEditingController();
  String _selectedCategory = 'General';
  TimeOfDay _reminderTime = const TimeOfDay(hour: 8, minute: 0);

  final List<String> _categories = [
    'General', 'Lácteos', 'Carnes', 'Granos', 'Frutas', 'Aseo', 'Lacteos'
  ];

  void _addProduct() {
    if (_nameController.text.trim().isEmpty) return;
    HiveService.addProduct(Product(
      name: _nameController.text.trim(),
      quantity: _qtyController.text.trim(),
      category: _selectedCategory,
      createdAt: DateTime.now(),
    ));
    _nameController.clear();
    _qtyController.clear();
    setState(() {});
    Navigator.pop(context);
    _scheduleNotification();
  }

  Future<void> _scheduleNotification() async {
    final pending = HiveService.getAllProducts()
        .where((p) => !p.isPurchased)
        .length;
    await NotificationService.scheduleDailyReminder(
      hour: _reminderTime.hour,
      minute: _reminderTime.minute,
      pendingCount: pending,
    );
  }

  void _showAddDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom + 16,
          top: 24, left: 24, right: 24,
        ),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40, height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            const SizedBox(height: 16),
            const Text('Nuevo producto',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                hintText: 'Nombre del producto',
                prefixIcon: const Icon(Icons.shopping_bag_outlined),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14)),
                filled: true, fillColor: const Color(0xFFF8F4FF),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _qtyController,
              decoration: InputDecoration(
                hintText: 'Cantidad (ej: 2kg, x3)',
                prefixIcon: const Icon(Icons.scale_outlined),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14)),
                filled: true, fillColor: const Color(0xFFF8F4FF),
              ),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: _selectedCategory,
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.category_outlined),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14)),
                filled: true, fillColor: const Color(0xFFF8F4FF),
              ),
              items: _categories
                  .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                  .toList(),
              onChanged: (v) => setState(() => _selectedCategory = v!),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _addProduct,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                  backgroundColor: const Color(0xFF667eea),
                ),
                child: const Text('Agregar a la lista',
                    style: TextStyle(color: Colors.white, fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context, initialTime: _reminderTime,
    );
    if (picked != null) {
      setState(() => _reminderTime = picked);
      _scheduleNotification();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F3FF),
      body: SafeArea(
        child: ValueListenableBuilder(
          valueListenable: HiveService.box.listenable(),
          builder: (context, box, _) {
            final products = HiveService.getAllProducts();
            final pending = products.where((p) => !p.isPurchased).length;
            final done = products.where((p) => p.isPurchased).length;

            return CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        // Header
                        Row(
                          children: [
                            const Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Compralo 🛒',
                                    style: TextStyle(
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF2d2d2d))),
                                Text('Tu lista inteligente',
                                    style: TextStyle(
                                        color: Colors.grey, fontSize: 13)),
                              ],
                            ),
                            const Spacer(),
                            IconButton(
                              icon: const Icon(Icons.notifications_outlined,
                                  color: Color(0xFF667eea)),
                              onPressed: _pickTime,
                              tooltip: 'Configurar recordatorio',
                            ),
                            IconButton(
                              icon: const Icon(Icons.smart_toy_outlined,
                                  color: Color(0xFFf5576c)),
                              onPressed: () => Navigator.push(context,
                                  MaterialPageRoute(
                                      builder: (_) => const AiChatScreen())),
                              tooltip: 'Asistente IA',
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),

                        // Info header (hora, fecha, frase)
                        const InfoHeader(),
                        const SizedBox(height: 16),

                        // Progreso
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFF43e97b), Color(0xFF38f9d7)],
                            ),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Row(
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('Progreso',
                                      style: TextStyle(
                                          color: Colors.white70, fontSize: 12)),
                                  Text('$done / ${products.length}',
                                      style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 22,
                                          fontWeight: FontWeight.bold)),
                                  Text('$pending pendiente(s)',
                                      style: const TextStyle(
                                          color: Colors.white70, fontSize: 11)),
                                ],
                              ),
                              const Spacer(),
                              SizedBox(
                                width: 60, height: 60,
                                child: Stack(
                                  alignment: Alignment.center,
                                  children: [
                                    CircularProgressIndicator(
                                      value: products.isEmpty
                                          ? 0
                                          : done / products.length,
                                      backgroundColor:
                                          Colors.white.withOpacity(0.3),
                                      valueColor:
                                          const AlwaysStoppedAnimation<Color>(
                                              Colors.white),
                                      strokeWidth: 6,
                                    ),
                                    Text(
                                      products.isEmpty
                                          ? '0%'
                                          : '${((done / products.length) * 100).round()}%',
                                      style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 13),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 12),

                        // Recordatorio
                        GestureDetector(
                          onTap: _pickTime,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 10),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFFF8E1),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                  color: const Color(0xFFFFD54F), width: 1),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.alarm,
                                    color: Color(0xFFffa000), size: 18),
                                const SizedBox(width: 8),
                                const Text('Recordatorio diario: ',
                                    style: TextStyle(fontSize: 13)),
                                Text(
                                  _reminderTime.format(context),
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFFffa000)),
                                ),
                                const Spacer(),
                                const Icon(Icons.edit_outlined,
                                    size: 14, color: Colors.grey),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Lista de productos
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  sliver: products.isEmpty
                      ? SliverToBoxAdapter(
                          child: Center(
                            child: Padding(
                              padding: const EdgeInsets.only(top: 60),
                              child: Column(
                                children: [
                                  const Text('🛍️',
                                      style: TextStyle(fontSize: 48)),
                                  const SizedBox(height: 12),
                                  Text('Tu lista está vacía',
                                      style: TextStyle(
                                          fontSize: 16,
                                          color: Colors.grey.shade500)),
                                  const SizedBox(height: 4),
                                  Text(
                                      'Toca + para agregar tu primer producto',
                                      style: TextStyle(
                                          fontSize: 13,
                                          color: Colors.grey.shade400)),
                                ],
                              ),
                            ),
                          ),
                        )
                      : SliverList(
                          delegate: SliverChildBuilderDelegate(
                            (context, i) {
                              final product = products[i];
                              final key = HiveService.box.keyAt(i) as int;
                              return ProductTile(
                                product: product,
                                index: key,
                                onToggle: () async {
                                  await HiveService.togglePurchased(key);
                                  _scheduleNotification();
                                },
                                onDelete: () =>
                                    HiveService.deleteProduct(key),
                              );
                            },
                            childCount: products.length,
                          ),
                        ),
                ),
                const SliverToBoxAdapter(child: SizedBox(height: 100)),
              ],
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddDialog,
        backgroundColor: const Color(0xFF667eea),
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('Agregar',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
    );
  }
}
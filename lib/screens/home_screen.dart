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
    'General',
    'Lácteos',
    'Carnes',
    'Granos',
    'Frutas',
    'Aseo',
  ];

  @override
  void initState() {
    super.initState();
    // Pide permisos de notificación al primer arranque
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final hasPermission = await NotificationService.hasPermission();
      if (!hasPermission) {
        await NotificationService.requestPermissions();
      }
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _qtyController.dispose();
    super.dispose();
  }

  Future<void> _scheduleNotification() async {
    final pending = HiveService.getPendingCount();
    await NotificationService.scheduleDailyReminder(
      hour: _reminderTime.hour,
      minute: _reminderTime.minute,
      pendingCount: pending,
    );
  }

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
    setState(() => _selectedCategory = 'General');
    Navigator.pop(context);
    _scheduleNotification();
  }

  void _showAddDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _AddProductSheet(
        nameController: _nameController,
        qtyController: _qtyController,
        categories: _categories,
        initialCategory: _selectedCategory,
        onCategoryChanged: (v) => _selectedCategory = v,
        onAdd: _addProduct,
      ),
    );
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _reminderTime,
    );
    if (picked != null) {
      setState(() => _reminderTime = picked);
      _scheduleNotification();
    }
  }

  // ─── Diálogo completo de notificaciones ───
  void _showNotificationDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.notifications_active, color: Color(0xFF667eea)),
            SizedBox(width: 8),
            Text('Notificaciones'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Cambiar hora
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const CircleAvatar(
                backgroundColor: Color(0xFFFFF8E1),
                child: Icon(Icons.alarm, color: Color(0xFFffa000)),
              ),
              title: const Text('Hora del recordatorio'),
              subtitle: Text(_reminderTime.format(context)),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                Navigator.pop(context);
                _pickTime();
              },
            ),
            const Divider(),
            // Notificación de prueba
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const CircleAvatar(
                backgroundColor: Color(0xFFE8F5E9),
                child: Icon(Icons.send, color: Color(0xFF43a047)),
              ),
              title: const Text('Probar notificación'),
              subtitle: const Text('Verifica sonido y vibración'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () async {
                Navigator.pop(context);
                await NotificationService.sendTestNotification();
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('🔔 Notificación de prueba enviada'),
                      backgroundColor: Color(0xFF43a047),
                    ),
                  );
                }
              },
            ),
            const Divider(),
            // Verificar permisos
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const CircleAvatar(
                backgroundColor: Color(0xFFEDE7F6),
                child: Icon(Icons.security, color: Color(0xFF667eea)),
              ),
              title: const Text('Verificar permisos'),
              subtitle: const Text('Activa si no llegan notificaciones'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () async {
                Navigator.pop(context);
                final granted =
                    await NotificationService.requestPermissions();
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(granted
                          ? '✅ Permisos concedidos correctamente'
                          : '❌ Permisos denegados — actívalos en Ajustes del sistema'),
                      backgroundColor:
                          granted ? const Color(0xFF43a047) : Colors.red,
                      duration: const Duration(seconds: 3),
                    ),
                  );
                }
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F3FF),
      body: SafeArea(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                child: Column(
                  children: [
                    // ─── Header ───
                    Row(
                      children: [
                        const Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'SmartCart 🛒',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF2d2d2d),
                              ),
                            ),
                            Text(
                              'Tu lista inteligente',
                              style: TextStyle(
                                  color: Colors.grey, fontSize: 13),
                            ),
                          ],
                        ),
                        const Spacer(),
                        // Botón notificaciones — abre diálogo completo
                        IconButton(
                          icon: const Icon(
                            Icons.notifications_outlined,
                            color: Color(0xFF667eea),
                          ),
                          onPressed: _showNotificationDialog,
                          tooltip: 'Notificaciones',
                        ),
                        // Botón IA
                        IconButton(
                          icon: const Icon(
                            Icons.smart_toy_outlined,
                            color: Color(0xFFf5576c),
                          ),
                          onPressed: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => const AiChatScreen()),
                          ),
                          tooltip: 'Asistente IA',
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // ─── Info: hora, fecha y frase ───
                    const InfoHeader(),
                    const SizedBox(height: 16),

                    // ─── Barra de progreso (widget aislado) ───
                    _ProgressBar(box: HiveService.box),
                    const SizedBox(height: 12),

                    // ─── Recordatorio ───
                    GestureDetector(
                      onTap: _showNotificationDialog,
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
                            const Text('Recordatorio diario:',
                                style: TextStyle(fontSize: 13)),
                            const SizedBox(width: 6),
                            Text(
                              _reminderTime.format(context),
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Color(0xFFffa000),
                              ),
                            ),
                            const Spacer(),
                            const Icon(Icons.edit_outlined,
                                size: 14, color: Colors.grey),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                  ],
                ),
              ),
            ),

            // ─── Lista de productos (widget aislado, fix FPS) ───
            _ProductList(onSchedule: _scheduleNotification),

            const SliverToBoxAdapter(child: SizedBox(height: 100)),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddDialog,
        backgroundColor: const Color(0xFF667eea),
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text(
          'Agregar',
          style: TextStyle(
              color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Widget aislado: barra de progreso.
// Solo se reconstruye cuando Hive cambia.
// ─────────────────────────────────────────────────────────────
class _ProgressBar extends StatelessWidget {
  final Box<Product> box;
  const _ProgressBar({required this.box});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: box.listenable(),
      builder: (_, __, ___) {
        final products = HiveService.getAllProducts();
        final done = products.where((p) => p.isPurchased).length;
        final total = products.length;
        final pending = total - done;
        final progress = total == 0 ? 0.0 : done / total;

        return Container(
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
                      style:
                          TextStyle(color: Colors.white70, fontSize: 12)),
                  Text(
                    '$done / $total',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    '$pending pendiente(s)',
                    style: const TextStyle(
                        color: Colors.white70, fontSize: 11),
                  ),
                ],
              ),
              const Spacer(),
              SizedBox(
                width: 60,
                height: 60,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    CircularProgressIndicator(
                      value: progress,
                      backgroundColor: Colors.white.withOpacity(0.3),
                      valueColor: const AlwaysStoppedAnimation<Color>(
                          Colors.white),
                      strokeWidth: 6,
                    ),
                    Text(
                      '${(progress * 100).round()}%',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Widget aislado: lista de productos.
// Separado para que tipear en TextField no cause rebuild aquí.
// ─────────────────────────────────────────────────────────────
class _ProductList extends StatelessWidget {
  final VoidCallback onSchedule;
  const _ProductList({required this.onSchedule});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: HiveService.box.listenable(),
      builder: (context, box, _) {
        final products = HiveService.getAllProducts();

        if (products.isEmpty) {
          return const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.only(top: 60),
              child: Column(
                children: [
                  Text('🛍️', style: TextStyle(fontSize: 52)),
                  SizedBox(height: 12),
                  Text(
                    'Tu lista está vacía',
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Toca + para agregar tu primer producto',
                    style: TextStyle(fontSize: 13, color: Colors.grey),
                  ),
                ],
              ),
            ),
          );
        }

        return SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, i) {
                final product = products[i];
                final realKey = product.key as int;
                return ProductTile(
                  key: ValueKey('tile_$realKey'),
                  product: product,
                  index: realKey,
                  onToggle: () async {
                    await HiveService.togglePurchased(realKey);
                    onSchedule();
                  },
                  onDelete: () => HiveService.deleteProduct(realKey),
                );
              },
              childCount: products.length,
            ),
          ),
        );
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Bottom sheet para agregar productos.
// StatefulWidget propio para que su setState no afecte HomeScreen.
// ─────────────────────────────────────────────────────────────
class _AddProductSheet extends StatefulWidget {
  final TextEditingController nameController;
  final TextEditingController qtyController;
  final List<String> categories;
  final String initialCategory;
  final ValueChanged<String> onCategoryChanged;
  final VoidCallback onAdd;

  const _AddProductSheet({
    required this.nameController,
    required this.qtyController,
    required this.categories,
    required this.initialCategory,
    required this.onCategoryChanged,
    required this.onAdd,
  });

  @override
  State<_AddProductSheet> createState() => _AddProductSheetState();
}

class _AddProductSheetState extends State<_AddProductSheet> {
  late String _category;

  @override
  void initState() {
    super.initState();
    _category = widget.initialCategory;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + 16,
        top: 24,
        left: 24,
        right: 24,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Nuevo producto',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),

          // Nombre
          TextField(
            controller: widget.nameController,
            autofocus: true,
            textCapitalization: TextCapitalization.sentences,
            decoration: InputDecoration(
              hintText: 'Nombre del producto',
              prefixIcon: const Icon(Icons.shopping_bag_outlined),
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14)),
              filled: true,
              fillColor: const Color(0xFFF8F4FF),
            ),
          ),
          const SizedBox(height: 12),

          // Cantidad
          TextField(
            controller: widget.qtyController,
            decoration: InputDecoration(
              hintText: 'Cantidad (ej: 2kg, x3, 1 bolsa)',
              prefixIcon: const Icon(Icons.scale_outlined),
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14)),
              filled: true,
              fillColor: const Color(0xFFF8F4FF),
            ),
          ),
          const SizedBox(height: 12),

          // Categoría
          DropdownButtonFormField<String>(
            value: _category,
            decoration: InputDecoration(
              prefixIcon: const Icon(Icons.category_outlined),
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14)),
              filled: true,
              fillColor: const Color(0xFFF8F4FF),
            ),
            items: widget.categories
                .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                .toList(),
            onChanged: (v) {
              if (v != null) {
                setState(() => _category = v);
                widget.onCategoryChanged(v);
              }
            },
          ),
          const SizedBox(height: 20),

          // Botón agregar
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: widget.onAdd,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
                backgroundColor: const Color(0xFF667eea),
              ),
              child: const Text(
                'Agregar a la lista',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
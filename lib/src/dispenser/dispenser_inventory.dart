import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:backend_client/backend_client.dart';

class InventoryManagement extends StatefulWidget {
  const InventoryManagement({super.key});

  @override
  State<InventoryManagement> createState() => _InventoryManagementState();
}

class _InventoryManagementState extends State<InventoryManagement> {

  Future<int?> _getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    final storedUserId = prefs.getString('user_id');
    return storedUserId != null ? int.tryParse(storedUserId) : null;
  }

  // Start with an empty inventory; real data will be loaded from backend in _loadInventory().
  List<Map<String, dynamic>> _inventory = [];

  @override
  void initState() {
    super.initState();
    // Load real inventory from backend on startup
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadInventory();
    });
  }

  /// Refresh inventory list from backend
  Future<void> _loadInventory() async {
    try {
      final result = await client.dispenser.listInventoryItems();
      final mapped = result.map((item) => {
        'id': item.itemId,
        'name': item.itemName,
        'unit': item.unit,
        'currentStock': item.currentQuantity,
        'minThreshold': item.minimumStock,
        'lastUpdate': DateTime.now(),
      }).toList();

      if (!mounted) return;
      setState(() {
        _inventory = mapped;
      });
    } catch (e) {
      debugPrint('Failed to load inventory from backend: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to load inventory from server')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final unique = _inventory; // use the raw inventory list (no deduplication)

    return Scaffold(
      backgroundColor: Colors.grey[50],

      body: Column(
        children: [
          // 🔸 LOW STOCK ALERT
          Padding(
            padding: const EdgeInsets.all(16),
            child: Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    const Icon(Icons.warning, color: Colors.orange, size: 28),
                    const SizedBox(width: 12),
                    const Text(
                      'Low Stock Alert:',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      // use unique list for low-stock count
                      '${unique.where((item) => (item['currentStock'] as int) <= (item['minThreshold'] as int)).length} items',
                      style: const TextStyle(
                        color: Colors.red,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const Spacer(),
                    Icon(Icons.inventory_2, color: Colors.blue.shade700, size: 28),
                  ],
                ),
              ),
            ),
          ),

          // 🔸 INVENTORY COUNT
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Text(
                  // show count of unique names
                  'Total Medicines: ${unique.length}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),

          // 🔸 MEDICINE LIST
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              // use inventory list (no deduplication)
              itemCount: unique.length,
              itemBuilder: (context, index) {
                final item = unique[index];
                final currentStock = item['currentStock'] as int;
                final minThreshold = item['minThreshold'] as int;
                final isLowStock = currentStock <= minThreshold;
                final lastUpdate = item['lastUpdate'] as DateTime;

                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  elevation: 3,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: ListTile(
                    leading: Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: isLowStock ? Colors.red.shade100 : Colors.green.shade100,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: isLowStock ? Colors.red : Colors.green,
                          width: 1,
                        ),
                      ),
                      child: Icon(
                        Icons.medication,
                        color: isLowStock ? Colors.red : Colors.green,
                      ),
                    ),
                    title: Text(
                      item['name'] as String,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: isLowStock ? Colors.red : Colors.black,
                        fontSize: 16,
                      ),
                    ),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Show stock, min and unit
                          Text(
                            'Stock: $currentStock ${item['unit']} (Min: $minThreshold ${item['unit']})',
                            style: TextStyle(
                              color: isLowStock ? Colors.red : Colors.black,
                              fontWeight: isLowStock ? FontWeight.bold : FontWeight.normal,
                            ),
                          ),
                          const SizedBox(height: 4),
                          // last update time
                          Text(
                            '🕒 Last update: ${lastUpdate.day}/${lastUpdate.month}/${lastUpdate.year} ${lastUpdate.hour.toString().padLeft(2, '0')}:${lastUpdate.minute.toString().padLeft(2, '0')}',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),

                    // 🔸 RESTOCK BUTTON AND ICON
                    trailing: SizedBox(
                      width: 80,
                      height: 48,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            isLowStock ? Icons.warning : Icons.check_circle,
                            color: isLowStock ? Colors.orange : Colors.green,
                            size: 20,
                          ),
                          const SizedBox(height: 2),

                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                              minimumSize: const Size(60, 30),
                              visualDensity: VisualDensity.compact,
                            ),
                            child: const Text('Restock', style: TextStyle(fontSize: 12)),

                            onPressed: () async {
                              final restockController = TextEditingController();

                              showDialog(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title: Text('Restock ${item['name']}'),
                                  content: TextField(
                                    controller: restockController,
                                    keyboardType: TextInputType.number,
                                    decoration: const InputDecoration(
                                      labelText: 'Quantity',
                                      border: OutlineInputBorder(),
                                    ),
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.pop(context),
                                      child: const Text('Cancel'),
                                    ),
                                    ElevatedButton(
                                      child: const Text('Restock'),
                                      onPressed: () async {
                                        final qty = int.tryParse(restockController.text) ?? 0;
                                        if (qty <= 0) return;

                                        final userId = await _getUserId();
                                        if (userId == null) {
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            const SnackBar(content: Text('User not logged in')),
                                          );
                                          return;
                                        }

                                        // Use 'id' from local sample inventory. Replace with actual item id when integrating.
                                        final success = await client.dispenser.restockItem(
                                          userId: userId,
                                          itemId: item['id'],
                                          quantity: qty,
                                        );

                                        Navigator.pop(context);

                                        if (success) {
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            const SnackBar(
                                              content: Text('✅ Stock updated successfully'),
                                              backgroundColor: Colors.green,
                                            ),
                                          );

                                          // 🔄 Refresh inventory from backend
                                          await _loadInventory();
                                        } else {
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            const SnackBar(
                                              content: Text('❌ Restock failed (permission or error)'),
                                              backgroundColor: Colors.red,
                                            ),
                                          );
                                        }
                                      },
                                    ),
                                  ],
                                ),
                              );
                            },
                          )

                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

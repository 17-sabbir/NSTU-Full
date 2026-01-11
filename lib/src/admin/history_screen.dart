import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:backend_client/backend_client.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  final Color primaryColor = const Color(0xFF00796B); // Deep Teal
  List<InventoryAuditLog> historyItems = [];
  List<AuditEntry> _generalLogs = [];
  bool _loading = false;

  // Pagination এর জন্য ভেরিয়েবল (আপনার এন্ডপয়েন্টে এগুলো প্রয়োজন)
  final int _limit = 20;
  final int _offset = 0;

  @override
  void initState() {
    super.initState();
    _fetchAllData();
  }

  Future<void> _fetchAllData() async {
    setState(() => _loading = true);
    // একসাথে দুই ধরণের ডেটাই ফেচ করা হবে
    await Future.wait([_fetchInventoryHistory(), _fetchGeneralAuditHistory()]);
    if (mounted) setState(() => _loading = false);
  }

  Future<void> _fetchInventoryHistory() async {
    if (!mounted) return;
    setState(() => _loading = true);

    try {

      final res = await client.adminInventoryEndpoints.getInventoryAuditLogs(
        _limit,
        _offset,
      );

      if (mounted) {
        setState(() {
          historyItems = res;
        });
      }
    } catch (e) {
      debugPrint('Failed to load audit logs: $e');
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Failed to load history')));
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _fetchGeneralAuditHistory() async {
    try {
      final res = await client.adminEndpoints.getAuditLogs();
      setState(() {
        _generalLogs = res;
      });
    } catch (e) {
      debugPrint('General Audit load failed: $e');
    }
  }

  // অ্যাকশন অনুযায়ী সহজ নাম দেওয়া
  String _mapActionType(String action) {
    switch (action) {
      case 'CREATE_ITEM':
        return 'create';
      case 'ADD_STOCK':
        return 'stock_in';
      case 'REMOVE_STOCK':
        return 'stock_out';
      case 'EDIT_MIN_THRESHOLD':
        return 'update';
      default:
        return 'admin_action';
    }
  }

  IconData _getActionIcon(String type) {
    switch (type) {
      case 'create':
        return Icons.add_circle;
      case 'update':
        return Icons.edit_note;
      case 'stock_in':
        return Icons.arrow_circle_up;
      case 'stock_out':
        return Icons.arrow_circle_down;
      default:
        return Icons.history;
    }
  }

  Color _getIconColor(String type) {
    switch (type) {
      case 'create':
        return Colors.green;
      case 'update':
        return Colors.blue;
      case 'stock_in':
        return Colors.lightGreen;
      case 'stock_out':
        return Colors.red;
      default:
        return primaryColor;
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(50),
          child: AppBar(
            backgroundColor: Colors.white,
            elevation: 0,
            bottom: TabBar(
              labelColor: primaryColor,
              unselectedLabelColor: Colors.grey,
              indicatorColor: primaryColor,
              tabs: const [
                Tab(text: "Inventory Logs"),
                Tab(text: "General Logs"),
              ],
            ),
          ),
        ),
        body: _loading
            ? const Center(child: CircularProgressIndicator())
            : TabBarView(
                children: [
                  _buildInventoryTab(), // আপনার আগের ডিজাইন
                  _buildGeneralAuditTab(), // নতুন ডিজাইন
                ],
              ),
      ),
    );
  }

  Widget _buildGeneralAuditTab() {
    if (_generalLogs.isEmpty) {
      return const Center(child: Text("No general logs found"));
    }

    return RefreshIndicator(
      onRefresh: _fetchAllData,
      child: ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: _generalLogs.length,
        itemBuilder: (context, index) {
          final log = _generalLogs[index];

          return Card(
            elevation: 1,
            margin: const EdgeInsets.symmetric(vertical: 6),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: Colors.blue.withOpacity(0.1),
                child: const Icon(
                  Icons.admin_panel_settings,
                  color: Colors.blue,
                ),
              ),
              title: Text(
                log.adminName ?? 'Unknown Admin',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 4),
                  Text(
                    "Action: ${log.action}",
                    style: const TextStyle(color: Colors.black87),
                  ),
                  Text(
                    "Target Name: ${log.targetName}",
                    style: const TextStyle(fontSize: 12),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    DateFormat('dd MMM yyyy | hh:mm a').format(log.createdAt),
                    style: const TextStyle(color: Colors.grey, fontSize: 11),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildInventoryTab() {
    if (historyItems.isEmpty) {
      return const Center(child: Text('No inventory history found'));
    }
    return RefreshIndicator(
      onRefresh: _fetchAllData,
      child: ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: historyItems.length,
        itemBuilder: (context, index) {
          final item = historyItems[index];
          final action = item.action;
          final type = _mapActionType(action);

          return Card(
            elevation: 1,
            margin: const EdgeInsets.symmetric(vertical: 6),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(color: Colors.grey.shade200),
            ),
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(
                vertical: 8,
                horizontal: 16,
              ),
              leading: CircleAvatar(
                backgroundColor: _getIconColor(type).withOpacity(0.12),
                child: Icon(_getActionIcon(type), color: _getIconColor(type)),
              ),
              title: Text(
                item.userName ?? 'System Admin', // আপনার YAML অনুযায়ী userName
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 4),
                  Text(
                    "Action: $action",
                    style: const TextStyle(color: Colors.black87),
                  ),
                  // স্টক পরিবর্তন দেখালে ভালো হয়
                  if (item.oldQuantity != null && item.newQuantity != null)
                    Text(
                      "Change: ${item.oldQuantity} → ${item.newQuantity}",
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.blueGrey.shade700,
                      ),
                    ),
                  const SizedBox(height: 6),
                  Text(
                    // সরাসরি item.timestamp ব্যবহার করা (কারণ এটি অলরেডি DateTime অবজেক্ট)
                    DateFormat('dd MMM yyyy | hh:mm a').format(item.timestamp),
                    style: const TextStyle(color: Colors.grey, fontSize: 11),
                  ),
                ],
              ),
              isThreeLine: true,
            ),
          );
        },
      ),
    );
  }
}

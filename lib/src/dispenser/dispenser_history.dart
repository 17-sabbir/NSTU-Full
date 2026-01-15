import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:backend_client/backend_client.dart';
import 'package:intl/intl.dart';

class DispenseLogsScreen extends StatefulWidget {
  const DispenseLogsScreen({super.key});

  @override
  State<DispenseLogsScreen> createState() => _DispenseLogsScreenState();
}

class _DispenseLogsScreenState extends State<DispenseLogsScreen> {
  List<InventoryAuditLog> _logs = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    if (!mounted) return;
    setState(() => _isLoading = true);

    final prefs = await SharedPreferences.getInstance();
    final userIdStr = prefs.getString('user_id');
    final userId = int.tryParse(userIdStr ?? '');

    if (userId != null) {
      try {
        // ব্যাকএন্ড থেকে ডেটা ফেচ (আপনার এন্ডপয়েন্ট অনুযায়ী নাম চেক করে নিন)
        final result = await client.dispenser.getDispenserHistory();
        if (mounted) {
          setState(() {
            _logs = result;
            _isLoading = false;
          });
        }
      } catch (e) {
        if (mounted) setState(() => _isLoading = false);
        debugPrint("Error loading history: $e");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadHistory,
              child: _logs.isEmpty
                  ? _buildEmptyState()
                  : ListView.builder(
                      itemCount: _logs.length,
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      itemBuilder: (context, index) {
                        final log = _logs[index];
                        return _buildLogCard(log);
                      },
                    ),
            ),
    );
  }

  Widget _buildLogCard(InventoryAuditLog log) {
    bool isDispensed = log.action == 'DISPENSE';
    Color actionColor = isDispensed ? Colors.orange : Colors.green;
    IconData actionIcon = isDispensed ? Icons.outbox : Icons.add_business;

    return Card(
      elevation: 1,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: CircleAvatar(
          backgroundColor: actionColor.withOpacity(0.1),
          child: Icon(actionIcon, color: actionColor),
        ),
        title: Text(
          log.userName ?? 'Unknown Item', // এখানে আইটেম নাম দেখাবে
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    log.action,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: actionColor,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  "Stock: ${log.oldQuantity} → ${log.newQuantity}",
                  style: const TextStyle(fontSize: 13, color: Colors.black87),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              DateFormat('dd MMM yyyy • hh:mm a').format(log.timestamp),
              style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.history_toggle_off, size: 60, color: Colors.grey.shade400),
          const SizedBox(height: 16),
          const Text(
            "No activity history found",
            style: TextStyle(color: Colors.grey, fontSize: 16),
          ),
        ],
      ),
    );
  }
}

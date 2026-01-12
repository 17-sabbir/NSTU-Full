import 'package:flutter/material.dart';
import 'dispenser_medicine_item.dart';
import 'dispenser_profile.dart';
import 'dispenser_history.dart';
import 'dispenser_inventory.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:backend_client/backend_client.dart';

// Use Map-based structures for prescriptions and logs to avoid custom classes
typedef PrescriptionMap = Map<String, dynamic>;
typedef DispenseLogMap = Map<String, dynamic>;

class DispenserDashboard extends StatefulWidget {
  const DispenserDashboard({super.key});

  @override
  State<DispenserDashboard> createState() => _DispenserDashboardState();
}

class _DispenserDashboardState extends State<DispenserDashboard> {
  final _searchController = TextEditingController();
  PrescriptionMap? _currentPrescription;
  bool _isLoading = false;
  int _selectedIndex = 0;
  String _searchQuery = '';
  final List<int> _navigationHistory = [0]; // Track tab navigation

  final List<PrescriptionMap> _allPrescriptions = [];

  int _toInt(dynamic v) {
    if (v == null) return 0;
    if (v is int) return v;
    if (v is num) return v.toInt();
    return int.tryParse(v.toString()) ?? 0;
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _verifyDispenser();
      _loadPendingPrescriptions();
    });
  }

  Future<void> _verifyDispenser() async {
    try {
      // ignore: deprecated_member_use
      final authKey = await client.authenticationKeyManager?.get();
      if (authKey == null || authKey.isEmpty) {
        if (!mounted) return;
        Navigator.pushReplacementNamed(context, '/');
        return;
      }

      final prefs = await SharedPreferences.getInstance();
      final storedUserId = prefs.getString('user_id');
      if (storedUserId == null || storedUserId.isEmpty) {
        if (!mounted) return;
        Navigator.pushReplacementNamed(context, '/');
        return;
      }
      final int? numericId = int.tryParse(storedUserId);
      if (numericId == null) {
        if (!mounted) return;
        Navigator.pushReplacementNamed(context, '/');
        return;
      }
      String role = '';
      try {
        role = (await client.patient.getUserRole(0)).toUpperCase();
      } catch (e) {
        debugPrint('Failed to fetch user role: $e');
      }
      if (role == 'DISPENSER' || role == 'NURSE') {
        // allowed
      } else {
        if (!mounted) return;
        Navigator.pushReplacementNamed(context, '/');
        return;
      }
    } catch (e) {
      debugPrint('Dispenser auth failed: $e');
      if (!mounted) return;
      Navigator.pushReplacementNamed(context, '/');
      return;
    }
  }

  Future<int?> _getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    final storedUserId = prefs.getString('user_id');
    return storedUserId != null ? int.tryParse(storedUserId) : null;
  }

  // Fetch pending prescriptions from backend
  Future<void> _loadPendingPrescriptions() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final serverList = await client.dispenser.getPendingPrescriptions();

      // Map exactly what backend sends
      final mapped = serverList.map((p) {
        return <String, dynamic>{
          'id': (p.id ?? 0).toString(),
          'name': p.name ?? '',
          'doctorId': p.doctorId,
          'doctorName': p.doctorName ?? '',
          'mobileNumber': p.mobileNumber ?? '',
          'prescriptionDate': p.prescriptionDate,
        };
      }).toList();

      if (!mounted) return;
      setState(() {
        _allPrescriptions
          ..clear()
          ..addAll(mapped);
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Failed to load pending prescriptions: $e');
      if (!mounted) return;
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to load prescriptions from server'),
        ),
      );
    }
  }

  Future<void> _selectPrescription(PrescriptionMap localPres) async {
    setState(() => _isLoading = true);

    try {
      final presId = int.parse(localPres['id']);
      final detail = await client.dispenser.getPrescriptionDetail(presId);

      if (detail == null || detail.items.isEmpty) {
        debugPrint('No prescription items found for ID $presId');
        // ignore: use_build_context_synchronously
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No prescription items found')),
        );
        return;
      }

      final List<Medicine> meds = [];

      for (final it in detail.items) {
        final int dosage = _toInt(it.dosageTimes);
        final int duration = _toInt(it.duration);
        final int prescribedQty = dosage * duration;

        // getStockByFirstWord দিয়ে inventory match
        final stockInfo = await client.dispenser.getStockByFirstWord(
          it.medicineName,
        );
        // Only set originalItemId if it exists in inventory
        final int? originalId = stockInfo != null ? it.itemId : null;
        meds.add(
          Medicine(
            itemId: stockInfo?.itemId, // match পেলে itemId, না পেলে null
            name: it.medicineName,
            stock: stockInfo?.currentQuantity ?? 0,
            dose: '$dosage × $duration',
            prescribedQty: prescribedQty,
            dispenseQty: prescribedQty,
            isAlternative: false,
            originalItemId: originalId, // মূল prescription এর id
          ),
        );
      }

      setState(() {
        localPres['medicines'] = meds;
        localPres['status'] = 'pending';
        _currentPrescription = localPres;
      });
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _dispensePrescription() async {
    final meds = _currentPrescription!['medicines'] as List<Medicine>;
    final dispenserId = await _getUserId();

    final List<DispenseItemRequest> items = [];

    for (var m in meds) {
      if (m.dispenseQty <= 0 || m.itemId == null) continue;

      int? originalId;

      if (m.originalItemId != null) {
        // check inventory before assigning FK
        final stockCheck = await client.dispenser.getStockByFirstWord(m.name);
        if (stockCheck != null && stockCheck.itemId == m.originalItemId) {
          originalId = m.originalItemId;
        } else {
          originalId = null; // inventory তে নেই → FK skip
        }
      }

      items.add(
        DispenseItemRequest(
          itemId: m.itemId!,
          medicineName: m.name,
          quantity: m.dispenseQty,
          isAlternative: m.isAlternative,
          originalMedicineId: originalId, // only safe ID
        ),
      );
    }

    if (items.isEmpty) {
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No valid medicine selected for dispensing'),
        ),
      );
      return;
    }

    try {
      final success = await client.dispenser.dispensePrescription(
        prescriptionId: int.parse(_currentPrescription!['id']),
        dispenserId: dispenserId!,
        items: items,
      );

      if (success) {
        _loadPendingPrescriptions();
        setState(() => _currentPrescription = null);
      }
    } catch (e) {
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Dispense failed: ${e.toString()}')),
      );
    }
  }

  void _updateMedicine(Medicine updatedMed) {
    final meds = (_currentPrescription!['medicines'] as List<Medicine>);
    final index = meds.indexWhere((m) => m.itemId == updatedMed.itemId);

    if (index != -1) {
      setState(() => meds[index] = updatedMed);
    }
  }

  Future<void> _refresh() async {
    await _loadPendingPrescriptions();
  }

  Future<bool> _onWillPop() async {
    if (_navigationHistory.isNotEmpty) {
      setState(() {
        _selectedIndex = _navigationHistory.removeLast();
      });
      return false;
    } else {
      final shouldExit = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text(
            "Exit App Confirmation",
            textAlign: TextAlign.center,
          ),
          content: const Text("Do you want to exit?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text("No"),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text("Yes"),
            ),
          ],
        ),
      );
      return shouldExit ?? false;
    }
  }

  Widget _buildSearchSection() {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: 'Prescription Number or name',
                prefixIcon: const Icon(Icons.search),
                border: const OutlineInputBorder(),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          setState(() {
                            _searchQuery = '';
                            _searchController.clear();
                          });
                        },
                      )
                    : null,
              ),
              onSubmitted: (_) => _searchPrescription(),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _searchPrescription() async {
    final searchTerm = _searchController.text.trim();
    if (searchTerm.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter Prescription ID, Patient ID or Name'),
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
      _searchQuery = searchTerm;
    });

    // Filter locally first; server-side search not implemented in endpoint
    await Future.delayed(const Duration(milliseconds: 300));
    setState(() => _isLoading = false);
  }

  Widget _buildPrescriptionView() {
    if (_currentPrescription == null) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.medical_services, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'Select a prescription to begin dispensing',
              style: TextStyle(color: Colors.grey, fontSize: 16),
            ),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Add a back button
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.blue),
                onPressed: () {
                  setState(() {
                    _currentPrescription = null; // go back to list
                  });
                },
              ),
              const SizedBox(width: 8),
              const Text(
                'Prescription Details',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 8),

          Card(
            elevation: 2,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Prescription #${_currentPrescription!['id']}',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Chip(
                        label: Text(
                          _currentPrescription!['status']
                              .toString()
                              .toUpperCase(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                          ),
                        ),
                        backgroundColor:
                            _currentPrescription!['status'] == 'completed'
                            ? Colors.green
                            : Colors.blue,
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text('Patient: ${_currentPrescription!['name']}'),
                  Text('Doctor: ${_currentPrescription!['doctorName']}'),
                  if (_currentPrescription!['prescriptionDate'] != null)
                    Text(
                      'Date: ${_currentPrescription!['prescriptionDate'].toString().split(' ')[0]}',
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          if (_currentPrescription!['status'] == 'pending') ...[
            const Text(
              'Medicines to Dispense',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            ...(_currentPrescription!['medicines'] as List<Medicine>)
                .asMap()
                .entries
                .map((entry) {
                  final index = entry.key;
                  final med = entry.value;
                  return MedicineItem(
                    client: client,
                    key: ValueKey('${med.itemId}-$index'),
                    medicine: med,
                    onChanged: _updateMedicine,
                  );
                }),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _dispensePrescription,
                icon: const Icon(Icons.medication, color: Colors.white),
                label: const Text(
                  'Dispense Prescription',
                  style: TextStyle(fontSize: 16, color: Colors.white),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ] else ...[
            const SizedBox(height: 16),
            Card(
              color: Colors.green[50],
              child: const Padding(
                padding: EdgeInsets.all(16),
                child: Row(
                  children: [
                    Icon(Icons.check_circle, color: Colors.green),
                    SizedBox(width: 8),
                    Text(
                      'This prescription has been dispensed',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildAllPrescriptionsList() {
    final prescriptions = _searchQuery.isEmpty
        ? _allPrescriptions
        : _allPrescriptions.where((prescription) {
            final id = (prescription['id'] ?? '').toString().toLowerCase();
            final name = (prescription['name'] ?? '').toString().toLowerCase();
            final doctor = (prescription['doctorName'] ?? '')
                .toString()
                .toLowerCase();
            return id.contains(_searchQuery.toLowerCase()) ||
                name.contains(_searchQuery.toLowerCase()) ||
                doctor.contains(_searchQuery.toLowerCase());
          }).toList();

    if (prescriptions.isEmpty) {
      return Center(
        child: _isLoading
            ? const Padding(
                padding: EdgeInsets.all(24.0),
                child: CircularProgressIndicator(),
              )
            : const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.medical_services, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    'No prescriptions found',
                    style: TextStyle(color: Colors.grey, fontSize: 16),
                  ),
                ],
              ),
      );
    }

    return RefreshIndicator(
      onRefresh: _refresh,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: prescriptions.length,
        itemBuilder: (context, index) {
          final prescription = prescriptions[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: ListTile(
              leading: const Icon(Icons.medical_services, color: Colors.blue),
              title: Text('Prescription #${prescription['id']}'),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Patient: ${prescription['name']}'),
                  Text('Doctor: ${prescription['doctorName']}'),
                  Text('Mobile: ${prescription['mobileNumber']}'),
                  if (prescription['prescriptionDate'] != null)
                    Text(
                      'Date: ${prescription['prescriptionDate'].toString().split(' ')[0]}',
                    ),
                ],
              ),
              onTap: () => _selectPrescription(prescription),
            ),
          );
        },
      ),
    );
  }

  void _confirmLogout() async {
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Logout', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (shouldLogout == true) {
      // Clear stored session if needed, then navigate to root
      try {
        try {
          await client.auth.logout();
        } catch (_) {}
        // ignore: deprecated_member_use
        await client.authenticationKeyManager?.remove();
      } catch (_) {}

      try {
        final prefs = await SharedPreferences.getInstance();
        await prefs.remove('user_id');
        await prefs.remove('user_role');
        await prefs.remove('user_email');
      } catch (_) {}

      if (!mounted) return;
      Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
    }
  }

  @override
  Widget build(BuildContext context) {
    // ignore: deprecated_member_use
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            _selectedIndex == 0
                ? 'Dispenser Dashboard'
                : _selectedIndex == 1
                ? 'Inventory Management'
                : _selectedIndex == 2
                ? 'Dispense History'
                : 'Profile',
            style: const TextStyle(color: Colors.blueAccent),
          ),
          centerTitle: true,
          backgroundColor: Colors.white,
          foregroundColor: Colors.blueAccent,
          elevation: 0,
          actions: [
            if (_selectedIndex == 0) ...[
              IconButton(
                icon: const Icon(Icons.refresh, color: Colors.blueAccent),
                tooltip: 'Refresh',
                onPressed: _refresh,
              ),
              IconButton(
                icon: const Icon(Icons.notifications),
                onPressed: () async {
                  await Navigator.pushNamed(context, '/notifications');
                },
              ),
            ],
            // Show logout button at AppBar when in Profile tab
            if (_selectedIndex == 3) ...[
              IconButton(
                icon: const Icon(Icons.logout, color: Colors.blueAccent),
                tooltip: 'Logout',
                onPressed: _confirmLogout,
              ),
            ],
          ],
        ),

        body: _selectedIndex == 0
            ? Column(
                children: [
                  _buildSearchSection(),
                  if (_currentPrescription != null)
                    Expanded(child: _buildPrescriptionView())
                  else
                    Expanded(child: _buildAllPrescriptionsList()),
                ],
              )
            : _selectedIndex == 1
            ? const InventoryManagement()
            : _selectedIndex == 2
            ? DispenseLogsScreen()
            : const DispenserProfile(),
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: (index) {
            if (_navigationHistory.isEmpty ||
                _navigationHistory.last != index) {
              _navigationHistory.add(index);
            }
            setState(() => _selectedIndex = index);
          },
          type: BottomNavigationBarType.fixed,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.medical_services),
              label: 'Dispense',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.inventory),
              label: 'Inventory',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.history),
              label: 'History',
            ),
            BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
          ],
        ),
      ),
    );
  }
}

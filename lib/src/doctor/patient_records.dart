import 'package:flutter/material.dart';
import 'prescription_page.dart';
import 'package:backend_client/backend_client.dart';

class PatientRecordsPage extends StatefulWidget {
  const PatientRecordsPage({super.key});

  @override
  State<PatientRecordsPage> createState() => _PatientRecordsPageState();
}

class _PatientRecordsPageState extends State<PatientRecordsPage> {
  final TextEditingController _searchController = TextEditingController();

  bool _loading = false;
  String? _error;

  List<PatientPrescriptionListItem> _patients = [];
  List<PatientPrescriptionListItem> _filteredPatients = [];

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_filterPatients);
    _fetchPatients();
  }

  @override
  void dispose() {
    _searchController.removeListener(_filterPatients);
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _fetchPatients() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final data = await client.doctor.getPatientPrescriptionList(
        query: _searchController.text.trim(),
        limit: 200,
        offset: 0,
      );

      if (!mounted) return;

      setState(() {
        _patients = data;
        _filteredPatients = data; // initial
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  void _filterPatients() {
    if (!mounted) return;
    final query = _searchController.text.toLowerCase().trim();

    // backend search already supported, কিন্তু UI instant filter রাখলাম
    setState(() {
      if (query.isEmpty) {
        _filteredPatients = _patients;
      } else {
        _filteredPatients = _patients.where((p) {
          final name = p.name.toLowerCase();
          final mobile = (p.mobileNumber ?? '').toLowerCase();
          return name.contains(query) || mobile.contains(query);
        }).toList();
      }
    });
  }


  Future<void> _viewPatientDetails(PatientPrescriptionListItem patient) async {
    try {
      final details = await client.doctor.getPrescriptionDetails(
        prescriptionId: patient.prescriptionId,
      );

      if (!mounted || details == null) return;

      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        builder: (context) => PatientDetailsSheet(details: details),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final query = _searchController.text.trim();

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Patient Record",
          style: TextStyle(
            color: Colors.blueAccent,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications),
            onPressed: () async {
              await Navigator.pushNamed(context, '/notifications');
            },
          ),
          IconButton(
            tooltip: 'Refresh',
            icon: const Icon(Icons.refresh),
            onPressed: _fetchPatients,
          ),
        ],
        centerTitle: true,
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.blueAccent),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search by Patient Name or Number...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Colors.grey[50],
              ),
              onSubmitted: (_) => _fetchPatients(), // server-side search
            ),
          ),

          if (_loading)
            const Expanded(child: Center(child: CircularProgressIndicator()))
          else if (_error != null)
            Expanded(
              child: Center(
                child: Text(_error!, style: const TextStyle(color: Colors.red)),
              ),
            )
          else if (_filteredPatients.isEmpty && query.isNotEmpty)
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  const SizedBox(height: 10),
                  Text(
                    'No Record Found for "$query"',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            )
          else
            Expanded(
              child: ListView.builder(
                itemCount: _filteredPatients.length,
                itemBuilder: (context, index) {
                  final patient = _filteredPatients[index];

                  return Card(
                    margin: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 4,
                    ),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: Colors.blue.shade100,
                        child: const Icon(Icons.person, color: Colors.blue),
                      ),
                      title: Text(patient.name),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Number: ${patient.mobileNumber ?? '-'}'),
                          Text(
                            'Gender: ${patient.gender ?? '-'}  •  Age: ${patient.age ?? '-'}',
                          ),
                        ],
                      ),
                      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                      onTap: () => _viewPatientDetails(patient),
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



class PatientDetailsSheet extends StatelessWidget {
  final PatientPrescriptionDetails details;

  const PatientDetailsSheet({super.key, required this.details});

  Widget _buildInfoRow(String label, String value) {
    final v = value.trim();
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 90,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          Expanded(child: Text(v.isEmpty ? '-' : v)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.98, // ✅ almost full screen
      minChildSize: 0.50,
      maxChildSize: 1.0, // ✅ top পর্যন্ত
      builder: (context, scrollController) {
        return SafeArea(
          top: true,
          child: Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
            ),
            child: Stack(
              children: [
                // ✅ scrollable content
                SingleChildScrollView(
                  controller: scrollController,
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // handle
                      Center(
                        child: Container(
                          width: 60,
                          height: 4,
                          decoration: BoxDecoration(
                            color: Colors.grey[300],
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // header row
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 30,
                            backgroundColor: Colors.blue.shade100,
                            child: const Icon(Icons.person, size: 30, color: Colors.blue),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  details.name,
                                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                                ),
                                Text('Number: ${details.mobileNumber ?? '-'}',
                                    style: const TextStyle(color: Colors.grey)),
                                Text('Gender: ${details.gender ?? '-'} • Age: ${details.age ?? '-'}',
                                    style: const TextStyle(color: Colors.grey)),
                              ],
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 20),

                      // requirement: first row OE then advice,test,medicine
                      _buildInfoRow('OE', details.oe ?? ''),
                      _buildInfoRow('Advice', details.advice ?? ''),
                      _buildInfoRow('Test', details.test ?? ''),
                      _buildInfoRow('CC', details.cc ?? ''),

                      const SizedBox(height: 12),
                      const Text(
                        'Medicine',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),

                      if (details.items.isEmpty)
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 24),
                          child: Center(child: Text('-')),
                        )
                      else
                        ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: details.items.length,
                          itemBuilder: (context, i) {
                            final m = details.items[i];
                            return Card(
                              child: ListTile(
                                title: Text(
                                  m.medicineName,
                                  style: const TextStyle(fontWeight: FontWeight.w700),
                                ),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('Dosage: ${m.dosageTimes ?? '-'}'),
                                    Text('Meal: ${m.mealTiming ?? '-'}'),
                                    Text('Duration: ${m.duration?.toString() ?? '-'}'),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),

                      const SizedBox(height: 20),
                    ],
                  ),
                ),

                // ✅ close button (top-right)
                Positioned(
                  top: 6,
                  right: 6,
                  child: IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

import 'package:flutter/material.dart';
import 'lab_test_create_and_upload.dart';
import 'lab_staff_profile.dart';
import 'manage_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:backend_client/backend_client.dart';

class LabTesterHome extends StatefulWidget {
  const LabTesterHome({super.key});

  @override
  State<LabTesterHome> createState() => _LabTesterHomeState();
}

class _LabTesterHomeState extends State<LabTesterHome> {
  final GlobalKey<ManageTestState> _manageTestKey =
      GlobalKey<ManageTestState>();
  int _selectedIndex = 0;
  final Color primaryColor = Colors.blueAccent;
  final List<int> _navigationHistory = [];

  String name = '';
  String designation = '';
  String? profilePictureUrl;
  LabToday? _twoDay;
  List<LabTenHistory> _last10 = [];
  bool _homeLoading = false;
  String? _homeError;

  // Auth guard
  bool _checkingAuth = true;
  bool _authorized = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _verifyLabStaff();
    });
  }

  Future<void> _verifyLabStaff() async {
    try {
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
        role = (await client.patient.getUserRole(numericId)).toUpperCase();
      } catch (e) {
        debugPrint('Failed to fetch user role: $e');
      }

      if (role == 'LABSTAFF' || role == 'LAB') {
        setState(() {
          _authorized = true;
          _checkingAuth = false;
        });
        await _loadBasicProfile(numericId);
        await _loadHomeData();
      } else {
        if (!mounted) return;
        Navigator.pushReplacementNamed(context, '/');
        return;
      }
    } catch (e) {
      debugPrint('Lab staff auth failed: $e');
      if (!mounted) return;
      Navigator.pushReplacementNamed(context, '/');
      return;
    }
  }

  Future<void> _loadBasicProfile(int userId) async {
    try {
      final profile = await client.lab.getStaffProfile(userId);

      if (profile != null && mounted) {
        setState(() {
          name = profile.name;
          designation = profile.designation;
          profilePictureUrl = profile.profilePictureUrl;
        });
      }
    } catch (e) {
      debugPrint('Failed to load basic profile: $e');
    }
  }

  Future<void> _loadHomeData() async {
    setState(() {
      _homeLoading = true;
      _homeError = null;
    });

    try {
      final twoDay = await client.lab.getLabHomeTwoDaySummary();
      final last10 = await client.lab.getLast10TestHistory();

      if (!mounted) return;
      setState(() {
        _twoDay = twoDay;
        _last10 = last10;
        _homeLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _homeError = e.toString();
        _homeLoading = false;
      });
    }
  }

  String _getTitle() {
    switch (_selectedIndex) {
      case 0:
        return "Home";
      case 1:
        return "Upload";
      case 2:
        return "Manage Test";
      case 3:
        return "Profile";
      default:
        return "";
    }
  }

  Widget _getBody() {
    switch (_selectedIndex) {
      case 0:
        return _homeUI();
      case 1:
        return const LabTestCreateAndUpload(); // Upload
      case 2:
        return ManageTest(key: _manageTestKey);
      case 3:
        return const LabTesterProfile();
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _homeUI() {
    final todayPending = (_twoDay?.todayPendingUploads ?? 0).toString();
    final todaySubmitted = (_twoDay?.todaySubmitted ?? 0).toString();
    final yesterdayPending = (_twoDay?.yesterdayPendingUploads ?? 0).toString();
    final yesterdaySubmitted = (_twoDay?.yesterdaySubmitted ?? 0).toString();

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF4FACFE), Color(0xFF00F2FE)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withAlpha((0.06 * 255).round()),
                  blurRadius: 12,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 50,
                  backgroundColor: Colors.white.withAlpha((0.2 * 255).round()),
                  backgroundImage:
                      (profilePictureUrl != null &&
                          profilePictureUrl!.isNotEmpty)
                      ? NetworkImage(profilePictureUrl!)
                      : null,
                  child:
                      (profilePictureUrl == null || profilePictureUrl!.isEmpty)
                      ? const Icon(Icons.person, color: Colors.white, size: 40)
                      : null,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name.isNotEmpty ? name : 'Name',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        designation.isNotEmpty ? designation : 'Lab Technician',
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Chip(
                            backgroundColor: Colors.brown,
                            label: Text(
                              'Today: ${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}',
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),
          const Text(
            "Two Day Overview",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),

          Wrap(
            runSpacing: 12,
            spacing: 12,
            children: [
              SizedBox(
                width: MediaQuery.of(context).size.width * 0.50,
                child: _interactiveStat(
                  todayPending,
                  'Pending (Today)',
                  Icons.pending_actions,
                  Colors.orange,
                ),
              ),
              SizedBox(
                width: MediaQuery.of(context).size.width * 0.40,
                child: _interactiveStat(
                  todaySubmitted,
                  'Submitted (Today)',
                  Icons.task_alt,
                  Colors.green,
                ),
              ),
              SizedBox(
                width: MediaQuery.of(context).size.width * 0.50,
                child: _interactiveStat(
                  yesterdayPending,
                  'Pending (Yesterday)',
                  Icons.pending_actions,
                  Colors.deepOrange,
                ),
              ),
              SizedBox(
                width: MediaQuery.of(context).size.width * 0.40,
                child: _interactiveStat(
                  yesterdaySubmitted,
                  'Submitted (Yesterday)',
                  Icons.task_alt,
                  Colors.teal,
                ),
              ),
            ],
          ),

          const SizedBox(height: 18),
          Row(
            children: [
              const Text(
                "Last 10 Test History",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const Spacer(),
              IconButton(
                tooltip: 'Refresh',
                onPressed: _loadHomeData,
                icon: const Icon(Icons.refresh),
              ),
            ],
          ),
          const SizedBox(height: 8),

          if (_homeLoading)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(12),
                child: CircularProgressIndicator(),
              ),
            )
          else if (_homeError != null)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                'Failed: $_homeError',
                style: const TextStyle(color: Colors.red),
              ),
            )
          else
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: _last10.isEmpty
                    ? [const ListTile(title: Text('No history found'))]
                    : _last10.map((item) {
                        final isPending = item.isUploaded == false;
                        final isSubmitted = item.submittedAt != null;

                        String _fmt(DateTime? dt) {
                          if (dt == null) return '';
                          return '${dt.day}/${dt.month}/${dt.year} ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
                        }

                        final dateText = _fmt(item.createdAt);
                        final statusText = isPending
                            ? 'Pending'
                            : (isSubmitted ? 'Submitted' : 'Uploaded');

                        final statusColor = isPending
                            ? Colors.orange
                            : Colors.green;
                        // Keep a consistent badge width so the last character aligns.
                        const double statusBadgeWidth = 90;

                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          child: Row(
                            children: [
                              CircleAvatar(
                                backgroundColor: Colors.grey.shade200,
                                child: Icon(
                                  isPending ? Icons.pending_actions : Icons.task_alt,
                                  color: statusColor,
                                ),
                              ),
                              const SizedBox(width: 12),

                              // ✅ This takes all remaining space
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      item.patientName.isNotEmpty ? item.patientName : 'Unknown',
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(fontWeight: FontWeight.w600),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      '${item.mobileNumber}  •  $dateText',
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(color: Colors.grey.shade700, fontSize: 12),
                                    ),
                                  ],
                                ),
                              ),

                              const SizedBox(width: 12),

                              // right badges (no big gap)
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                    decoration: BoxDecoration(
                                      color: statusColor.withAlpha((0.12 * 255).round()),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      statusText,
                                      style: TextStyle(
                                        color: statusColor,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    item.testName ?? '',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey.shade700,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        );

                }).toList(),
              ),
            ),
        ],
      ),
    );
  }

  // Helper: interactive stat card
  Widget _interactiveStat(
    String count,
    String label,
    IconData icon,
    Color color,
  ) {
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: () {
        showModalBottomSheet(
          context: context,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
          ),
          builder: (context) {
            final v = ((int.tryParse(count) ?? 0) / 100.0).clamp(0.0, 1.0);
            return Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(icon, color: color),
                      const SizedBox(width: 8),
                      Text(
                        label,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        count,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: color,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  LinearProgressIndicator(
                    value: v,
                    color: color,
                    backgroundColor: color.withAlpha((0.15 * 255).round()),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Tap a row to view details or take action.',
                    style: TextStyle(color: Colors.grey[700]),
                  ),
                  const SizedBox(height: 12),
                ],
              ),
            );
          },
        );
      },
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
          child: Row(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: color.withAlpha((0.12 * 255).round()),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: color),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '$count items',
                      style: TextStyle(color: Colors.grey[600], fontSize: 12),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: color.withAlpha((0.14 * 255).round()),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  count,
                  style: TextStyle(color: color, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_checkingAuth) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    if (!_authorized) {
      return const Scaffold(body: Center(child: Text('Unauthorized')));
    }

    return WillPopScope(
      onWillPop: () async {
        // If we have navigation history inside the bottom nav, consume the back
        // action by navigating to the previous index instead of exiting the app.
        if (_navigationHistory.isNotEmpty) {
          setState(() {
            _selectedIndex = _navigationHistory.removeLast();
          });
          return false; // handled
        }

        // No more internal history -> confirm exit
        final shouldExit = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Exit app'),
            content: const Text('Are you sure you want to exit the app?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text('Exit', style: TextStyle(color: Colors.red)),
              ),
            ],
          ),
        );

        return shouldExit == true;
      },
      child: PopScope(
        canPop: _navigationHistory.isEmpty,
        onPopInvokedWithResult: (didPop, result) {
          if (didPop) return;
          if (_navigationHistory.isNotEmpty) {
            setState(() {
              _selectedIndex = _navigationHistory.removeLast();
            });
          }
        },
        child: Scaffold(
          backgroundColor: Colors.grey[50],
          appBar: AppBar(
            title: Text(
              _getTitle(),
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            backgroundColor: Colors.white,
            foregroundColor: Colors.blueAccent,
            centerTitle: true,
            elevation: 0,
            actions: [
              IconButton(
                icon: const Icon(Icons.notifications),
                onPressed: () async {
                  await Navigator.pushNamed(context, '/notifications');
                },
              ),

              if (_selectedIndex == 2) ...[
                IconButton(
                  tooltip: "Add New Test",
                  icon: const Icon(
                    Icons.add_circle_outline,
                    color: Colors.blueAccent,
                  ),
                  onPressed: () {
                    _manageTestKey.currentState?.openTestDialog();
                  },
                ),
                IconButton(
                  tooltip: "Refresh",
                  icon: const Icon(Icons.refresh, color: Colors.blueAccent),
                  onPressed: () {
                    _manageTestKey.currentState?.fetchData();
                  },
                ),
              ],
            ],
          ),

          body: _getBody(),
          bottomNavigationBar: BottomNavigationBar(
            currentIndex: _selectedIndex,
            selectedItemColor: primaryColor,
            unselectedItemColor: Colors.grey.shade600,
            type: BottomNavigationBarType.fixed,
            onTap: (index) {
              if (index != _selectedIndex) {
                _navigationHistory.add(_selectedIndex);
                setState(() => _selectedIndex = index);
              }
            },
            items: const [
              BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
              BottomNavigationBarItem(
                icon: Icon(Icons.cloud_upload),
                label: "Upload",
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.manage_accounts),
                label: "ManageTest",
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.person),
                label: "Profile",
              ),
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:backend_client/backend_client.dart';
import 'dosage_times.dart';
import 'test_reports_view.dart';

class DoctorHomePage extends StatefulWidget {
  const DoctorHomePage({super.key, required this.doctorId});
  final int doctorId;

  @override
  State<DoctorHomePage> createState() => _DoctorHomePageState();
}

class _DoctorHomePageState extends State<DoctorHomePage> {
  DoctorHomeData? _homeData;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _fetchHomeData();
  }

  Future<void> _fetchHomeData() async {
    setState(() => _loading = true);
    try {
      // Backend resolves doctor from auth user; doctorId not needed.
      final data = await client.doctor.getDoctorHomeData();

      if (!mounted) return;
      setState(() {
        _homeData = data;
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _homeData = null;
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final resolvedDoctorName = (_homeData?.doctorName ?? '').trim();

    final designation = (_homeData?.doctorDesignation ?? '').trim();
    final today = (_homeData?.today ?? DateTime.now()).toLocal();

    final lastMonthCount = _homeData?.lastMonthPrescriptions ?? 0;
    final lastWeekCount = _homeData?.lastWeekPrescriptions ?? 0;

    final profilePictureUrl = _homeData?.doctorProfilePictureUrl;

    final recent = _homeData?.recent ?? <DoctorHomeRecentItem>[];
    final reports = _homeData?.reviewedReports ?? <DoctorHomeReviewedReport>[];

    return SafeArea(
      child: RefreshIndicator(
        onRefresh: _fetchHomeData,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              HeaderCard(
                doctorName: resolvedDoctorName,
                designation: designation,
                today: today,
                profilePictureUrl: profilePictureUrl,
                lastMonthPrescriptions: lastMonthCount,
                lastWeekPrescriptions: lastWeekCount,
                loading: _loading,
              ),
              const SizedBox(height: 14),
              RecentActivityCard(
                items: recent,
                titleStyle: theme.textTheme.titleMedium,
                onTapItem: _handleRecentTap,
              ),
              const SizedBox(height: 14),
              ReviewedReportsCard(items: reports),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _handleRecentTap(DoctorHomeRecentItem item) async {
    if (item.type == 'prescription' && item.prescriptionId != null) {
      try {
        final details = await client.doctor.getPrescriptionDetails(
          prescriptionId: item.prescriptionId!,
        );

        if (!mounted) return;

        if (details == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Prescription not found.')),
          );
          return;
        }

        await showDialog<void>(
          context: context,
          builder: (_) => PrescriptionDetailsDialog(details: details),
        );
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed: $e')));
      }
      return;
    }

    if (!mounted) return;
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => TestReportsView(doctorId: widget.doctorId),
      ),
    );
  }
}

/* ---------------- UI Widgets ---------------- */

class HeaderCard extends StatelessWidget {
  const HeaderCard({
    super.key,
    required this.doctorName,
    required this.designation,
    required this.today,
    required this.profilePictureUrl,
    required this.lastMonthPrescriptions,
    required this.lastWeekPrescriptions,
    required this.loading,
  });

  final String doctorName;
  final String designation;
  final DateTime today;
  final String? profilePictureUrl;
  final int lastMonthPrescriptions;
  final int lastWeekPrescriptions;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    final dateStr = '${today.day}/${today.month}/${today.year}';
    final maxWidth = MediaQuery.of(context).size.width;
    final bool isNarrow = maxWidth < 560;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 18,
            offset: const Offset(0, 10),
          ),
        ],
        border: Border.all(color: Colors.grey.shade200),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(18),
              decoration: const BoxDecoration(color: Color(0xFF38B6FF)),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    width: 76,
                    height: 76,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Color(0xFF6EC9FF),
                    ),
                    child: ClipOval(
                      child: (profilePictureUrl ?? '').trim().isEmpty
                          ? const Icon(
                              Icons.person,
                              size: 40,
                              color: Colors.white,
                            )
                          : Image.network(
                              profilePictureUrl!,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => const Icon(
                                Icons.person,
                                size: 40,
                                color: Colors.white,
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          doctorName.trim().isEmpty ? '—' : doctorName.trim(),
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          designation.trim().isEmpty ? ' ' : designation.trim(),
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 10),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFF6B4B3A),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            'Today: $dateStr',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (loading)
                    const Padding(
                      padding: EdgeInsets.only(left: 12),
                      child: SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 14),
          if (isNarrow)
            Column(
              children: [
                StatTile(
                  title: 'Last Month',
                  subtitle: 'Prescriptions',
                  value: '$lastMonthPrescriptions',
                  icon: Icons.description_rounded,
                  accent: const Color(0xFF2563EB),
                ),
                const SizedBox(height: 12),
                StatTile(
                  title: 'Last Week',
                  subtitle: 'Prescriptions (7 days)',
                  value: '$lastWeekPrescriptions',
                  icon: Icons.calendar_today_rounded,
                  accent: const Color(0xFF0EA5A5),
                ),
              ],
            )
          else
            Row(
              children: [
                Expanded(
                  child: StatTile(
                    title: 'Last Month',
                    subtitle: 'Prescriptions',
                    value: '$lastMonthPrescriptions',
                    icon: Icons.description_rounded,
                    accent: const Color(0xFF2563EB),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: StatTile(
                    title: 'Last Week',
                    subtitle: 'Prescriptions (7 days)',
                    value: '$lastWeekPrescriptions',
                    icon: Icons.calendar_today_rounded,
                    accent: const Color(0xFF0EA5A5),
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }
}

/// Beginner-friendly reusable widget:
/// shows a small label on top and the value below it.
class LabeledValue extends StatelessWidget {
  const LabeledValue({
    super.key,
    required this.label,
    required this.value,
    this.placeholder = '',
    this.labelStyle,
    this.valueStyle,
  });

  final String label;
  final String value;
  final String placeholder;
  final TextStyle? labelStyle;
  final TextStyle? valueStyle;

  @override
  Widget build(BuildContext context) {
    final effectiveValue = value.trim().isEmpty ? placeholder : value.trim();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style:
              labelStyle ??
              TextStyle(color: Colors.grey.shade600, fontSize: 12),
        ),
        const SizedBox(height: 3),
        Text(
          effectiveValue,
          style: valueStyle,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}

class StatTile extends StatelessWidget {
  const StatTile({
    super.key,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.icon,
    required this.accent,
  });

  final String title;
  final String subtitle;
  final String value;
  final IconData icon;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Container(
            height: 34,
            width: 34,
            decoration: BoxDecoration(
              color: accent.withOpacity(0.10),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: accent, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: Colors.grey.shade500,
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class RecentActivityCard extends StatelessWidget {
  const RecentActivityCard({
    super.key,
    required this.items,
    required this.titleStyle,
    required this.onTapItem,
  });

  final List<DoctorHomeRecentItem> items;
  final TextStyle? titleStyle;
  final Future<void> Function(DoctorHomeRecentItem item) onTapItem;

  @override
  Widget build(BuildContext context) {
    return DashboardCard(
      title: 'Recent Activity',
      subtitle: '', //subtaitel thakbe na
      trailing: Icon(Icons.show_chart_rounded, color: Colors.grey.shade600),
      child: items.isEmpty
          ? Padding(
              padding: const EdgeInsets.all(6),
              child: Text(
                'No activity found',
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontWeight: FontWeight.w600,
                ),
              ),
            )
          : Column(
              children: [
                for (int i = 0; i < items.length; i++) ...[
                  InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: () => onTapItem(items[i]),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      child: _RecentActivityRow(item: items[i]),
                    ),
                  ),
                  if (i != items.length - 1)
                    Divider(height: 18, color: Colors.grey.shade200),
                ],
              ],
            ),
    );
  }
}

class _RecentActivityRow extends StatelessWidget {
  const _RecentActivityRow({required this.item});
  final DoctorHomeRecentItem item;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          margin: const EdgeInsets.only(top: 4),
          height: 10,
          width: 10,
          decoration: const BoxDecoration(
            color: Color(0xFF10B981),
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                item.title,
                style: const TextStyle(
                  fontWeight: FontWeight.w800,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                item.subtitle,
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 10),
        Text(
          item.timeAgo,
          style: TextStyle(
            color: Colors.grey.shade600,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class ReviewedReportsCard extends StatelessWidget {
  const ReviewedReportsCard({super.key, required this.items});

  final List<DoctorHomeReviewedReport> items;

  @override
  Widget build(BuildContext context) {
    return DashboardCard(
      title: 'Reviewed Reports',
      subtitle: 'Last 10',
      trailing: Icon(Icons.fact_check_rounded, color: Colors.purple.shade700),
      child: items.isEmpty
          ? Text(
              'No reports found',
              style: TextStyle(
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w600,
              ),
            )
          : Column(
              children: [
                for (int i = 0; i < items.length; i++) ...[
                  _ReviewedReportRow(item: items[i]),
                  if (i != items.length - 1)
                    Divider(height: 18, color: Colors.grey.shade200),
                ],
              ],
            ),
    );
  }
}

class _ReviewedReportRow extends StatelessWidget {
  const _ReviewedReportRow({required this.item});
  final DoctorHomeReviewedReport item;

  @override
  Widget build(BuildContext context) {
    final iconColor = Colors.purple.shade700;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          height: 34,
          width: 34,
          decoration: BoxDecoration(
            color: iconColor.withOpacity(0.12),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(Icons.fact_check, color: iconColor, size: 18),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                item.type.isEmpty ? 'Report' : item.type,
                style: const TextStyle(
                  fontWeight: FontWeight.w800,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                (item.uploadedByName).trim().isEmpty
                    ? 'Uploaded by: Unknown'
                    : 'Uploaded by: ${item.uploadedByName}',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 10),
        Text(
          item.timeAgo,
          style: TextStyle(
            color: Colors.grey.shade600,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class DashboardCard extends StatelessWidget {
  const DashboardCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.child,
    required this.trailing,
  });

  final String title;
  final String? subtitle;
  final Widget child;
  final Widget trailing;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 18,
            offset: const Offset(0, 10),
          ),
        ],
        border: Border.all(color: Colors.grey.shade200),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                        color: Colors.black87,
                      ),
                    ),
                    if (subtitle != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        subtitle!,
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              trailing,
            ],
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}

class PrescriptionDetailsDialog extends StatelessWidget {
  const PrescriptionDetailsDialog({super.key, required this.details});
  final PatientPrescriptionDetails details;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Prescription #${details.prescriptionId}'),
      content: SizedBox(
        width: double.maxFinite,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Patient: ${details.name}'),
              const SizedBox(height: 6),
              Text('Mobile: ${details.mobileNumber ?? ''}'),
              const SizedBox(height: 6),
              Text('Advice: ${details.advice ?? ''}'),
              const SizedBox(height: 10),
              const Text(
                'Medicines:',
                style: TextStyle(fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 6),
              if (details.items.isEmpty)
                const Text('No items')
              else
                for (final it in details.items)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: Text(() {
                      final dt = dosageTimesDisplayBangla(it.dosageTimes ?? '');
                      return '- ${it.medicineName} | ${dt.isEmpty ? '-' : dt} | ${it.mealTiming ?? ''} | ${it.duration ?? ''}';
                    }()),
                  ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Close'),
        ),
      ],
    );
  }
}

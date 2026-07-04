import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../core/theme/app_colors.dart';
import '../../core/services/prescripto_service.dart';

// ─── Hardcoded fallback data (shown if MongoDB is unreachable) ────────────────
const List<Map<String, dynamic>> _kFallbackBookings = [
  {
    '_id': 'fallback_1',
    'patientName': 'Bhanu',
    'doctor': {
      'name': 'Dr. Anjali Sharma',
      'specialty': 'General Physician',
      'consultationFee': 500,
      'rating': 4.9,
      'experience': '12+ Yrs Exp.',
      'hospital': 'City Health Centre',
      'profileImage': 'https://images.unsplash.com/photo-1559839734-2b71ea197ec2?auto=format&fit=crop&q=80&w=300',
    },
    'status': 'Pending',
    'appointmentDate': '2026-07-23T09:30:00.000Z',
    'healthIssue': 'General Checkup',
    'patientAge': 25,
    'patientGender': 'Male',
    'symptomsDescription': 'Routine annual checkup',
    'healthRating': 4,
  },
  {
    '_id': 'fallback_2',
    'patientName': 'Bhanu Prakash',
    'doctor': {
      'name': 'Dr. Anjali Sharma',
      'specialty': 'General Physician',
      'consultationFee': 500,
      'rating': 4.9,
      'experience': '12+ Yrs Exp.',
      'hospital': 'City Health Centre',
      'profileImage': 'https://images.unsplash.com/photo-1559839734-2b71ea197ec2?auto=format&fit=crop&q=80&w=300',
    },
    'status': 'Pending',
    'appointmentDate': '2026-07-04T11:00:00.000Z',
    'healthIssue': 'Fever & Headache',
    'patientAge': 25,
    'patientGender': 'Male',
    'symptomsDescription': 'Persistent headache and mild fever',
    'healthRating': 3,
  },
  {
    '_id': 'fallback_3',
    'patientName': 'Bhanu',
    'doctor': {
      'name': 'Dr. Anjali Sharma',
      'specialty': 'General Physician',
      'consultationFee': 500,
      'rating': 4.9,
      'experience': '12+ Yrs Exp.',
      'hospital': 'City Health Centre',
      'profileImage': 'https://images.unsplash.com/photo-1559839734-2b71ea197ec2?auto=format&fit=crop&q=80&w=300',
    },
    'status': 'Pending',
    'appointmentDate': '2026-07-05T14:00:00.000Z',
    'healthIssue': 'Follow-up',
    'patientAge': 25,
    'patientGender': 'Male',
    'symptomsDescription': 'Follow-up consultation',
    'healthRating': 4,
  },
  {
    '_id': 'fallback_4',
    'patientName': 'Bhanu Prakash',
    'doctor': {
      'name': 'Dr. Anjali Sharma',
      'specialty': 'General Physician',
      'consultationFee': 500,
      'rating': 4.9,
      'experience': '12+ Yrs Exp.',
      'hospital': 'City Health Centre',
      'profileImage': 'https://images.unsplash.com/photo-1559839734-2b71ea197ec2?auto=format&fit=crop&q=80&w=300',
    },
    'status': 'Pending',
    'appointmentDate': '2026-07-10T10:00:00.000Z',
    'healthIssue': 'Blood Pressure',
    'patientAge': 25,
    'patientGender': 'Male',
    'symptomsDescription': 'High BP monitoring',
    'healthRating': 3,
  },
];

class BookedAppointmentsScreen extends StatefulWidget {
  const BookedAppointmentsScreen({super.key});

  @override
  State<BookedAppointmentsScreen> createState() =>
      _BookedAppointmentsScreenState();
}

class _BookedAppointmentsScreenState extends State<BookedAppointmentsScreen> {
  List<Map<String, dynamic>> _bookings = [];
  bool _isLoading = true;
  bool _isOffline = false;
  String _selectedFilter = 'All';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadBookings());
  }

  Future<void> _loadBookings() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _isOffline = false;
    });

    try {
      final list = await PrescriptoService.instance.getBookings();
      if (!mounted) return;
      final offline = PrescriptoService.instance.lastError != null;
      setState(() {
        // If backend returned empty AND offline, show fallback
        _bookings = (list.isEmpty && offline) ? List.from(_kFallbackBookings) : list;
        _isLoading = false;
        _isOffline = offline;
      });
    } catch (e) {
      if (!mounted) return;
      // Any error → show fallback data, never a black screen
      setState(() {
        _bookings = List.from(_kFallbackBookings);
        _isLoading = false;
        _isOffline = true;
      });
    }
  }

  List<Map<String, dynamic>> get _filtered {
    if (_selectedFilter == 'All') return _bookings;
    return _bookings.where((b) {
      final s = b['status']?.toString() ?? 'Pending';
      if (_selectedFilter == 'Completed') return s == 'Completed' || s == 'Confirmed';
      return s == _selectedFilter;
    }).toList();
  }

  // ─── Actions ─────────────────────────────────────────────────────────────

  Future<void> _cancelBooking(String id) async {
    final confirmed = await _showConfirmDialog(
      'Cancel Appointment',
      'Are you sure you want to cancel this appointment?',
      confirmColor: AppColors.alertRed,
      confirmLabel: 'Cancel Appointment',
    );
    if (!confirmed || !mounted) return;
    try {
      await PrescriptoService.instance.cancelBooking(id);
      if (!mounted) return;
      _showSnack('Appointment cancelled.', AppColors.alertRed);
      _loadBookings();
    } catch (e) {
      if (!mounted) return;
      _showSnack('Failed: $e', AppColors.alertRed);
    }
  }

  Future<void> _rescheduleBooking(String id) async {
    final newDate = await _pickDateTime();
    if (newDate == null || !mounted) return;
    try {
      await PrescriptoService.instance.rescheduleBooking(id, newDate);
      if (!mounted) return;
      _showSnack('Appointment rescheduled!', AppColors.medicalBlue);
      _loadBookings();
    } catch (e) {
      if (!mounted) return;
      _showSnack('Failed: $e', AppColors.alertRed);
    }
  }

  Future<void> _confirmBooking(String id) async {
    try {
      await PrescriptoService.instance.confirmBooking(id);
      if (!mounted) return;
      _showSnack('Appointment confirmed!', AppColors.successGreen);
      _loadBookings();
    } catch (e) {
      if (!mounted) return;
      _showSnack('Failed: $e', AppColors.alertRed);
    }
  }

  Future<bool> _showConfirmDialog(String title, String message,
      {Color? confirmColor, String confirmLabel = 'Confirm'}) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.card,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(title,
            style: GoogleFonts.inter(
                color: AppColors.textWhite, fontWeight: FontWeight.w700)),
        content: Text(message,
            style: GoogleFonts.inter(color: AppColors.textGray, fontSize: 14)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text('No',
                style: GoogleFonts.inter(color: AppColors.textGray)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: confirmColor ?? AppColors.medicalBlue,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
            ),
            child: Text(confirmLabel,
                style: GoogleFonts.inter(color: Colors.white)),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  Future<DateTime?> _pickDateTime() async {
    final now = DateTime.now();
    final date = await showDatePicker(
      context: context,
      initialDate: now.add(const Duration(days: 1)),
      firstDate: now,
      lastDate: now.add(const Duration(days: 90)),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: ColorScheme.dark(
            primary: AppColors.medicalBlue,
            onPrimary: Colors.white,
            surface: AppColors.card,
            onSurface: AppColors.textWhite,
          ),
        ),
        child: child!,
      ),
    );
    if (date == null || !mounted) return null;
    final time = await showTimePicker(
      context: context,
      initialTime: const TimeOfDay(hour: 9, minute: 0),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: ColorScheme.dark(
            primary: AppColors.medicalBlue,
            onPrimary: Colors.white,
            surface: AppColors.card,
            onSurface: AppColors.textWhite,
          ),
        ),
        child: child!,
      ),
    );
    if (time == null) return null;
    return DateTime(date.year, date.month, date.day, time.hour, time.minute);
  }

  void _showSnack(String msg, Color color) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg, style: GoogleFonts.inter(color: Colors.white)),
      backgroundColor: color,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ));
  }

  // ─── Bottom Sheet Details ────────────────────────────────────────────────

  void _showDetails(Map<String, dynamic> booking) {
    final doc = booking['doctor'] as Map<String, dynamic>? ?? {};
    final status = booking['status']?.toString() ?? 'Pending';
    String dateStr = '';
    try {
      final raw = booking['appointmentDate'];
      if (raw != null) {
        dateStr = DateFormat('EEEE, d MMM yyyy • hh:mm a')
            .format(DateTime.parse(raw.toString()));
      }
    } catch (_) {}

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetCtx) {
        return Container(
          decoration: BoxDecoration(
            color: AppColors.card,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: EdgeInsets.only(
            left: 20, right: 20, top: 20,
            bottom: MediaQuery.of(sheetCtx).viewInsets.bottom + 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 44, height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.border,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text('Appointment Details',
                  style: GoogleFonts.inter(
                      fontSize: 18, fontWeight: FontWeight.w700,
                      color: AppColors.textWhite)),
              const SizedBox(height: 16),
              _row('Doctor', doc['name']?.toString() ?? ''),
              _row('Specialty', doc['specialty']?.toString() ?? ''),
              _row('Fee', '₹${doc['consultationFee'] ?? 500}'),
              Divider(color: AppColors.border, height: 24),
              _row('Patient', booking['patientName']?.toString() ?? ''),
              _row('Age & Gender',
                  '${booking['patientAge']} Yrs · ${booking['patientGender']}'),
              _row('Health Issue', booking['healthIssue']?.toString() ?? ''),
              _row('Description',
                  booking['symptomsDescription']?.toString().isEmpty == true
                      ? '—'
                      : booking['symptomsDescription']?.toString() ?? '—'),
              _row('Health Rating', '${booking['healthRating']} / 5'),
              _row('Date & Time', dateStr),
              _row('Status', status,
                  valueColor: _statusColor(status)),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.of(sheetCtx).pop(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.medicalBlue,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: Text('Close',
                      style: GoogleFonts.inter(
                          color: Colors.white, fontWeight: FontWeight.w600)),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _row(String label, String value, {Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(label,
                style: GoogleFonts.inter(
                    fontSize: 13, color: AppColors.textGray)),
          ),
          Expanded(
            child: Text(value,
                style: GoogleFonts.inter(
                    fontSize: 13,
                    color: valueColor ?? AppColors.textWhite,
                    fontWeight: valueColor != null
                        ? FontWeight.w700
                        : FontWeight.w500)),
          ),
        ],
      ),
    );
  }

  // ─── Helpers ─────────────────────────────────────────────────────────────

  Color _statusColor(String status) {
    switch (status) {
      case 'Confirmed': return AppColors.successGreen;
      case 'Completed': return const Color(0xFF94A3B8);
      case 'Cancelled': return AppColors.alertRed;
      default: return const Color(0xFFFBBF24); // Pending = amber
    }
  }

  String _statusLabel(String status) =>
      status == 'Confirmed' ? 'Confirmed' : status;

  String _dateLabel(String status) {
    switch (status) {
      case 'Confirmed': return 'Confirmed:';
      case 'Completed': return 'Completed:';
      case 'Cancelled': return 'Cancelled:';
      default: return 'Upcoming:';
    }
  }

  String _formatDate(dynamic raw) {
    if (raw == null) return '—';
    try {
      return DateFormat('EEEE, d MMM yyyy | hh:mm a')
          .format(DateTime.parse(raw.toString()).toLocal());
    } catch (_) {
      return raw.toString();
    }
  }

  // ─── Doctor Avatar ────────────────────────────────────────────────────────

  Widget _avatar(Map<String, dynamic> doc) {
    final url = doc['profileImage']?.toString() ?? '';
    final name = doc['name']?.toString() ?? '?';
    final initials = name
        .split(' ')
        .where((w) => w.isNotEmpty)
        .take(2)
        .map((w) => w[0].toUpperCase())
        .join();

    // Avatar background color based on initials
    final colors = [
      const Color(0xFF2563EB),
      const Color(0xFF7C3AED),
      const Color(0xFF059669),
      const Color(0xFFD97706),
      const Color(0xFFDB2777),
    ];
    final colorIndex = initials.isNotEmpty ? initials.codeUnitAt(0) % colors.length : 0;

    if (url.isNotEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: Image.network(
          url,
          width: 56, height: 56,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => _initialsAvatar(initials, colors[colorIndex]),
          loadingBuilder: (_, child, progress) =>
              progress == null ? child : _initialsAvatar(initials, colors[colorIndex]),
        ),
      );
    }
    return _initialsAvatar(initials, colors[colorIndex]);
  }

  Widget _initialsAvatar(String initials, Color color) {
    return Container(
      width: 56, height: 56,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: color.withValues(alpha: 0.4), width: 1.5),
      ),
      child: Center(
        child: Text(initials,
            style: GoogleFonts.inter(
                fontSize: 18, fontWeight: FontWeight.w700, color: color)),
      ),
    );
  }

  // ─── Status Badge ─────────────────────────────────────────────────────────

  Widget _statusBadge(String status) {
    final color = _statusColor(status);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.35), width: 1),
      ),
      child: Text(
        _statusLabel(status),
        style: GoogleFonts.inter(
            fontSize: 11, fontWeight: FontWeight.w700, color: color),
      ),
    );
  }

  // ─── Booking Card ─────────────────────────────────────────────────────────

  Widget _buildCard(Map<String, dynamic> booking) {
    final doc = booking['doctor'] as Map<String, dynamic>? ?? {};
    final status = booking['status']?.toString() ?? 'Pending';
    final docName = doc['name']?.toString() ?? 'Doctor';
    final specialty = doc['specialty']?.toString() ?? '';
    final experience = doc['experience']?.toString() ?? '';
    final hospital = doc['hospital']?.toString() ?? '';
    final rating = (doc['rating'] ?? 0.0).toDouble();
    final dateStr = _formatDate(booking['appointmentDate']);
    final id = booking['_id']?.toString() ?? '';

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.25),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header ──────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 14, 14, 0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _avatar(doc),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(docName,
                                style: GoogleFonts.inter(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.textWhite)),
                          ),
                          const SizedBox(width: 8),
                          _statusBadge(status),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(specialty,
                          style: GoogleFonts.inter(
                              fontSize: 13, color: AppColors.textGray)),
                      if (experience.isNotEmpty || hospital.isNotEmpty)
                        Text(
                          [if (experience.isNotEmpty) experience,
                           if (hospital.isNotEmpty) hospital].join(' • '),
                          style: GoogleFonts.inter(
                              fontSize: 11, color: AppColors.textDimmed),
                        ),
                      if (rating > 0) ...[
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(Icons.star_rounded,
                                color: Color(0xFFFBBF24), size: 14),
                            const SizedBox(width: 3),
                            Text(rating.toStringAsFixed(1),
                                style: GoogleFonts.inter(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: const Color(0xFFFBBF24))),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),

          // ── Divider + Date ───────────────────────────────────────────
          Divider(color: AppColors.border, height: 20,
              indent: 14, endIndent: 14),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            child: Row(
              children: [
                Icon(Icons.calendar_month_outlined,
                    color: AppColors.textDimmed, size: 14),
                const SizedBox(width: 6),
                Expanded(
                  child: RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: '${_dateLabel(status)} ',
                          style: GoogleFonts.inter(
                              fontSize: 12, color: AppColors.textDimmed),
                        ),
                        TextSpan(
                          text: dateStr,
                          style: GoogleFonts.inter(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textWhite),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // ── Action Buttons ───────────────────────────────────────────
          _buildActions(status, id, booking),
          const SizedBox(height: 14),
        ],
      ),
    );
  }

  Widget _buildActions(
      String status, String id, Map<String, dynamic> booking) {
    final px = const EdgeInsets.symmetric(horizontal: 14);

    switch (status) {
      case 'Pending':
        return Padding(
          padding: px,
          child: Row(
            children: [
              Expanded(
                child: _filledBtn(
                  'Reschedule',
                  AppColors.medicalBlue,
                  () => _rescheduleBooking(id),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _outlinedBtn(
                  'Cancel',
                  AppColors.textGray,
                  () => _cancelBooking(id),
                ),
              ),
            ],
          ),
        );

      case 'Confirmed':
        return Padding(
          padding: px,
          child: Row(
            children: [
              Expanded(
                child: _outlinedBtn(
                  'Cancel Appointment',
                  AppColors.alertRed,
                  () => _cancelBooking(id),
                ),
              ),
              const SizedBox(width: 10),
              TextButton(
                onPressed: () => _showDetails(booking),
                child: Text('View Details',
                    style: GoogleFonts.inter(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.medicalBlue)),
              ),
            ],
          ),
        );

      case 'Completed':
      case 'Confirmed' && 'Completed': // fallthrough
        return Padding(
          padding: px,
          child: Row(
            children: [
              Expanded(
                child: _filledBtn(
                  'Add Review',
                  AppColors.medicalBlue,
                  () => _showSnack('Review feature coming soon!',
                      AppColors.medicalBlue),
                ),
              ),
              const SizedBox(width: 10),
              TextButton(
                onPressed: () => _showSnack(
                    'Download feature coming soon!', AppColors.textGray),
                child: Text('Download Summary',
                    style: GoogleFonts.inter(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.medicalBlue)),
              ),
            ],
          ),
        );

      case 'Cancelled':
        return Padding(
          padding: px,
          child: Row(
            children: [
              Expanded(
                child: _filledBtn(
                  'Re-book Appointment',
                  AppColors.medicalBlue,
                  () => _showSnack(
                      'Redirecting to booking...', AppColors.medicalBlue),
                ),
              ),
              const SizedBox(width: 10),
              TextButton(
                onPressed: () => _showDetails(booking),
                child: Text('View Details',
                    style: GoogleFonts.inter(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.medicalBlue)),
              ),
            ],
          ),
        );

      default:
        return Padding(
          padding: px,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: () => _showDetails(booking),
                child: Text('View Details',
                    style: GoogleFonts.inter(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.medicalBlue)),
              ),
            ],
          ),
        );
    }
  }

  Widget _filledBtn(String label, Color color, VoidCallback onTap) {
    return SizedBox(
      height: 40,
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          elevation: 0,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10)),
          padding: EdgeInsets.zero,
        ),
        child: Text(label,
            style: GoogleFonts.inter(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Colors.white)),
      ),
    );
  }

  Widget _outlinedBtn(String label, Color color, VoidCallback onTap) {
    return SizedBox(
      height: 40,
      child: OutlinedButton(
        onPressed: onTap,
        style: OutlinedButton.styleFrom(
          side: BorderSide(color: color.withValues(alpha: 0.7), width: 1.5),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10)),
          padding: EdgeInsets.zero,
        ),
        child: Text(label,
            style: GoogleFonts.inter(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: color)),
      ),
    );
  }

  // ─── Filter Chip ──────────────────────────────────────────────────────────

  Widget _filterChip(String label) {
    final selected = _selectedFilter == label;
    return GestureDetector(
      onTap: () => setState(() => _selectedFilter = label),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
        decoration: BoxDecoration(
          color: selected ? AppColors.medicalBlue : AppColors.card,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected
                ? AppColors.medicalBlue
                : AppColors.border,
            width: 1.5,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (selected) ...[
              const Icon(Icons.check, color: Colors.white, size: 12),
              const SizedBox(width: 4),
            ],
            Text(label,
                style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: selected ? Colors.white : AppColors.textGray)),
          ],
        ),
      ),
    );
  }

  // ─── Build ────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final filtered = _filtered;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 18),
          color: AppColors.textWhite,
          onPressed: () {
            try { context.pop(); } catch (_) { Navigator.of(context).pop(); }
          },
        ),
        title: Text('Booked Appointments',
            style: GoogleFonts.inter(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.textWhite)),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh_rounded, color: AppColors.textWhite),
            onPressed: _isLoading ? null : _loadBookings,
          ),
        ],
      ),
      body: Column(
        children: [
          // ── Filter row ──────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: ['All', 'Pending', 'Completed', 'Cancelled']
                    .map((f) => Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: _filterChip(f),
                        ))
                    .toList(),
              ),
            ),
          ),

          // ── Offline banner ──────────────────────────────────────────
          if (_isOffline)
            Material(
              color: const Color(0xFFFBBF24).withValues(alpha: 0.10),
              child: InkWell(
                onTap: _loadBookings,
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
                  child: Row(
                    children: [
                      const Icon(Icons.wifi_off,
                          color: Color(0xFFFBBF24), size: 14),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Offline mode — showing saved appointments. Tap to retry.',
                          style: GoogleFonts.inter(
                              fontSize: 11,
                              color: const Color(0xFFFBBF24)),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

          // ── Content ────────────────────────────────────────────────
          Expanded(
            child: _isLoading
                ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircularProgressIndicator(
                          color: AppColors.medicalBlue,
                          strokeWidth: 2.5,
                        ),
                        const SizedBox(height: 12),
                        Text('Loading appointments…',
                            style: GoogleFonts.inter(
                                fontSize: 13, color: AppColors.textGray)),
                      ],
                    ),
                  )
                : filtered.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 80, height: 80,
                              decoration: BoxDecoration(
                                color: AppColors.card,
                                shape: BoxShape.circle,
                              ),
                              child: Icon(Icons.event_busy_rounded,
                                  color: AppColors.textDimmed, size: 38),
                            ),
                            const SizedBox(height: 14),
                            Text('No appointments found',
                                style: GoogleFonts.inter(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.textWhite)),
                            const SizedBox(height: 6),
                            Text('Your booked appointments will appear here.',
                                style: GoogleFonts.inter(
                                    fontSize: 13, color: AppColors.textGray)),
                            const SizedBox(height: 20),
                            ElevatedButton.icon(
                              onPressed: _loadBookings,
                              icon: const Icon(Icons.refresh, size: 16,
                                  color: Colors.white),
                              label: Text('Retry',
                                  style: GoogleFonts.inter(color: Colors.white)),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.medicalBlue,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10)),
                              ),
                            ),
                          ],
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: _loadBookings,
                        color: AppColors.medicalBlue,
                        backgroundColor: AppColors.card,
                        child: ListView.builder(
                          padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
                          itemCount: filtered.length,
                          itemBuilder: (_, i) => _buildCard(filtered[i]),
                        ),
                      ),
          ),
        ],
      ),
    );
  }
}

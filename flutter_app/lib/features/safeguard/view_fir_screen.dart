import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/services/safeguard_service.dart';
import '../../shared/widgets/app_button.dart';

class ViewFirScreen extends StatefulWidget {
  const ViewFirScreen({super.key});

  @override
  State<ViewFirScreen> createState() => _ViewFirScreenState();
}

class _ViewFirScreenState extends State<ViewFirScreen> {
  List<Map<String, dynamic>> _firs = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadFirs();
  }

  Future<void> _loadFirs() async {
    setState(() => _isLoading = true);
    final list = await SafeguardService.instance.getFirs();
    setState(() {
      _firs = list;
      _isLoading = false;
    });
  }

  void _showDeleteFineDialog(String firNumber) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        return _PaymentScannerDialog(
          firNumber: firNumber,
          onComplete: () {
            _loadFirs();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('FIR $firNumber has been successfully withdrawn/deleted.'),
                backgroundColor: AppColors.successGreen,
              ),
            );
          },
        );
      },
    );
  }

  void _showFirDetails(Map<String, dynamic> fir) {
    final comp = fir['complainantDetails'] ?? {};
    final details = fir['firDetails'] ?? {};
    final registration = fir['registrationDateTime'] != null
        ? DateTime.tryParse(fir['registrationDateTime'])?.toLocal().toString().split('.')[0]
        : 'N/A';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.background,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.85,
          maxChildSize: 0.95,
          minChildSize: 0.5,
          expand: false,
          builder: (context, scrollController) {
            return SingleChildScrollView(
              controller: scrollController,
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 50,
                      height: 5,
                      decoration: BoxDecoration(
                        color: AppColors.border,
                        borderRadius: BorderRadius.circular(2.5),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              fir['firNumber'] ?? 'Unknown FIR',
                              style: AppTextStyles.h2.copyWith(color: AppColors.successGreen),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Registered on: $registration',
                              style: AppTextStyles.caption.copyWith(color: AppColors.textGray),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.close, color: AppColors.textWhite),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Divider(color: AppColors.border),
                  const SizedBox(height: 12),

                  // Laws applied
                  _buildSectionTitle('Applicable Laws / Acts'),
                  _buildDetailCard(fir['specificLaws'] ?? 'N/A'),

                  const SizedBox(height: 16),

                  // Complainant section
                  _buildSectionTitle('Complainant Details'),
                  _buildInfoRow('Full Name', comp['fullName'] ?? 'N/A'),
                  _buildInfoRow('Age', '${comp['age'] ?? 'N/A'} years'),
                  _buildInfoRow('Occupation', comp['occupation'] ?? 'N/A'),
                  _buildInfoRow('Contact Number', comp['contactNumber'] ?? 'N/A'),
                  _buildInfoRow('Permanent Address', comp['permanentAddress'] ?? 'N/A'),
                  _buildInfoRow('Temporary Address', comp['temporaryAddress'] ?? 'N/A'),

                  const SizedBox(height: 20),

                  // Incident Details
                  _buildSectionTitle('FIR Incident & Narrative'),
                  _buildInfoRow('Offense Date', details['incidentDate'] ?? 'N/A'),
                  _buildInfoRow('Offense Time', details['incidentTime'] ?? 'N/A'),
                  _buildInfoRow('Offense Location', details['incidentLocation'] ?? 'N/A'),
                  _buildInfoRow('Motives Involved', details['motives'] ?? 'N/A'),
                  _buildInfoRow('Weapons Used', details['weaponsUsed'] ?? 'N/A'),
                  _buildInfoRow('Property Stolen', details['propertyStolen'] ?? 'N/A'),
                  _buildInfoRow('Crime Description', details['crimeDescription'] ?? 'N/A'),

                  const SizedBox(height: 16),
                  _buildSectionTitle('Chronological Narrative'),
                  _buildDetailCard(details['incidentNarrative'] ?? 'N/A'),

                  const SizedBox(height: 28),
                  AppButton(
                    label: 'Withdraw FIR (₹500 Fine)',
                    gradientColors: [AppColors.alertRed, AppColors.alertRed],
                    onPressed: () {
                      Navigator.pop(context); // close details bottomsheet
                      _showDeleteFineDialog(fir['firNumber'] ?? '');
                    },
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0, top: 8.0),
      child: Text(
        title,
        style: AppTextStyles.labelLarge.copyWith(
          color: AppColors.secondaryPurple,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
            child: Text(
              label,
              style: AppTextStyles.bodySmall.copyWith(color: AppColors.textGray),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: AppTextStyles.bodySmall.copyWith(color: AppColors.textWhite),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailCard(String text) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Text(
        text,
        style: AppTextStyles.bodySmall.copyWith(color: AppColors.textWhite, height: 1.4),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, color: AppColors.textWhite, size: 18),
          onPressed: () => context.pop(),
        ),
        title: Text('FILED FIRS', style: AppTextStyles.appBarTitle),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('My Filed Reports', style: AppTextStyles.h2),
              const SizedBox(height: 4),
              Text('Tap on any filed FIR to view full details or withdraw/delete it.', style: AppTextStyles.bodySmall.copyWith(color: AppColors.textGray)),
              const SizedBox(height: 20),
              Expanded(
                child: _isLoading
                    ? Center(
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation(AppColors.secondaryPurple),
                        ),
                      )
                    : _firs.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.folder_open, size: 64, color: AppColors.textGray),
                                const SizedBox(height: 12),
                                Text(
                                  'No FIRs filed yet.',
                                  style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textGray),
                                ),
                              ],
                            ),
                          )
                        : ListView.separated(
                            itemCount: _firs.length,
                            separatorBuilder: (_, __) => const SizedBox(height: 12),
                            itemBuilder: (context, index) {
                              final fir = _firs[index];
                              final registration = fir['registrationDateTime'] != null
                                  ? DateTime.tryParse(fir['registrationDateTime'])?.toLocal().toString().split(' ')[0]
                                  : 'N/A';

                              return GestureDetector(
                                onTap: () => _showFirDetails(fir),
                                child: Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: AppColors.card,
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(color: AppColors.border),
                                  ),
                                  child: Row(
                                    children: [
                                      CircleAvatar(
                                        backgroundColor: AppColors.alertRed.withOpacity(0.1),
                                        child: Icon(Icons.gavel, color: AppColors.alertRed),
                                      ),
                                      const SizedBox(width: 14),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              fir['firNumber'] ?? 'Unknown FIR',
                                              style: AppTextStyles.bodyLarge.copyWith(
                                                color: AppColors.textWhite,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            const SizedBox(height: 2),
                                            Text(
                                              'Complainant: ${(fir['complainantDetails'] ?? {})['fullName'] ?? 'N/A'}',
                                              style: AppTextStyles.bodySmall.copyWith(color: AppColors.textGray),
                                            ),
                                            const SizedBox(height: 2),
                                            Text(
                                              'Date: $registration',
                                              style: AppTextStyles.caption.copyWith(color: AppColors.textGray),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Icon(Icons.arrow_forward_ios, size: 16, color: AppColors.textGray),
                                    ],
                                  ),
                                ),
                              ).animate().fadeIn(delay: (index * 50).ms);
                            },
                          ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PaymentScannerDialog extends StatefulWidget {
  final String firNumber;
  final VoidCallback onComplete;

  const _PaymentScannerDialog({
    required this.firNumber,
    required this.onComplete,
  });

  @override
  State<_PaymentScannerDialog> createState() => _PaymentScannerDialogState();
}

class _PaymentScannerDialogState extends State<_PaymentScannerDialog> {
  int _secondsLeft = 30;
  Timer? _timer;
  bool _isDeleting = false;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsLeft == 1) {
        timer.cancel();
        _deleteFir();
      } else {
        setState(() {
          _secondsLeft--;
        });
      }
    });
  }

  Future<void> _deleteFir() async {
    setState(() => _isDeleting = true);
    final success = await SafeguardService.instance.deleteFir(widget.firNumber);
    if (mounted) {
      Navigator.pop(context); // close popup
      if (success) {
        widget.onComplete();
      }
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppColors.card,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 36),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: AppColors.border),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Withdrawal Fine',
                  style: AppTextStyles.h3.copyWith(color: AppColors.textWhite),
                ),
                Text(
                  '0:${_secondsLeft.toString().padLeft(2, '0')}',
                  style: AppTextStyles.h2.copyWith(color: AppColors.alertRed),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              'A fine of ₹500 is required to withdraw/delete this FIR. Scan the UPI QR code below to make the payment.',
              style: AppTextStyles.bodySmall.copyWith(color: AppColors.textGray),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            // The scanner QR code image
            Container(
              height: 250,
              width: 250,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.border, width: 2),
                color: Colors.white,
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.asset(
                  'assets/images/Scanner@Payment.jpeg',
                  fit: BoxFit.contain,
                ),
              ),
            ),
            const SizedBox(height: 20),
            if (_isDeleting)
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation(Colors.white)),
                  ),
                  const SizedBox(width: 10),
                  Text('Processing Withdrawal...', style: AppTextStyles.bodySmall.copyWith(color: AppColors.textWhite)),
                ],
              )
            else
              Text(
                'Waiting for payment verification...',
                style: AppTextStyles.bodySmall.copyWith(color: AppColors.textGray, fontStyle: FontStyle.italic),
              ),
            const SizedBox(height: 12),
            OutlinedButton(
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: AppColors.border),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: () {
                _timer?.cancel();
                Navigator.pop(context); // cancel withdrawal
              },
              child: Text('Cancel Withdrawal', style: TextStyle(color: AppColors.textWhite)),
            ),
          ],
        ),
      ),
    );
  }
}

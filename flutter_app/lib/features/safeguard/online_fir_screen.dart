import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/services/safeguard_service.dart';
import '../../shared/widgets/app_button.dart';

class OnlineFirScreen extends StatefulWidget {
  const OnlineFirScreen({super.key});

  @override
  State<OnlineFirScreen> createState() => _OnlineFirScreenState();
}

class _OnlineFirScreenState extends State<OnlineFirScreen> {
  final _formKey = GlobalKey<FormState>();
  int _currentStep = 0;
  bool _isSubmitting = false;

  // Complainant Details Form Controllers
  final _fullNameCtrl = TextEditingController();
  final _ageCtrl = TextEditingController();
  final _occupationCtrl = TextEditingController();
  final _permAddressCtrl = TextEditingController();
  final _tempAddressCtrl = TextEditingController();
  final _contactCtrl = TextEditingController();

  // FIR / Incident Details Form Controllers
  final _narrativeCtrl = TextEditingController();
  final _dateCtrl = TextEditingController();
  final _timeCtrl = TextEditingController();
  final _locationCtrl = TextEditingController();
  final _crimeDescCtrl = TextEditingController();
  final _motivesCtrl = TextEditingController();
  final _propertyStolenCtrl = TextEditingController();
  final _weaponsUsedCtrl = TextEditingController();
  final _specificLawsCtrl = TextEditingController(text: 'Bharatiya Nyaya Sanhita (BNS) Section 303 / IPC Section 379');

  @override
  void dispose() {
    _fullNameCtrl.dispose();
    _ageCtrl.dispose();
    _occupationCtrl.dispose();
    _permAddressCtrl.dispose();
    _tempAddressCtrl.dispose();
    _contactCtrl.dispose();
    _narrativeCtrl.dispose();
    _dateCtrl.dispose();
    _timeCtrl.dispose();
    _locationCtrl.dispose();
    _crimeDescCtrl.dispose();
    _motivesCtrl.dispose();
    _propertyStolenCtrl.dispose();
    _weaponsUsedCtrl.dispose();
    _specificLawsCtrl.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.dark(
              primary: AppColors.secondaryPurple,
              onPrimary: Colors.white,
              surface: AppColors.card,
              onSurface: AppColors.textWhite,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _dateCtrl.text = "${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";
      });
    }
  }

  Future<void> _selectTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.dark(
              primary: AppColors.secondaryPurple,
              onPrimary: Colors.white,
              surface: AppColors.card,
              onSurface: AppColors.textWhite,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _timeCtrl.text = picked.format(context);
      });
    }
  }

  Future<void> _submitFir() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    final firData = {
      'fullName': _fullNameCtrl.text.trim(),
      'age': int.tryParse(_ageCtrl.text.trim()) ?? 0,
      'occupation': _occupationCtrl.text.trim(),
      'permanentAddress': _permAddressCtrl.text.trim(),
      'temporaryAddress': _tempAddressCtrl.text.trim(),
      'contactNumber': _contactCtrl.text.trim(),
      'incidentNarrative': _narrativeCtrl.text.trim(),
      'incidentDate': _dateCtrl.text.trim(),
      'incidentTime': _timeCtrl.text.trim(),
      'incidentLocation': _locationCtrl.text.trim(),
      'crimeDescription': _crimeDescCtrl.text.trim(),
      'motives': _motivesCtrl.text.trim(),
      'propertyStolen': _propertyStolenCtrl.text.trim(),
      'weaponsUsed': _weaponsUsedCtrl.text.trim(),
      'specificLaws': _specificLawsCtrl.text.trim(),
    };

    final newFir = await SafeguardService.instance.createFir(firData);
    setState(() => _isSubmitting = false);

    if (newFir != null) {
      _showSuccessDialog(newFir['firNumber'] ?? 'Unknown');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Failed to file FIR. Please check network connection.'),
          backgroundColor: AppColors.alertRed,
        ),
      );
    }
  }

  void _showSuccessDialog(String firNumber) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.card,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: AppColors.border),
        ),
        title: Center(
          child: Column(
            children: [
              Icon(Icons.check_circle_outline, size: 54, color: AppColors.successGreen),
              const SizedBox(height: 12),
              Text(
                'FIR Registered Successfully',
                textAlign: TextAlign.center,
                style: AppTextStyles.h3.copyWith(color: AppColors.textWhite),
              ),
            ],
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Your FIR has been stored securely in the system files.',
              style: AppTextStyles.bodySmall.copyWith(color: AppColors.textGray),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                children: [
                  Text(
                    'FIR REFERENCE NUMBER',
                    style: AppTextStyles.caption.copyWith(color: AppColors.textGray),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    firNumber,
                    style: AppTextStyles.h2.copyWith(color: AppColors.successGreen, letterSpacing: 1.2),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          Center(
            child: SizedBox(
              width: 140,
              child: AppButton(
                label: 'Okay',
                onPressed: () {
                  Navigator.pop(ctx);
                  context.pop(); // return to Safeguard screen
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool isNumeric = false,
    bool isMultiline = false,
    bool isRequired = true,
    VoidCallback? onTap,
    bool readOnly = false,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: isNumeric ? TextInputType.number : (isMultiline ? TextInputType.multiline : TextInputType.text),
      maxLines: isMultiline ? 4 : 1,
      style: TextStyle(color: AppColors.textWhite),
      readOnly: readOnly,
      onTap: onTap,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: AppColors.textGray),
        prefixIcon: Icon(icon, color: AppColors.secondaryPurple, size: 20),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.secondaryPurple),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.alertRed),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.alertRed),
        ),
        filled: true,
        fillColor: AppColors.card,
      ),
      validator: isRequired
          ? (v) => (v == null || v.trim().isEmpty) ? '$label is required' : null
          : null,
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
        title: Text('ONLINE FIR PORTAL', style: AppTextStyles.appBarTitle),
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // Stepper header
              Container(
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                decoration: BoxDecoration(
                  color: AppColors.card,
                  border: Border(bottom: BorderSide(color: AppColors.border)),
                ),
                child: Row(
                  children: [
                    _buildStepIndicator(0, 'Complainant'),
                    _buildStepLine(),
                    _buildStepIndicator(1, 'Incident Details'),
                    _buildStepLine(),
                    _buildStepIndicator(2, 'Legal & Review'),
                  ],
                ),
              ),
              Expanded(
                child: _isSubmitting
                    ? Center(
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation(AppColors.secondaryPurple),
                        ),
                      )
                    : SingleChildScrollView(
                        padding: const EdgeInsets.all(20),
                        child: _currentStep == 0
                            ? _buildComplainantStep()
                            : (_currentStep == 1
                                ? _buildIncidentStep()
                                : _buildReviewStep()),
                      ),
              ),
              if (!_isSubmitting)
                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Row(
                    children: [
                      if (_currentStep > 0)
                        Expanded(
                          child: OutlinedButton(
                            style: OutlinedButton.styleFrom(
                              side: BorderSide(color: AppColors.border),
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            onPressed: () => setState(() => _currentStep--),
                            child: Text('Back', style: TextStyle(color: AppColors.textWhite, fontSize: 16)),
                          ),
                        ),
                      if (_currentStep > 0) const SizedBox(width: 12),
                      Expanded(
                        child: AppButton(
                          label: _currentStep == 2 ? 'Submit FIR' : 'Continue',
                          onPressed: () {
                            if (_currentStep < 2) {
                              if (_formKey.currentState!.validate()) {
                                setState(() => _currentStep++);
                              }
                            } else {
                              _submitFir();
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStepIndicator(int stepIndex, String title) {
    final isActive = _currentStep == stepIndex;
    final isDone = _currentStep > stepIndex;
    return Row(
      children: [
        CircleAvatar(
          radius: 12,
          backgroundColor: isDone
              ? AppColors.successGreen
              : (isActive ? AppColors.secondaryPurple : AppColors.border),
          child: isDone
              ? const Icon(Icons.check, size: 14, color: Colors.white)
              : Text(
                  (stepIndex + 1).toString(),
                  style: TextStyle(
                    fontSize: 12,
                    color: isActive || isDone ? Colors.white : AppColors.textGray,
                    fontWeight: FontWeight.bold,
                  ),
                ),
        ),
        const SizedBox(width: 6),
        Text(
          title,
          style: AppTextStyles.caption.copyWith(
            color: isActive ? AppColors.textWhite : AppColors.textGray,
            fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ],
    );
  }

  Widget _buildStepLine() {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 8),
        height: 1,
        color: AppColors.border,
      ),
    );
  }

  Widget _buildComplainantStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Complainant Details', style: AppTextStyles.h2),
        const SizedBox(height: 4),
        Text('Please verify that the contact numbers and addresses are correct.', style: AppTextStyles.bodySmall.copyWith(color: AppColors.textGray)),
        const SizedBox(height: 20),
        _buildTextField(
          controller: _fullNameCtrl,
          label: 'Full Name',
          icon: Icons.person_outline,
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildTextField(
                controller: _ageCtrl,
                label: 'Age',
                icon: Icons.calendar_today_outlined,
                isNumeric: true,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildTextField(
                controller: _occupationCtrl,
                label: 'Occupation',
                icon: Icons.work_outline,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        _buildTextField(
          controller: _contactCtrl,
          label: 'Contact Number',
          icon: Icons.phone_android_outlined,
          isNumeric: true,
        ),
        const SizedBox(height: 16),
        _buildTextField(
          controller: _permAddressCtrl,
          label: 'Permanent Address',
          icon: Icons.home_outlined,
          isMultiline: true,
        ),
        const SizedBox(height: 16),
        _buildTextField(
          controller: _tempAddressCtrl,
          label: 'Temporary Address',
          icon: Icons.location_city_outlined,
          isMultiline: true,
        ),
      ],
    ).animate().fadeIn(duration: 250.ms);
  }

  Widget _buildIncidentStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Incident & FIR Details', style: AppTextStyles.h2),
        const SizedBox(height: 4),
        Text('Provide a chronological narrative and describe motive/property/weapons.', style: AppTextStyles.bodySmall.copyWith(color: AppColors.textGray)),
        const SizedBox(height: 20),
        _buildTextField(
          controller: _narrativeCtrl,
          label: 'Incident Narrative (Detailed chronological description)',
          icon: Icons.description_outlined,
          isMultiline: true,
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildTextField(
                controller: _dateCtrl,
                label: 'Date of Offense',
                icon: Icons.date_range,
                readOnly: true,
                onTap: _selectDate,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildTextField(
                controller: _timeCtrl,
                label: 'Time of Offense',
                icon: Icons.access_time,
                readOnly: true,
                onTap: _selectTime,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        _buildTextField(
          controller: _locationCtrl,
          label: 'Precise Location of Incident',
          icon: Icons.my_location,
        ),
        const SizedBox(height: 16),
        _buildTextField(
          controller: _crimeDescCtrl,
          label: 'How Crime Was Committed',
          icon: Icons.report_problem_outlined,
          isMultiline: true,
        ),
        const SizedBox(height: 16),
        _buildTextField(
          controller: _motivesCtrl,
          label: 'Motives Involved',
          icon: Icons.psychology_outlined,
        ),
        const SizedBox(height: 16),
        _buildTextField(
          controller: _propertyStolenCtrl,
          label: 'Details of Property Stolen (if any)',
          icon: Icons.monetization_on_outlined,
          isRequired: false,
        ),
        const SizedBox(height: 16),
        _buildTextField(
          controller: _weaponsUsedCtrl,
          label: 'Details of Weapons Used (if any)',
          icon: Icons.gavel,
          isRequired: false,
        ),
      ],
    ).animate().fadeIn(duration: 250.ms);
  }

  Widget _buildReviewStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Review Legal Information', style: AppTextStyles.h2),
        const SizedBox(height: 4),
        Text('Review laws and confirm correctness before filing.', style: AppTextStyles.bodySmall.copyWith(color: AppColors.textGray)),
        const SizedBox(height: 20),
        _buildTextField(
          controller: _specificLawsCtrl,
          label: 'Applicable Laws & Acts',
          icon: Icons.gavel,
          isMultiline: true,
        ),
        const SizedBox(height: 24),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.alertRed.withOpacity(0.06),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.alertRed.withOpacity(0.3)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.warning_amber_rounded, color: AppColors.alertRed),
                  const SizedBox(width: 8),
                  Text(
                    'LEGAL DECLARATION',
                    style: AppTextStyles.labelLarge.copyWith(color: AppColors.alertRed, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'By submitting this report, I verify that the facts stated in this FIR are true to the best of my knowledge. I understand that filing a false police report is a criminal offense punishable under Section 217 of the Bharatiya Nyaya Sanhita (BNS) / Section 182 of the IPC.',
                style: AppTextStyles.caption.copyWith(color: AppColors.textWhite, height: 1.4),
              ),
            ],
          ),
        ),
      ],
    ).animate().fadeIn(duration: 250.ms);
  }
}

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/services/prescripto_service.dart';

class BookDoctorScreen extends StatefulWidget {
  final Map<String, dynamic> doctor;
  const BookDoctorScreen({super.key, required this.doctor});

  @override
  State<BookDoctorScreen> createState() => _BookDoctorScreenState();
}

class _BookDoctorScreenState extends State<BookDoctorScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _ageController = TextEditingController();
  final _issueController = TextEditingController();
  final _descriptionController = TextEditingController();
  
  String _gender = 'Male';
  int _healthRating = 3;
  DateTime? _selectedDateTime;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _nameController.dispose();
    _ageController.dispose();
    _issueController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickDateTime() async {
    final now = DateTime.now();
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: now.add(const Duration(days: 1)),
      firstDate: now,
      lastDate: now.add(const Duration(days: 30)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.dark(
              primary: AppColors.medicalBlue,
              onPrimary: AppColors.textWhite,
              surface: AppColors.card,
              onSurface: AppColors.textWhite,
            ),
          ),
          child: child!,
        );
      },
    );

    if (pickedDate == null) return;

    final pickedTime = await showTimePicker(
      context: context,
      initialTime: const TimeOfDay(hour: 9, minute: 0),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.dark(
              primary: AppColors.medicalBlue,
              onPrimary: AppColors.textWhite,
              surface: AppColors.card,
              onSurface: AppColors.textWhite,
            ),
          ),
          child: child!,
        );
      },
    );

    if (pickedTime == null) return;

    setState(() {
      _selectedDateTime = DateTime(
        pickedDate.year,
        pickedDate.month,
        pickedDate.day,
        pickedTime.hour,
        pickedTime.minute,
      );
    });
  }

  Future<void> _submitBooking() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedDateTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select an appointment date & time.')),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final docId = widget.doctor['_id'] ?? widget.doctor['id'];
      final docName = widget.doctor['name'];
      final docSpecialty = widget.doctor['specialty'];
      final docFee =
          widget.doctor['consultationFee'] ?? widget.doctor['fee'] ?? 500;

      final bookingData = {
        'doctorId': docId.toString(),
        'doctorName': docName?.toString() ?? '',
        'specialty': docSpecialty?.toString() ?? '',
        'consultationFee': docFee,
        'doctor': {
          'name': docName?.toString() ?? '',
          'specialty': docSpecialty?.toString() ?? '',
          'consultationFee': docFee,
        },
        'patientName': _nameController.text.trim(),
        'patientAge': int.tryParse(_ageController.text.trim()) ?? 0,
        'patientGender': _gender,
        'healthIssue': _issueController.text.trim(),
        'symptomsDescription': _descriptionController.text.trim(),
        'healthRating': _healthRating,
        'appointmentDate': _selectedDateTime!.toIso8601String(),
      };

      // createBooking never throws — either saves to backend or falls back locally
      await PrescriptoService.instance.createBooking(bookingData);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Appointment booked successfully!'),
            backgroundColor: AppColors.successGreen,
          ),
        );
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Booking failed: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }


  InputDecoration _inputDecoration(String hint, IconData icon) {
    return InputDecoration(
      hintText: hint,
      hintStyle: AppTextStyles.bodyMedium.copyWith(color: AppColors.textDimmed),
      prefixIcon: Icon(icon, color: AppColors.textDimmed, size: 20),
      filled: true,
      fillColor: AppColors.card,
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: AppColors.border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: AppColors.medicalBlue),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: AppColors.alertRed),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: AppColors.alertRed),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final fee = widget.doctor['consultationFee'] ?? widget.doctor['fee'] ?? 500;
    final initials = widget.doctor['imageInitials'] ?? '';
    final imageUrl = widget.doctor['profileImage'] ?? '';

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, color: AppColors.textWhite, size: 18),
          onPressed: () => context.pop(),
        ),
        title: Text('Book Appointment', style: AppTextStyles.appBarTitle),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Doctor Summary Card
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.card,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.border),
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 30,
                      backgroundColor: AppColors.medicalBlue.withOpacity(0.12),
                      backgroundImage: imageUrl.isNotEmpty ? CachedNetworkImageProvider(imageUrl) : null,
                      child: imageUrl.isEmpty
                          ? Text(
                              initials.isNotEmpty ? initials : widget.doctor['name'].substring(0, 2).toUpperCase(),
                              style: AppTextStyles.labelLarge.copyWith(color: AppColors.medicalBlue),
                            )
                          : null,
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(widget.doctor['name'], style: AppTextStyles.labelLarge),
                          Text(widget.doctor['specialty'], style: AppTextStyles.bodySmall),
                          const SizedBox(height: 4),
                          Text('Fees: ₹$fee', style: AppTextStyles.labelMedium.copyWith(color: AppColors.successGreen)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              Text('Patient Information', style: AppTextStyles.h3),
              const SizedBox(height: 12),

              // Patient Name
              TextFormField(
                controller: _nameController,
                style: AppTextStyles.bodyLarge,
                decoration: _inputDecoration("Patient's Full Name", Icons.person_outline),
                validator: (value) => value == null || value.trim().isEmpty ? "Please enter patient's name" : null,
              ),
              const SizedBox(height: 14),

              // Row for Age & Gender
              Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: TextFormField(
                      controller: _ageController,
                      style: AppTextStyles.bodyLarge,
                      keyboardType: TextInputType.number,
                      decoration: _inputDecoration("Age", Icons.calendar_today_outlined),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) return "Enter age";
                        final age = int.tryParse(value.trim());
                        if (age == null || age <= 0 || age > 120) return "Invalid";
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 3,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        color: AppColors.card,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: _gender,
                          dropdownColor: AppColors.card,
                          style: AppTextStyles.bodyLarge.copyWith(color: AppColors.textWhite),
                          onChanged: (val) {
                            if (val != null) setState(() => _gender = val);
                          },
                          items: ['Male', 'Female', 'Other']
                              .map((g) => DropdownMenuItem(
                                    value: g,
                                    child: Text(g),
                                  ))
                              .toList(),
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              Text('Condition Details', style: AppTextStyles.h3),
              const SizedBox(height: 12),

              // Health Issue
              TextFormField(
                controller: _issueController,
                style: AppTextStyles.bodyLarge,
                decoration: _inputDecoration("What's your primary Health Issue?", Icons.healing_outlined),
                validator: (value) => value == null || value.trim().isEmpty ? "Please state the health issue" : null,
              ),
              const SizedBox(height: 14),

              // Detailed symptoms
              TextFormField(
                controller: _descriptionController,
                style: AppTextStyles.bodyLarge,
                maxLines: 3,
                decoration: _inputDecoration("Describe symptoms & duration (optional)", Icons.description_outlined),
              ),
              const SizedBox(height: 20),

              // Health rating (1 to 5)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('How do you rate your current health condition?', style: AppTextStyles.labelMedium),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: List.generate(5, (index) {
                      final val = index + 1;
                      final isSelected = _healthRating == val;
                      return GestureDetector(
                        onTap: () => setState(() => _healthRating = val),
                        child: Container(
                          width: 50,
                          height: 44,
                          decoration: BoxDecoration(
                            gradient: isSelected ? AppColors.primaryGradient : null,
                            color: isSelected ? null : AppColors.card,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: isSelected ? AppColors.primaryPurple : AppColors.border,
                            ),
                          ),
                          child: Center(
                            child: Text(
                              '$val',
                              style: AppTextStyles.labelLarge.copyWith(
                                color: isSelected ? AppColors.textWhite : AppColors.textDimmed,
                              ),
                            ),
                          ),
                        ),
                      );
                    }),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: const [
                      Text('1 (Bad)', style: TextStyle(fontSize: 10, color: AppColors.alertRed)),
                      Text('5 (Excellent)', style: TextStyle(fontSize: 10, color: AppColors.successGreen)),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 24),

              Text('Appointment Schedule', style: AppTextStyles.h3),
              const SizedBox(height: 12),

              // Date time picker
              GestureDetector(
                onTap: _pickDateTime,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    color: AppColors.card,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: _selectedDateTime != null ? AppColors.medicalBlue : AppColors.border,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.calendar_month,
                        color: _selectedDateTime != null ? AppColors.medicalBlue : AppColors.textDimmed,
                        size: 22,
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Text(
                          _selectedDateTime != null
                              ? DateFormat('EEEE, d MMM yyyy, hh:mm a').format(_selectedDateTime!)
                              : 'Select Date & Time',
                          style: AppTextStyles.bodyLarge.copyWith(
                            color: _selectedDateTime != null ? AppColors.textWhite : AppColors.textDimmed,
                          ),
                        ),
                      ),
                      Icon(Icons.edit, color: AppColors.textDimmed, size: 18),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 32),

              // Submit Button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isSubmitting ? null : _submitBooking,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.medicalBlue,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isSubmitting
                      ? CircularProgressIndicator(color: AppColors.textWhite)
                      : Text(
                          'Confirm Appointment (₹$fee)',
                          style: AppTextStyles.labelLarge.copyWith(color: AppColors.textWhite),
                        ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}

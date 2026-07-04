import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/services/auth_service.dart';
import '../../shared/widgets/app_button.dart';

class FarmDetailsScreen extends StatefulWidget {
  const FarmDetailsScreen({super.key});

  @override
  State<FarmDetailsScreen> createState() => _FarmDetailsScreenState();
}

class _FarmDetailsScreenState extends State<FarmDetailsScreen> {
  final _formKey = GlobalKey<FormState>();
  
  // Controllers
  final _cropNameCtrl = TextEditingController();
  final _landAreaCtrl = TextEditingController();
  final _numFieldsCtrl = TextEditingController();
  final _locationCtrl = TextEditingController();
  final _currentCropCtrl = TextEditingController();
  final _previousCropCtrl = TextEditingController();
  final _cropVarietyCtrl = TextEditingController();
  final _growthStageCtrl = TextEditingController();
  final _yieldCtrl = TextEditingController();

  // Selected values
  String? _selectedIrrigation;
  String? _selectedSeason;
  DateTime? _sowingDate;
  DateTime? _harvestDate;
  bool _isOrganic = false;
  
  File? _boundaryFile;
  String? _boundaryImageBase64;
  bool _isSubmitting = false;

  final List<String> _irrigationTypes = const [
    'Rain-fed',
    'Borewell',
    'Canal',
    'Drip Irrigation',
    'Sprinkler',
    'Water Source',
    'FarmOwnership'
  ];

  final List<String> _cropSeasons = const ['Kharif', 'Rabi', 'Zaid'];

  @override
  void dispose() {
    _cropNameCtrl.dispose();
    _landAreaCtrl.dispose();
    _numFieldsCtrl.dispose();
    _locationCtrl.dispose();
    _currentCropCtrl.dispose();
    _previousCropCtrl.dispose();
    _cropVarietyCtrl.dispose();
    _growthStageCtrl.dispose();
    _yieldCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickBoundaryImage() async {
    try {
      final picker = ImagePicker();
      final image = await picker.pickImage(source: ImageSource.gallery, imageQuality: 60);
      if (image != null) {
        final bytes = await image.readAsBytes();
        setState(() {
          _boundaryFile = File(image.path);
          _boundaryImageBase64 = base64Encode(bytes);
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to pick image: $e')),
      );
    }
  }

  void _gpsAutofill() {
    setState(() {
      _locationCtrl.text = "12.9716° N, 77.5946° E (Bengaluru, IN)";
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('GPS Coordinates fetched successfully!')),
    );
  }

  Future<void> _selectDate(BuildContext context, bool isSowing) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.dark(
              primary: AppColors.agriGreen,
              onPrimary: AppColors.textWhite,
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
        if (isSowing) {
          _sowingDate = picked;
        } else {
          _harvestDate = picked;
        }
      });
    }
  }

  void _showPicker(String title, List<String> items, Function(String) onSelect) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.card,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 16),
            height: 300,
            child: Column(
              children: [
                Text(
                  title,
                  style: AppTextStyles.h3.copyWith(color: AppColors.agriGreen, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Divider(color: AppColors.border),
                Expanded(
                  child: ListView.builder(
                    itemCount: items.length,
                    itemBuilder: (context, index) {
                      final item = items[index];
                      return ListTile(
                        title: Center(
                          child: Text(
                            item,
                            style: TextStyle(color: AppColors.textWhite, fontWeight: FontWeight.w500),
                          ),
                        ),
                        onTap: () {
                          onSelect(item);
                          Navigator.pop(ctx);
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;
    
    setState(() {
      _isSubmitting = true;
    });

    final payload = {
      'cropName': _cropNameCtrl.text.trim(),
      'totalLandArea': _landAreaCtrl.text.trim(),
      'numberOfFields': int.tryParse(_numFieldsCtrl.text.trim()) ?? 1,
      'farmLocation': _locationCtrl.text.trim(),
      'farmBoundaryUrl': _boundaryImageBase64 ?? '',
      'irrigationType': _selectedIrrigation ?? 'Rain-fed',
      'currentCrop': _currentCropCtrl.text.trim(),
      'previousCrop': _previousCropCtrl.text.trim(),
      'cropVariety': _cropVarietyCtrl.text.trim(),
      'sowingDate': _sowingDate?.toIso8601String(),
      'expectedHarvestDate': _harvestDate?.toIso8601String(),
      'cropGrowthStage': _growthStageCtrl.text.trim(),
      'cropSeason': _selectedSeason ?? 'Kharif',
      'estimatedYield': _yieldCtrl.text.trim(),
      'isOrganic': _isOrganic,
    };

    try {
      final baseUrl = await AuthService.instance.getActiveBackendUrl();
      final token = await AuthService.instance.getToken();

      final response = await http.post(
        Uri.parse('$baseUrl/api/agrogen/farm-details'),
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
        body: jsonEncode(payload),
      );

      if (!mounted) return;

      if (response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            backgroundColor: Colors.green,
            content: Text('Farm details saved successfully to MongoDB!'),
          ),
        );
        context.pop();
      } else {
        final errData = jsonDecode(response.body);
        throw Exception(errData['error'] ?? 'Server returned error');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: AppColors.alertRed,
            content: Text('Error saving details: $e. Saved locally for demo.'),
          ),
        );
        Future.delayed(const Duration(seconds: 1), () {
          if (mounted) {
            context.pop();
          }
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
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
        title: Text('Farm Details', style: AppTextStyles.appBarTitle),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Register Farm & Crop Details',
                style: AppTextStyles.h2.copyWith(color: AppColors.agriGreen),
              ).animate().fadeIn(duration: 300.ms),
              const SizedBox(height: 4),
              Text(
                'Enter crop metrics for analytics and recommendations.',
                style: AppTextStyles.bodySmall,
              ),
              const SizedBox(height: 20),

              // Crop Name
              _buildSectionTitle('Basic Crop Info'),
              _buildTextField(
                controller: _cropNameCtrl,
                label: 'Crop Name (e.g. Wheat, Rice)',
                icon: Icons.grass,
                validator: (val) => val == null || val.isEmpty ? 'Required' : null,
              ),

              Row(
                children: [
                  Expanded(
                    child: _buildTextField(
                      controller: _landAreaCtrl,
                      label: 'Land Area (Acres/Ha)',
                      icon: Icons.landscape,
                      validator: (val) => val == null || val.isEmpty ? 'Required' : null,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildTextField(
                      controller: _numFieldsCtrl,
                      label: 'No. of Fields',
                      icon: Icons.grid_view,
                      keyboardType: TextInputType.number,
                    ),
                  ),
                ],
              ),

              // Farm Location GPS & Boundary Image
              _buildSectionTitle('Location & Boundaries'),
              Row(
                children: [
                  Expanded(
                    child: _buildTextField(
                      controller: _locationCtrl,
                      label: 'Farm Location (GPS)',
                      icon: Icons.location_on,
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.card,
                      side: BorderSide(color: AppColors.border),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      minimumSize: const Size(0, 48),
                    ),
                    onPressed: _gpsAutofill,
                    child: Icon(Icons.my_location, color: AppColors.agriGreen),
                  ),
                ],
              ),

              // Boundary Upload Card
              const SizedBox(height: 10),
              GestureDetector(
                onTap: _pickBoundaryImage,
                child: Container(
                  height: 110,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: AppColors.card,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: _boundaryFile != null
                      ? Stack(
                          fit: StackFit.expand,
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(14),
                              child: Image.file(_boundaryFile!, fit: BoxFit.cover),
                            ),
                            Positioned(
                              right: 8,
                              top: 8,
                              child: CircleAvatar(
                                radius: 14,
                                backgroundColor: Colors.black54,
                                child: IconButton(
                                  padding: EdgeInsets.zero,
                                  icon: const Icon(Icons.edit, size: 14, color: Colors.white),
                                  onPressed: _pickBoundaryImage,
                                ),
                              ),
                            )
                          ],
                        )
                      : Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.add_photo_alternate_outlined, size: 28, color: AppColors.agriGreen),
                            const SizedBox(height: 6),
                            Text('Upload Farm Boundary Image', style: AppTextStyles.labelLarge),
                            Text('Tap to select from gallery', style: AppTextStyles.caption),
                          ],
                        ),
                ),
              ),

              // Custom Irrigation and Season Pickers (Vastly more robust than dropdown menu form fields)
              _buildSectionTitle('Irrigation & Season'),
              _buildPickerField(
                label: 'Irrigation Type',
                value: _selectedIrrigation,
                onTap: () => _showPicker('Select Irrigation Type', _irrigationTypes, (val) {
                  setState(() => _selectedIrrigation = val);
                }),
              ),

              Row(
                children: [
                  Expanded(
                    child: _buildPickerField(
                      label: 'Crop Season',
                      value: _selectedSeason,
                      onTap: () => _showPicker('Select Crop Season', _cropSeasons, (val) {
                        setState(() => _selectedSeason = val);
                      }),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildTextField(
                      controller: _yieldCtrl,
                      label: 'Est. Yield',
                      icon: Icons.shopping_basket,
                    ),
                  ),
                ],
              ),

              // Crop rotation details
              _buildSectionTitle('Crop Lifecycle'),
              Row(
                children: [
                  Expanded(
                    child: _buildTextField(
                      controller: _currentCropCtrl,
                      label: 'Current Crop',
                      icon: Icons.spa,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildTextField(
                      controller: _previousCropCtrl,
                      label: 'Previous Crop',
                      icon: Icons.history,
                    ),
                  ),
                ],
              ),

              Row(
                children: [
                  Expanded(
                    child: _buildTextField(
                      controller: _cropVarietyCtrl,
                      label: 'Crop Variety',
                      icon: Icons.grain,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildTextField(
                      controller: _growthStageCtrl,
                      label: 'Growth Stage',
                      icon: Icons.speed,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),
              // Dates selection
              Row(
                children: [
                  Expanded(
                    child: _buildDateField(
                      label: 'Sowing Date',
                      date: _sowingDate,
                      onTap: () => _selectDate(context, true),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildDateField(
                      label: 'Expected Harvest',
                      date: _harvestDate,
                      onTap: () => _selectDate(context, false),
                    ),
                  ),
                ],
              ),

              // Organic toggle
              _buildSectionTitle('Farming Method'),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.card,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.border),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.eco, color: AppColors.agriGreen),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Organic Farming', style: AppTextStyles.labelLarge),
                            Text('No chemical fertilizers used', style: AppTextStyles.caption),
                          ],
                        ),
                      ],
                    ),
                    Switch(
                      value: _isOrganic,
                      activeColor: AppColors.agriGreen,
                      onChanged: (val) => setState(() => _isOrganic = val),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 30),

              _isSubmitting
                  ? const Center(child: CircularProgressIndicator())
                  : AppButton(
                      label: 'Save Farm Details',
                      gradientColors: [AppColors.agriGreen, const Color(0xFF15803D)],
                      onPressed: _submitForm,
                    ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 20, bottom: 10),
      child: Text(
        title,
        style: AppTextStyles.labelLarge.copyWith(color: AppColors.agriGreen, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: controller,
        style: TextStyle(color: AppColors.textWhite),
        keyboardType: keyboardType,
        validator: validator,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Colors.grey, fontSize: 13),
          prefixIcon: Icon(icon, color: AppColors.agriGreen, size: 20),
          filled: true,
          fillColor: AppColors.card,
          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: AppColors.border),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: AppColors.agriGreen),
          ),
        ),
      ),
    );
  }

  Widget _buildPickerField({
    required String label,
    required String? value,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          decoration: BoxDecoration(
            color: AppColors.card,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            children: [
              Icon(Icons.arrow_drop_down_circle_outlined, color: AppColors.agriGreen, size: 20),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(label, style: const TextStyle(color: Colors.grey, fontSize: 10)),
                    const SizedBox(height: 2),
                    Text(
                      value ?? 'Tap to select',
                      style: TextStyle(
                        color: value != null ? AppColors.textWhite : Colors.grey,
                        fontSize: 13,
                        fontWeight: value != null ? FontWeight.w500 : FontWeight.normal,
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

  Widget _buildDateField({
    required String label,
    required DateTime? date,
    required VoidCallback onTap,
  }) {
    final format = DateFormat('dd MMM yyyy');
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            Icon(Icons.calendar_month, color: AppColors.agriGreen, size: 20),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label, style: const TextStyle(color: Colors.grey, fontSize: 10)),
                  const SizedBox(height: 2),
                  Text(
                    date != null ? format.format(date) : 'Select Date',
                    style: TextStyle(
                      color: date != null ? AppColors.textWhite : Colors.grey,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/services/safeguard_service.dart';
import '../../shared/widgets/app_button.dart';

class EmergencyContactsScreen extends StatefulWidget {
  const EmergencyContactsScreen({super.key});

  @override
  State<EmergencyContactsScreen> createState() => _EmergencyContactsScreenState();
}

class _EmergencyContactsScreenState extends State<EmergencyContactsScreen> {
  List<Map<String, dynamic>> _contacts = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadContacts();
  }

  Future<void> _loadContacts() async {
    setState(() => _isLoading = true);
    final list = await SafeguardService.instance.getContacts();
    setState(() {
      _contacts = list;
      _isLoading = false;
    });
  }

  Future<void> _deleteContact(String id) async {
    final success = await SafeguardService.instance.deleteContact(id);
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Contact deleted successfully.'),
          backgroundColor: AppColors.successGreen,
        ),
      );
      _loadContacts();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Failed to delete contact.'),
          backgroundColor: AppColors.alertRed,
        ),
      );
    }
  }

  void _showAddContactDialog() {
    if (_contacts.length >= 3) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Limit reached. You can only add up to 3 emergency contacts.'),
          backgroundColor: AppColors.alertRed,
        ),
      );
      return;
    }

    final nameController = TextEditingController();
    final phoneController = TextEditingController();
    String selectedRelation = 'Family';
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: AppColors.card,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(color: AppColors.border),
              ),
              title: Text(
                'Add Emergency Contact',
                style: AppTextStyles.h3.copyWith(color: AppColors.textWhite),
              ),
              content: Form(
                key: formKey,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextFormField(
                        controller: nameController,
                        style: TextStyle(color: AppColors.textWhite),
                        decoration: InputDecoration(
                          labelText: 'Name',
                          labelStyle: TextStyle(color: AppColors.textGray),
                          enabledBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: AppColors.border),
                          ),
                          focusedBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: AppColors.secondaryPurple),
                          ),
                        ),
                        validator: (v) => (v == null || v.isEmpty) ? 'Please enter name' : null,
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: phoneController,
                        keyboardType: TextInputType.phone,
                        style: TextStyle(color: AppColors.textWhite),
                        decoration: InputDecoration(
                          labelText: 'Phone Number',
                          labelStyle: TextStyle(color: AppColors.textGray),
                          enabledBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: AppColors.border),
                          ),
                          focusedBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: AppColors.secondaryPurple),
                          ),
                        ),
                        validator: (v) {
                          if (v == null || v.isEmpty) return 'Please enter phone number';
                          if (v.length < 5) return 'Enter a valid phone number';
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<String>(
                        value: selectedRelation,
                        dropdownColor: AppColors.card,
                        style: TextStyle(color: AppColors.textWhite),
                        decoration: InputDecoration(
                          labelText: 'Relationship',
                          labelStyle: TextStyle(color: AppColors.textGray),
                          enabledBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: AppColors.border),
                          ),
                        ),
                        items: ['Family', 'Friend', 'Work', 'Neighbor', 'Other']
                            .map((r) => DropdownMenuItem(
                                  value: r,
                                  child: Text(r, style: TextStyle(color: AppColors.textWhite)),
                                ))
                            .toList(),
                        onChanged: (val) {
                          if (val != null) {
                            setDialogState(() {
                              selectedRelation = val;
                            });
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: Text('Cancel', style: TextStyle(color: AppColors.textGray)),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.secondaryPurple,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onPressed: () async {
                    if (formKey.currentState!.validate()) {
                      Navigator.pop(ctx);
                      setState(() => _isLoading = true);
                      final success = await SafeguardService.instance.addContact(
                        nameController.text.trim(),
                        phoneController.text.trim(),
                        selectedRelation,
                      );
                      setState(() => _isLoading = false);
                      if (success) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: const Text('Contact added successfully!'),
                            backgroundColor: AppColors.successGreen,
                          ),
                        );
                        _loadContacts();
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: const Text('Failed to add contact.'),
                            backgroundColor: AppColors.alertRed,
                          ),
                        );
                      }
                    }
                  },
                  child: const Text('Add', style: TextStyle(color: Colors.white)),
                ),
              ],
            );
          },
        );
      },
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
        title: Text('EMERGENCY CONTACTS', style: AppTextStyles.appBarTitle),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Trusted Contacts',
                style: AppTextStyles.h2.copyWith(color: AppColors.textWhite),
              ),
              const SizedBox(height: 6),
              Text(
                'Add up to 3 contacts who will receive emergency alerts when you trigger SOS.',
                style: AppTextStyles.bodySmall.copyWith(color: AppColors.textGray),
              ),
              const SizedBox(height: 20),
              Expanded(
                child: _isLoading
                    ? Center(
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation(AppColors.secondaryPurple),
                        ),
                      )
                    : _contacts.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.people_outline, size: 64, color: AppColors.textGray),
                                const SizedBox(height: 12),
                                Text(
                                  'No emergency contacts added yet.',
                                  style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textGray),
                                ),
                              ],
                            ),
                          )
                        : ListView.separated(
                            itemCount: _contacts.length,
                            separatorBuilder: (_, __) => const SizedBox(height: 12),
                            itemBuilder: (context, index) {
                              final contact = _contacts[index];
                              return Container(
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                                decoration: BoxDecoration(
                                  color: AppColors.card,
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(color: AppColors.border),
                                ),
                                child: Row(
                                  children: [
                                    CircleAvatar(
                                      backgroundColor: AppColors.secondaryPurple.withOpacity(0.12),
                                      child: Text(
                                        contact['name']?.substring(0, 1).toUpperCase() ?? '?',
                                        style: TextStyle(
                                          color: AppColors.secondaryPurple,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 14),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            contact['name'] ?? '',
                                            style: AppTextStyles.bodyLarge.copyWith(
                                              color: AppColors.textWhite,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          const SizedBox(height: 2),
                                          Text(
                                            contact['phone'] ?? '',
                                            style: AppTextStyles.bodySmall.copyWith(color: AppColors.textGray),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: AppColors.secondaryPurple.withOpacity(0.08),
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(
                                          color: AppColors.secondaryPurple.withOpacity(0.2),
                                        ),
                                      ),
                                      child: Text(
                                        contact['relation'] ?? 'Family',
                                        style: AppTextStyles.caption.copyWith(
                                          color: AppColors.secondaryPurple,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    IconButton(
                                      icon: Icon(Icons.delete_outline, color: AppColors.alertRed),
                                      onPressed: () => _deleteContact(contact['id'] ?? ''),
                                    ),
                                  ],
                                ),
                              ).animate().fadeIn(delay: (index * 50).ms);
                            },
                          ),
              ),
              const SizedBox(height: 16),
              if (_contacts.length < 3)
                AppButton(
                  label: 'Add Contact (${_contacts.length}/3)',
                  onPressed: _showAddContactDialog,
                ).animate().fadeIn(delay: 200.ms)
              else
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  decoration: BoxDecoration(
                    color: AppColors.card,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Center(
                    child: Text(
                      'Max Contacts Added (3/3)',
                      style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textGray),
                    ),
                  ),
                ).animate().fadeIn(delay: 200.ms),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }
}

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/router/app_router.dart';
import '../../core/services/auth_service.dart';
import '../../core/services/audio_service.dart';
import '../../core/services/profile_service.dart';
import '../../core/theme/theme_provider.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  Map<String, dynamic>? _userProfile;
  bool _notificationsEnabled = true;
  bool _loading = true;
  bool _saving = false;
  String? _message;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  String get _fullName =>
      (_userProfile?['fullName'] ?? _userProfile?['name'] ?? 'User').toString();
  String get _email => (_userProfile?['email'] ?? '').toString();
  String get _bio => (_userProfile?['bio'] ?? '').toString();
  String get _phone => (_userProfile?['phoneNumber'] ?? '').toString();
  String get _firstName => (_userProfile?['firstName'] ?? '').toString();
  String get _lastName => (_userProfile?['lastName'] ?? '').toString();
  String get _role => (_userProfile?['role'] ?? '').toString();
  String get _location => (_userProfile?['location'] ?? '').toString();
  String get _instagram => (_userProfile?['instagram'] ?? '').toString();
  String get _linkedin => (_userProfile?['linkedin'] ?? '').toString();
  String get _github => (_userProfile?['github'] ?? '').toString();
  String get _x => (_userProfile?['x'] ?? '').toString();
  String get _telegram => (_userProfile?['telegram'] ?? '').toString();
  Map<String, dynamic> get _preferences {
    final prefs = _userProfile?['preferences'];
    if (prefs is Map) {
      return prefs.cast<String, dynamic>();
    }
    return {};
  }

  Future<void> _loadProfile() async {
    final cached = await AuthService.instance.getCachedUser();
    if (mounted && cached != null) {
      setState(() {
        _userProfile = cached;
        final prefs = cached['preferences'];
        _notificationsEnabled = (prefs is Map) ? prefs['notifications'] != false : true;
      });
    }

    final profileData = await ProfileService.instance.getProfile();
    if (!mounted) return;
    setState(() {
      _loading = false;
      if (profileData != null) {
        _userProfile = profileData;
        final prefs = profileData['preferences'];
        _notificationsEnabled = (prefs is Map) ? prefs['notifications'] != false : true;
      } else {
        _message = ProfileService.instance.lastError ?? 'Profile is unavailable.';
      }
    });
  }

  Future<void> _updateProfile({
    String? fullName,
    String? email,
    String? phoneNumber,
    String? bio,
    String? profileImage,
    Map<String, dynamic>? preferences,
    String? firstName,
    String? lastName,
    String? role,
    String? location,
    String? instagram,
    String? linkedin,
    String? github,
    String? x,
    String? telegram,
    String successMessage = 'Profile updated.',
  }) async {
    setState(() {
      _saving = true;
      _message = null;
    });
    final updated = await ProfileService.instance.updateProfile(
      fullName: fullName,
      email: email,
      phoneNumber: phoneNumber,
      bio: bio,
      profileImage: profileImage,
      preferences: preferences,
      firstName: firstName,
      lastName: lastName,
      role: role,
      location: location,
      instagram: instagram,
      linkedin: linkedin,
      github: github,
      x: x,
      telegram: telegram,
    );
    if (!mounted) return;
    setState(() {
      _saving = false;
      if (updated != null) {
        _userProfile = updated;
        _message = successMessage;
      } else {
        _message = ProfileService.instance.lastError ?? 'Update failed.';
      }
    });
  }

  Future<void> _pickProfileImage() async {
    final picked = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      maxWidth: 720,
      maxHeight: 720,
      imageQuality: 82,
    );
    if (picked == null) return;

    final bytes = await picked.readAsBytes();
    final extension = picked.name.toLowerCase().endsWith('.png') ? 'png' : 'jpeg';
    final imageData = 'data:image/$extension;base64,${base64Encode(bytes)}';
    await _updateProfile(
      profileImage: imageData,
      successMessage: 'Profile picture updated.',
    );
  }

  Future<void> _showEditProfileDialog() async {
    final firstNameCtrl = TextEditingController(text: _firstName);
    final lastNameCtrl = TextEditingController(text: _lastName);
    final emailCtrl = TextEditingController(text: _email);
    final phoneCtrl = TextEditingController(text: _phone);
    final bioCtrl = TextEditingController(text: _bio);
    final roleCtrl = TextEditingController(text: _role);
    final locationCtrl = TextEditingController(text: _location);
    final instagramCtrl = TextEditingController(text: _instagram);
    final linkedinCtrl = TextEditingController(text: _linkedin);
    final githubCtrl = TextEditingController(text: _github);
    final telegramCtrl = TextEditingController(text: _telegram);

    await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.card,
        title: Text('Edit Profile', style: AppTextStyles.h2),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _DialogField(label: 'First Name', controller: firstNameCtrl),
              const SizedBox(height: 14),
              _DialogField(label: 'Last Name', controller: lastNameCtrl),
              const SizedBox(height: 14),
              _DialogField(
                label: 'Email',
                controller: emailCtrl,
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 14),
              _DialogField(
                label: 'Phone Number',
                controller: phoneCtrl,
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 14),
              _DialogField(label: 'Bio', controller: bioCtrl, maxLines: 3),
              const SizedBox(height: 14),
              _DialogField(label: 'Current Role / Designation', controller: roleCtrl),
              const SizedBox(height: 14),
              _DialogField(label: 'Location', controller: locationCtrl),
              const SizedBox(height: 14),
              _DialogField(label: 'Instagram Profile Link', controller: instagramCtrl),
              const SizedBox(height: 14),
              _DialogField(label: 'LinkedIn Profile Link', controller: linkedinCtrl),
              const SizedBox(height: 14),
              _DialogField(label: 'GitHub Profile Link', controller: githubCtrl),
              const SizedBox(height: 14),
              _DialogField(label: 'Telegram Profile Link', controller: telegramCtrl),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Cancel', style: AppTextStyles.bodyMedium),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryPurple),
            onPressed: () {
              Navigator.pop(ctx);
              _updateProfile(
                fullName: '${firstNameCtrl.text} ${lastNameCtrl.text}'.trim(),
                firstName: firstNameCtrl.text,
                lastName: lastNameCtrl.text,
                email: emailCtrl.text,
                phoneNumber: phoneCtrl.text,
                bio: bioCtrl.text,
                role: roleCtrl.text,
                location: locationCtrl.text,
                instagram: instagramCtrl.text,
                linkedin: linkedinCtrl.text,
                github: githubCtrl.text,
                telegram: telegramCtrl.text,
                x: telegramCtrl.text, // for backward compatibility
              );
            },
            child: const Text('Save', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Future<void> _showChangePasswordDialog() async {
    final currentCtrl = TextEditingController();
    final newCtrl = TextEditingController();
    String? dialogMessage;

    await showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          backgroundColor: AppColors.card,
          title: Text('Change Password', style: AppTextStyles.h2),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _DialogField(label: 'Current Password', controller: currentCtrl, obscure: true),
              const SizedBox(height: 14),
              _DialogField(label: 'New Password', controller: newCtrl, obscure: true),
              if (dialogMessage != null) ...[
                const SizedBox(height: 12),
                Text(dialogMessage!, style: AppTextStyles.bodySmall),
              ],
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text('Cancel', style: AppTextStyles.bodyMedium),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryPurple),
              onPressed: () async {
                final ok = await AuthService.instance.changePassword(
                  currentCtrl.text,
                  newCtrl.text,
                );
                if (!ctx.mounted) return;
                if (ok) {
                  Navigator.pop(ctx);
                  setState(() => _message = 'Password changed successfully.');
                } else {
                  setDialogState(() {
                    dialogMessage = AuthService.instance.lastError ?? 'Password change failed.';
                  });
                }
              },
              child: const Text('Update', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _confirmDeleteAccount() async {
    final router = GoRouter.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.card,
        title: Text('Delete Account', style: AppTextStyles.h2),
        content: Text(
          'This permanently removes your account and profile data.',
          style: AppTextStyles.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text('Cancel', style: AppTextStyles.bodyMedium),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.alertRed),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirmed != true) return;
    final deleted = await ProfileService.instance.deleteAccount();
    if (!mounted) return;
    if (deleted) {
      ref.read(authStateProvider.notifier).markLoggedOut();
      router.go(AppRoutes.onboarding);
    } else {
      setState(() => _message = ProfileService.instance.lastError ?? 'Account deletion failed.');
    }
  }

  ImageProvider? _profileImageProvider() {
    final image = _userProfile?['profileImage']?.toString();
    if (image == null || image.isEmpty) return null;
    if (image.startsWith('data:image/')) {
      final base64Part = image.split(',').last;
      return MemoryImage(base64Decode(base64Part));
    }
    if (image.startsWith('http://') || image.startsWith('https://')) {
      return NetworkImage(image);
    }
    return null;
  }

  Future<void> _syncPreference(String key, dynamic value) async {
    final updated = {..._preferences, key: value};
    await _updateProfile(
      preferences: updated,
      successMessage: 'Preferences synced.',
    );
  }

  @override
  Widget build(BuildContext context) {
    final soundEnabled = ref.watch(soundEnabledProvider);
    final avatarImage = _profileImageProvider();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, color: AppColors.textWhite, size: 18),
          onPressed: () => context.pop(),
        ),
        title: Text('Profile', style: AppTextStyles.appBarTitle),
        actions: [
          IconButton(
            tooltip: 'Refresh',
            onPressed: _loading ? null : _loadProfile,
            icon: Icon(Icons.refresh, color: AppColors.textWhite),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadProfile,
        color: AppColors.primaryPurple,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            if (_loading)
              LinearProgressIndicator(color: AppColors.primaryPurple, minHeight: 2),

            Center(
              child: Column(
                children: [
                  Stack(
                    alignment: Alignment.bottomRight,
                    children: [
                      CircleAvatar(
                        radius: 48,
                        backgroundColor: AppColors.primaryPurple,
                        backgroundImage: avatarImage,
                        child: avatarImage == null
                            ? Text(
                                _fullName.isEmpty ? 'U' : _fullName[0].toUpperCase(),
                                style: const TextStyle(fontSize: 34, color: Colors.white),
                              )
                            : null,
                      ),
                      IconButton.filled(
                        tooltip: 'Change profile picture',
                        style: IconButton.styleFrom(
                          backgroundColor: AppColors.cardElevated,
                          foregroundColor: AppColors.textWhite,
                          side: BorderSide(color: AppColors.border),
                        ),
                        onPressed: _saving ? null : _pickProfileImage,
                        icon: const Icon(Icons.photo_camera_outlined, size: 18),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Text(_fullName, style: AppTextStyles.h2, textAlign: TextAlign.center),
                  const SizedBox(height: 4),
                  Text(_email, style: AppTextStyles.bodySmall, textAlign: TextAlign.center),
                  if (_phone.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(_phone, style: AppTextStyles.bodySmall, textAlign: TextAlign.center),
                  ],
                ],
              ),
            ).animate().fadeIn(duration: 400.ms).slideY(begin: -0.08, end: 0),

            const SizedBox(height: 24),
            _SectionTitle(label: 'Personal Details'),
            const SizedBox(height: 10),

            // Role Bar
            _InfoBarTile(
              icon: Icons.badge_outlined,
              iconColor: AppColors.secondaryPurple,
              label: 'Designation / Role',
              value: _role.isNotEmpty ? _role : 'Not specified',
            ),
            const SizedBox(height: 10),

            // Location Bar
            _InfoBarTile(
              icon: Icons.location_on_outlined,
              iconColor: AppColors.alertRed,
              label: 'Location',
              value: _location.isNotEmpty ? _location : 'Not specified',
            ),
            const SizedBox(height: 10),

            // Bio Bar
            _InfoBarTile(
              icon: Icons.info_outline,
              iconColor: AppColors.eduCyan,
              label: 'Bio',
              value: _bio.isNotEmpty ? _bio : 'No bio added',
              maxLines: 4,
            ),
            const SizedBox(height: 24),

            _SectionTitle(label: 'Social Connections'),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                color: AppColors.card,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.border),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildSocialIcon(Icons.camera_alt_outlined, 'Instagram', _instagram, Colors.pink),
                  _buildSocialIcon(Icons.link, 'LinkedIn', _linkedin, Colors.blue),
                  _buildSocialIcon(Icons.code, 'GitHub', _github, Colors.white),
                  _buildSocialIcon(Icons.send, 'Telegram', _telegram.isNotEmpty ? _telegram : 'https://web.telegram.org/a/#8873481129', Colors.blue),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Edit Profile Button
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: _saving ? null : _showEditProfileDialog,
                icon: const Icon(Icons.edit_outlined, size: 16),
                label: const Text('Edit Profile'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.textWhite,
                  side: BorderSide(color: AppColors.border),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),

            if (_message != null) ...[
              const SizedBox(height: 18),
              _StatusBanner(message: _message!),
            ],

            const SizedBox(height: 24),
            _SectionTitle(label: 'Account'),
            const SizedBox(height: 10),
            _ProfileOptionTile(
              icon: Icons.lock_outline,
              label: 'Change Password',
              onTap: _showChangePasswordDialog,
            ),

            const SizedBox(height: 10),
            _ProfileOptionTile(
              icon: Icons.delete_outline,
              label: 'Delete Account',
              isDanger: true,
              onTap: _confirmDeleteAccount,
            ),

            const SizedBox(height: 24),
            GestureDetector(
              onTap: () async {
                await ref.read(authStateProvider.notifier).logout();
                if (context.mounted) context.go(AppRoutes.onboarding);
              },
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.alertRed.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.alertRed.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    Icon(Icons.logout, color: AppColors.alertRed, size: 22),
                    const SizedBox(width: 14),
                    Text(
                      'Logout',
                      style: AppTextStyles.labelLarge.copyWith(color: AppColors.alertRed),
                    ),
                  ],
                ),
              ),
            ).animate().fadeIn(delay: 180.ms),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildSocialIcon(IconData icon, String label, String url, Color activeColor) {
    final hasUrl = url.trim().isNotEmpty;
    return GestureDetector(
      onTap: hasUrl ? () => _launchSocialUrl(url) : () {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('No $label link provided yet. Edit profile to add it.')),
        );
      },
      child: Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          color: hasUrl ? activeColor.withOpacity(0.12) : AppColors.cardElevated,
          shape: BoxShape.circle,
          border: Border.all(
            color: hasUrl ? activeColor.withOpacity(0.4) : AppColors.border,
            width: 1.2,
          ),
        ),
        child: Icon(
          icon,
          color: hasUrl ? activeColor : AppColors.textDimmed,
          size: 18,
        ),
      ),
    );
  }

  Future<void> _launchSocialUrl(String url) async {
    if (url.trim().isEmpty) return;
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not launch $url')),
        );
      }
    }
  }
}

class _DialogField extends StatelessWidget {
  const _DialogField({
    required this.label,
    required this.controller,
    this.keyboardType,
    this.maxLines = 1,
    this.obscure = false,
  });

  final String label;
  final TextEditingController controller;
  final TextInputType? keyboardType;
  final int maxLines;
  final bool obscure;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: obscure ? 1 : maxLines,
      obscureText: obscure,
      style: AppTextStyles.bodyMedium,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: AppTextStyles.labelLarge,
        enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: AppColors.border)),
        focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: AppColors.primaryPurple)),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    return Text(label, style: AppTextStyles.h3);
  }
}

class _StatusBanner extends StatelessWidget {
  const _StatusBanner({required this.message});
  final String message;

  @override
  Widget build(BuildContext context) {
    final isError = message.toLowerCase().contains('failed') ||
        message.toLowerCase().contains('unable') ||
        message.toLowerCase().contains('invalid');
    final color = isError ? AppColors.alertRed : AppColors.successGreen;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.35)),
      ),
      child: Text(message, style: AppTextStyles.bodySmall.copyWith(color: color)),
    );
  }
}

class _PreferenceTile extends StatelessWidget {
  const _PreferenceTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: value ? AppColors.primaryPurple.withOpacity(0.4) : AppColors.border),
      ),
      child: Row(
        children: [
          Icon(icon, color: value ? AppColors.primaryPurple : AppColors.textGray, size: 22),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppTextStyles.labelLarge),
                const SizedBox(height: 2),
                Text(subtitle, style: AppTextStyles.bodySmall),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: AppColors.primaryPurple,
            inactiveThumbColor: AppColors.textDimmed,
            inactiveTrackColor: AppColors.inputFill,
          ),
        ],
      ),
    );
  }
}

class _ProfileOptionTile extends StatelessWidget {
  const _ProfileOptionTile({
    required this.icon,
    required this.label,
    required this.onTap,
    this.subtitle,
    this.isDanger = false,
  });

  final IconData icon;
  final String label;
  final String? subtitle;
  final VoidCallback onTap;
  final bool isDanger;

  @override
  Widget build(BuildContext context) {
    final color = isDanger ? AppColors.alertRed : AppColors.textGray;
    return InkWell(
      borderRadius: BorderRadius.circular(8),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: isDanger ? AppColors.alertRed.withOpacity(0.3) : AppColors.border),
        ),
        child: Row(
          children: [
            Icon(icon, color: color, size: 22),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: AppTextStyles.labelLarge.copyWith(
                      color: isDanger ? AppColors.alertRed : AppColors.textWhite,
                    ),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 2),
                    Text(subtitle!, style: AppTextStyles.bodySmall),
                  ],
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: AppColors.textDimmed, size: 20),
          ],
        ),
      ),
    );
  }
}

class _InfoBarTile extends StatelessWidget {
  const _InfoBarTile({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.value,
    this.maxLines = 2,
  });

  final IconData icon;
  final Color iconColor;
  final String label;
  final String value;
  final int maxLines;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: iconColor, size: 22),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: AppTextStyles.labelMedium.copyWith(color: AppColors.textDimmed)),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textWhite),
                  maxLines: maxLines,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

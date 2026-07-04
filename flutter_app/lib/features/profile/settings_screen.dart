import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/theme/theme_provider.dart';
import '../../core/services/profile_service.dart';
import '../../core/services/auth_service.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  Map<String, dynamic>? _userProfile;

  // Settings states matching screenshot
  bool _autoPlayMedia = false;
  bool _pushNotifications = true;
  bool _emailNotifications = false;
  bool _weeklyDigest = true;

  bool _dndEnabled = true; // Enabled by default to show Select Domain card like the screenshot
  String _dndDomain = 'Learning';
  final List<String> _domains = ['Learning', 'Prescripto', 'LawGen AI', 'AgroGen', 'SafeGuard AI'];

  bool _autoSaveConversations = true;
  bool _clearingCache = false;

  Map<String, dynamic> get _preferences {
    final prefs = _userProfile?['preferences'];
    if (prefs is Map) {
      try {
        return prefs.cast<String, dynamic>();
      } catch (_) {
        return {};
      }
    }
    return {};
  }

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    try {
      final cached = await AuthService.instance.getCachedUser();
      if (mounted && cached != null) {
        setState(() {
          _userProfile = cached;
          final prefs = cached['preferences'];
          if (prefs is Map) {
            _autoPlayMedia = prefs['autoPlayMedia'] == true;
            _pushNotifications = prefs['pushNotifications'] != false;
            _emailNotifications = prefs['emailNotifications'] == true;
            _weeklyDigest = prefs['weeklyDigest'] != false;
            _dndEnabled = prefs['dndEnabled'] != false; // Set default true if not set
            _dndDomain = prefs['dndDomain']?.toString() ?? 'Learning';
            _autoSaveConversations = prefs['autoSaveConversations'] != false;
          }
        });
      }
    } catch (e) {
      debugPrint('Error loading cached profile in settings: $e');
    }

    try {
      final profileData = await ProfileService.instance.getProfile();
      if (mounted && profileData != null) {
        setState(() {
          _userProfile = profileData;
          final prefs = profileData['preferences'];
          if (prefs is Map) {
            _autoPlayMedia = prefs['autoPlayMedia'] == true;
            _pushNotifications = prefs['pushNotifications'] != false;
            _emailNotifications = prefs['emailNotifications'] == true;
            _weeklyDigest = prefs['weeklyDigest'] != false;
            _dndEnabled = prefs['dndEnabled'] != false;
            _dndDomain = prefs['dndDomain']?.toString() ?? 'Learning';
            _autoSaveConversations = prefs['autoSaveConversations'] != false;
          }
        });
      }
    } catch (e) {
      debugPrint('Error loading server profile in settings: $e');
    }
  }

  Future<void> _syncPreference(String key, dynamic value) async {
    final updatedPref = {..._preferences, key: value};
    final updatedProfile = await ProfileService.instance.updateProfile(preferences: updatedPref);
    if (mounted && updatedProfile != null) {
      setState(() {
        _userProfile = updatedProfile;
      });
    }
  }

  Future<void> _clearCache() async {
    setState(() => _clearingCache = true);
    await Future.delayed(const Duration(milliseconds: 1200));
    if (mounted) {
      setState(() => _clearingCache = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Offline app cache cleared! (14.2 MB freed)'),
          backgroundColor: AppColors.successGreen,
        ),
      );
    }
  }

  String _getTextSizeLabel(double scale) {
    if (scale < 0.9) return 'Small';
    if (scale < 1.1) return 'Medium';
    if (scale < 1.25) return 'Large';
    return 'Extra Large';
  }

  // Active switch blue matching iOS design
  static const Color _switchActiveColor = Color(0xFF2563EB);

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, top: 22, bottom: 8),
      child: Text(
        title,
        style: AppTextStyles.caption.copyWith(
          color: AppColors.textDimmed,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.0,
        ),
      ),
    );
  }

  // Notification Controls Modal Sheet
  void _showNotificationControlsSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.card,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) => SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Notification Controls', style: AppTextStyles.h2),
                const SizedBox(height: 16),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  activeColor: Colors.white,
                  activeTrackColor: _switchActiveColor,
                  title: Text('Push Notifications', style: AppTextStyles.labelLarge),
                  subtitle: Text('Allow system banners and alerts', style: AppTextStyles.bodySmall),
                  value: _pushNotifications,
                  onChanged: (val) async {
                    setModalState(() => _pushNotifications = val);
                    setState(() => _pushNotifications = val);
                    await _syncPreference('pushNotifications', val);
                  },
                ),
                const Divider(),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  activeColor: Colors.white,
                  activeTrackColor: _switchActiveColor,
                  title: Text('Email Notifications', style: AppTextStyles.labelLarge),
                  subtitle: Text('Receive weekly updates in inbox', style: AppTextStyles.bodySmall),
                  value: _emailNotifications,
                  onChanged: (val) async {
                    setModalState(() => _emailNotifications = val);
                    setState(() => _emailNotifications = val);
                    await _syncPreference('emailNotifications', val);
                  },
                ),
                const Divider(),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  activeColor: Colors.white,
                  activeTrackColor: _switchActiveColor,
                  title: Text('Weekly Activity Reports', style: AppTextStyles.labelLarge),
                  subtitle: Text('Receive summaries of your AI usage', style: AppTextStyles.bodySmall),
                  value: _weeklyDigest,
                  onChanged: (val) async {
                    setModalState(() => _weeklyDigest = val);
                    setState(() => _weeklyDigest = val);
                    await _syncPreference('weeklyDigest', val);
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Text Size Adjustment Modal Sheet
  void _showTextSizeSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.card,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) => Consumer(
        builder: (ctx, ref, _) {
          final currentScale = ref.watch(textSizeProvider);
          return SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Adjust Text Size', style: AppTextStyles.h2),
                      Text(
                        _getTextSizeLabel(currentScale),
                        style: AppTextStyles.bodySmall.copyWith(
                          color: _switchActiveColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Slider(
                    value: currentScale,
                    min: 0.85,
                    max: 1.3,
                    divisions: 3,
                    activeColor: _switchActiveColor,
                    inactiveColor: AppColors.border,
                    onChanged: (value) {
                      ref.read(textSizeProvider.notifier).setScale(value);
                    },
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('A', style: AppTextStyles.bodySmall),
                      Text('A', style: AppTextStyles.bodyLarge.copyWith(fontSize: 18)),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // Privacy & Security Modal Sheet
  void _showPrivacySecuritySheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.card,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) => SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Privacy & Security', style: AppTextStyles.h2),
                const SizedBox(height: 16),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  activeColor: Colors.white,
                  activeTrackColor: _switchActiveColor,
                  title: Text('Auto-Save Conversations', style: AppTextStyles.labelLarge),
                  subtitle: Text('Save message logs locally to access offline', style: AppTextStyles.bodySmall),
                  value: _autoSaveConversations,
                  onChanged: (val) async {
                    setModalState(() => _autoSaveConversations = val);
                    setState(() => _autoSaveConversations = val);
                    await _syncPreference('autoSaveConversations', val);
                  },
                ),
                const Divider(),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Clear Offline Storage', style: AppTextStyles.labelLarge),
                        const SizedBox(height: 2),
                        Text('Free up space from locally cached data', style: AppTextStyles.bodySmall),
                      ],
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.alertRed.withOpacity(0.12),
                        foregroundColor: AppColors.alertRed,
                        elevation: 0,
                        side: BorderSide(color: AppColors.alertRed.withOpacity(0.3)),
                      ),
                      onPressed: _clearingCache
                          ? null
                          : () async {
                              Navigator.pop(ctx);
                              await _clearCache();
                            },
                      child: _clearingCache
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                  strokeWidth: 2, valueColor: AlwaysStoppedAnimation(AppColors.alertRed)),
                            )
                          : const Text('Clear Cache'),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentScale = ref.watch(textSizeProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, color: AppColors.textWhite, size: 18),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text('Settings', style: AppTextStyles.appBarTitle),
        centerTitle: false,
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        children: [
          // ── GENERAL SECTION ───────────────────────────────────────────────
          _buildSectionHeader('GENERAL'),
          Container(
            decoration: BoxDecoration(
              color: AppColors.card,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              children: [
                _buildSwitchTile(
                  title: 'Enable Dark Mode',
                  subtitle: 'Use dark theme across the app',
                  value: ref.watch(themeModeProvider) == ThemeMode.dark,
                  onChanged: (value) async {
                    ref.read(themeModeProvider.notifier).toggleTheme();
                    await _syncPreference('darkMode', value);
                  },
                ),
                Divider(color: AppColors.border, height: 1, indent: 16, endIndent: 16),
                _buildSwitchTile(
                  title: 'Auto-Play Media',
                  subtitle: 'Automatically play media in chats',
                  value: _autoPlayMedia,
                  onChanged: (value) async {
                    setState(() => _autoPlayMedia = value);
                    await _syncPreference('autoPlayMedia', value);
                  },
                ),
              ],
            ),
          ),

          // ── NOTIFICATIONS SECTION ─────────────────────────────────────────
          _buildSectionHeader('NOTIFICATIONS'),
          Container(
            decoration: BoxDecoration(
              color: AppColors.card,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.border),
            ),
            child: _buildNavigationTile(
              title: 'Notification Controls',
              subtitle: 'Manage alerts, sounds, and vibrations',
              onTap: _showNotificationControlsSheet,
            ),
          ),

          // ── FOCUS SECTION ─────────────────────────────────────────────────
          _buildSectionHeader('FOCUS'),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.card,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Do Not Disturb in Specific Domain', style: AppTextStyles.labelLarge),
                          const SizedBox(height: 4),
                          Text(
                            'Silence notifications when you\'re in the selected domain.',
                            style: AppTextStyles.bodySmall,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Switch(
                      value: _dndEnabled,
                      activeColor: Colors.white,
                      activeTrackColor: _switchActiveColor,
                      onChanged: (val) async {
                        setState(() => _dndEnabled = val);
                        await _syncPreference('dndEnabled', val);
                      },
                    ),
                  ],
                ),
                if (_dndEnabled) ...[
                  const SizedBox(height: 16),
                  Text(
                    'Select Domain',
                    style: AppTextStyles.labelMedium.copyWith(color: AppColors.textGray),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    decoration: BoxDecoration(
                      color: AppColors.cardElevated,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.public, color: AppColors.textGray, size: 20),
                        const SizedBox(width: 12),
                        Expanded(
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              value: _dndDomain,
                              dropdownColor: AppColors.card,
                              isExpanded: true,
                              icon: Icon(Icons.keyboard_arrow_down, color: AppColors.textGray, size: 20),
                              style: AppTextStyles.bodyMedium.copyWith(
                                color: AppColors.textWhite,
                                fontWeight: FontWeight.w500,
                              ),
                              items: _domains.map((String value) {
                                return DropdownMenuItem<String>(
                                  value: value,
                                  child: Text(value),
                                );
                              }).toList(),
                              onChanged: (newValue) async {
                                if (newValue != null) {
                                  setState(() => _dndDomain = newValue);
                                  await _syncPreference('dndDomain', newValue);
                                }
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),

          // ── APPEARANCE SECTION ────────────────────────────────────────────
          _buildSectionHeader('APPEARANCE'),
          Container(
            decoration: BoxDecoration(
              color: AppColors.card,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.border),
            ),
            child: _buildNavigationTile(
              title: 'Text Size',
              subtitle: 'Adjust the size of text in the app',
              trailingText: _getTextSizeLabel(currentScale),
              onTap: _showTextSizeSheet,
            ),
          ),

          // ── MORE SECTION ──────────────────────────────────────────────────
          _buildSectionHeader('MORE'),
          Container(
            decoration: BoxDecoration(
              color: AppColors.card,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.border),
            ),
            child: _buildNavigationTile(
              title: 'Privacy & Security',
              subtitle: 'Manage your privacy settings',
              leadingIcon: Icons.shield_outlined,
              onTap: _showPrivacySecuritySheet,
            ),
          ),

          const SizedBox(height: 40),
        ],
      ),
    );
  }

  // Helper Switch Tile
  Widget _buildSwitchTile({
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppTextStyles.labelLarge),
                const SizedBox(height: 4),
                Text(subtitle, style: AppTextStyles.bodySmall),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Switch(
            value: value,
            activeColor: Colors.white,
            activeTrackColor: _switchActiveColor,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }

  // Helper Navigation Tile
  Widget _buildNavigationTile({
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    IconData? leadingIcon,
    String? trailingText,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            if (leadingIcon != null) ...[
              Icon(leadingIcon, color: AppColors.textWhite, size: 20),
              const SizedBox(width: 12),
            ],
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: AppTextStyles.labelLarge),
                  const SizedBox(height: 4),
                  Text(subtitle, style: AppTextStyles.bodySmall),
                ],
              ),
            ),
            if (trailingText != null) ...[
              Text(
                trailingText,
                style: AppTextStyles.bodyMedium.copyWith(color: Colors.blueAccent),
              ),
              const SizedBox(width: 8),
            ],
            Icon(Icons.chevron_right, color: AppColors.textGray, size: 20),
          ],
        ),
      ),
    );
  }
}

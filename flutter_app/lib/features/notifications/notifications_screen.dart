import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../data/mock/notifications_mock.dart';
import '../../core/services/auth_service.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';

class NotificationsScreen extends ConsumerStatefulWidget {
  const NotificationsScreen({super.key});

  @override
  ConsumerState<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends ConsumerState<NotificationsScreen> {
  Map<String, dynamic>? _userProfile;
  bool _dndEnabled = false;
  String _dndDomain = 'Learning';

  @override
  void initState() {
    super.initState();
    _loadDndSettings();
  }

  Future<void> _loadDndSettings() async {
    final cached = await AuthService.instance.getCachedUser();
    if (mounted && cached != null) {
      setState(() {
        _userProfile = cached;
        final prefs = cached['preferences'];
        if (prefs is Map) {
          _dndEnabled = prefs['dndEnabled'] == true;
          _dndDomain = prefs['dndDomain']?.toString() ?? 'Learning';
        } else {
          _dndEnabled = false;
          _dndDomain = 'Learning';
        }
      });
    }
  }

  void _markAllRead() {
    ref.read(notificationsProvider.notifier).markAllRead();
  }

  @override
  Widget build(BuildContext context) {
    final notifications = ref.watch(notificationsProvider);
    
    // Filter notifications based on DND settings
    final filteredNotifications = notifications.where((n) {
      if (_dndEnabled) {
        final normDnd = _dndDomain.toLowerCase().replaceAll(' ai', '').trim();
        final normNotif = n.domain.toLowerCase().replaceAll(' ai', '').trim();
        if (normDnd == normNotif) return false; // Silence it
      }
      return true;
    }).toList();

    final unreadCount = filteredNotifications.where((n) => !n.isRead).length;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new,
              color: AppColors.textWhite, size: 18),
          onPressed: () => context.pop(),
        ),
        title: Text('Notifications', style: AppTextStyles.appBarTitle),
        actions: [
          if (unreadCount > 0)
            TextButton(
              onPressed: _markAllRead,
              child: Text(
                'Mark all as read',
                style: AppTextStyles.labelMedium
                    .copyWith(color: AppColors.secondaryPurple),
              ),
            ),
        ],
      ),
      body: Column(
        children: [
          if (_dndEnabled)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              color: AppColors.primaryPurple.withOpacity(0.12),
              child: Row(
                children: [
                  const Icon(Icons.do_not_disturb_on, color: AppColors.secondaryPurple, size: 16),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'DND Mode Active: Silenced notifications for $_dndDomain',
                      style: AppTextStyles.bodySmall.copyWith(color: AppColors.secondaryPurple, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),
          Expanded(
            child: filteredNotifications.isEmpty
                ? Center(
                    child: Text('No notifications', style: AppTextStyles.bodyMedium),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: filteredNotifications.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (ctx, i) {
                      return GestureDetector(
                        onTap: () {
                          if (!filteredNotifications[i].isRead) {
                            ref.read(notificationsProvider.notifier).markAsRead(filteredNotifications[i].id);
                          }
                        },
                        child: _NotificationTile(notification: filteredNotifications[i]),
                      )
                          .animate()
                          .fadeIn(
                            delay: Duration(milliseconds: 60 * i),
                            duration: 350.ms,
                          )
                          .slideY(begin: 0.1, end: 0);
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class _NotificationTile extends StatelessWidget {
  final AppNotification notification;

  const _NotificationTile({required this.notification});

  Color _domainColor() {
    return switch (notification.domain) {
      'Learning' => AppColors.eduCyan,
      'Prescripto' => AppColors.medicalBlue,
      'LawGen' => AppColors.legalGold,
      'AgroGen' => AppColors.agriGreen,
      'SafeGuard' => AppColors.alertRed,
      _ => AppColors.secondaryPurple,
    };
  }

  @override
  Widget build(BuildContext context) {
    final color = _domainColor();

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: notification.isRead ? AppColors.card : AppColors.card,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: notification.isRead
              ? AppColors.border
              : color.withOpacity(0.4),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Icon
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(notification.icon,
                  style: const TextStyle(fontSize: 20)),
            ),
          ),

          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(notification.title,
                          style: AppTextStyles.labelLarge.copyWith(
                            color: notification.isRead
                                ? AppColors.textGray
                                : AppColors.textWhite,
                          )),
                    ),
                    Text(notification.time, style: AppTextStyles.caption),
                  ],
                ),
                const SizedBox(height: 4),
                Text(notification.body,
                    style: AppTextStyles.bodySmall,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis),
                const SizedBox(height: 6),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(notification.domain,
                      style: AppTextStyles.caption.copyWith(color: color)),
                ),
              ],
            ),
          ),

          // Unread dot
          if (!notification.isRead) ...[
            const SizedBox(width: 6),
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

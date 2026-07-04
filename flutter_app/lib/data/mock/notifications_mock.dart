/// Mock data for Notifications screen.
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AppNotification {
  final String id;
  final String title;
  final String body;
  final String time;
  final String domain;
  final bool isRead;
  final String icon;

  const AppNotification({
    required this.id,
    required this.title,
    required this.body,
    required this.time,
    required this.domain,
    this.isRead = false,
    required this.icon,
  });
}

// ── Mock Data ─────────────────────────────────────────────────────────────

final notificationsProvider = StateNotifierProvider<NotificationsNotifier, List<AppNotification>>((ref) {
  return NotificationsNotifier();
});

class NotificationsNotifier extends StateNotifier<List<AppNotification>> {
  NotificationsNotifier() : super(List.from(mockNotifications));

  void markAllRead() {
    state = state.map((n) => AppNotification(
      id: n.id, title: n.title, body: n.body, time: n.time,
      domain: n.domain, icon: n.icon, isRead: true,
    )).toList();
  }

  void markAsRead(String id) {
    state = state.map((n) {
      if (n.id == id) {
        return AppNotification(
          id: n.id, title: n.title, body: n.body, time: n.time,
          domain: n.domain, icon: n.icon, isRead: true,
        );
      }
      return n;
    }).toList();
  }
}

const List<AppNotification> mockNotifications = [
  AppNotification(
    id: 'n001',
    title: 'Course Reminder',
    body: 'Don\'t forget to complete AI & ML Basics — you\'re 70% done!',
    time: '2m ago',
    domain: 'Learning',
    icon: '📚',
  ),
  AppNotification(
    id: 'n002',
    title: 'Appointment Confirmed',
    body: 'Your appointment with Dr. Anjali is confirmed for tomorrow.',
    time: '18m ago',
    domain: 'Prescripto',
    icon: '🏥',
    isRead: true,
  ),
  AppNotification(
    id: 'n003',
    title: 'Weather Alert',
    body: 'Heavy rainfall expected tomorrow. Consider early harvesting.',
    time: '30m ago',
    domain: 'AgroGen',
    icon: '🌧',
  ),
  AppNotification(
    id: 'n004',
    title: 'Market Update',
    body: 'Wheat price has risen by 2.8% today. Best time to sell!',
    time: '1h ago',
    domain: 'AgroGen',
    icon: '📈',
    isRead: true,
  ),
  AppNotification(
    id: 'n005',
    title: 'New Message',
    body: 'You have a new message from the support team.',
    time: '2h ago',
    domain: 'General',
    icon: '💬',
    isRead: true,
  ),
  AppNotification(
    id: 'n006',
    title: 'Legal Case Update',
    body: 'Your employment dispute case has been reviewed. Status: Active.',
    time: '3h ago',
    domain: 'LawGen',
    icon: '⚖️',
  ),
  AppNotification(
    id: 'n007',
    title: 'SOS Test Alert',
    body: 'Your monthly SOS system test was successful.',
    time: '1d ago',
    domain: 'SafeGuard',
    icon: '🆘',
    isRead: true,
  ),
];

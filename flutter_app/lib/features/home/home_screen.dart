import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/router/app_router.dart';
import '../../../core/services/audio_service.dart';
import '../../../core/services/auth_service.dart';
import '../../../data/mock/notifications_mock.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/services/translation_service.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  int _currentIndex = 0;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey();

  final _domains = const [
    _DomainItem(
      title: 'LEARNING',
      subtitle: 'AI Learning Platform',
      imagePath: 'assets/images/learning_domain.png',
      colors: [Color(0xFF0369A1), Color(0xFF0891B2)],
      route: AppRoutes.learning,
    ),
    _DomainItem(
      title: 'PRESCRIPTO',
      subtitle: 'Healthcare Services',
      imagePath: 'assets/images/prescripto_domain.png',
      colors: [Color(0xFF1D4ED8), Color(0xFF2563EB)],
      route: AppRoutes.prescripto,
    ),
    _DomainItem(
      title: 'LAWGEN AI',
      subtitle: 'Legal Assistance',
      imagePath: 'assets/images/lawgen_domain.png',
      colors: [Color(0xFFB45309), Color(0xFFD4A017)],
      route: AppRoutes.lawgen,
    ),
    _DomainItem(
      title: 'AGROGEN',
      subtitle: 'Smart Agriculture',
      imagePath: 'assets/images/agrogen_domain.png',
      colors: [Color(0xFF15803D), Color(0xFF22C55E)],
      route: AppRoutes.agrogen,
    ),
    _DomainItem(
      title: 'SAFEGUARD AI',
      subtitle: 'Safety & Security',
      imagePath: 'assets/images/safeguard_domain.png',
      colors: [Color(0xFFB91C1C), Color(0xFFEF4444)],
      route: AppRoutes.safeguard,
    ),
  ];

  Map<String, dynamic>? _userProfile;
  bool _dndEnabled = false;
  String _dndDomain = 'Learning';

  @override
  void initState() {
    super.initState();
    _loadDnd();
  }

  Future<void> _loadDnd() async {
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

  void _onTabTap(int index) async {
    if (index == _currentIndex) return;
    await ref.read(audioServiceProvider).playMenuClick();
    setState(() => _currentIndex = index);
    switch (index) {
      case 1: context.push(AppRoutes.explore); break;
      case 2: context.push(AppRoutes.aiAssistance); break;
      case 3: context.push(AppRoutes.activity); break;
      case 4: context.push(AppRoutes.profile).then((_) => _loadDnd()); break;
    }
  }

  int get _unreadCount {
    final notifications = ref.watch(notificationsProvider);
    return notifications.where((n) {
      if (_dndEnabled) {
        final normDnd = _dndDomain.toLowerCase().replaceAll(' ai', '').trim();
        final normNotif = n.domain.toLowerCase().replaceAll(' ai', '').trim();
        if (normDnd == normNotif) return false;
      }
      return !n.isRead;
    }).length;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: AppColors.background,
      endDrawer: const _SideDrawer(),
      appBar: AppBar(
        backgroundColor: AppColors.background,
        leading: Padding(
          padding: const EdgeInsets.only(left: 16),
          child: Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              image: const DecorationImage(
                image: AssetImage('assets/images/logo.png'),
                fit: BoxFit.cover,
              ),
            ),
          ),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Team LogSagittarius', style: AppTextStyles.h3),
            Text('Company', style: AppTextStyles.caption),
          ],
        ),
        actions: [
          // Notification bell
          Stack(
            alignment: Alignment.topRight,
            children: [
              IconButton(
                icon: Icon(Icons.notifications_outlined,
                    color: AppColors.textWhite),
                onPressed: () => context.push(AppRoutes.notifications).then((_) => _loadDnd()),
              ),
              if (_unreadCount > 0)
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    width: 16,
                    height: 16,
                    decoration: BoxDecoration(
                      color: AppColors.alertRed,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        '$_unreadCount',
                        style: const TextStyle(
                            color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ),
            ],
          ),
          IconButton(
            icon: Icon(Icons.menu, color: AppColors.textWhite),
            onPressed: () => _scaffoldKey.currentState?.openEndDrawer(),
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: Column(
        children: [
          Divider(color: AppColors.border, height: 1),
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: _domains.length,
              separatorBuilder: (_, __) => const SizedBox(height: 14),
              itemBuilder: (context, i) {
                return _DomainCard(item: _domains[i])
                    .animate()
                    .fadeIn(delay: Duration(milliseconds: 80 * i), duration: 400.ms)
                    .slideY(begin: 0.15, end: 0);
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: _BottomNavBar(
        currentIndex: _currentIndex,
        onTap: _onTabTap,
      ),
    );
  }
}

// ── Domain Card ─────────────────────────────────────────────────────────────

class _DomainItem {
  final String title;
  final String subtitle;
  final String? emoji;
  final String? imagePath;
  final List<Color> colors;
  final String route;

  const _DomainItem({
    required this.title,
    required this.subtitle,
    this.emoji,
    this.imagePath,
    required this.colors,
    required this.route,
  });
}

class _DomainCard extends StatelessWidget {
  final _DomainItem item;
  const _DomainCard({required this.item});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push(item.route),
      child: Container(
        height: 88,
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            // Left colour strip
            Container(
              width: 6,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: item.colors,
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  bottomLeft: Radius.circular(16),
                ),
              ),
            ),
            const SizedBox(width: 16),

            // Icon (Full box size)
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: item.colors.last.withOpacity(0.25),
                    blurRadius: 10,
                    spreadRadius: 1,
                  ),
                ],
                image: item.imagePath != null
                    ? DecorationImage(
                        image: AssetImage(item.imagePath!),
                        fit: BoxFit.cover,
                      )
                    : null,
              ),
              child: item.imagePath == null
                  ? Center(child: Text(item.emoji ?? '', style: const TextStyle(fontSize: 24)))
                  : null,
            ),

            const SizedBox(width: 14),

            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(item.title, style: AppTextStyles.h3),
                  const SizedBox(height: 4),
                  Text(item.subtitle, style: AppTextStyles.bodySmall),
                ],
              ),
            ),

            Icon(Icons.chevron_right,
                color: AppColors.textDimmed, size: 22),
            const SizedBox(width: 12),
          ],
        ),
      ),
    );
  }
}

// ── Bottom Navigation ────────────────────────────────────────────────────────

class _BottomNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const _BottomNavBar({required this.currentIndex, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final items = [
      (icon: Icons.home_outlined, activeIcon: Icons.home, label: 'Home'),
      (icon: Icons.explore_outlined, activeIcon: Icons.explore, label: 'Explore'),
      (icon: Icons.auto_awesome_outlined, activeIcon: Icons.auto_awesome, label: 'AI'),
      (icon: Icons.insights_outlined, activeIcon: Icons.insights, label: 'Activity'),
      (icon: Icons.person_outline, activeIcon: Icons.person, label: 'Profile'),
    ];

    return Container(
      height: 76 + MediaQuery.of(context).padding.bottom,
      decoration: BoxDecoration(
        color: AppColors.card,
        border: Border(top: BorderSide(color: AppColors.border)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: List.generate(items.length, (i) {
          final isActive = i == currentIndex;
          return GestureDetector(
            onTap: () => onTap(i),
            behavior: HitTestBehavior.opaque,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              decoration: BoxDecoration(
                color: isActive
                    ? AppColors.primaryPurple.withOpacity(0.12)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    isActive ? items[i].activeIcon : items[i].icon,
                    color: isActive
                        ? AppColors.secondaryPurple
                        : AppColors.textDimmed,
                    size: 24,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    items[i].label,
                    style: AppTextStyles.labelSmall.copyWith(
                      color: isActive
                          ? AppColors.secondaryPurple
                          : AppColors.textDimmed,
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }
}

// ── Side Drawer ──────────────────────────────────────────────────────────────

class _SideDrawer extends ConsumerWidget {
  const _SideDrawer();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final items = [
      (icon: Icons.home_outlined, label: 'HOME', route: AppRoutes.home),
      (icon: Icons.mic_outlined, label: 'AI VOICE ASSISTANT', route: AppRoutes.aiAssistance),
      (icon: Icons.school_outlined, label: 'COURSES', route: AppRoutes.learning),
      (icon: Icons.info_outline, label: 'ABOUT US', route: AppRoutes.aboutUs),
      (icon: Icons.feedback_outlined, label: 'MENTOR FEEDBACK', route: AppRoutes.mentorFeedback),
      (icon: Icons.gavel_outlined, label: 'FILE AN FIR', route: AppRoutes.lawgen),
      (icon: Icons.bar_chart_outlined, label: 'Productivity Section', route: AppRoutes.activity),
      (icon: Icons.rate_review_outlined, label: 'Reviews', route: AppRoutes.reviews),
      (icon: Icons.person_outline, label: 'PROFILE', route: AppRoutes.profile),
      (icon: Icons.settings_outlined, label: 'Settings', route: AppRoutes.settings),
    ];

    return Drawer(
      backgroundColor: AppColors.card,
      width: 260,
      child: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Multi-Domain', style: AppTextStyles.h3),
                        Text('AI Assistance', style: AppTextStyles.h2.copyWith(
                          color: AppColors.secondaryPurple,
                        )),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.close, color: AppColors.textGray),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),
            Divider(color: AppColors.border),

            // Nav items
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(vertical: 8),
                itemCount: items.length,
                itemBuilder: (context, i) {
                  final isActive = i == 0;
                  return ListTile(
                    dense: true,
                    leading: Icon(
                      items[i].icon,
                      color: isActive
                          ? AppColors.secondaryPurple
                          : AppColors.textGray,
                      size: 20,
                    ),
                    title: Text(
                      items[i].label,
                      style: AppTextStyles.labelMedium.copyWith(
                        color: isActive
                            ? AppColors.textWhite
                            : AppColors.textGray,
                        fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
                      ),
                    ),
                    tileColor: isActive
                        ? AppColors.primaryPurple.withOpacity(0.12)
                        : Colors.transparent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    onTap: () {
                      Navigator.of(context).pop();
                      if (items[i].route != null) {
                        context.push(items[i].route!);
                      }
                    },
                  ).animate().fadeIn(
                        delay: Duration(milliseconds: 50 * i),
                        duration: 300.ms,
                      );
                },
              ),
            ),

            Divider(color: AppColors.border),

            // Community + Logout
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Join Our Community',
                      style: AppTextStyles.labelSmall),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      _SocialIcon(icon: Icons.public, label: 'Web', url: 'https://logsagittarius.netlify.app/'),
                      const SizedBox(width: 12),
                      _SocialIcon(icon: Icons.send, label: 'Telegram', url: 'https://web.telegram.org/a/#8873481129'),
                      const SizedBox(width: 12),
                      _SocialIcon(icon: Icons.link, label: 'LinkedIn', url: 'https://linkedin.com/in/chagantipatibhanuprakash'),
                      const SizedBox(width: 12),
                      _SocialIcon(icon: Icons.code, label: 'GitHub', url: 'https://github.com/BHANUPRAKASH302'),
                    ],
                  ),
                  const SizedBox(height: 16),
                  GestureDetector(
                    onTap: () async {
                      Navigator.of(context).pop();
                      await ref.read(authStateProvider.notifier).logout();
                      if (context.mounted) context.go(AppRoutes.onboarding);
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 10),
                      decoration: BoxDecoration(
                        color: AppColors.alertRed.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                            color: AppColors.alertRed.withOpacity(0.3)),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.logout,
                              color: AppColors.alertRed, size: 18),
                          const SizedBox(width: 8),
                          Text(
                            'Logout',
                            style: AppTextStyles.labelLarge
                                .copyWith(color: AppColors.alertRed),
                          ),
                        ],
                      ),
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

class _SocialIcon extends StatelessWidget {
  final IconData icon;
  final String label;
  final String? url;

  const _SocialIcon({required this.icon, required this.label, this.url});

  Future<void> _launchUrl() async {
    if (url != null) {
      final uri = Uri.parse(url!);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _launchUrl,
      child: Container(
        width: 34,
        height: 34,
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.border),
        ),
        child: Icon(icon, color: AppColors.textGray, size: 16),
      ),
    );
  }
}

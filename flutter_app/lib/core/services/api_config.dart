import 'dart:io';
import 'package:flutter/foundation.dart';

abstract final class ApiConfig {
  static const _configuredBackendUrl = String.fromEnvironment('BACKEND_URL');

  // ── Mac's local network IP ─────────────────────────────────────────────────
  // Update this if your IP changes. Find it with: ifconfig | grep "inet "
  // This IP is required when running on a REAL iPhone (not the simulator).
  static const _macLocalIp = '192.168.0.7';

  /// Base URL for the Node.js backend (Ollama and other features)
  static String get baseUrl {
    return candidateBaseUrls.first;
  }

  static List<String> get candidateBaseUrls {
    if (_configuredBackendUrl.isNotEmpty) return [_configuredBackendUrl];
    if (!kIsWeb && Platform.isAndroid) {
      // Android Emulator uses 10.0.2.2 to reach the host Mac/PC
      return const ['http://10.0.2.2:3001', 'http://10.0.2.2:3000'];
    }
    if (!kIsWeb && Platform.isIOS) {
      // On a real iPhone, 127.0.0.1 refers to the PHONE itself, not the Mac.
      // Put the Mac's LAN IP first so real devices connect immediately.
      // The 127.0.0.1 entries serve as fallback for the iOS Simulator.
      return [
        'http://$_macLocalIp:3001',
        'http://$_macLocalIp:3000',
        'http://127.0.0.1:3001',
        'http://127.0.0.1:3000',
      ];
    }
    // macOS / web — loopback works fine
    return const ['http://127.0.0.1:3001', 'http://127.0.0.1:3000'];
  }

  /// Direct URL to the JARVIS Flask server (bypasses Node.js proxy).
  /// Works from a real iPhone because it uses the Mac's network IP.
  static String get jarvisUrl {
    if (kIsWeb) return 'http://127.0.0.1:5002';
    if (!kIsWeb && Platform.isAndroid) return 'http://10.0.2.2:5002';
    // iOS (simulator or real device) — use Mac's local IP
    return 'http://$_macLocalIp:5002';
  }
}

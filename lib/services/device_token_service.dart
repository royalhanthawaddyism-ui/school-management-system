import 'dart:async';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class DeviceTokenService {
  DeviceTokenService._();
  static final DeviceTokenService instance = DeviceTokenService._();

  StreamSubscription<String>? _tokenRefreshSub;

  Future<void> syncTokenForCurrentUser() async {
    final supabase = Supabase.instance.client;
    final user = supabase.auth.currentUser;
    if (user == null) return;

    final messaging = FirebaseMessaging.instance;

    // 1. Notification permission တောင်းခြင်း
    final settings = await messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.denied) {
      debugPrint('Notification permission denied');
      return;
    }

    final token = await messaging.getToken();
    if (token != null && token.isNotEmpty) {
      await _upsertToken(userId: user.id, token: token);
    }

    await _tokenRefreshSub?.cancel();
    _tokenRefreshSub = messaging.onTokenRefresh.listen((newToken) async {
      final currentUser = Supabase.instance.client.auth.currentUser;
      if (currentUser != null && newToken.isNotEmpty) {
        await _upsertToken(userId: currentUser.id, token: newToken);
      }
    });
  }

  Future<void> _upsertToken({
    required String userId,
    required String token,
  }) async {
    try {
      await Supabase.instance.client.from('device_tokens').upsert(
        {
          'user_id': userId,
          'fcm_token': token,
        },
        onConflict: 'user_id,fcm_token',
      );
      debugPrint('FCM token synced for user $userId');
    } catch (e) {
      debugPrint('Failed to upsert FCM token: $e');
    }
  }
}
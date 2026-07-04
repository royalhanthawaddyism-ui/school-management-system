import 'package:flutter/material.dart';
import 'package:hism_management_system/models/profile.dart';
import 'package:hism_management_system/services/profile_service.dart';

class ProfileController extends ChangeNotifier {
  Future<List<Profile>> fetchProfiles() async {
    try {
      return await ProfileService().fetchProfiles();
    } catch (error, stackTrace) {
      debugPrint('Failed to load profiles: $error');
      debugPrintStack(stackTrace: stackTrace);
      return [];
    }
  }

  Future<void> updateProfile({
    required String id,
    required String email,
    required String password,
    required String role,
  }) {
    return ProfileService().updateProfile(
      id: id,
      email: email,
      password: password,
      role: role,
    );
  }

  Future<void> deleteProfile(String id) async {
    try {
      await ProfileService().deleteProfile(id);
    } catch (error, stackTrace) {
      debugPrint('Failed to delete profile: $error');
      debugPrintStack(stackTrace: stackTrace);
      rethrow;
    }
  }
}

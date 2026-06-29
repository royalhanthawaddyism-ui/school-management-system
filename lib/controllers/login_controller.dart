import 'package:hism_management_system/services/supabase_service.dart';

class LoginController {
  final SupabaseService _service = SupabaseService();

  Future<void> signIn(String email, String password) async {
    await _service.signIn(email, password);
  }
}

import 'package:hism_management_system/services/supabase_service.dart';

class LoginController {
  final SupabaseService _service = SupabaseService();

  Future<Map<String, dynamic>?> signIn(String email, String password) async {
    return _service.signIn(email, password);
  }
}

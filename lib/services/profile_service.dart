import 'package:supabase_flutter/supabase_flutter.dart';

class ProfileService {
  final SupabaseClient _client = Supabase.instance.client;

  // Mengambil profil pengguna yang sedang login
  Future<Map<String, dynamic>?> getMyProfile() async {
    final user = _client.auth.currentUser;

    if (user == null) {
      return null;
    }

    final data = await _client
        .from('profiles')
        .select('id, email, name, role')
        .eq('id', user.id)
        .maybeSingle();

    return data;
  }
}

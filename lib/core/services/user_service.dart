import 'package:supabase_flutter/supabase_flutter.dart';

Future<void> ensureUserProfile() async {
  final user = Supabase.instance.client.auth.currentUser;
  if (user == null) return;

  final profiles = await Supabase.instance.client
      .from('users')
      .select()
      .eq('auth_user_id', user.id);

  if (profiles.isEmpty) {
    await Supabase.instance.client.from('users').insert({
      'auth_user_id': user.id,
      'email': user.email,
      'display_name': user.userMetadata?['full_name'] ?? 'Anonymous',
      'role': 'user',
    });
  }
}

Future<bool> isAdmin() async {
  final user = Supabase.instance.client.auth.currentUser;
  if (user == null) return false;

  try {
    final isAdmin = await Supabase.instance.client
        .from('admins')
        .select()
        .eq('auth_user_id', user.id) // phải lấy user.id
        .maybeSingle();
    print('Checking admin: user.id=${user.id}, foundRow=$isAdmin');
    return isAdmin != null;
  } catch (e) {
    print('Error querying admins table: $e');
    return false;
  }
}
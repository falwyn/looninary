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
  print('Current user: ${user?.id}');
  if (user == null) return false;

  final userProfile = await Supabase.instance.client
      .from('users')
      .select()
      .eq('auth_user_id', user.id)
      .maybeSingle();
  print('User profile: $userProfile');

  if (userProfile == null) return false;

  final isAdmin = await Supabase.instance.client
      .from('admin')
      .select()
      .eq('user_id', userProfile['id'])
      .maybeSingle();
  print('Admin row: $isAdmin');

  return isAdmin != null;
}
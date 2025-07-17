import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:provider/provider.dart';

import 'package:looninary/core/services/auth_service.dart';
import 'package:looninary/core/utils/language_provider.dart';
import 'package:looninary/features/auth/views/login_screen.dart';
import 'package:looninary/features/auth/views/register_screen.dart';
import 'package:looninary/features/auth/views/forgot_password_screen.dart';
import 'package:looninary/features/home/views/home_page.dart';
import 'package:looninary/features/admin/views/admin_home_page.dart'; // Đảm bảo import đúng file
import 'package:looninary/core/services/user_service.dart'; // Thêm để dùng isAdmin

class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  final AuthService _authService = AuthService();

  AuthScreen _currentScreen = AuthScreen.login;
  bool? _isAdmin;
  String? _lastCheckedUserId;

  @override
  void initState() {
    super.initState();
    _restoreSession();
  }

  Future<void> _restoreSession() async {
    if (!kIsWeb) {
      await _authService.restoreSession();
    }
  }

  Future<void> _checkAdmin(String userId) async {
    final admin = await isAdmin();
    if (mounted) setState(() {
      _isAdmin = admin;
      _lastCheckedUserId = userId;
    });
  }

  void _showLogin() {
    setState(() {
      _currentScreen = AuthScreen.login;
    });
  }

  void _showRegister() {
    setState(() {
      _currentScreen = AuthScreen.register;
    });
  }

  void _showForgotPassword() {
    setState(() {
      _currentScreen = AuthScreen.forgotPassword;
    });
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<AuthState>(
      stream: Supabase.instance.client.auth.onAuthStateChange,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final AuthState? authState = snapshot.data;
        final lang = Provider.of<LanguageProvider>(context).language;
        final user = Supabase.instance.client.auth.currentUser;

        if (authState != null && authState.session != null && user != null) {
          if (_lastCheckedUserId != user.id) {
            _isAdmin = null;
            _checkAdmin(user.id);
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }
          if (_isAdmin == true) {
            return AdminHomePage(initialLanguage: lang);
          } else if (_isAdmin == false) {
            return HomePage(initialLanguage: lang);
          } else {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }
        } else {
          switch (_currentScreen) {
            case AuthScreen.login:
              return LoginScreen(
                onShowRegister: _showRegister,
                onShowForgotPassword: _showForgotPassword,
              );
            case AuthScreen.register:
              return RegisterScreen(
                onShowLogin: _showLogin,
              );
            case AuthScreen.forgotPassword:
              return ForgotPasswordScreen(
                onShowLogin: _showLogin,
              );
          }
        }
      },
    );
  }
}

enum AuthScreen { login, register, forgotPassword }
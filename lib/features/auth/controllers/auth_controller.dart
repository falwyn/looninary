import 'package:flutter/material.dart';
import 'package:looninary/core/services/auth_service.dart';
import 'package:looninary/core/utils/logger.dart';
import 'package:looninary/core/widgets/app_snack_bar.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthController {
  final AuthService _authService = AuthService();

  Future<void> signUp(
    BuildContext context,
    String email,
    String password,
  ) async {
    logger.i("Attempting to sign up user with email: $email");

    try {
      final user = await _authService.signUp(email, password);

      // since the await up there create an async gap, user might navigate away in the sign up process
      // after the await completes, we have to check the widget which provided the BuildContext still in the widget tree, in case it not mounted, we won't process since using 'context' would result in an error
      if (!context.mounted) return;

      if (user != null) {
        logger.i("Sign up successfully for user with email: $email");
        showAppSnackBar(
          context,
          "Sign up successfully! Please check your email for verification",
          SnackBarType.success,
        );
      }
    } on AuthException catch (e) {
      logger.e(
        "Sign up failed for user with email: $email. Error: ${e.message}",
      );
      if (!context.mounted) return;
      showAppSnackBar(context, e.message, SnackBarType.failure);
    } catch (e) {
      logger.e("Unexpected error during sign up: $e");
      if (!context.mounted) return;
      showAppSnackBar(
        context,
        "Unexpected error during sign up, please try again.",
        SnackBarType.failure,
      );
    }
  }

  Future<void> logIn(
    BuildContext context,
    String email,
    String password,
  ) async {
    logger.i("Attempting log in user with email: $email");
    try {
      final user = await _authService.logIn(email, password);

      if (!context.mounted) return;

      if (user != null) {
        logger.i("Log in successfully for user with email: $email");
        showAppSnackBar(context, "Log in successfully", SnackBarType.success);
      }
    } on AuthException catch (e) {
      logger.e("Log in failed for user with email: $email, error: ${e.message}");
      showAppSnackBar(context, e.message, SnackBarType.failure);
    } catch (e) {
      logger.e("Unexpected error during login: $e");
      showAppSnackBar(context, "Log in failed, please try again", SnackBarType.failure);
    }
  }
}

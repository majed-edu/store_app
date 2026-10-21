import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:store_app/providers/auth_provider.dart';
import 'package:store_app/screens/auth/login_page.dart';
import 'package:store_app/screens/auth/splash_page.dart';
import 'package:store_app/screens/customer/customer_shell.dart';
import 'package:store_app/screens/merchant/merchant_shell.dart';

/// Decides what to show first: splash, login, or the app for this user's role.
class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    if (auth.isRestoring) return const SplashPage();
    if (!auth.isLoggedIn) return const LoginPage();

    // The key rebuilds the shell from scratch when a different user logs in.
    final key = ValueKey(auth.user!.id);
    return auth.isMerchant ? MerchantShell(key: key) : CustomerShell(key: key);
  }
}

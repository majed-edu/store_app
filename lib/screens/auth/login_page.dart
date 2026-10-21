import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:store_app/core/routes.dart';
import 'package:store_app/core/validators.dart';
import 'package:store_app/providers/auth_provider.dart';
import 'package:store_app/theme/app_theme.dart';
import 'package:store_app/widgets/brand_mark.dart';
import 'package:store_app/widgets/custom_button.dart';
import 'package:store_app/widgets/custom_text_field.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _username = TextEditingController();
  final _password = TextEditingController();

  bool _obscure = true;
  bool _loading = false;
  String? _error;

  @override
  void dispose() {
    _username.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      await context.read<AuthProvider>().login(
        username: _username.text,
        password: _password.text,
      );
    } on AuthException catch (e) {
      if (mounted) setState(() => _error = e.message);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 440),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Align(
                      alignment: Alignment.centerLeft,
                      child: BrandMark(),
                    ),
                    const SizedBox(height: 28),
                    Text('Welcome back', style: AppText.display(34)),
                    const SizedBox(height: 8),
                    const Text(
                      'Log in to see what is new today.',
                      style: TextStyle(color: AppColors.inkSoft, fontSize: 16),
                    ),
                    const SizedBox(height: 28),
                    CustomTextField(
                      label: 'Username',
                      controller: _username,
                      prefixIcon: Icons.person_outline,
                      textInputAction: TextInputAction.next,
                      autofillHints: const [AutofillHints.username],
                      validator: (v) => Validators.requiredText(
                        v,
                        message: 'Enter your username',
                      ),
                    ),
                    const SizedBox(height: 14),
                    CustomTextField(
                      label: 'Password',
                      controller: _password,
                      obscureText: _obscure,
                      prefixIcon: Icons.lock_outline,
                      textInputAction: TextInputAction.done,
                      autofillHints: const [AutofillHints.password],
                      onSubmitted: (_) => _submit(),
                      validator: (v) => Validators.requiredText(
                        v,
                        message: 'Enter your password',
                      ),
                      suffixIcon: IconButton(
                        tooltip: _obscure ? 'Show password' : 'Hide password',
                        onPressed: () => setState(() => _obscure = !_obscure),
                        icon: Icon(
                          _obscure
                              ? Icons.visibility_outlined
                              : Icons.visibility_off_outlined,
                        ),
                      ),
                    ),
                    if (_error != null) ...[
                      const SizedBox(height: 14),
                      Text(
                        _error!,
                        style: const TextStyle(
                          color: AppColors.danger,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                    const SizedBox(height: 22),
                    CustomButton(
                      text: 'Log in',
                      onTap: _submit,
                      isLoading: _loading,
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          'New here?',
                          style: TextStyle(color: AppColors.inkSoft),
                        ),
                        TextButton(
                          onPressed: () =>
                              Navigator.pushNamed(context, Routes.register),
                          child: const Text(
                            'Create an account',
                            style: TextStyle(fontWeight: FontWeight.w700),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

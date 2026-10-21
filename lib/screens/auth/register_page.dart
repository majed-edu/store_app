import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:store_app/core/validators.dart';
import 'package:store_app/models/user_model.dart';
import 'package:store_app/providers/auth_provider.dart';
import 'package:store_app/theme/app_theme.dart';
import 'package:store_app/widgets/custom_button.dart';
import 'package:store_app/widgets/custom_text_field.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _firstName = TextEditingController();
  final _lastName = TextEditingController();
  final _email = TextEditingController();
  final _username = TextEditingController();
  final _phone = TextEditingController();
  final _password = TextEditingController();
  final _confirm = TextEditingController();

  UserRole _role = UserRole.customer;
  bool _loading = false;
  String? _error;

  @override
  void dispose() {
    for (final c in [_firstName, _lastName, _email, _username, _phone, _password, _confirm]) {
      c.dispose();
    }
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
      await context.read<AuthProvider>().register(
            firstName: _firstName.text,
            lastName: _lastName.text,
            email: _email.text,
            username: _username.text,
            phone: _phone.text,
            password: _password.text,
            role: _role,
          );
      // The gate already switched to the app; close this page on top of it.
      if (mounted) Navigator.popUntil(context, (route) => route.isFirst);
    } on AuthException catch (e) {
      if (mounted) setState(() => _error = e.message);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create account')),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 440),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text('I want to',
                        style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: _RoleOption(
                            icon: Icons.shopping_bag_outlined,
                            title: 'Shop',
                            subtitle: 'Browse and order',
                            selected: _role == UserRole.customer,
                            onTap: () => setState(() => _role = UserRole.customer),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _RoleOption(
                            icon: Icons.storefront_outlined,
                            title: 'Sell',
                            subtitle: 'Manage products',
                            selected: _role == UserRole.merchant,
                            onTap: () => setState(() => _role = UserRole.merchant),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        Expanded(
                          child: CustomTextField(
                            label: 'First name',
                            controller: _firstName,
                            textInputAction: TextInputAction.next,
                            validator: (v) => Validators.requiredText(v, message: 'Required'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: CustomTextField(
                            label: 'Last name',
                            controller: _lastName,
                            textInputAction: TextInputAction.next,
                            validator: (v) => Validators.requiredText(v, message: 'Required'),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    CustomTextField(
                      label: 'Email',
                      controller: _email,
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                      validator: Validators.email,
                    ),
                    const SizedBox(height: 14),
                    CustomTextField(
                      label: 'Username',
                      controller: _username,
                      textInputAction: TextInputAction.next,
                      validator: Validators.username,
                    ),
                    const SizedBox(height: 14),
                    CustomTextField(
                      label: 'Phone',
                      controller: _phone,
                      keyboardType: TextInputType.phone,
                      textInputAction: TextInputAction.next,
                      validator: (v) =>
                          Validators.requiredText(v, message: 'Enter a phone number'),
                    ),
                    const SizedBox(height: 14),
                    CustomTextField(
                      label: 'Password',
                      controller: _password,
                      obscureText: true,
                      textInputAction: TextInputAction.next,
                      validator: Validators.password,
                    ),
                    const SizedBox(height: 14),
                    CustomTextField(
                      label: 'Repeat password',
                      controller: _confirm,
                      obscureText: true,
                      textInputAction: TextInputAction.done,
                      onSubmitted: (_) => _submit(),
                      validator: (v) => Validators.confirmPassword(v, _password.text),
                    ),
                    if (_error != null) ...[
                      const SizedBox(height: 14),
                      Text(_error!,
                          style: const TextStyle(
                              color: AppColors.danger, fontWeight: FontWeight.w600)),
                    ],
                    const SizedBox(height: 24),
                    CustomButton(text: 'Create account', onTap: _submit, isLoading: _loading),
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

class _RoleOption extends StatelessWidget {
  const _RoleOption({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: selected,
      child: Material(
        color: selected ? AppColors.accentSoft : AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
            color: selected ? AppColors.accent : AppColors.line,
            width: selected ? 1.6 : 1,
          ),
        ),
        child: InkWell(
          customBorder: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(icon, color: AppColors.accent),
                const SizedBox(height: 10),
                Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
                const SizedBox(height: 2),
                Text(subtitle,
                    style: const TextStyle(color: AppColors.inkSoft, fontSize: 13)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

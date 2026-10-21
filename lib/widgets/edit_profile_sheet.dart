import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:store_app/core/validators.dart';
import 'package:store_app/providers/auth_provider.dart';
import 'package:store_app/widgets/custom_button.dart';
import 'package:store_app/widgets/custom_text_field.dart';

/// Bottom sheet to edit phone and delivery address.
/// Returns true when the user saved.
Future<bool?> showEditProfileSheet(BuildContext context) {
  return showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    builder: (_) => const _EditProfileSheet(),
  );
}

class _EditProfileSheet extends StatefulWidget {
  const _EditProfileSheet();

  @override
  State<_EditProfileSheet> createState() => _EditProfileSheetState();
}

class _EditProfileSheetState extends State<_EditProfileSheet> {
  final _formKey = GlobalKey<FormState>();
  late final _phone = TextEditingController(text: context.read<AuthProvider>().user!.phone);
  late final _street = TextEditingController(text: context.read<AuthProvider>().user!.street);
  late final _city = TextEditingController(text: context.read<AuthProvider>().user!.city);

  @override
  void dispose() {
    _phone.dispose();
    _street.dispose();
    _city.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    await context.read<AuthProvider>().updateProfile(
          phone: _phone.text.trim(),
          street: _street.text.trim(),
          city: _city.text.trim(),
        );
    if (mounted) Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        24, 4, 24, MediaQuery.viewInsetsOf(context).bottom + 24,
      ),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text('Delivery details',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
            const SizedBox(height: 16),
            CustomTextField(
              label: 'Phone',
              controller: _phone,
              keyboardType: TextInputType.phone,
              textInputAction: TextInputAction.next,
              validator: (v) => Validators.requiredText(v, message: 'Enter a phone number'),
            ),
            const SizedBox(height: 12),
            CustomTextField(
              label: 'Street and number',
              controller: _street,
              textInputAction: TextInputAction.next,
              validator: (v) => Validators.requiredText(v, message: 'Enter your street'),
            ),
            const SizedBox(height: 12),
            CustomTextField(
              label: 'City',
              controller: _city,
              textInputAction: TextInputAction.done,
              validator: (v) => Validators.requiredText(v, message: 'Enter your city'),
            ),
            const SizedBox(height: 20),
            CustomButton(text: 'Save', onTap: _save),
          ],
        ),
      ),
    );
  }
}

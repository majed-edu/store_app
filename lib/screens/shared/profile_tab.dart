import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:store_app/core/routes.dart';
import 'package:store_app/models/user_model.dart';
import 'package:store_app/providers/auth_provider.dart';
import 'package:store_app/theme/app_theme.dart';
import 'package:store_app/widgets/custom_button.dart';
import 'package:store_app/widgets/edit_profile_sheet.dart';
import 'package:store_app/widgets/section_header.dart';
import 'package:store_app/widgets/user_avatar.dart';

/// Profile tab. Used by both shoppers and merchants.
class ProfileTab extends StatelessWidget {
  const ProfileTab({super.key});

  Future<void> _confirmLogout(BuildContext context) async {
    final auth = context.read<AuthProvider>();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Log out?'),
        content: const Text('You can log back in at any time.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text(
              'Log out',
              style: TextStyle(
                color: AppColors.danger,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
    if (confirmed == true) await auth.logout();
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user!;
    final isMerchant = user.role == UserRole.merchant;

    return SafeArea(
      bottom: false,
      child: ListView(
        padding: const EdgeInsets.only(bottom: 32),
        children: [
          const ScreenHeader(title: 'Profile'),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
            child: Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                children: [
                  UserAvatar(user: user, size: 60),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          user.fullName.isEmpty ? user.username : user.fullName,
                          style: AppText.display(22),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '@${user.username}',
                          style: const TextStyle(color: AppColors.inkSoft),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.accentSoft,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      isMerchant ? 'Merchant' : 'Shopper',
                      style: const TextStyle(
                        color: AppColors.accent,
                        fontWeight: FontWeight.w700,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          _Card(
            children: [
              _InfoRow(
                icon: Icons.mail_outline,
                label: 'Email',
                value: user.email,
              ),
              _InfoRow(
                icon: Icons.phone_outlined,
                label: 'Phone',
                value: user.phone.isEmpty ? 'Not added yet' : user.phone,
              ),
              _InfoRow(
                icon: Icons.location_on_outlined,
                label: isMerchant ? 'Store address' : 'Delivery address',
                value: user.address.isEmpty ? 'Not added yet' : user.address,
              ),
            ],
          ),
          const SizedBox(height: 16),
          _Card(
            children: [
              _ActionRow(
                icon: Icons.edit_outlined,
                label: isMerchant
                    ? 'Edit contact details'
                    : 'Edit delivery details',
                onTap: () => showEditProfileSheet(context),
              ),
              if (!isMerchant)
                _ActionRow(
                  icon: Icons.receipt_long_outlined,
                  label: 'My orders',
                  onTap: () => Navigator.pushNamed(context, Routes.orders),
                ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: CustomButton(
              text: 'Log out',
              icon: Icons.logout,
              outlined: true,
              color: AppColors.danger,
              onTap: () => _confirmLogout(context),
            ),
          ),
        ],
      ),
    );
  }
}

class _Card extends StatelessWidget {
  const _Card({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(children: children),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AppColors.inkSoft, size: 22),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    color: AppColors.inkSoft,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionRow extends StatelessWidget {
  const _ActionRow({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      leading: Icon(icon, color: AppColors.ink),
      title: Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
      trailing: const Icon(Icons.chevron_right, color: AppColors.inkSoft),
      contentPadding: const EdgeInsets.symmetric(horizontal: 18),
    );
  }
}

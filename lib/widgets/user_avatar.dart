import 'package:flutter/material.dart';
import 'package:store_app/models/user_model.dart';
import 'package:store_app/theme/app_theme.dart';

class UserAvatar extends StatelessWidget {
  const UserAvatar({super.key, required this.user, this.size = 44});

  final AppUser user;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: const BoxDecoration(
        color: AppColors.accentSoft,
        shape: BoxShape.circle,
      ),
      child: Text(
        user.initials,
        style: AppText.display(size * 0.38, color: AppColors.accent),
      ),
    );
  }
}

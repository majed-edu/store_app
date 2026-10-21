import 'package:flutter/material.dart';
import 'package:store_app/theme/app_theme.dart';
import 'package:store_app/widgets/custom_button.dart';

/// A centered icon, title, message and an optional action.
/// Used for errors and for empty screens (an empty screen is an invitation to act).
class StateMessage extends StatelessWidget {
  const StateMessage({
    super.key,
    required this.icon,
    required this.title,
    required this.message,
    this.actionLabel,
    this.onAction,
  });

  final IconData icon;
  final String title;
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: const BoxDecoration(
                color: AppColors.accentSoft,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: AppColors.accent, size: 30),
            ),
            const SizedBox(height: 20),
            Text(title, style: AppText.display(22), textAlign: TextAlign.center),
            const SizedBox(height: 8),
            Text(message,
                textAlign: TextAlign.center,
                style: const TextStyle(
                    color: AppColors.inkSoft, fontSize: 15, height: 1.4)),
            if (actionLabel != null) ...[
              const SizedBox(height: 24),
              SizedBox(
                width: 220,
                child: CustomButton(text: actionLabel!, onTap: onAction),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Shown when a request fails. Says what happened and how to fix it.
class ErrorView extends StatelessWidget {
  const ErrorView({super.key, required this.onRetry, this.title = "Couldn't load the store"});

  final VoidCallback onRetry;
  final String title;

  @override
  Widget build(BuildContext context) {
    return StateMessage(
      icon: Icons.wifi_off_rounded,
      title: title,
      message: 'Check your internet connection and try again.',
      actionLabel: 'Try again',
      onAction: onRetry,
    );
  }
}

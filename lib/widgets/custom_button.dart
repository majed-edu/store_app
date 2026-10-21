import 'package:flutter/material.dart';
import 'package:store_app/theme/app_theme.dart';

/// Main button of the app. Shows a spinner while [isLoading].
class CustomButton extends StatelessWidget {
  const CustomButton({
    super.key,
    required this.text,
    required this.onTap,
    this.icon,
    this.outlined = false,
    this.isLoading = false,
    this.color = AppColors.accent,
  });

  final String text;
  final VoidCallback? onTap;
  final IconData? icon;
  final bool outlined;
  final bool isLoading;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final enabled = onTap != null && !isLoading;
    final foreground = outlined ? color : Colors.white;
    final background = outlined
        ? Colors.transparent
        : (onTap == null ? AppColors.line : color);

    return Material(
      color: background,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: outlined ? BorderSide(color: color, width: 1.5) : BorderSide.none,
      ),
      child: InkWell(
        onTap: enabled ? onTap : null,
        child: SizedBox(
          height: 56,
          width: double.infinity,
          child: Center(
            child: isLoading
                ? SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(strokeWidth: 2.4, color: foreground),
                  )
                : Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (icon != null) ...[
                        Icon(icon, size: 20, color: foreground),
                        const SizedBox(width: 8),
                      ],
                      Flexible(
                        child: Text(
                          text,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: foreground,
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}

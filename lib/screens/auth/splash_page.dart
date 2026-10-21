import 'package:flutter/material.dart';
import 'package:store_app/theme/app_theme.dart';
import 'package:store_app/widgets/brand_mark.dart';

/// Shown for a moment while the app checks for a saved session.
class SplashPage extends StatelessWidget {
  const SplashPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const BrandMark(size: 64),
            const SizedBox(height: 16),
            Text('New Trend', style: AppText.display(28)),
          ],
        ),
      ),
    );
  }
}

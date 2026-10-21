import 'package:flutter/material.dart';
import 'package:store_app/theme/app_theme.dart';

class BrandMark extends StatelessWidget {
  const BrandMark({super.key, this.size = 48});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: AppColors.accent,
        borderRadius: BorderRadius.circular(size * 0.3),
      ),
      child: Text('NT', style: AppText.display(size * 0.4, color: Colors.white)),
    );
  }
}

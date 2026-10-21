import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:store_app/theme/app_theme.dart';

/// Network image that keeps the whole product visible (BoxFit.contain),
/// caches it, and shows a calm placeholder while loading or on error.
class ProductImage extends StatelessWidget {
  const ProductImage({
    super.key,
    required this.url,
    this.padding = const EdgeInsets.all(12),
  });

  final String url;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding,
      child: CachedNetworkImage(
        imageUrl: url,
        fit: BoxFit.contain,
        placeholder: (context, _) => const Center(
          child: SizedBox(
            width: 22,
            height: 22,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        ),
        errorWidget: (context, _, error) => const Center(
          child: Icon(Icons.image_not_supported_outlined,
              color: AppColors.inkSoft, size: 32),
        ),
      ),
    );
  }
}

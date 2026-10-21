import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:store_app/core/app_config.dart';
import 'package:store_app/core/formatters.dart';
import 'package:store_app/models/user_model.dart';
import 'package:store_app/providers/auth_provider.dart';
import 'package:store_app/providers/catalog_provider.dart';
import 'package:store_app/providers/shell_controller.dart';
import 'package:store_app/theme/app_theme.dart';
import 'package:store_app/widgets/product_card.dart';
import 'package:store_app/widgets/product_image.dart';
import 'package:store_app/widgets/section_header.dart';
import 'package:store_app/widgets/state_views.dart';
import 'package:store_app/widgets/user_avatar.dart';

class HomeTab extends StatelessWidget {
  const HomeTab({super.key});

  @override
  Widget build(BuildContext context) {
    final catalog = context.watch<CatalogProvider>();
    final user = context.select<AuthProvider, AppUser?>((a) => a.user);
    final shell = context.read<ShellController>();

    final hasData = catalog.products.isNotEmpty;
    final isLoading = catalog.status == LoadStatus.loading;
    final hasFailed = catalog.status == LoadStatus.error;

    return SafeArea(
      bottom: false,
      child: RefreshIndicator(
        onRefresh: () => catalog.load(force: true),
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(child: _Header(user: user)),
            SliverToBoxAdapter(
              child: _SearchPill(onTap: () => shell.openExplore(focusSearch: true)),
            ),
            const SliverToBoxAdapter(child: _DeliveryBanner()),
            if (!hasData && isLoading)
              const SliverPadding(
                padding: EdgeInsets.fromLTRB(20, 24, 20, 32),
                sliver: ProductSkeletonSliverGrid(),
              )
            else if (!hasData && hasFailed)
              SliverFillRemaining(
                hasScrollBody: false,
                child: ErrorView(onRetry: () => catalog.load(force: true)),
              )
            else ...[
              SliverToBoxAdapter(
                child: SectionHeader(
                  title: 'New arrivals',
                  actionLabel: 'See all',
                  onAction: () => shell.openExplore(),
                ),
              ),
              SliverToBoxAdapter(
                child: SizedBox(
                  height: 252,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    itemCount: catalog.newArrivals.length,
                    separatorBuilder: (context, index) => const SizedBox(width: 14),
                    itemBuilder: (context, index) => SizedBox(
                      width: 170,
                      child: ProductCard(
                        product: catalog.newArrivals[index],
                        heroScope: 'home-new',
                      ),
                    ),
                  ),
                ),
              ),
              const SliverToBoxAdapter(child: SectionHeader(title: 'Shop by category')),
              SliverToBoxAdapter(
                child: SizedBox(
                  height: 132,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    itemCount: catalog.categories.length,
                    separatorBuilder: (context, index) => const SizedBox(width: 12),
                    itemBuilder: (context, index) {
                      final category = catalog.categories[index];
                      return _CategoryTile(
                        name: category,
                        imageUrl: catalog.imageForCategory(category),
                        onTap: () => shell.openExplore(category: category),
                      );
                    },
                  ),
                ),
              ),
              const SliverToBoxAdapter(child: SectionHeader(title: 'Top rated')),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
                sliver: ProductSliverGrid(
                  products: catalog.topRated,
                  heroScope: 'home-top',
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.user});

  final AppUser? user;

  @override
  Widget build(BuildContext context) {
    final address = user?.address ?? '';
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 4),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Hello, ${user?.displayFirstName ?? ''}', style: AppText.display(28)),
                const SizedBox(height: 6),
                Row(
                  children: [
                    const Icon(Icons.location_on_outlined, size: 16, color: AppColors.inkSoft),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        address.isEmpty ? 'Add a delivery address in Profile' : address,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(color: AppColors.inkSoft, fontSize: 14),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          if (user != null) UserAvatar(user: user!),
        ],
      ),
    );
  }
}

class _SearchPill extends StatelessWidget {
  const _SearchPill({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Material(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: onTap,
          child: const SizedBox(
            height: 52,
            child: Row(
              children: [
                SizedBox(width: 16),
                Icon(Icons.search, color: AppColors.inkSoft),
                SizedBox(width: 12),
                Text('Search products', style: TextStyle(color: AppColors.inkSoft, fontSize: 16)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _DeliveryBanner extends StatelessWidget {
  const _DeliveryBanner();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.accentSoft,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            const Icon(Icons.local_shipping_outlined, color: AppColors.accent, size: 20),
            const SizedBox(width: 10),
            Text(
              'Free delivery on orders over ${Formatters.price(AppConfig.freeShippingThreshold)}',
              style: const TextStyle(
                  color: AppColors.accent, fontWeight: FontWeight.w600, fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }
}

class _CategoryTile extends StatelessWidget {
  const _CategoryTile({required this.name, required this.imageUrl, required this.onTap});

  final String name;
  final String? imageUrl;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(20),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: SizedBox(
          width: 138,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(14, 14, 8, 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  Formatters.sentenceCase(name),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15, height: 1.2),
                ),
                const Spacer(),
                if (imageUrl != null)
                  Align(
                    alignment: Alignment.bottomRight,
                    child: SizedBox(
                      width: 62,
                      height: 62,
                      child: ProductImage(url: imageUrl!, padding: EdgeInsets.zero),
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

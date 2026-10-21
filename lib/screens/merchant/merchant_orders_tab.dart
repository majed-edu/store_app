import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:store_app/models/order_model.dart';
import 'package:store_app/providers/catalog_provider.dart';
import 'package:store_app/providers/orders_provider.dart';
import 'package:store_app/widgets/category_tabs.dart';
import 'package:store_app/widgets/order_card.dart';
import 'package:store_app/widgets/section_header.dart';
import 'package:store_app/widgets/state_views.dart';

class MerchantOrdersTab extends StatefulWidget {
  const MerchantOrdersTab({super.key});

  @override
  State<MerchantOrdersTab> createState() => _MerchantOrdersTabState();
}

class _MerchantOrdersTabState extends State<MerchantOrdersTab> {
  static const _all = 'all';
  String _filter = _all;

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<OrdersProvider>();
    final catalog = context.read<CatalogProvider>();

    final all = provider.allOrders;
    final orders = _filter == _all
        ? all
        : all.where((o) => o.status.name == _filter).toList();

    return SafeArea(
      bottom: false,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ScreenHeader(title: 'Orders', subtitle: '${all.length} in total'),
          const SizedBox(height: 8),
          CategoryTabs(
            categories: [_all, ...OrderStatus.values.map((s) => s.name)],
            selected: _filter,
            onSelected: (value) => setState(() => _filter = value),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: RefreshIndicator(
              onRefresh: () => provider.loadServerOrders(catalog.productsById),
              child: orders.isEmpty
                  ? ListView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      children: [
                        SizedBox(
                          height: 380,
                          child: provider.serverFailed && all.isEmpty
                              ? ErrorView(
                                  title: "Couldn't load orders",
                                  onRetry: () =>
                                      provider.loadServerOrders(catalog.productsById),
                                )
                              : const StateMessage(
                                  icon: Icons.receipt_long_outlined,
                                  title: 'No orders here',
                                  message: 'Orders in this status will show up here.',
                                ),
                        ),
                      ],
                    )
                  : ListView.separated(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                      itemCount: orders.length,
                      separatorBuilder: (context, index) => const SizedBox(height: 14),
                      itemBuilder: (context, index) {
                        final order = orders[index];
                        final canAdvance =
                            !order.fromServer && order.status != OrderStatus.delivered;
                        return OrderCard(
                          order: order,
                          showCustomer: true,
                          onAdvance: canAdvance ? () => provider.advance(order) : null,
                        );
                      },
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

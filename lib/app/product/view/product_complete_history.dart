import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ultimate_salon_owner_flutter/app/product/controller/product_complete_history_controller.dart';
import 'package:ultimate_salon_owner_flutter/app/product/models/product_history_model.dart';
import 'package:ultimate_salon_owner_flutter/app/util/theme.dart';

class ProductCompleteHistoryScreen extends StatelessWidget {
  const ProductCompleteHistoryScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ProductCompleteHistoryController>(
      builder: (value) {
        return DefaultTabController(
          length: 4,
          child: Scaffold(
            backgroundColor: Colors.grey[50],
            appBar: AppBar(
              backgroundColor: ThemeProvider.appColor,
              iconTheme: const IconThemeData(color: ThemeProvider.whiteColor),
              title: Text(
                value.title,
                style: ThemeProvider.titleStyle,
              ),
              bottom: TabBar(
                isScrollable: true,
                indicatorColor: Colors.white,
                labelColor: Colors.white,
                unselectedLabelColor: Colors.white70,
                tabs: [
                  Tab(
                      text:
                          '${'Future'.tr} (${value.bundle.count('future_orders')})'),
                  Tab(
                      text:
                          '${'Current'.tr} (${value.bundle.count('current_orders')})'),
                  Tab(
                      text:
                          '${'Past deliveries'.tr} (${value.bundle.count('past_deliveries')})'),
                  Tab(
                      text:
                          '${'Cancelled'.tr} (${value.bundle.count('cancelled')})'),
                ],
              ),
            ),
            body: value.apiCalled == false
                ? const Center(
                    child: CircularProgressIndicator(
                        color: ThemeProvider.appColor),
                  )
                : TabBarView(
                    children: [
                      _list(value, value.bundle.futureOrders),
                      _list(value, value.bundle.currentOrders),
                      _list(value, value.bundle.pastDeliveries),
                      _list(value, value.bundle.cancelled),
                    ],
                  ),
          ),
        );
      },
    );
  }

  Widget _list(ProductCompleteHistoryController value,
      List<ProductHistoryRow> rows) {
    if (rows.isEmpty) {
      return Center(child: Text('No orders'.tr));
    }
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: rows.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (_, index) => _card(value, rows[index]),
    );
  }

  Widget _card(
      ProductCompleteHistoryController value, ProductHistoryRow row) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  row.item ?? row.customer ?? 'Order'.tr,
                  style: const TextStyle(fontFamily: 'bold', fontSize: 15),
                ),
              ),
              Text(
                row.statusLabel ?? '',
                style: const TextStyle(
                    fontFamily: 'regular',
                    color: ThemeProvider.appColor, fontSize: 12),
              ),
            ],
          ),
          const SizedBox(height: 6),
          if ((row.customer ?? '').isNotEmpty)
            Text('${'Customer'.tr}: ${row.customer}'),
          if ((row.deliveryType ?? '').isNotEmpty)
            Text('${'Delivery'.tr}: ${row.deliveryType}'),
          if ((row.deliveryDate ?? row.deliveryAt ?? '').isNotEmpty)
            Text('${'Delivery at'.tr}: ${row.deliveryDate ?? row.deliveryAt}'),
          if ((row.color ?? '').isNotEmpty)
            Text('${'Color'.tr}: ${row.color}'),
          const SizedBox(height: 6),
          Text(
            '${'Qty'.tr} ${row.qty ?? 1}  •  ${value.money(row.amount)}  •  ${'Paid'.tr} ${value.money(row.paidAmount)}',
            style: const TextStyle(fontFamily: 'bold'),
          ),
          if ((row.payment ?? '').isNotEmpty)
            Text(row.payment!, style: TextStyle(fontFamily: 'regular', color: Colors.grey[600])),
        ],
      ),
    );
  }
}

// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
import 'package:ultimate_salon_owner_flutter/app/controller/locale_controller.dart';
// import 'package:skeletons/skeletons.dart';
// import 'package:ultimate_salon_owner_flutter/app/controller/product_history_controller.dart';
// import 'package:ultimate_salon_owner_flutter/app/env.dart';
// import 'package:ultimate_salon_owner_flutter/app/util/theme.dart';

// class HistoryScreen extends StatefulWidget {
//   const HistoryScreen({Key? key}) : super(key: key);

//   @override
//   State<HistoryScreen> createState() => _HistoryScreenState();
// }

// class _HistoryScreenState extends State<HistoryScreen> {
//   @override
//   Widget build(BuildContext context) {
//     return GetBuilder<HistoryController>(
//       builder: (value) {
//         return Scaffold(
//           backgroundColor: Colors.grey[50],
//           appBar: _buildAppBar(value),
//           body: value.apiCalled == false
//               ? _buildSkeletonLoader()
//               : _buildTabContent(value),
//         );
//       },
//     );
//   }

//   PreferredSizeWidget _buildAppBar(HistoryController value) {
//     return AppBar(
//       automaticallyImplyLeading: true,
//       backgroundColor: ThemeProvider.appColor,
//       elevation: 0,
//       iconTheme: const IconThemeData(color: Colors.white),
//       titleSpacing: 0,
//       title: Row(
//         children: [
//           Padding(
//             padding: const EdgeInsets.all(8.0),
//             child: Image.asset(
//               'assets/images/icon_logo.png',
//               width: 40,
//               height: 40,
//               fit: BoxFit.contain,
//             ),
//           ),
//           const Text(
//             'Order History',
//             style: TextStyle(
//               color: Colors.white,
//               fontSize: 20,
//               fontWeight: FontWeight.w600,
//             ),
//           ),
//         ],
//       ),
//       actions: [
//         _buildActionButton(
//           icon: Icons.notifications_outlined,
//           onTap: () => value.onOpenNotifications(),
//         ),
//         _buildActionButton(
//           icon: Icons.chat_outlined,
//           onTap: () => value.onInbox(),
//         ),
//         const SizedBox(width: 8),
//       ],
//       bottom: PreferredSize(
//         preferredSize: const Size.fromHeight(60),
//         child: TabBar(
//           controller: value.tabController,
//           unselectedLabelColor: Colors.white70,
//           labelColor: Colors.white,
//           indicatorColor: Colors.white,
//           indicatorWeight: 3,
//           indicatorPadding: const EdgeInsets.symmetric(horizontal: 32),
//           labelStyle: const TextStyle(
//             fontWeight: FontWeight.w600,
//             fontSize: 16,
//           ),
//           unselectedLabelStyle: const TextStyle(
//             fontWeight: FontWeight.w400,
//             fontSize: 16,
//           ),
//           tabs: [
//             Tab(
//               child: Row(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   Container(
//                     padding:
//                         const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
//                     decoration: BoxDecoration(
//                       color: Colors.white.withOpacity(0.1),
//                       borderRadius: BorderRadius.circular(12),
//                     ),
//                     child: Text('New Orders'.tr),
//                   ),
//                 ],
//               ),
//             ),
//             Tab(
//               child: Row(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   Container(
//                     padding:
//                         const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
//                     decoration: BoxDecoration(
//                       color: Colors.white.withOpacity(0.1),
//                       borderRadius: BorderRadius.circular(12),
//                     ),
//                     child: Text('Past Orders'.tr),
//                   ),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildActionButton(
//       {required IconData icon, required VoidCallback onTap}) {
//     return GestureDetector(
//       onTap: onTap,
//       child: Container(
//         margin: const EdgeInsets.symmetric(horizontal: 4),
//         padding: const EdgeInsets.all(8),
//         decoration: BoxDecoration(
//           color: Colors.white.withOpacity(0.1),
//           borderRadius: BorderRadius.circular(8),
//         ),
//         child: Icon(
//           icon,
//           color: ThemeProvider.golden,
//           size: 22,
//         ),
//       ),
//     );
//   }

//   Widget _buildSkeletonLoader() {
//     return Padding(
//       padding: const EdgeInsets.all(16.0),
//       child: ListView.builder(
//         itemCount: 5,
//         itemBuilder: (context, index) => Container(
//           margin: const EdgeInsets.only(bottom: 16),
//           child: SkeletonItem(
//             child: Container(
//               height: 200,
//               decoration: BoxDecoration(
//                 color: Colors.white,
//                 borderRadius: BorderRadius.circular(16),
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildTabContent(HistoryController value) {
//     return TabBarView(
//       controller: value.tabController,
//       children: [
//         _buildOrdersList(value, value.productSalonList, 'No New Orders Found!'),
//         _buildOrdersList(
//             value, value.productSalonListOld, 'No Past Orders Found!'),
//       ],
//     );
//   }

//   Widget _buildOrdersList(
//       HistoryController value, List ordersList, String emptyMessage) {
//     if (ordersList.isEmpty) {
//       return _buildEmptyState(emptyMessage);
//     }

//     return SingleChildScrollView(
//       padding: const EdgeInsets.all(16.0),
//       child: Column(
//         children: [
//           _buildOrdersHeader(ordersList.length),
//           const SizedBox(height: 16),
//           ...ordersList.asMap().entries.map((entry) {
//             int index = entry.key;
//             var order = entry.value;
//             return _buildOrderCard(value, order, index);
//           }).toList(),
//         ],
//       ),
//     );
//   }

//   Widget _buildOrdersHeader(int orderCount) {
//     return Container(
//       padding: const EdgeInsets.all(16),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(12),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.05),
//             blurRadius: 8,
//             offset: const Offset(0, 2),
//           ),
//         ],
//       ),
//       child: Row(
//         children: [
//           Container(
//             padding: const EdgeInsets.all(8),
//             decoration: BoxDecoration(
//               color: ThemeProvider.appColor.withOpacity(0.1),
//               borderRadius: BorderRadius.circular(8),
//             ),
//             child: const Icon(
//               Icons.receipt_long_outlined,
//               color: ThemeProvider.appColor,
//               size: 24,
//             ),
//           ),
//           const SizedBox(width: 12),
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 const Text(
//                   'Orders Summary',
//                   style: TextStyle(
//                     fontWeight: FontWeight.w600,
//                     fontSize: 16,
//                   ),
//                 ),
//                 Text(
//                   '$orderCount orders found',
//                   style: TextStyle(
//                     color: Colors.grey[600],
//                     fontSize: 14,
//                   ),
//                 ),
//               ],
//             ),
//           ),
//           Container(
//             padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
//             decoration: BoxDecoration(
//               color: ThemeProvider.appColor,
//               borderRadius: BorderRadius.circular(20),
//             ),
//             child: Text(
//               '$orderCount',
//               style: const TextStyle(
//                 color: Colors.white,
//                 fontWeight: FontWeight.w600,
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildOrderCard(HistoryController value, dynamic order, int index) {
//     return Container(
//       margin: const EdgeInsets.only(bottom: 16),
//       child: Material(
//         color: Colors.transparent,
//         child: InkWell(
//           onTap: () => value.onProductDetail(order.id as int),
//           borderRadius: BorderRadius.circular(16),
//           child: Container(
//             decoration: BoxDecoration(
//               color: Colors.white,
//               borderRadius: BorderRadius.circular(16),
//               boxShadow: [
//                 BoxShadow(
//                   color: Colors.black.withOpacity(0.08),
//                   blurRadius: 12,
//                   offset: const Offset(0, 4),
//                 ),
//               ],
//             ),
//             child: Column(
//               children: [
//                 _buildOrderHeader(value, order),
//                 _buildOrderItems(value, order),
//                 _buildOrderFooter(value, order),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildOrderHeader(HistoryController value, dynamic order) {
//     return Container(
//       padding: const EdgeInsets.all(16),
//       decoration: BoxDecoration(
//         color: _getStatusColor(order.status).withOpacity(0.1),
//         borderRadius: const BorderRadius.only(
//           topLeft: Radius.circular(16),
//           topRight: Radius.circular(16),
//         ),
//       ),
//       child: Column(
//         children: [
//           Row(
//             children: [
//               _buildCustomerAvatar(order),
//               const SizedBox(width: 12),
//               Expanded(child: _buildCustomerInfo(order)),
//               _buildStatusChip(value, order.status),
//             ],
//           ),
//           const SizedBox(height: 12),
//           Container(
//             height: 1,
//             color: Colors.grey[200],
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildCustomerAvatar(dynamic order) {
//     return Container(
//       width: 56,
//       height: 56,
//       decoration: BoxDecoration(
//         borderRadius: BorderRadius.circular(12),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.1),
//             blurRadius: 4,
//             offset: const Offset(0, 2),
//           ),
//         ],
//       ),
//       child: ClipRRect(
//         borderRadius: BorderRadius.circular(12),
//         child: FadeInImage(
//           image:
//               NetworkImage('${Environments.imageURL}${order.userInfo!.cover}'),
//           placeholder: const AssetImage("assets/images/placeholder.jpeg"),
//           imageErrorBuilder: (context, error, stackTrace) {
//             return Container(
//               color: Colors.grey[100],
//               child: Icon(
//                 Icons.person_outline,
//                 color: Colors.grey[400],
//                 size: 28,
//               ),
//             );
//           },
//           fit: BoxFit.cover,
//         ),
//       ),
//     );
//   }

//   Widget _buildCustomerInfo(dynamic order) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text(
//           '${order.userInfo!.firstName} ${order.userInfo!.lastName}',
//           style: const TextStyle(
//             fontWeight: FontWeight.w600,
//             fontSize: 16,
//             color: Colors.black87,
//           ),
//           overflow: TextOverflow.ellipsis,
//         ),
//         const SizedBox(height: 4),
//         Text(
//           '${order.address!.address} ${order.address!.landmark}',
//           style: TextStyle(
//             color: Colors.grey[600],
//             fontSize: 14,
//           ),
//           maxLines: 2,
//           overflow: TextOverflow.ellipsis,
//         ),
//         const SizedBox(height: 4),
//         Text(
//           'Order #${order.id}',
//           style: TextStyle(
//             color: Colors.grey[500],
//             fontSize: 12,
//             fontWeight: FontWeight.w500,
//           ),
//         ),
//       ],
//     );
//   }

//   Widget _buildStatusChip(HistoryController value, int status) {
//     final statusName = value.statusName[status] ?? 'Unknown';
//     final statusColor = _getStatusColor(status);

//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
//       decoration: BoxDecoration(
//         color: statusColor,
//         borderRadius: BorderRadius.circular(20),
//       ),
//       child: Text(
//         statusName.tr,
//         style: const TextStyle(
//           color: Colors.white,
//           fontWeight: FontWeight.w600,
//           fontSize: 12,
//         ),
//       ),
//     );
//   }

//   Widget _buildOrderItems(HistoryController value, dynamic order) {
//     return Padding(
//       padding: const EdgeInsets.all(16),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           const Text(
//             'Order Items',
//             style: TextStyle(
//               fontWeight: FontWeight.w600,
//               fontSize: 16,
//               color: Colors.black87,
//             ),
//           ),
//           const SizedBox(height: 12),
//           ...order.orders!
//               .map<Widget>((item) => _buildOrderItem(value, item))
//               .toList(),
//         ],
//       ),
//     );
//   }

//   Widget _buildOrderItem(HistoryController value, dynamic item) {
//     return Container(
//       margin: const EdgeInsets.only(bottom: 8),
//       padding: const EdgeInsets.all(12),
//       decoration: BoxDecoration(
//         color: Colors.grey[50],
//         borderRadius: BorderRadius.circular(8),
//       ),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//         children: [
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   item.name.toString(),
//                   style: const TextStyle(
//                     fontWeight: FontWeight.w500,
//                     fontSize: 14,
//                     color: Colors.black87,
//                   ),
//                 ),
//                 const SizedBox(height: 4),
//                 Text(
//                   'Quantity: ${item.quantity}',
//                   style: TextStyle(
//                     color: Colors.grey[600],
//                     fontSize: 12,
//                   ),
//                 ),
//               ],
//             ),
//           ),
//           Column(
//             crossAxisAlignment: CrossAxisAlignment.end,
//             children: [
//               if (item.originalPrice != item.sellPrice)
//                 Text(
//                   _formatPrice(value, item.originalPrice),
//                   style: const TextStyle(
//                     fontSize: 12,
//                     color: Colors.grey,
//                     decoration: TextDecoration.lineThrough,
//                   ),
//                 ),
//               Text(
//                 _formatPrice(value, item.sellPrice),
//                 style: const TextStyle(
//                   fontWeight: FontWeight.w600,
//                   fontSize: 14,
//                   color: ThemeProvider.greenColor,
//                 ),
//               ),
//             ],
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildOrderFooter(HistoryController value, dynamic order) {
//     return Container(
//       padding: const EdgeInsets.all(16),
//       decoration: BoxDecoration(
//         color: Colors.grey[50],
//         borderRadius: const BorderRadius.only(
//           bottomLeft: Radius.circular(16),
//           bottomRight: Radius.circular(16),
//         ),
//       ),
//       child: Column(
//         children: [
//           Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               const Text(
//                 'Grand Total',
//                 style: TextStyle(
//                   fontWeight: FontWeight.w600,
//                   fontSize: 16,
//                   color: Colors.black87,
//                 ),
//               ),
//               Text(
//                 _formatPrice(value, order.grandTotal),
//                 style: const TextStyle(
//                   fontWeight: FontWeight.w700,
//                   fontSize: 18,
//                   color: ThemeProvider.appColor,
//                 ),
//               ),
//             ],
//           ),
//           const SizedBox(height: 12),
//           Container(
//             height: 1,
//             color: Colors.grey[200],
//           ),
//           const SizedBox(height: 12),
//           Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               Row(
//                 children: [
//                   Icon(
//                     Icons.access_time_outlined,
//                     size: 16,
//                     color: Colors.grey[600],
//                   ),
//                   const SizedBox(width: 4),
//                   Text(
//                     'Order Date',
//                     style: TextStyle(
//                       color: Colors.grey[600],
//                       fontSize: 14,
//                     ),
//                   ),
//                 ],
//               ),
//               Text(
//                 order.createdAt.toString(),
//                 style: const TextStyle(
//                   fontWeight: FontWeight.w500,
//                   fontSize: 14,
//                   color: Colors.black87,
//                 ),
//               ),
//             ],
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildEmptyState(String message) {
//     return Center(
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           Container(
//             width: 120,
//             height: 120,
//             decoration: BoxDecoration(
//               color: Colors.grey[100],
//               borderRadius: BorderRadius.circular(60),
//             ),
//             child: Icon(
//               Icons.receipt_long_outlined,
//               size: 60,
//               color: Colors.grey[400],
//             ),
//           ),
//           const SizedBox(height: 24),
//           Text(
//             message.tr,
//             style: const TextStyle(
//               fontSize: 18,
//               fontWeight: FontWeight.w600,
//               color: Colors.black87,
//             ),
//           ),
//           const SizedBox(height: 8),
//           Text(
//             'Your orders will appear here once they are placed.',
//             style: TextStyle(
//               fontSize: 14,
//               color: Colors.grey[600],
//             ),
//             textAlign: TextAlign.center,
//           ),
//         ],
//       ),
//     );
//   }

//   Color _getStatusColor(int status) {
//     // You can customize these colors based on your status values
//     switch (status) {
//       case 0:
//         return Colors.orange; // Pending
//       case 1:
//         return Colors.blue; // Confirmed
//       case 2:
//         return Colors.purple; // In Progress
//       case 3:
//         return Colors.green; // Completed
//       case 4:
//         return Colors.red; // Cancelled
//       default:
//         return ThemeProvider.appColor;
//     }
//   }

//   String _formatPrice(HistoryController value, dynamic price) {
//     return value.currencySide == 'left'
//         ? '${value.currencySymbol}$price'
//         : '$price${value.currencySymbol}';
//   }
// }
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:skeletons/skeletons.dart';
import 'package:ultimate_salon_owner_flutter/app/controller/locale_controller.dart';
import 'package:ultimate_salon_owner_flutter/app/controller/product_history_controller.dart';
import 'package:ultimate_salon_owner_flutter/app/util/app_image.dart';
import 'package:ultimate_salon_owner_flutter/app/util/theme.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({Key? key}) : super(key: key);

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  @override
  Widget build(BuildContext context) {
    return GetBuilder<LocaleController>(builder: (_) {
      return GetBuilder<HistoryController>(
        builder: (value) {
          return Scaffold(
            backgroundColor: Colors.grey[50],
            appBar: _buildAppBar(value),
            body: value.apiCalled == false
                ? _buildSkeletonLoader()
                : _buildTabContent(value),
          );
        },
      );
    });
  }

  PreferredSizeWidget _buildAppBar(HistoryController value) {
    return AppBar(
      automaticallyImplyLeading: true,
      backgroundColor: ThemeProvider.appColor,
      elevation: 0,
      iconTheme: const IconThemeData(color: Colors.white),
      titleSpacing: 0,
      title: Row(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Image.asset(
              'assets/images/icon_logo.png',
              width: 40,
              height: 40,
              fit: BoxFit.contain,
            ),
          ),
          Text(
            'Order History'.tr,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
      actions: [
        _buildActionButton(
          icon: Icons.notifications_outlined,
          onTap: () => value.onOpenNotifications(),
        ),
        _buildActionButton(
          icon: Icons.chat_outlined,
          onTap: () => value.onInbox(),
        ),
        const SizedBox(width: 8),
      ],
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(60),
        child: TabBar(
          controller: value.tabController,
          unselectedLabelColor: Colors.white70,
          labelColor: Colors.white,
          indicatorColor: Colors.white,
          indicatorWeight: 3,
          indicatorPadding: const EdgeInsets.symmetric(horizontal: 32),
          labelStyle: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
          unselectedLabelStyle: const TextStyle(
            fontWeight: FontWeight.w400,
            fontSize: 16,
          ),
          tabs: [
            Tab(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text('New Orders'.tr),
                  ),
                ],
              ),
            ),
            Tab(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text('Past Orders'.tr),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton(
      {required IconData icon, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          icon,
          color: ThemeProvider.golden,
          size: 22,
        ),
      ),
    );
  }

  Widget _buildSkeletonLoader() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: ListView.builder(
        itemCount: 5,
        itemBuilder: (context, index) => Container(
          margin: const EdgeInsets.only(bottom: 16),
          child: SkeletonItem(
            child: Container(
              height: 200,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTabContent(HistoryController value) {
    return TabBarView(
      controller: value.tabController,
      children: [
        _buildOrdersTab(
          value: value,
          isNewOrders: true,
          emptyMessage: 'No New Orders Found!'.tr,
        ),
        _buildOrdersTab(
          value: value,
          isNewOrders: false,
          emptyMessage: 'No Past Orders Found!'.tr,
        ),
      ],
    );
  }

  Widget _buildStatusFilterChips(HistoryController value, bool isNewOrders) {
    final availableStatuses = isNewOrders
        ? value.getAvailableStatusesForNewOrders()
        : value.getAvailableStatusesForPastOrders();

    if (availableStatuses.isEmpty) return const SizedBox.shrink();

    return Container(
      height: 50,
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: availableStatuses.length + 1, // +1 for "All" chip
        itemBuilder: (context, index) {
          if (index == 0) {
            // "All" filter chip
            final isSelected = isNewOrders
                ? value.selectedNewOrdersFilter == -1
                : value.selectedPastOrdersFilter == -1;

            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: FilterChip(
                label: Text('All'.tr),
                selected: isSelected,
                onSelected: (selected) {
                  if (isNewOrders) {
                    value.setNewOrdersFilter(-1);
                  } else {
                    value.setPastOrdersFilter(-1);
                  }
                },
                selectedColor: ThemeProvider.appColor.withOpacity(0.2),
                checkmarkColor: ThemeProvider.appColor,
                labelStyle: TextStyle(
                  color: isSelected ? ThemeProvider.appColor : Colors.grey[600],
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                ),
                side: BorderSide(
                  color:
                      isSelected ? ThemeProvider.appColor : Colors.grey[300]!,
                ),
              ),
            );
          }

          final statusIndex = availableStatuses[index - 1];
          final isSelected = isNewOrders
              ? value.selectedNewOrdersFilter == statusIndex
              : value.selectedPastOrdersFilter == statusIndex;

          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilterChip(
              label: Text(value.statusName[statusIndex]),
              selected: isSelected,
              onSelected: (selected) {
                if (isNewOrders) {
                  value.setNewOrdersFilter(selected ? statusIndex : -1);
                } else {
                  value.setPastOrdersFilter(selected ? statusIndex : -1);
                }
              },
              selectedColor: value.statusColors[statusIndex]?.withOpacity(0.2),
              checkmarkColor: value.statusColors[statusIndex],
              labelStyle: TextStyle(
                color: isSelected
                    ? value.statusColors[statusIndex]
                    : Colors.grey[600],
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
              side: BorderSide(
                color: isSelected
                    ? value.statusColors[statusIndex] ?? Colors.grey[300]!
                    : Colors.grey[300]!,
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildOrdersTab({
    required HistoryController value,
    required bool isNewOrders,
    required String emptyMessage,
  }) {
    // Get filtered orders
    final filteredOrders = isNewOrders
        ? value.getFilteredNewOrders()
        : value.getFilteredPastOrders();

    return Column(
      children: [
        // Status Filter Chips
        _buildStatusFilterChips(value, isNewOrders),

        // Content
        Expanded(
          child: filteredOrders.isEmpty
              ? _buildEmptyState(
                  (isNewOrders
                              ? value.productSalonList
                              : value.productSalonListOld)
                          .isEmpty
                      ? emptyMessage
                      : 'No orders found for the selected filter',
                )
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      _buildOrdersHeader(filteredOrders.length),
                      const SizedBox(height: 16),
                      ...filteredOrders.asMap().entries.map((entry) {
                        int index = entry.key;
                        var order = entry.value;
                        return _buildOrderCard(value, order, index);
                      }).toList(),
                    ],
                  ),
                ),
        ),
      ],
    );
  }

  Widget _buildOrdersHeader(int orderCount) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: ThemeProvider.appColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.receipt_long_outlined,
              color: ThemeProvider.appColor,
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Orders Summary',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
                Text(
                  '$orderCount order${orderCount != 1 ? 's' : ''} found',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: ThemeProvider.appColor,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              '$orderCount',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderCard(HistoryController value, dynamic order, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => value.onProductDetail(order.id as int),
          borderRadius: BorderRadius.circular(16),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              children: [
                _buildOrderHeader(value, order),
                _buildOrderItems(value, order),
                _buildOrderFooter(value, order),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildOrderHeader(HistoryController value, dynamic order) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _getStatusColor(order.status).withOpacity(0.1),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              _buildCustomerAvatar(order),
              const SizedBox(width: 12),
              Expanded(child: _buildCustomerInfo(order)),
              _buildStatusChip(value, order.status),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            height: 1,
            color: Colors.grey[200],
          ),
        ],
      ),
    );
  }

  Widget _buildCustomerAvatar(dynamic order) {
    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: AppNetImage(
          path: order.userInfo!.cover,
          fit: BoxFit.cover,
          placeholder: Container(
            color: Colors.grey[100],
            child: Icon(
              Icons.person_outline,
              color: Colors.grey[400],
              size: 28,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCustomerInfo(dynamic order) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '${order.userInfo!.firstName} ${order.userInfo!.lastName}',
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 16,
            color: Colors.black87,
          ),
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 4),
        Text(
          '${order.address!.address} ${order.address!.landmark}',
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: 14,
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 4),
        Text(
          'Order #${order.id}',
          style: TextStyle(
            color: Colors.grey[500],
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildStatusChip(HistoryController value, int status) {
    final statusName = value.statusName[status] ?? 'Unknown';
    final statusColor = _getStatusColor(status);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: statusColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        statusName.tr,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w600,
          fontSize: 12,
        ),
      ),
    );
  }

  Widget _buildOrderItems(HistoryController value, dynamic order) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Order Items',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 16,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 12),
          ...order.orders!
              .map<Widget>((item) => _buildOrderItem(value, item))
              .toList(),
        ],
      ),
    );
  }

  Widget _buildOrderItem(HistoryController value, dynamic item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.name.toString(),
                  style: const TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Quantity: ${item.quantity}',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              if (item.originalPrice != item.sellPrice)
                Text(
                  _formatPrice(value, item.originalPrice),
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                    decoration: TextDecoration.lineThrough,
                  ),
                ),
              Text(
                _formatPrice(value, item.sellPrice),
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                  color: ThemeProvider.greenColor,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildOrderFooter(HistoryController value, dynamic order) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(16),
          bottomRight: Radius.circular(16),
        ),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Grand Total',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                  color: Colors.black87,
                ),
              ),
              Text(
                _formatPrice(value, order.grandTotal),
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 18,
                  color: ThemeProvider.appColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            height: 1,
            color: Colors.grey[200],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.access_time_outlined,
                    size: 16,
                    color: Colors.grey[600],
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Order Date',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
              Text(
                order.createdAt.toString(),
                style: const TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 14,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(60),
            ),
            child: Icon(
              Icons.receipt_long_outlined,
              size: 60,
              color: Colors.grey[400],
            ),
          ),
          const SizedBox(height: 24),
          Text(
            message.tr,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Your orders will appear here once they are placed.',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(int status) {
    // You can customize these colors based on your status values
    switch (status) {
      case 0:
        return Colors.orange; // Pending
      case 1:
        return Colors.blue; // Confirmed
      case 2:
        return Colors.purple; // In Progress
      case 3:
        return Colors.green; // Completed
      case 4:
        return Colors.red; // Cancelled
      default:
        return ThemeProvider.appColor;
    }
  }

  String _formatPrice(HistoryController value, dynamic price) {
    return value.currencySide == 'left'
        ? '${value.currencySymbol}$price'
        : '$price${value.currencySymbol}';
  }
}

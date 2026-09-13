import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ultimate_salon_owner_flutter/app/backend/models/notification_model.dart';
import 'package:ultimate_salon_owner_flutter/app/controller/notification_controller.dart';
import 'package:ultimate_salon_owner_flutter/app/controller/withdrawal_controller.dart';
import 'package:ultimate_salon_owner_flutter/app/helper/router.dart';
import 'package:ultimate_salon_owner_flutter/app/util/theme.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({Key? key}) : super(key: key);

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  @override
  Widget build(BuildContext context) {
    return GetBuilder<NotificationController>(
      builder: (controller) {
        return Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios,
                  color: ThemeProvider.appColor),
              onPressed: () => Navigator.of(context).pop(),
            ),
            title: Text(
              'Notifications'.tr,
              style: const TextStyle(
                color: ThemeProvider.appColor,
                fontSize: 24,
                fontWeight: FontWeight.w700,
              ),
            ),
            centerTitle: true,
            actions: [
              IconButton(
                icon: Icon(Icons.refresh, color: ThemeProvider.appColor),
                onPressed: () {
                  // Add clear all notifications functionality
                  controller.getAllNotifications(controller.uid);
                },
              ),
              SizedBox(
                width: 5,
              )
            ],
          ),
          body: controller.apiCalled
              ? const Center(
                  child: CircularProgressIndicator(
                    color: ThemeProvider.appColor,
                    strokeWidth: 3,
                  ),
                )
              : controller.notificationList.isEmpty
                  ? _buildEmptyNotificationsView()
                  : _buildNotificationsList(controller),
        );
      },
    );
  }

  Widget _buildEmptyNotificationsView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            'assets/images/no_notifications.png',
            height: 150,
            width: 150,
            errorBuilder: (context, error, stackTrace) => Icon(
              Icons.notifications_off,
              size: 80,
              color: Colors.grey[400],
            ),
          ),
          const SizedBox(height: 20),
          Text(
            "No notifications yet".tr,
            style: TextStyle(
              fontSize: 22,
              color: Colors.grey[800],
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            "You're all caught up!".tr,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationsList(NotificationController controller) {
    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      itemCount: controller.notificationList.length,
      separatorBuilder: (context, index) => const SizedBox(height: 16),
      itemBuilder: (context, index) {
        var notification = controller.notificationList[index];
        return GestureDetector(
          onTap: () {
            // controller.showNotificationDialog(context, notification);
          },
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.15),
                  spreadRadius: 1,
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
              border: Border.all(
                color: notification.status == 'Unread'
                    ? ThemeProvider.appColor.withOpacity(0.3)
                    : Colors.transparent,
                width: 1.5,
              ),
            ),
            child: Column(
              children: [
                // Top section with status indicator and time
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: notification.status == 'Unread'
                        ? ThemeProvider.appColor.withOpacity(0.05)
                        : Colors.grey[50],
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(16),
                      topRight: Radius.circular(16),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Order/Appointment ID
                      Row(
                        children: [
                          Icon(
                            _getNotificationTypeIcon(notification.type),
                            size: 16,
                            color: ThemeProvider.appColor,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            _getIdDisplay(notification),
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                              color: Colors.grey[800],
                            ),
                          ),
                        ],
                      ),
                      // Date and status indicator
                      Row(
                        children: [
                          Text(
                            notification.data.date,
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: notification.status == 'Unread'
                                  ? Colors.red
                                  : Colors.transparent,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                // Main content
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Notification icon
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: _getNotificationColor(notification.type)
                              .withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          _getNotificationContentIcon(notification.type),
                          color: _getNotificationColor(notification.type),
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 16),
                      // Notification content
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              notification.title,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: Colors.grey[900],
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              notification.data.businessName,
                              style: TextStyle(
                                fontWeight: FontWeight.w500,
                                fontSize: 14,
                                color: ThemeProvider.appColor,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              notification.message,
                              style: TextStyle(
                                color: Colors.grey[700],
                                fontSize: 14,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                // Bottom section with price and action button
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(16),
                      bottomRight: Radius.circular(16),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Price
                      notification.type == 'Withdrawal'
                          ? Container()
                          : Text(
                              'INR ${notification.data.price.toStringAsFixed(2)}',
                              style: TextStyle(
                                color: ThemeProvider.appColor,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                      // Action button
                      ElevatedButton(
                        onPressed: () {
                          if (notification.type == 'Withdrawal') {
                            Get.delete<WithdrawalsController>(force: true);
                            Get.toNamed(AppRouter.getWithdrawalsRoute());
                            return;
                          }

                          // Handle action based on notification type
                          // controller.handleNotificationAction(notification);
                          controller.showNotificationDialog(
                              context, notification);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: ThemeProvider.appColor,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 8),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: Text(
                          _getActionButtonText(
                              notification.type, notification.data.status),
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  String _getIdDisplay(NotificationItem notification) {
    if (notification.type == 'Appointment' &&
        notification.data.appointmentId != null) {
      return "Appointment #${notification.data.appointmentId}".tr;
    } else if (notification.type == 'Product' &&
        notification.data.orderId != null) {
      return "Order #${notification.data.orderId}".tr;
    } else {
      return "${notification.type.capitalize} #${notification.id}".tr;
    }
  }

  IconData _getNotificationTypeIcon(String type) {
    switch (type.toLowerCase()) {
      case 'appointment':
        return Icons.calendar_today;
      case 'order':
        return Icons.shopping_bag;
      case 'promotion':
        return Icons.local_offer;
      case 'payment':
        return Icons.payment;
      case 'Product':
        return Icons.shopping_bag;
      case 'Withdrawal':
        return Icons.attach_money;
      default:
        return Icons.notifications;
    }
  }

  IconData _getNotificationContentIcon(String type) {
    switch (type.toLowerCase()) {
      case 'appointment':
        return Icons.event_available;
      case 'order':
        return Icons.shopping_cart;
      case 'promotion':
        return Icons.discount;
      case 'payment':
        return Icons.attach_money;
      case 'Product':
        return Icons.shopping_bag;
      case 'Withdrawal':
        return Icons.attach_money;
      default:
        return Icons.notifications_active;
    }
  }

  Color _getNotificationColor(String type) {
    switch (type.toLowerCase()) {
      case 'appointment':
        return Colors.purple;
      case 'order':
        return Colors.blue;
      case 'promotion':
        return Colors.orange;
      case 'payment':
        return Colors.green;
      case 'Product':
        return Colors.amber;
      case 'Withdrawal':
        return Colors.blue;
      default:
        return ThemeProvider.appColor;
    }
  }

  String _getActionButtonText(String type, String status) {
    switch (type.toLowerCase()) {
      case 'appointment':
        switch (status.toLowerCase()) {
          case 'confirmed':
            return 'View Details'.tr;
          case 'pending':
            return 'Confirm Now'.tr;
          case 'cancelled':
            return 'Rebook'.tr;
          case 'completed':
            return 'Rate Service'.tr;
          default:
            return 'View'.tr;
        }
      case 'order':
        switch (status.toLowerCase()) {
          case 'processing':
            return 'Track Order'.tr;
          case 'delivered':
            return 'Review'.tr;
          case 'cancelled':
            return 'Reorder'.tr;
          case 'completed':
            return 'Buy Again'.tr;
          default:
            return 'View Order'.tr;
        }
      case 'payment':
        return 'View Receipt'.tr;
      case 'promotion':
        return 'Use Now'.tr;
      default:
        return 'View'.tr;
    }
  }
}

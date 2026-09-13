import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ultimate_salon_owner_flutter/app/backend/api/handler.dart';
import 'package:ultimate_salon_owner_flutter/app/backend/models/notification_model.dart';
import 'package:ultimate_salon_owner_flutter/app/backend/parse/notification_parser.dart';
import 'package:ultimate_salon_owner_flutter/app/controller/order_details_controller.dart';
import 'package:ultimate_salon_owner_flutter/app/controller/product_order_details_controller.dart';
import 'package:ultimate_salon_owner_flutter/app/helper/router.dart';
import 'package:ultimate_salon_owner_flutter/app/util/theme.dart';

class NotificationController extends GetxController implements GetxService {
  final NotificationParser parser;
  String uid = '';
  bool apiCalled = false;
  List<NotificationItem> _notificationList =
      []; // Changed to List<NotificationItem>
  List<NotificationItem> get notificationList => _notificationList;
  NotificationController({required this.parser});

  @override
  void onInit() {
    super.onInit();
    uid = parser.getUID();
    getAllNotifications(uid);
  }

  void showNotificationDialog(
      BuildContext context, NotificationItem notification) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 10,
                  offset: Offset(0, 5),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header with icon and title
                Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: ThemeProvider.appColor.withOpacity(0.1),
                      child: const Icon(
                        Icons.notifications_active,
                        color: ThemeProvider.appColor,
                      ),
                    ),
                    const SizedBox(width: 15),
                    Expanded(
                      child: Text(
                        notification.title,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: Colors.black87,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                // Notification Details
                _buildDetailRow(
                  icon: Icons.monetization_on,
                  label: 'Price',
                  value: notification.data.price.toString(),
                ),

                _buildDetailRow(
                  icon: Icons.business,
                  label: 'Customer Name',
                  value: notification.data.customerName,
                ),

                _buildDetailRow(
                  icon: Icons.calendar_today,
                  label: 'Date',
                  value: notification.data.date,
                ),

                const SizedBox(height: 15),

                // Message Section
                Text(
                  notification.message,
                  style: TextStyle(
                    color: Colors.grey[800],
                    fontSize: 16,
                    height: 1.5,
                  ),
                ),

                const SizedBox(height: 20),

                // Action Buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Dismiss Button
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: Text(
                        'Dismiss',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),

                    // More Info Button
                    ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                        readNotifications(notification.id.toString());

                        if (notification.data.appointmentId != null) {
                          onAppointment(notification.data.appointmentId!);
                        } else if (notification.data.orderId != null) {
                          onProductDetail(notification.data.orderId!);
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: ThemeProvider.appColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        elevation: 2,
                      ),
                      child: const Text(
                        'More Details',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

// Helper method to create consistent detail rows
  Widget _buildDetailRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(
            icon,
            color: ThemeProvider.appColor.withOpacity(0.7),
            size: 20,
          ),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                value,
                style: const TextStyle(
                  color: Colors.black87,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void onProductDetail(int id) {
    Get.delete<ProductOrderDetailsController>(force: true);
    Get.toNamed(AppRouter.getProductOrderDetailsRoutes(), arguments: [id]);
  }

  void onAppointment(int id) {
    Get.delete<OrderDetailsController>(force: true);
    Get.toNamed(AppRouter.getOrderDetailsRoute(), arguments: [id]);
  }

  Future<void> getAllNotifications(String uid) async {
    uid = parser.getUID();

    apiCalled = true;
    update();
    Response response = await parser.getAllNotification(uid);
    apiCalled = true;
    if (response.statusCode == 200) {
      Map<String, dynamic> jsonData = Map<String, dynamic>.from(response.body);
      NotificationModel notificationResponse =
          NotificationModel.fromJson(jsonData);
      if (notificationResponse.success) {
        _notificationList = notificationResponse.data.reversed
            .toList(); // Directly assign the data list
        debugPrint(notificationList.length.toString());
      }
      apiCalled = false;
    } else {
      ApiChecker.checkApi(response);
      apiCalled = false;

      update();
    }
    update();
  }

  Future<void> readNotifications(String id) async {
    Response response = await parser.readNotification(id);
    apiCalled = true;
    if (response.statusCode == 200) {
      getAllNotifications(uid); // Refresh the list after marking as read
    } else {
      ApiChecker.checkApi(response);
    }
    update();
  }
}

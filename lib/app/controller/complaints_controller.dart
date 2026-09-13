// complaints_controller.dart
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ultimate_salon_owner_flutter/app/backend/api/handler.dart';
import 'package:ultimate_salon_owner_flutter/app/backend/models/complaint_model.dart';
import 'package:ultimate_salon_owner_flutter/app/backend/parse/complaint_parse.dart';
import 'package:ultimate_salon_owner_flutter/app/controller/order_details_controller.dart';
import 'package:ultimate_salon_owner_flutter/app/controller/product_order_details_controller.dart';
import 'package:ultimate_salon_owner_flutter/app/helper/router.dart';

class ComplaintsController extends GetxController implements GetxService {
  final ComplaintParser parser;

  // Basic properties
  bool apiCalled = false;
  bool updateApiCalled = false;

  // Complaints data
  List<Complaint> _complaints = <Complaint>[];
  List<Complaint> get complaints => _complaints;

  // Filter properties
  int uid = 0;
  int freelancerId = 0;

  ComplaintsController({required this.parser});

  @override
  void onInit() {
    super.onInit();
    // if (Get.arguments != null && Get.arguments.isNotEmpty) {
    getComplaints();
    // }
  }

  // Get complaints from API
  Future<void> getComplaints() async {
    try {
      apiCalled = false;
      update();

      var response = await parser.getComplaintsById({
        "uid": 0,
        "freelancer_id": parser.getUId(),
      });

      apiCalled = true;

      if (response.statusCode == 200) {
        debugPrint('Complaints Response: ${response.bodyString}');

        Map<String, dynamic> myMap = Map<String, dynamic>.from(response.body);

        if (myMap['success'] == true && myMap['data'] != null) {
          _complaints = [];
          var complaintsData = myMap['data'] as List;

          for (var element in complaintsData) {
            Complaint complaint = Complaint.fromJson(element);
            _complaints.add(complaint);
          }
        }
      } else {
        ApiChecker.checkApi(response);
      }
    } catch (e) {
      debugPrint('Error getting complaints: $e');
      apiCalled = true;
    }
    update();
  }

  // Update complaint status
  Future<void> updateComplaintStatus(int complaintId, int status) async {
    try {
      updateApiCalled = true;
      update();

      var response = await parser.updateComplaintsById({
        "id": complaintId,
        "status": status,
      });

      updateApiCalled = false;

      if (response.statusCode == 200) {
        debugPrint('Update Response: ${response.bodyString}');

        Map<String, dynamic> myMap = Map<String, dynamic>.from(response.body);

        if (myMap['success'] == true) {
          // Update local complaint status
          int index = _complaints
              .indexWhere((complaint) => complaint.id == complaintId);
          if (index != -1) {
            _complaints[index] = _complaints[index].copyWith(status: status);
          }

          Get.snackbar(
            'Success',
            'Complaint status updated successfully',
            snackPosition: SnackPosition.BOTTOM,
          );
        }
      } else {
        ApiChecker.checkApi(response);
      }
    } catch (e) {
      debugPrint('Error updating complaint: $e');
      updateApiCalled = false;
      Get.snackbar(
        'Error',
        'Failed to update complaint status',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
    update();
  }

  // Refresh complaints
  Future<void> onRefresh() async {
    await getComplaints();
  }

  // Get status text
  String getStatusText(int status) {
    switch (status) {
      case 0:
        return 'Pending';
      case 1:
        return 'Resolved';
      case 2:
        return 'Rejected';
      default:
        return 'Unknown';
    }
  }

  // Get status color
  Color getStatusColor(int status) {
    switch (status) {
      case 0:
        return Colors.orange;
      case 1:
        return Colors.green;
      case 2:
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  void onProductDetail(int id) {
    Get.delete<ProductOrderDetailsController>(force: true);
    Get.toNamed(AppRouter.getProductOrderDetailsRoutes(), arguments: [id]);
  }

  void onAppointment(int id) {
    Get.delete<OrderDetailsController>(force: true);
    Get.toNamed(AppRouter.getOrderDetailsRoute(), arguments: [id]);
  }
}

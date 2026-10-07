import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:ultimate_salon_owner_flutter/app/controller/coupon_controller.dart';
import 'package:ultimate_salon_owner_flutter/app/util/app_image.dart';
import 'package:ultimate_salon_owner_flutter/app/util/currency_helper.dart';
import 'package:ultimate_salon_owner_flutter/app/util/theme.dart';

import '../backend/models/coupons_model.dart';

class CouponsScreen extends StatefulWidget {
  const CouponsScreen({Key? key}) : super(key: key);
  @override
  State<CouponsScreen> createState() => _CouponsScreenState();
}

class _CouponsScreenState extends State<CouponsScreen> {
  @override
  Widget build(BuildContext context) {
    return GetBuilder<CouponsController>(builder: (_controller) {
      return Scaffold(
        backgroundColor: Colors.grey[50],
        floatingActionButtonLocation: FloatingActionButtonLocation.startFloat,
        floatingActionButton: FloatingActionButton.small(
          heroTag: 'add_offer_fab',
          onPressed: () {
            Get.to(() => CouponFormScreen());
          },
          backgroundColor: ThemeProvider.golden,
          foregroundColor: Colors.black,
          tooltip: 'Add Offer'.tr,
          child: const Icon(Icons.add, size: 22),
        ),
        body: CustomScrollView(
          slivers: [
            SliverAppBar(
              expandedHeight: 60,
              floating: true,
              pinned: true,
              backgroundColor: Colors.black87,
              foregroundColor: Colors.white,
              elevation: 0,
              flexibleSpace: FlexibleSpaceBar(
                title: Text(
                  'Offers'.tr,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
                titlePadding: const EdgeInsets.only(left: 56, bottom: 16),
              ),
            ),
            SliverToBoxAdapter(
              child: _controller.isLoading.value
                  ? const SizedBox(
                      height: 400,
                      child: Center(child: CircularProgressIndicator()),
                    )
                  : Obx(() {
                      if (_controller.coupons.isEmpty) {
                        return _buildEmptyState();
                      }
                      return Padding(
                        padding: const EdgeInsets.fromLTRB(16, 16, 16, 88),
                        child: Column(
                          children: [
                            _buildStatsCard(_controller),
                            const SizedBox(height: 20),
                            ..._controller.coupons
                                .map((coupon) =>
                                    _buildCouponCard(coupon, _controller))
                                .toList(),
                          ],
                        ),
                      );
                    }),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildStatsCard(CouponsController controller) {
    final activeCoupons = controller.coupons.where((c) => c.status == 1).length;
    final totalCoupons = controller.coupons.length;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color.fromARGB(255, 53, 53, 53),
            Color.fromARGB(255, 75, 75, 75)
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Color.fromARGB(255, 59, 59, 59).withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Active Offers'.tr,
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 8),
                Text('$activeCoupons'.tr,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                const Icon(
                  Icons.confirmation_number_outlined,
                  color: Colors.white,
                  size: 32,
                ),
                const SizedBox(height: 8),
                Text('$totalCoupons'.tr,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCouponCard(CouponModel coupon, CouponsController controller) {
    final DateTime? expiryDate = DateTime.tryParse(coupon.expire);
    final bool isExpired =
        expiryDate != null && expiryDate.isBefore(DateTime.now());
    final bool isActive = coupon.status == 1 && !isExpired;

    // Calculate days until expiry
    String expiryInfo = '';
    Color statusColor = _getStatusColor(isExpired, isActive);
    IconData statusIcon = _getStatusIcon(isExpired, isActive);

    if (expiryDate != null) {
      final daysLeft = expiryDate.difference(DateTime.now()).inDays + 1;
      if (isExpired) {
        expiryInfo =
            'Expired on ${DateFormat('MMM dd, yyyy').format(expiryDate)}';
      } else if (daysLeft <= 7) {
        expiryInfo = 'Expires in $daysLeft ${daysLeft == 1 ? 'day' : 'days'}';
      } else {
        expiryInfo =
            'Valid until ${DateFormat('MMM dd, yyyy').format(expiryDate)}';
      }
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: Colors.white,
        border: Border.all(
          color: const Color(0xFFE5E7EB),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF000000).withOpacity(0.04),
            blurRadius: 16,
            offset: const Offset(0, 4),
            spreadRadius: -2,
          ),
          BoxShadow(
            color: const Color(0xFF000000).withOpacity(0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Column(
          children: [
            if (coupon.displayImage.isNotEmpty)
              SizedBox(
                height: 140,
                width: double.infinity,
                child: AppNetImage(
                  path: coupon.displayImage,
                  fit: BoxFit.cover,
                ),
              ),
            // Header Section
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    isActive
                        ? const Color(0xFFF8FAFC)
                        : const Color(0xFFF9FAFB),
                    isActive
                        ? const Color(0xFFEEF2FF)
                        : const Color(0xFFF3F4F6),
                  ],
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title and Status Row
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              coupon.name,
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF111827),
                                letterSpacing: -0.5,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              coupon.shortDescription,
                              style: const TextStyle(
                                color: Color(0xFF6B7280),
                                fontSize: 15,
                                height: 1.5,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      _buildStatusBadge(
                          isExpired, isActive, statusColor, statusIcon),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // Coupon Code Section
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: const Color(0xFFE5E7EB),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: const Color(0xFF3B82F6).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Icons.confirmation_number_outlined,
                            color: Color(0xFF3B82F6),
                            size: 18,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Coupon Code'.tr,
                                style: TextStyle(
                                  color: Color(0xFF6B7280),
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  letterSpacing: 0.3,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                coupon.code,
                                style: const TextStyle(
                                  color: Color(0xFF111827),
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 1,
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Container(
                        //   padding: const EdgeInsets.symmetric(
                        //       horizontal: 8, vertical: 4),
                        //   decoration: BoxDecoration(
                        //     color: const Color(0xFF3B82F6).withOpacity(0.1),
                        //     borderRadius: BorderRadius.circular(6),
                        //   ),
                        //   child: const Text(
                        //     'COPY',
                        //     style: TextStyle(
                        //       color: Color(0xFF3B82F6),
                        //       fontSize: 10,
                        //       fontWeight: FontWeight.w600,
                        //       letterSpacing: 0.5,
                        //     ),
                        //   ),
                        // ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Content Section
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  // Discount Information Grid
                  Row(
                    children: [
                      Expanded(
                        child: _buildMetricCard(
                          icon: Icons.local_fire_department_rounded,
                          label: 'Discount'.tr,
                          value: coupon.isPercent
                              ? '${coupon.discount}%'
                              : CurrencyHelper.format(coupon.discount),
                          color: const Color(0xFFEF4444),
                          backgroundColor: const Color(0xFFFEF2F2),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildMetricCard(
                          icon: Icons.savings_rounded,
                          label: 'Max Save'.tr,
                          value: CurrencyHelper.format(coupon.upto),
                          color: const Color(0xFF10B981),
                          backgroundColor: const Color(0xFFF0FDF4),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  Row(
                    children: [
                      Expanded(
                        child: _buildMetricCard(
                          icon: Icons.shopping_cart_rounded,
                          label: 'Min Cart'.tr,
                          value: CurrencyHelper.format(coupon.minCartValue),
                          color: const Color(0xFF3B82F6),
                          backgroundColor: const Color(0xFFEFF6FF),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildMetricCard(
                          icon: Icons.repeat_rounded,
                          label: 'Max Uses'.tr,
                          value: '${coupon.maxUsage}',
                          color: const Color(0xFF8B5CF6),
                          backgroundColor: const Color(0xFFF5F3FF),
                        ),
                      ),
                    ],
                  ),

                  // Expiry Information
                  if (expiryDate != null) ...[
                    const SizedBox(height: 20),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: _getExpiryBackgroundColor(isExpired, expiryDate),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: _getExpiryBorderColor(isExpired, expiryDate),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: _getExpiryIconBackgroundColor(
                                  isExpired, expiryDate),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(
                              _getExpiryIcon(isExpired, expiryDate),
                              color: _getExpiryIconColor(isExpired, expiryDate),
                              size: 16,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              expiryInfo,
                              style: TextStyle(
                                color:
                                    _getExpiryTextColor(isExpired, expiryDate),
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],

                  if (coupon.startDate.isNotEmpty ||
                      coupon.couponScope.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        if (coupon.startDate.isNotEmpty)
                          Expanded(
                            child: Text(
                              'Starts ${coupon.startDate}',
                              style: const TextStyle(
                                color: Color(0xFF6B7280),
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        if (coupon.couponScope.isNotEmpty)
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: const Color(0xFFEEF2FF),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              coupon.couponScope,
                              style: const TextStyle(
                                color: Color(0xFF4338CA),
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ],

                  if (coupon.applyAllServices ||
                      coupon.services.isNotEmpty ||
                      coupon.serviceIds.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          if (coupon.applyAllServices)
                            _buildServiceChip('All services')
                          else if (coupon.services.isNotEmpty)
                            ...coupon.services.map(
                                (service) => _buildServiceChip(service.name))
                          else
                            ...coupon.serviceIds.map(
                                (id) => _buildServiceChip('Service #$id')),
                        ],
                      ),
                    ),
                  ],

                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Text('Active'.tr,
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF374151),
                        ),
                      ),
                      const Spacer(),
                      Switch(
                        value: coupon.status == 1,
                        activeThumbColor: ThemeProvider.appColor,
                        onChanged: (_) => controller.toggleStatus(coupon),
                      ),
                    ],
                  ),

                  const SizedBox(height: 8),

                  // Action Buttons
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () {
                            Get.to(() => CouponFormScreen(coupon: coupon));
                          },
                          icon: const Icon(Icons.edit_rounded, size: 18),
                          label: Text('Edit Offer'.tr),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Color.fromARGB(255, 54, 54, 54),
                            side: const BorderSide(
                              color: Color.fromARGB(255, 55, 55, 55),
                              width: 1.5,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            textStyle: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            _showDeleteConfirmationDialog(
                                context, coupon, controller);
                          },
                          icon: const Icon(Icons.delete_rounded, size: 18),
                          label: Text('Delete'.tr),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFFEF2F2),
                            foregroundColor: const Color(0xFFDC2626),
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            textStyle: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBadge(
      bool isExpired, bool isActive, Color statusColor, IconData statusIcon) {
    String statusText = isExpired
        ? 'Expired'
        : isActive
            ? 'Active'
            : 'Inactive';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: statusColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: statusColor.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            statusIcon,
            color: statusColor,
            size: 14,
          ),
          const SizedBox(width: 6),
          Text(
            statusText,
            style: TextStyle(
              color: statusColor,
              fontWeight: FontWeight.w600,
              fontSize: 12,
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricCard({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
    required Color backgroundColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Icon(
                  icon,
                  size: 16,
                  color: color,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    color: color.withOpacity(0.8),
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 0.2,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 18,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.3,
            ),
          ),
        ],
      ),
    );
  }

// Helper methods for status and expiry styling
  Color _getStatusColor(bool isExpired, bool isActive) {
    if (isExpired) return const Color(0xFFDC2626);
    if (isActive) return const Color(0xFF10B981);
    return const Color(0xFFF59E0B);
  }

  IconData _getStatusIcon(bool isExpired, bool isActive) {
    if (isExpired) return Icons.block_rounded;
    if (isActive) return Icons.check_circle_rounded;
    return Icons.pause_circle_rounded;
  }

  Color _getExpiryBackgroundColor(bool isExpired, DateTime expiryDate) {
    if (isExpired) return const Color(0xFFFEF2F2);
    final daysLeft = expiryDate.difference(DateTime.now()).inDays;
    if (daysLeft <= 7) return const Color(0xFFFEF3C7);
    return const Color(0xFFF0FDF4);
  }

  Color _getExpiryBorderColor(bool isExpired, DateTime expiryDate) {
    if (isExpired) return const Color(0xFFFECACA);
    final daysLeft = expiryDate.difference(DateTime.now()).inDays;
    if (daysLeft <= 7) return const Color(0xFFFDE68A);
    return const Color(0xFFBBF7D0);
  }

  Color _getExpiryIconBackgroundColor(bool isExpired, DateTime expiryDate) {
    if (isExpired) return const Color(0xFFDC2626).withOpacity(0.1);
    final daysLeft = expiryDate.difference(DateTime.now()).inDays;
    if (daysLeft <= 7) return const Color(0xFFF59E0B).withOpacity(0.1);
    return const Color(0xFF10B981).withOpacity(0.1);
  }

  Color _getExpiryIconColor(bool isExpired, DateTime expiryDate) {
    if (isExpired) return const Color(0xFFDC2626);
    final daysLeft = expiryDate.difference(DateTime.now()).inDays;
    if (daysLeft <= 7) return const Color(0xFFF59E0B);
    return const Color(0xFF10B981);
  }

  Color _getExpiryTextColor(bool isExpired, DateTime expiryDate) {
    if (isExpired) return const Color(0xFFDC2626);
    final daysLeft = expiryDate.difference(DateTime.now()).inDays;
    if (daysLeft <= 7) return const Color(0xFFA16207);
    return const Color(0xFF059669);
  }

  IconData _getExpiryIcon(bool isExpired, DateTime expiryDate) {
    if (isExpired) return Icons.error_outline_rounded;
    final daysLeft = expiryDate.difference(DateTime.now()).inDays;
    if (daysLeft <= 7) return Icons.warning_amber_rounded;
    return Icons.check_circle_outline_rounded;
  }

  Widget _buildInfoChip({
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      height: 400,
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: Colors.grey[100],
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.confirmation_number_outlined,
              size: 60,
              color: Colors.grey[400],
            ),
          ),
          const SizedBox(height: 24),
          Text('No Offers Yet'.tr,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          Text('Create your first offer to start giving discounts to your customers'.tr,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
              height: 1.4,
            ),
          ),
          const SizedBox(height: 32),
          ElevatedButton.icon(
            onPressed: () {
              Get.to(() => CouponFormScreen());
            },
            icon: const Icon(Icons.add),
            label: Text('Create Offer'.tr),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF6C5CE7),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildServiceChip(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFF3F4F6),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: Color(0xFF374151),
        ),
      ),
    );
  }

  void _showDeleteConfirmationDialog(
      BuildContext context, CouponModel coupon, CouponsController controller) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Row(
            children: [
              Icon(Icons.warning_amber_rounded, color: Colors.red, size: 28),
              SizedBox(width: 12),
              Text("Delete Offer".tr),
            ],
          ),
          content: Text(
            "Are you sure you want to delete the offer '${coupon.name}'? This action cannot be undone.",
            style: const TextStyle(fontSize: 16),
          ),
          actions: <Widget>[
            TextButton(
              child: Text("Cancel".tr),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: Text("Delete".tr),
              onPressed: () {
                controller.deleteCoupons(coupon.id);
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}

// Enhanced Form Screen
class CouponFormScreen extends StatefulWidget {
  final CouponModel? coupon;

  const CouponFormScreen({Key? key, this.coupon}) : super(key: key);

  @override
  State<CouponFormScreen> createState() => _CouponFormScreenState();
}

class _CouponFormScreenState extends State<CouponFormScreen> {
  final CouponsController _controller = Get.find();
  final _formKey = GlobalKey<FormState>();

  final TextEditingController nameController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController codeController = TextEditingController();
  final TextEditingController discountController = TextEditingController();
  final TextEditingController uptoController = TextEditingController();
  final TextEditingController startDateController = TextEditingController();
  final TextEditingController expireController = TextEditingController();
  final TextEditingController maxUsageController = TextEditingController();
  final TextEditingController minCartValueController = TextEditingController();
  final TextEditingController originalAmountController = TextEditingController();
  final TextEditingController discountedAmountController = TextEditingController();
  int selectedType = 1;
  bool applyAllServices = false;
  final Set<int> selectedServiceIds = {};
  bool _recalcLock = false;
  XFile? _imageFile;

  @override
  void initState() {
    super.initState();
    discountController.addListener(_recalculateAmounts);
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _controller.fetchPartnerServices();
      if (!mounted) return;
      setState(() {
        _syncAllServicesFromSelection(_controller.partnerServices);
        if (applyAllServices && selectedServiceIds.isEmpty) {
          selectedServiceIds
              .addAll(_controller.partnerServices.map((s) => s.id));
        }
      });
      _syncOriginalFromServices();
      _recalculateAmounts();
    });
    if (widget.coupon != null) {
      nameController.text = widget.coupon!.name;
      descriptionController.text = widget.coupon!.shortDescription;
      codeController.text = widget.coupon!.code;
      discountController.text = widget.coupon!.discount.toString();
      uptoController.text = widget.coupon!.upto.toString();
      startDateController.text = widget.coupon!.startDate;
      expireController.text = widget.coupon!.expire;
      maxUsageController.text = widget.coupon!.maxUsage.toString();
      minCartValueController.text = widget.coupon!.minCartValue.toString();
      selectedType = widget.coupon!.type == 0 ? 1 : widget.coupon!.type;
      applyAllServices = widget.coupon!.applyAllServices;
      selectedServiceIds.addAll(widget.coupon!.serviceIds);
    }
  }

  void _syncAllServicesFromSelection(List services) {
    if (services.isEmpty) {
      applyAllServices = false;
      return;
    }
    final allSelected =
        services.every((s) => selectedServiceIds.contains(s.id));
    applyAllServices = allSelected;
  }

  double _selectedServicesTotal() {
    final services = applyAllServices
        ? _controller.partnerServices
        : _controller.partnerServices
            .where((service) => selectedServiceIds.contains(service.id));
    return services.fold<double>(0, (sum, service) => sum + service.price);
  }

  void _syncOriginalFromServices() {
    final total = _selectedServicesTotal();
    _recalcLock = true;
    originalAmountController.text =
        total > 0 ? total.toStringAsFixed(2) : '0.00';
    _recalcLock = false;
  }

  void _recalculateAmounts() {
    if (_recalcLock) return;
    _recalcLock = true;
    final original = double.tryParse(originalAmountController.text) ?? 0;
    final discount = double.tryParse(discountController.text) ?? 0;
    double discounted = original;
    if (selectedType == 1) {
      discounted = original - ((original * discount) / 100);
    } else {
      discounted = original - discount;
    }
    if (discounted < 0) discounted = 0;
    discountedAmountController.text = discounted.toStringAsFixed(2);
    _recalcLock = false;
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
        title: Text(
          widget.coupon == null ? 'Create Offer' : 'Update Offer',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            _buildFormCard([
              OfferImagePickerTile(
                file: _imageFile,
                existingUrl: widget.coupon?.displayImage,
                onPick: _pickOfferImage,
                onClear: () => setState(() => _imageFile = null),
              ),
              _buildServicePicker(),
            ]),
            const SizedBox(height: 20),
            _buildFormCard([
              _buildTextField(
                controller: nameController,
                label: 'Offer Name'.tr,
                hint: 'Enter offer name'.tr,
                icon: Icons.local_offer,
                validator: 'Please enter an offer name',
              ),
              _buildTextField(
                controller: descriptionController,
                label: 'Description'.tr,
                hint: 'Enter offer description'.tr,
                icon: Icons.description,
                validator: 'Please enter a description',
                maxLines: 3,
              ),
              _buildTextField(
                controller: codeController,
                label: 'Offer Code'.tr,
                hint: 'Enter unique offer code'.tr,
                icon: Icons.code,
                validator: 'Please enter an offer code',
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: DropdownButtonFormField<int>(
                  value: selectedType,
                  decoration: InputDecoration(
                    labelText: 'Discount Type'.tr,
                    prefixIcon: const Icon(Icons.tune, color: Color(0xFF6C5CE7)),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: Colors.grey[50],
                  ),
                  items: [
                    DropdownMenuItem(value: 1, child: Text('Percentage (%)'.tr)),
                    DropdownMenuItem(
                        value: 2,
                        child: Text('Flat Amount (${CurrencyHelper.code()})')),
                  ],
                  onChanged: (value) {
                    if (value != null) {
                      setState(() => selectedType = value);
                      _recalculateAmounts();
                    }
                  },
                ),
              ),
            ]),
            const SizedBox(height: 20),
            _buildFormCard([
              _buildTextField(
                controller: originalAmountController,
                label: 'Original Amount (${CurrencyHelper.code()})'.tr,
                hint: '0.00'.tr,
                icon: Icons.payments_outlined,
                isNumeric: true,
                readOnly: true,
                validator: '',
              ),
              _buildTextField(
                controller: discountController,
                label: selectedType == 1
                    ? 'Discount (%)'
                    : 'Discount (${CurrencyHelper.code()})',
                hint: '0'.tr,
                icon: Icons.percent,
                validator: 'Please enter discount',
                isNumeric: true,
              ),
              _buildTextField(
                controller: discountedAmountController,
                label: 'Discounted Amount (${CurrencyHelper.code()})'.tr,
                hint: '0.00'.tr,
                icon: Icons.sell_outlined,
                isNumeric: true,
                readOnly: true,
                validator: '',
              ),
              _buildTextField(
                controller: uptoController,
                label: 'Max Discount (${CurrencyHelper.code()})',
                hint: '0'.tr,
                icon: Icons.payments,
                validator: 'Please enter max discount',
                isNumeric: true,
              ),
              _buildTextField(
                controller: minCartValueController,
                label: 'Min Cart Value (${CurrencyHelper.code()})',
                hint: '0'.tr,
                icon: Icons.shopping_cart,
                validator: 'Please enter min cart value',
                isNumeric: true,
              ),
              _buildTextField(
                controller: maxUsageController,
                label: 'Max Usage'.tr,
                hint: '0'.tr,
                icon: Icons.repeat,
                validator: 'Please enter max usage',
                isNumeric: true,
              ),
              _buildDateField(
                controller: startDateController,
                label: 'Start Date'.tr,
                hint: 'Select start date'.tr,
                icon: Icons.event_available,
                validator: 'Please select start date',
              ),
              _buildDateField(
                controller: expireController,
                label: 'Expiry Date'.tr,
                hint: 'Select expiry date'.tr,
                icon: Icons.calendar_today,
                validator: 'Please select expiry date',
              ),
            ]),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: _submitForm,
              style: ElevatedButton.styleFrom(
                backgroundColor: Color.fromARGB(255, 37, 37, 37),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
              child: Text(
                widget.coupon == null ? 'Create Offer' : 'Update Offer',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFormCard(List<Widget> children) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: children,
      ),
    );
  }

  Widget _buildServicePicker() {
    return Obx(() {
      final services = _controller.partnerServices;
      if (_controller.loadingServices.value) {
        return const Padding(
          padding: EdgeInsets.symmetric(vertical: 16),
          child: Center(child: CircularProgressIndicator()),
        );
      }

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Apply to services'.tr,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text('Required. Choose ALL or select partner services.'.tr,
            style: TextStyle(
              fontSize: 12,
              color: Color(0xFF6B7280),
            ),
          ),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: Text('All services'.tr),
            value: applyAllServices,
            activeThumbColor: const Color(0xFF6C5CE7),
            activeTrackColor: const Color(0xFF6C5CE7).withOpacity(0.45),
            inactiveThumbColor: Colors.white,
            inactiveTrackColor: const Color(0xFFD1D5DB),
            onChanged: (value) {
              setState(() {
                applyAllServices = value;
                if (value) {
                  selectedServiceIds
                    ..clear()
                    ..addAll(services.map((s) => s.id));
                }
              });
              _syncOriginalFromServices();
              _recalculateAmounts();
            },
          ),
          if (services.isEmpty)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Text('No active services found for this partner.'.tr,
                style: const TextStyle(color: Colors.red),
              ),
            )
          else
            ...services.map((service) {
              final selected =
                  applyAllServices || selectedServiceIds.contains(service.id);
              return CheckboxListTile(
                contentPadding: EdgeInsets.zero,
                value: selected,
                title: Text(
                  service.name,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                subtitle: _servicePriceSubtitle(service, selected: selected),
                controlAffinity: ListTileControlAffinity.leading,
                onChanged: applyAllServices
                    ? null
                    : (checked) {
                        setState(() {
                          if (checked == true) {
                            selectedServiceIds.add(service.id);
                          } else {
                            selectedServiceIds.remove(service.id);
                          }
                          _syncAllServicesFromSelection(services);
                        });
                        _syncOriginalFromServices();
                        _recalculateAmounts();
                      },
              );
            }),
        ],
      );
    });
  }

  Widget _servicePriceSubtitle(OfferServiceModel service,
      {required bool selected}) {
    final original = CurrencyHelper.format(service.price, decimals: 2);
    final offer = CurrencyHelper.format(service.offerPrice, decimals: 2);
    final mins = service.duration % 1 == 0
        ? service.duration.toInt().toString()
        : service.duration.toStringAsFixed(1);
    final showDiscount = selected && service.hasDiscount;
    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 8,
            runSpacing: 4,
            children: [
              if (showDiscount) ...[
                Text(
                  original,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF9CA3AF),
                    decoration: TextDecoration.lineThrough,
                  ),
                ),
                Text(
                  offer,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF059669),
                  ),
                ),
                if (service.discount > 0)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFEF3C7),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      '${service.discount % 1 == 0 ? service.discount.toInt() : service.discount}% OFF',
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFFB45309),
                      ),
                    ),
                  ),
              ] else
                Text(
                  original,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF374151),
                  ),
                ),
              Text(
                '• $mins min',
                style: const TextStyle(fontSize: 12, color: Color(0xFF6B7280)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    required String validator,
    bool isNumeric = false,
    int maxLines = 1,
    bool readOnly = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        maxLines: maxLines,
        readOnly: readOnly,
        keyboardType: isNumeric ? TextInputType.number : TextInputType.text,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          prefixIcon: Icon(icon, color: const Color(0xFF6C5CE7)),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey[300]!),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey[300]!),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFF6C5CE7), width: 2),
          ),
          filled: true,
          fillColor: readOnly ? Colors.grey[100] : Colors.grey[50],
        ),
        validator: (value) {
          if (validator.isEmpty) return null;
          if (value == null || value.isEmpty) {
            return validator;
          }
          return null;
        },
      ),
    );
  }

  Widget _buildDateField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    required String validator,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        readOnly: true,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          prefixIcon: Icon(icon, color: const Color(0xFF6C5CE7)),
          suffixIcon: const Icon(Icons.arrow_drop_down),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey[300]!),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey[300]!),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFF6C5CE7), width: 2),
          ),
          filled: true,
          fillColor: Colors.grey[50],
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return validator;
          }
          return null;
        },
        onTap: () async {
          DateTime? picked = await showDatePicker(
            context: context,
            initialDate: DateTime.tryParse(controller.text) ?? DateTime.now(),
            firstDate: DateTime(2020),
            lastDate: DateTime(2101),
            builder: (context, child) {
              return Theme(
                data: Theme.of(context).copyWith(
                  colorScheme: Theme.of(context).colorScheme.copyWith(
                        primary: const Color(0xFF6C5CE7),
                      ),
                ),
                child: child!,
              );
            },
          );
          if (picked != null) {
            String formattedDate = DateFormat('yyyy-MM-dd').format(picked);
            setState(() {
              controller.text = formattedDate;
            });
          }
        },
      ),
    );
  }

  Future<void> _pickOfferImage() async {
    final picked = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      imageQuality: 70,
    );
    if (picked != null) setState(() => _imageFile = picked);
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      if (!applyAllServices && selectedServiceIds.isEmpty) {
        Get.snackbar(
          'Services required',
          'Select ALL or at least one partner service',
          backgroundColor: Colors.red,
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
        );
        return;
      }

      final offer = CouponModel(
        id: widget.coupon?.id ?? 0,
        name: nameController.text,
        shortDescription: descriptionController.text,
        code: codeController.text,
        type: selectedType,
        discount: int.parse(discountController.text),
        upto: int.parse(uptoController.text),
        startDate: startDateController.text,
        expire: expireController.text,
        maxUsage: int.parse(maxUsageController.text),
        minCartValue: int.parse(minCartValueController.text),
        status: widget.coupon?.status ?? 1,
        applyAllServices: applyAllServices,
        serviceIds: applyAllServices ? const [] : selectedServiceIds.toList(),
      );

      if (widget.coupon == null) {
        _controller.createCoupons(offer, image: _imageFile);
      } else {
        _controller.updateCoupon(offer, image: _imageFile);
      }
      Navigator.of(context).pop();
    }
  }

  @override
  void dispose() {
    discountController.removeListener(_recalculateAmounts);
    nameController.dispose();
    descriptionController.dispose();
    codeController.dispose();
    discountController.dispose();
    uptoController.dispose();
    startDateController.dispose();
    expireController.dispose();
    maxUsageController.dispose();
    minCartValueController.dispose();
    originalAmountController.dispose();
    discountedAmountController.dispose();
    super.dispose();
  }
}

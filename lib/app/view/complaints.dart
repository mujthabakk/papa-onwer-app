import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:skeletons/skeletons.dart';
import 'package:ultimate_salon_owner_flutter/app/backend/models/complaint_model.dart';
import 'package:ultimate_salon_owner_flutter/app/controller/complaints_controller.dart';
import 'package:ultimate_salon_owner_flutter/app/util/app_image.dart';
import 'package:ultimate_salon_owner_flutter/app/util/theme.dart';

class ComplaintsScreen extends StatefulWidget {
  const ComplaintsScreen({Key? key}) : super(key: key);

  @override
  State<ComplaintsScreen> createState() => _ComplaintsScreenState();
}

class _ComplaintsScreenState extends State<ComplaintsScreen> {
  @override
  Widget build(BuildContext context) {
    return GetBuilder<ComplaintsController>(
      builder: (value) {
        return Scaffold(
          backgroundColor: ThemeProvider.backgroundColor,
          appBar: AppBar(
            backgroundColor: ThemeProvider.appColor,
            iconTheme: const IconThemeData(color: ThemeProvider.whiteColor),
            elevation: 0,
            centerTitle: true,
            title: Text('Complaints'.tr,
              style: ThemeProvider.titleStyle,
            ),
            actions: [
              IconButton(
                onPressed: () => value.onRefresh(),
                icon: const Icon(Icons.refresh),
              ),
            ],
          ),
          body: value.apiCalled == true
              ? RefreshIndicator(
                  onRefresh: () => value.onRefresh(),
                  child: value.complaints.isEmpty
                      ? _buildEmptyState()
                      : ListView.builder(
                          padding: const EdgeInsets.all(10),
                          itemCount: value.complaints.length,
                          itemBuilder: (context, index) {
                            final complaint = value.complaints[index];
                            return _buildComplaintCard(complaint, value);
                          },
                        ),
                )
              : _buildLoadingSkeleton(),
        );
      },
    );
  }

  Widget _buildComplaintCard(
      Complaint complaint, ComplaintsController controller) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with user info and status
            Row(
              children: [
                CircleAvatar(
                  radius: 25,
                  backgroundColor: ThemeProvider.appColor.withOpacity(0.1),
                  child: AppImage.isValidPath(complaint.userInfo.cover)
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(25),
                          child: AppNetImage(
                            path: complaint.userInfo.cover,
                            fit: BoxFit.cover,
                            height: 50,
                            width: 50,
                            placeholder: Text(
                              complaint.userInfo.firstName[0].toUpperCase(),
                              style: TextStyle(
                                color: ThemeProvider.appColor,
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),
                          ),
                        )
                      : Text(
                          complaint.userInfo.firstName[0].toUpperCase(),
                          style: TextStyle(
                            color: ThemeProvider.appColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        complaint.userInfo.fullName,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        complaint.userInfo.email,
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 12,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: controller.getStatusColor(complaint.status),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    controller.getStatusText(complaint.status),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Complaint title and message
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey[200]!),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.report_problem_outlined,
                        color: Colors.orange[600],
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          complaint.title,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    complaint.shortMessage,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[700],
                      height: 1.4,
                    ),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            // // Store info
            // Container(
            //   padding: const EdgeInsets.all(12),
            //   decoration: BoxDecoration(
            //     color: ThemeProvider.appColor.withOpacity(0.05),
            //     borderRadius: BorderRadius.circular(8),
            //     border: Border.all(
            //       color: ThemeProvider.appColor.withOpacity(0.2),
            //     ),
            //   ),
            //   child: Row(
            //     children: [
            //       CircleAvatar(
            //         radius: 20,
            //         backgroundColor: ThemeProvider.appColor.withOpacity(0.1),
            //         child: complaint.storeInfo.cover.isNotEmpty
            //             ? ClipRRect(
            //                 borderRadius: BorderRadius.circular(20),
            //                 child: FadeInImage(
            //                   image: NetworkImage(
            //                       '${Environments.imageURL}${complaint.storeInfo.cover}'),
            //                   placeholder: const AssetImage(
            //                       "assets/images/placeholder.jpeg"),
            //                   imageErrorBuilder: (context, error, stackTrace) {
            //                     return Icon(
            //                       Icons.store,
            //                       color: ThemeProvider.appColor,
            //                       size: 20,
            //                     );
            //                   },
            //                   fit: BoxFit.cover,
            //                   height: 40,
            //                   width: 40,
            //                 ),
            //               )
            //             : Icon(
            //                 Icons.store,
            //                 color: ThemeProvider.appColor,
            //                 size: 20,
            //               ),
            //       ),
            //       const SizedBox(width: 12),
            //       Expanded(
            //         child: Column(
            //           crossAxisAlignment: CrossAxisAlignment.start,
            //           children: [
            //             Row(
            //               children: [
            //                 Icon(
            //                   Icons.business,
            //                   size: 14,
            //                   color: ThemeProvider.appColor,
            //                 ),
            //                 const SizedBox(width: 4),
            //                 Expanded(
            //                   child: Text(
            //                     complaint.storeInfo.name,
            //                     style: TextStyle(
            //                       fontWeight: FontWeight.w600,
            //                       fontSize: 14,
            //                       color: ThemeProvider.appColor,
            //                     ),
            //                     maxLines: 1,
            //                     overflow: TextOverflow.ellipsis,
            //                   ),
            //                 ),
            //               ],
            //             ),
            //             const SizedBox(height: 2),
            //             Row(
            //               children: [
            //                 Icon(
            //                   Icons.email_outlined,
            //                   size: 12,
            //                   color: Colors.grey[600],
            //                 ),
            //                 const SizedBox(width: 4),
            //                 Expanded(
            //                   child: Text(
            //                     complaint.storeUserInfo.email,
            //                     style: TextStyle(
            //                       color: Colors.grey[600],
            //                       fontSize: 12,
            //                     ),
            //                     maxLines: 1,
            //                     overflow: TextOverflow.ellipsis,
            //                   ),
            //                 ),
            //               ],
            //             ),
            //           ],
            //         ),
            //       ),
            //     ],
            //   ),
            // ),

            // Product info (if available)
            if (complaint.productInfo != null) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blue[200]!),
                ),
                child: Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: AppNetImage(
                        path: complaint.productInfo!.cover,
                        errorAsset: 'assets/images/notfound.png',
                        fit: BoxFit.cover,
                        height: 40,
                        width: 40,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.inventory_2_outlined,
                                size: 14,
                                color: Colors.blue[700],
                              ),
                              const SizedBox(width: 4),
                              Text('Item'.tr,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.blue[700],
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 2),
                          Text(
                            complaint.productInfo!.name,
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
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
            ],

            // Images (if available)
            if (complaint.imagesList.isNotEmpty) ...[
              const SizedBox(height: 12),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.photo_library_outlined,
                          size: 16,
                          color: Colors.grey[600],
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Attachments (${complaint.imagesList.length})',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      height: 80,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: complaint.imagesList.length,
                        itemBuilder: (context, index) {
                          final image = complaint.imagesList[index];
                          if (image.isEmpty) return const SizedBox();

                          return Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: GestureDetector(
                              onTap: () {
                                final url = AppImage.url(image);
                                if (url == null) return;
                                _showImageDialog(context, url);
                              },
                              child: SizedBox(
                                height: 80,
                                width: 80,
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: AppNetImage(
                                    path: image,
                                    errorAsset: 'assets/images/notfound.png',
                                    fit: BoxFit.cover,
                                    height: 80,
                                    width: 80,
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ],

            // Complaint details row
            const SizedBox(height: 12),
            Row(
              children: [
                // Expanded(
                //   child: _buildInfoChip(
                //     icon: Icons.person_outline,
                //     label: 'ID: ${complaint.id}',
                //     color: Colors.grey,
                //   ),
                // ),
                const SizedBox(width: 8),
                if (complaint.appointmentId != 0)
                  Expanded(
                    child: _buildInfoChip(
                      cmp: complaint,
                      controller: controller,
                      icon: Icons.calendar_today_outlined,
                      label:
                          'Open - Appointment Id: ${complaint.appointmentId}',
                      color: Colors.blue,
                    ),
                  ),
                if (complaint.orderId != 0)
                  Expanded(
                    child: _buildInfoChip(
                      cmp: complaint,
                      controller: controller,
                      icon: Icons.calendar_today_outlined,
                      label: 'Goto - Order Id: ${complaint.orderId}',
                      color: Colors.blue,
                    ),
                  ),
              ],
            ),

            // Action buttons (if complaint is pending)
            if (complaint.status == 0) ...[
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: controller.updateApiCalled
                          ? null
                          : () =>
                              controller.updateComplaintStatus(complaint.id, 1),
                      icon: controller.updateApiCalled
                          ? const SizedBox(
                              height: 16,
                              width: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor:
                                    AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          : const Icon(Icons.check_circle_outline, size: 18),
                      label: Text('Mark as Resolved'.tr,
                        style: TextStyle(fontSize: 13),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: controller.updateApiCalled
                          ? null
                          : () =>
                              controller.updateComplaintStatus(complaint.id, 2),
                      icon: controller.updateApiCalled
                          ? const SizedBox(
                              height: 16,
                              width: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor:
                                    AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          : const Icon(Icons.cancel_outlined, size: 18),
                      label: Text('Reject'.tr,
                        style: TextStyle(fontSize: 13),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildInfoChip({
    required ComplaintsController controller,
    required Complaint cmp,
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          if (cmp.appointmentId != 0) {
            controller.onAppointment(cmp.appointmentId);
          } else {
            controller.onProductDetail(cmp.orderId);
          }
        },
        borderRadius: BorderRadius.circular(12),
        splashColor: color.withOpacity(0.2),
        highlightColor: color.withOpacity(0.1),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                color.withOpacity(0.05),
                color.withOpacity(0.08),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: color.withOpacity(0.2),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.1),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(2),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Icon(
                  icon,
                  size: 16,
                  color: color,
                ),
              ),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 13,
                    color: color.withOpacity(0.9),
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.2,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 4),
              Icon(
                Icons.arrow_forward_ios,
                size: 12,
                color: color.withOpacity(0.6),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showImageDialog(BuildContext context, String imageUrl) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AppBar(
              title: Text('Image'.tr),
              backgroundColor: ThemeProvider.appColor,
              foregroundColor: Colors.white,
              automaticallyImplyLeading: false,
              actions: [
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            FadeInImage(
              image: NetworkImage(imageUrl),
              placeholder: const AssetImage("assets/images/placeholder.jpeg"),
              imageErrorBuilder: (context, error, stackTrace) {
                return Image.asset(
                  'assets/images/notfound.png',
                  fit: BoxFit.contain,
                );
              },
              fit: BoxFit.contain,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.feedback_outlined,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text('No Complaints Found'.tr,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text('No complaints have been submitted yet.'.tr,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingSkeleton() {
    return ListView.builder(
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.all(10),
      itemCount: 5,
      itemBuilder: (context, index) => Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Card(
          elevation: 3,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: SkeletonItem(
              child: Column(
                children: [
                  // Header skeleton
                  Row(
                    children: [
                      const SkeletonAvatar(
                        style: SkeletonAvatarStyle(
                          shape: BoxShape.circle,
                          width: 50,
                          height: 50,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: SkeletonParagraph(
                          style: SkeletonParagraphStyle(
                            lines: 2,
                            spacing: 6,
                            lineStyle: SkeletonLineStyle(
                              randomLength: true,
                              height: 12,
                              borderRadius: BorderRadius.circular(8),
                              minLength: MediaQuery.of(context).size.width / 6,
                              maxLength: MediaQuery.of(context).size.width / 3,
                            ),
                          ),
                        ),
                      ),
                      SkeletonAvatar(
                        style: SkeletonAvatarStyle(
                          width: 70,
                          height: 25,
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // Content skeleton
                  SkeletonParagraph(
                    style: SkeletonParagraphStyle(
                      lines: 3,
                      spacing: 6,
                      lineStyle: SkeletonLineStyle(
                        randomLength: true,
                        height: 12,
                        borderRadius: BorderRadius.circular(8),
                        minLength: MediaQuery.of(context).size.width / 2,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Store info skeleton
                  SkeletonAvatar(
                    style: SkeletonAvatarStyle(
                      width: double.infinity,
                      height: 60,
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Buttons skeleton
                  Row(
                    children: [
                      Expanded(
                        child: SkeletonAvatar(
                          style: SkeletonAvatarStyle(
                            width: double.infinity,
                            height: 40,
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: SkeletonAvatar(
                          style: SkeletonAvatarStyle(
                            width: double.infinity,
                            height: 40,
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// import 'package:carousel_slider/carousel_slider.dart';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:skeletons/skeletons.dart';
// import 'package:ultimate_salon_owner_flutter/app/controller/appointment_controller.dart';
// import 'package:ultimate_salon_owner_flutter/app/env.dart';
// import 'package:ultimate_salon_owner_flutter/app/util/theme.dart';

// class AppointmentScreen extends StatefulWidget {
//   const AppointmentScreen({Key? key}) : super(key: key);

//   @override
//   State<AppointmentScreen> createState() => _AppointmentScreenState();
// }

// class _AppointmentScreenState extends State<AppointmentScreen> {
//   final CarouselController _controller = CarouselController();

//   @override
//   Widget build(BuildContext context) {
//     return GetBuilder<AppointmentController>(
//       builder: (value) {
//         return Scaffold(
//           backgroundColor: const Color(0xFFF8FAFC),
//           appBar: AppBar(
//             automaticallyImplyLeading: false,
//             backgroundColor: ThemeProvider.appColor,
//             elevation: 0,
//             iconTheme: const IconThemeData(color: ThemeProvider.whiteColor),
//             title: Row(
//               children: [
//                 Image.asset(
//                   'assets/images/icon_logo.png',
//                   width: 50,
//                   height: 50,
//                   fit: BoxFit.contain,
//                 ),
//                 Text(
//                   value.name,
//                   style: ThemeProvider.titleStyle,
//                 ),
//               ],
//             ),
//             actions: <Widget>[
//               value.parser.getPremium()
//                   ? Row(
//                       children: [
//                         _buildPremiumBadge(value, true),
//                         const SizedBox(width: 5),
//                         _buildHeaderIcon(Icons.notifications_active,
//                             () => value.onOpenNotifications()),
//                         _buildHeaderIcon(Icons.chat, () => value.onInbox()),
//                         const SizedBox(width: 10)
//                       ],
//                     )
//                   : Row(
//                       children: [
//                         _buildPremiumBadge(value, false),
//                         const SizedBox(width: 5),
//                         _buildHeaderIcon(Icons.notifications_active,
//                             () => value.onOpenNotifications()),
//                         _buildHeaderIcon(Icons.chat, () => value.onInbox()),
//                         const SizedBox(width: 10)
//                       ],
//                     ),
//             ],
//             bottom: TabBar(
//               controller: value.tabController,
//               unselectedLabelColor: ThemeProvider.whiteColor.withOpacity(0.7),
//               labelColor: ThemeProvider.whiteColor,
//               indicatorColor: ThemeProvider.whiteColor,
//               indicatorWeight: 3,
//               labelStyle: const TextStyle(
//                 fontFamily: 'medium',
//                 fontSize: 16,
//                 fontWeight: FontWeight.w600,
//               ),
//               unselectedLabelStyle: const TextStyle(
//                 fontFamily: 'medium',
//                 fontSize: 16,
//                 fontWeight: FontWeight.w400,
//               ),
//               indicatorSize: TabBarIndicatorSize.tab,
//               labelPadding: const EdgeInsets.all(12),
//               tabs: const [
//                 Text('New Bookings'),
//                 Text('History'),
//               ],
//             ),
//           ),
//           body: value.apiCalled == false
//               ? _buildSkeletonLoader()
//               : TabBarView(
//                   controller: value.tabController,
//                   children: [
//                     _buildAppointmentTab(
//                       appointments: value.appointmentList,
//                       emptyMessage: 'No New Appointments Found!',
//                       value: value,
//                     ),
//                     _buildAppointmentTab(
//                       appointments: value.appointmentListOld,
//                       emptyMessage: 'No Past Appointments Found!',
//                       value: value,
//                     ),
//                   ],
//                 ),
//         );
//       },
//     );
//   }

//   Widget _buildPremiumBadge(AppointmentController value, bool isPremium) {
//     return GestureDetector(
//       onTap: () {
//         if (isPremium) {
//           value.showDialogScreen(
//             context,
//             'Premium User',
//             'Congratulations,\nEnjoy all premium benefits',
//             Icons.star,
//             Colors.green,
//           );
//         } else {
//           value.onUpgradeScreen();
//         }
//       },
//       child: Container(
//         padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
//         decoration: BoxDecoration(
//           border: Border.all(color: ThemeProvider.golden, width: 1),
//           borderRadius: BorderRadius.circular(8),
//         ),
//         child: Row(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             Icon(
//               isPremium ? Icons.star : Icons.workspace_premium,
//               color: ThemeProvider.golden,
//               size: 18,
//             ),
//             const SizedBox(width: 4),
//             Text(
//               isPremium ? 'Premium' : 'Upgrade',
//               style: const TextStyle(
//                 color: ThemeProvider.golden,
//                 fontSize: 11,
//                 fontWeight: FontWeight.bold,
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildHeaderIcon(IconData icon, VoidCallback onTap) {
//     return GestureDetector(
//       onTap: onTap,
//       child: Padding(
//         padding: const EdgeInsets.all(8.0),
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
//       padding: const EdgeInsets.all(16),
//       child: Column(
//         children: [
//           // Banner skeleton
//           Container(
//             height: 140,
//             decoration: BoxDecoration(
//               color: Colors.grey[300],
//               borderRadius: BorderRadius.circular(12),
//             ),
//           ),
//           const SizedBox(height: 16),
//           // Cards skeleton
//           Expanded(
//             child: SkeletonListView(
//               itemCount: 3,
//               item: Container(
//                 margin: const EdgeInsets.only(bottom: 16),
//                 height: 180,
//                 decoration: BoxDecoration(
//                   color: Colors.grey[300],
//                   borderRadius: BorderRadius.circular(16),
//                 ),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildAppointmentTab({
//     required List appointments,
//     required String emptyMessage,
//     required AppointmentController value,
//   }) {
//     return RefreshIndicator(
//       onRefresh: () async {
//         value.getList();
//       },
//       color: ThemeProvider.appColor,
//       child: CustomScrollView(
//         slivers: [
//           // Banner
//           SliverToBoxAdapter(
//             child: Padding(
//               padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
//               child: _buildModernBanner(value),
//             ),
//           ),

//           // Appointments List or Empty State
//           appointments.isNotEmpty
//               ? SliverPadding(
//                   padding: const EdgeInsets.symmetric(horizontal: 16),
//                   sliver: SliverList(
//                     delegate: SliverChildBuilderDelegate(
//                       (context, index) => _buildCompactAppointmentCard(
//                         appointments[index],
//                         index,
//                         value,
//                       ),
//                       childCount: appointments.length,
//                     ),
//                   ),
//                 )
//               : SliverFillRemaining(
//                   child: _buildEmptyState(emptyMessage, value),
//                 ),
//         ],
//       ),
//     );
//   }

//   Widget _buildModernBanner(AppointmentController value) {
//     if (value.bannerList.isEmpty) {
//       return Container(
//         height: 140,
//         decoration: BoxDecoration(
//           gradient: LinearGradient(
//             colors: [Colors.blue[400]!, Colors.purple[400]!],
//             begin: Alignment.topLeft,
//             end: Alignment.bottomRight,
//           ),
//           borderRadius: BorderRadius.circular(16),
//         ),
//         child: const Center(
//           child: Text(
//             'Welcome to Salon Owner',
//             style: TextStyle(
//               color: Colors.white,
//               fontSize: 18,
//               fontWeight: FontWeight.w600,
//             ),
//           ),
//         ),
//       );
//     }

//     return Container(
//       height: 140,
//       decoration: BoxDecoration(
//         borderRadius: BorderRadius.circular(16),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.1),
//             blurRadius: 10,
//             offset: const Offset(0, 4),
//           ),
//         ],
//       ),
//       child: CarouselSlider(
//         options: CarouselOptions(
//           height: 140,
//           viewportFraction: 1,
//           autoPlay: true,
//           autoPlayInterval: const Duration(seconds: 4),
//           autoPlayAnimationDuration: const Duration(milliseconds: 800),
//           enlargeCenterPage: false,
//         ),
//         carouselController: _controller,
//         items: value.bannerList.map((banner) {
//           return GestureDetector(
//             onTap: () => value.onBanner(banner.link.toString()),
//             child: ClipRRect(
//               borderRadius: BorderRadius.circular(16),
//               child: Stack(
//                 fit: StackFit.expand,
//                 children: [
//                   FadeInImage(
//                     image:
//                         NetworkImage('${Environments.imageURL}${banner.cover}'),
//                     placeholder:
//                         const AssetImage("assets/images/placeholder.jpeg"),
//                     imageErrorBuilder: (context, error, stackTrace) {
//                       return Container(
//                         color: Colors.grey[300],
//                         child: const Icon(Icons.image,
//                             size: 50, color: Colors.grey),
//                       );
//                     },
//                     fit: BoxFit.cover,
//                   ),
//                   Container(
//                     decoration: BoxDecoration(
//                       gradient: LinearGradient(
//                         begin: Alignment.topCenter,
//                         end: Alignment.bottomCenter,
//                         colors: [
//                           Colors.transparent,
//                           Colors.black.withOpacity(0.4),
//                         ],
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           );
//         }).toList(),
//       ),
//     );
//   }

//   Widget _buildCompactAppointmentCard(
//       dynamic appointment, int index, AppointmentController value) {
//     return Container(
//       margin: const EdgeInsets.only(bottom: 12),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(16),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.04),
//             blurRadius: 8,
//             offset: const Offset(0, 2),
//           ),
//         ],
//       ),
//       child: Material(
//         color: Colors.transparent,
//         child: InkWell(
//           onTap: () => value.onAppointment(appointment.id as int),
//           borderRadius: BorderRadius.circular(16),
//           child: Padding(
//             padding: const EdgeInsets.all(16),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 // Header with user info and status
//                 _buildCardHeader(appointment, value),
//                 const SizedBox(height: 12),

//                 // Appointment details in compact format
//                 _buildCompactDetails(appointment),

//                 // Services and packages
//                 if (_hasServicesOrPackages(appointment)) ...[
//                   const SizedBox(height: 12),
//                   _buildServicesCompact(appointment, value),
//                 ],

//                 const SizedBox(height: 12),

//                 // Footer with total and date
//                 _buildCardFooter(appointment, value),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildCardHeader(dynamic appointment, AppointmentController value) {
//     return Row(
//       children: [
//         // User avatar
//         Container(
//           width: 48,
//           height: 48,
//           decoration: BoxDecoration(
//             borderRadius: BorderRadius.circular(12),
//             border: Border.all(color: Colors.grey[200]!, width: 1),
//           ),
//           child: ClipRRect(
//             borderRadius: BorderRadius.circular(11),
//             child: FadeInImage(
//               image: NetworkImage(
//                   '${Environments.imageURL}${appointment.userInfo?.cover}'),
//               placeholder: const AssetImage("assets/images/placeholder.jpeg"),
//               imageErrorBuilder: (context, error, stackTrace) {
//                 return Container(
//                   color: Colors.grey[100],
//                   child: Icon(Icons.person, color: Colors.grey[400], size: 24),
//                 );
//               },
//               fit: BoxFit.cover,
//             ),
//           ),
//         ),
//         const SizedBox(width: 12),

//         // User info
//         Expanded(
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Text(
//                 '${appointment.userInfo?.firstName ?? ''} ${appointment.userInfo?.lastName ?? ''}',
//                 style: const TextStyle(
//                   fontSize: 16,
//                   fontWeight: FontWeight.w600,
//                   color: Colors.black87,
//                 ),
//                 overflow: TextOverflow.ellipsis,
//               ),
//               const SizedBox(height: 2),
//               Text(
//                 'ID #${appointment.id}',
//                 style: TextStyle(
//                   fontSize: 12,
//                   color: Colors.grey[600],
//                   fontWeight: FontWeight.w500,
//                 ),
//               ),
//             ],
//           ),
//         ),

//         // Status badge
//         _buildStatusBadge(appointment, value),
//       ],
//     );
//   }

//   Widget _buildStatusBadge(dynamic appointment, AppointmentController value) {
//     final status = appointment.status as int;
//     final statusColor = value.statusColors[status] ?? Colors.blue;
//     final statusText = value.statusName[status] ?? 'Unknown';

//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
//       decoration: BoxDecoration(
//         color: statusColor.withOpacity(0.1),
//         borderRadius: BorderRadius.circular(8),
//         border: Border.all(color: statusColor.withOpacity(0.3)),
//       ),
//       child: Text(
//         statusText,
//         style: TextStyle(
//           fontSize: 11,
//           fontWeight: FontWeight.w600,
//           color: statusColor,
//         ),
//       ),
//     );
//   }

//   Widget _buildCompactDetails(dynamic appointment) {
//     return Container(
//       padding: const EdgeInsets.all(12),
//       decoration: BoxDecoration(
//         color: const Color(0xFFF8FAFC),
//         borderRadius: BorderRadius.circular(12),
//       ),
//       child: Row(
//         children: [
//           // Location
//           Expanded(
//             flex: 2,
//             child: Row(
//               children: [
//                 Icon(Icons.location_on_outlined,
//                     size: 16, color: Colors.grey[600]),
//                 const SizedBox(width: 6),
//                 Expanded(
//                   child: Text(
//                     appointment.appointmentsTo == 1
//                         ? '${appointment.address?.house ?? ''} ${appointment.address?.address ?? ''}'
//                             .trim()
//                         : 'At Salon',
//                     style: const TextStyle(
//                         fontSize: 12, fontWeight: FontWeight.w500),
//                     overflow: TextOverflow.ellipsis,
//                   ),
//                 ),
//               ],
//             ),
//           ),

//           Container(
//             width: 1,
//             height: 20,
//             color: Colors.grey[300],
//             margin: const EdgeInsets.symmetric(horizontal: 12),
//           ),

//           // Date & Time
//           Row(
//             children: [
//               Icon(Icons.schedule_outlined, size: 16, color: Colors.grey[600]),
//               const SizedBox(width: 6),
//               Text(
//                 '${appointment.saveDate ?? ''}\n${appointment.slot ?? ''}',
//                 textAlign: TextAlign.right,
//                 style:
//                     const TextStyle(fontSize: 11, fontWeight: FontWeight.w500),
//                 overflow: TextOverflow.ellipsis,
//               ),
//             ],
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildServicesCompact(
//       dynamic appointment, AppointmentController value) {
//     return Container(
//       padding: const EdgeInsets.all(12),
//       decoration: BoxDecoration(
//         border: Border.all(color: Colors.grey[200]!),
//         borderRadius: BorderRadius.circular(12),
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           // Services
//           if (appointment.items?.services?.isNotEmpty == true) ...[
//             Row(
//               children: [
//                 Container(
//                   padding: const EdgeInsets.all(3),
//                   decoration: BoxDecoration(
//                     color: Colors.blue[50],
//                     borderRadius: BorderRadius.circular(4),
//                   ),
//                   child: Icon(Icons.design_services,
//                       size: 12, color: Colors.blue[600]),
//                 ),
//                 const SizedBox(width: 6),
//                 Text(
//                   'Services'.tr + ' (${appointment.items.services.length})',
//                   style: const TextStyle(
//                       fontSize: 12, fontWeight: FontWeight.w600),
//                 ),
//               ],
//             ),
//             const SizedBox(height: 8),
//             ...appointment.items.services
//                 .take(2)
//                 .map((service) => _buildServiceRowCompact(service, value))
//                 .toList(),
//             if (appointment.items.services.length > 2)
//               Text(
//                 '+${appointment.items.services.length - 2} ' + 'and more'.tr,
//                 style: TextStyle(fontSize: 11, color: Colors.grey[600]),
//               ),
//           ],

//           // Packages
//           if (appointment.items?.packages?.isNotEmpty == true) ...[
//             if (appointment.items?.services?.isNotEmpty == true)
//               const SizedBox(height: 12),
//             Row(
//               children: [
//                 Container(
//                   padding: const EdgeInsets.all(3),
//                   decoration: BoxDecoration(
//                     color: Colors.green[50],
//                     borderRadius: BorderRadius.circular(4),
//                   ),
//                   child: Icon(Icons.card_giftcard,
//                       size: 12, color: Colors.green[600]),
//                 ),
//                 const SizedBox(width: 6),
//                 Text(
//                   'Packages'.tr + ' (${appointment.items.packages.length})',
//                   style: const TextStyle(
//                       fontSize: 12, fontWeight: FontWeight.w600),
//                 ),
//               ],
//             ),
//             const SizedBox(height: 8),
//             ...appointment.items.packages
//                 .take(2)
//                 .map((package) => _buildPackageRowCompact(package, value))
//                 .toList(),
//             if (appointment.items.packages.length > 2)
//               Text(
//                 '+${appointment.items.packages.length - 2} ' + 'and more'.tr,
//                 style: TextStyle(fontSize: 11, color: Colors.grey[600]),
//               ),
//           ],
//         ],
//       ),
//     );
//   }

//   Widget _buildServiceRowCompact(dynamic service, AppointmentController value) {
//     return Padding(
//       padding: const EdgeInsets.only(bottom: 4),
//       child: Row(
//         children: [
//           const SizedBox(width: 4),
//           Expanded(
//             child: Text(
//               service.name?.toString() ?? '',
//               style: const TextStyle(fontSize: 11),
//               overflow: TextOverflow.ellipsis,
//             ),
//           ),
//           _buildGenderIcon(service.gender),
//           const SizedBox(width: 8),
//           _buildPriceText(service.price, service.off, value),
//         ],
//       ),
//     );
//   }

//   Widget _buildPackageRowCompact(dynamic package, AppointmentController value) {
//     return Padding(
//       padding: const EdgeInsets.only(bottom: 4),
//       child: Row(
//         children: [
//           const SizedBox(width: 4),
//           Expanded(
//             child: Text(
//               package.name?.toString() ?? '',
//               style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500),
//               overflow: TextOverflow.ellipsis,
//             ),
//           ),
//           _buildPriceText(package.price, package.off, value),
//         ],
//       ),
//     );
//   }

//   Widget _buildGenderIcon(int? gender) {
//     IconData icon;
//     Color color;

//     switch (gender) {
//       case 0:
//         icon = Icons.child_care;
//         color = Colors.orange;
//         break;
//       case 1:
//         icon = Icons.male;
//         color = Colors.blue;
//         break;
//       case 2:
//         icon = Icons.female;
//         color = Colors.pink;
//         break;
//       default:
//         icon = Icons.family_restroom;
//         color = Colors.purple;
//     }

//     return Icon(icon, size: 12, color: color);
//   }

//   Widget _buildPriceText(dynamic originalPrice, dynamic discountedPrice,
//       AppointmentController value) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.end,
//       children: [
//         if (originalPrice != discountedPrice)
//           Text(
//             value.currencySide == 'left'
//                 ? '${value.currencySymbol}${originalPrice}'
//                 : '${originalPrice}${value.currencySymbol}',
//             style: const TextStyle(
//               fontSize: 9,
//               decoration: TextDecoration.lineThrough,
//               color: Colors.grey,
//             ),
//           ),
//         Text(
//           value.currencySide == 'left'
//               ? '${value.currencySymbol}${discountedPrice}'
//               : '${discountedPrice}${value.currencySymbol}',
//           style: const TextStyle(
//             fontSize: 11,
//             fontWeight: FontWeight.w600,
//             color: Colors.black87,
//           ),
//         ),
//       ],
//     );
//   }

//   Widget _buildCardFooter(dynamic appointment, AppointmentController value) {
//     return Container(
//       padding: const EdgeInsets.all(12),
//       decoration: BoxDecoration(
//         color: Colors.blue[25],
//         borderRadius: BorderRadius.circular(12),
//       ),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//         children: [
//           const Text(
//             'Total Amount',
//             style: TextStyle(
//               fontSize: 14,
//               fontWeight: FontWeight.w600,
//               color: Colors.black87,
//             ),
//           ),
//           Text(
//             value.currencySide == 'left'
//                 ? '${value.currencySymbol}${appointment.grandTotal}'
//                 : '${appointment.grandTotal}${value.currencySymbol}',
//             style: const TextStyle(
//               fontSize: 16,
//               fontWeight: FontWeight.bold,
//               color: Colors.blue,
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildEmptyState(String message, AppointmentController value) {
//     return Center(
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           Container(
//             padding: const EdgeInsets.all(24),
//             decoration: BoxDecoration(
//               color: Colors.grey[50],
//               borderRadius: BorderRadius.circular(20),
//             ),
//             child: Icon(
//               Icons.calendar_today_outlined,
//               size: 64,
//               color: Colors.grey[400],
//             ),
//           ),
//           const SizedBox(height: 24),
//           Text(
//             message,
//             style: const TextStyle(
//               fontSize: 18,
//               fontWeight: FontWeight.w600,
//               color: Colors.black54,
//             ),
//           ),
//           const SizedBox(height: 8),
//           Text(
//             'Your appointments will appear here',
//             style: TextStyle(
//               fontSize: 14,
//               color: Colors.grey[600],
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   bool _hasServicesOrPackages(dynamic appointment) {
//     return (appointment.items?.services?.isNotEmpty == true) ||
//         (appointment.items?.packages?.isNotEmpty == true);
//   }
// }
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:skeletons/skeletons.dart';
import 'package:ultimate_salon_owner_flutter/app/controller/appointment_controller.dart';
import 'package:ultimate_salon_owner_flutter/app/controller/locale_controller.dart';
import 'package:ultimate_salon_owner_flutter/app/controller/tabs_controller.dart';
import 'package:ultimate_salon_owner_flutter/app/util/app_image.dart';
import 'package:ultimate_salon_owner_flutter/app/util/theme.dart';

class AppointmentScreen extends StatefulWidget {
  const AppointmentScreen({Key? key}) : super(key: key);

  @override
  State<AppointmentScreen> createState() => _AppointmentScreenState();
}

class _AppointmentScreenState extends State<AppointmentScreen>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return GetBuilder<LocaleController>(
      builder: (_) {
        return GetBuilder<AppointmentController>(
          builder: (value) {
            return Scaffold(
          backgroundColor: const Color(0xFFF8FAFC),
          appBar: AppBar(
            automaticallyImplyLeading: false,
            backgroundColor: ThemeProvider.appColor,
            elevation: 0,
            titleSpacing: 0,
            toolbarHeight: 64,
            iconTheme: const IconThemeData(color: ThemeProvider.whiteColor),
            leading: IconButton(
              icon: const Icon(Icons.menu, color: ThemeProvider.whiteColor),
              onPressed: () {
                if (Get.isRegistered<TabsController>()) {
                  Get.find<TabsController>().scaffoldKey.currentState?.openDrawer();
                }
              },
            ),
            leadingWidth: 40,
            title: Row(
              children: [
                Image.asset(
                  'assets/images/icon_logo.png',
                  width: 24,
                  height: 24,
                  fit: BoxFit.contain,
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    value.name,
                    style: ThemeProvider.titleStyle.copyWith(
                      fontSize: 13,
                      height: 1.15,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            actions: <Widget>[
              _buildPremiumBadge(value, value.parser.getPremium()),
              _buildHeaderIcon(Icons.notifications_active,
                  () => value.onOpenNotifications()),
              _buildHeaderIcon(Icons.chat, () => value.onInbox()),
              const SizedBox(width: 6),
            ],
            bottom: TabBar(
              controller: value.tabController,
              unselectedLabelColor: ThemeProvider.whiteColor.withOpacity(0.7),
              labelColor: ThemeProvider.whiteColor,
              indicatorColor: ThemeProvider.whiteColor,
              indicatorWeight: 3,
              labelStyle: const TextStyle(
                fontFamily: 'medium',
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
              unselectedLabelStyle: const TextStyle(
                fontFamily: 'medium',
                fontSize: 16,
                fontWeight: FontWeight.w400,
              ),
              indicatorSize: TabBarIndicatorSize.tab,
              labelPadding: const EdgeInsets.all(12),
              tabs: [
                Text('New Bookings'.tr),
                Text('History'.tr),
              ],
            ),
          ),
          body: value.apiCalled == false
              ? _buildSkeletonLoader()
              : IndexedStack(
                  index: value.tabController.index,
                  children: [
                    _buildAppointmentTab(
                      appointments: value.appointmentList,
                      emptyMessage: 'No New Appointments Found!'.tr,
                      value: value,
                      isNewBookings: true,
                    ),
                    _buildAppointmentTab(
                      appointments: value.appointmentListOld,
                      emptyMessage: 'No Past Appointments Found!'.tr,
                      value: value,
                      isNewBookings: false,
                    ),
                  ],
                ),
        );
          },
        );
      },
    );
  }

  Widget _buildPremiumBadge(AppointmentController value, bool isPremium) {
    return GestureDetector(
      onTap: () {
        if (isPremium) {
          value.showDialogScreen(
            context,
            'Premium User'.tr,
            'Congratulations,\nEnjoy all premium benefits'.tr,
            Icons.star,
            Colors.green,
          );
        } else {
          value.onUpgradeScreen();
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          border: Border.all(color: ThemeProvider.golden, width: 1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isPremium ? Icons.star : Icons.workspace_premium,
              color: ThemeProvider.golden,
              size: 18,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderIcon(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
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
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Banner skeleton
          Container(
            height: 140,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          const SizedBox(height: 16),
          // Cards skeleton
          Expanded(
            child: SkeletonListView(
              itemCount: 3,
              item: Container(
                margin: const EdgeInsets.only(bottom: 16),
                height: 180,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusFilterChips(
      AppointmentController value, bool isNewBookings) {
    final availableStatuses = isNewBookings
        ? value.getAvailableStatusesForNewBookings()
        : value.getAvailableStatusesForHistory();

    if (availableStatuses.isEmpty) return const SizedBox.shrink();

    return Container(
      height: 56,
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: availableStatuses.length + 1, // +1 for "All" chip
        itemBuilder: (context, index) {
          if (index == 0) {
            // "All" filter chip
            final isSelected = isNewBookings
                ? value.selectedNewBookingsFilter == -1
                : value.selectedHistoryFilter == -1;

            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: FilterChip(
                label: Text('All'.tr),
                selected: isSelected,
                onSelected: (selected) {
                  if (isNewBookings) {
                    value.setNewBookingsFilter(-1);
                  } else {
                    value.setHistoryFilter(-1);
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
          final isSelected = isNewBookings
              ? value.selectedNewBookingsFilter == statusIndex
              : value.selectedHistoryFilter == statusIndex;

          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilterChip(
              label: Text(value.statusName[statusIndex].tr),
              selected: isSelected,
              onSelected: (selected) {
                if (isNewBookings) {
                  value.setNewBookingsFilter(selected ? statusIndex : -1);
                } else {
                  value.setHistoryFilter(selected ? statusIndex : -1);
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

  Widget _buildAppointmentTab({
    required List appointments,
    required String emptyMessage,
    required AppointmentController value,
    bool isNewBookings = false,
  }) {
    // Get filtered appointments
    final filteredAppointments = isNewBookings
        ? value.getFilteredNewBookings()
        : value.getFilteredHistory();

    return RefreshIndicator(
      onRefresh: () async {
        value.getList();
      },
      color: ThemeProvider.appColor,
      child: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: _buildModernBanner(value),
          ),

          // Status Filter Chips
          SliverToBoxAdapter(
            child: _buildStatusFilterChips(value, isNewBookings),
          ),

          // Results count
          if (filteredAppointments.isNotEmpty)
            SliverToBoxAdapter(
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Text(
                  '${filteredAppointments.length} appointment${filteredAppointments.length != 1 ? 's' : ''} found',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),

          // Appointments List or Empty State
          filteredAppointments.isNotEmpty
              ? SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) => _buildCompactAppointmentCard(
                        filteredAppointments[index],
                        index,
                        value,
                      ),
                      childCount: filteredAppointments.length,
                    ),
                  ),
                )
              : SliverFillRemaining(
                  hasScrollBody: false,
                  child: _buildEmptyState(
                    appointments.isEmpty
                        ? emptyMessage
                        : 'No appointments found for the selected filter'.tr,
                    value,
                  ),
                ),
        ],
      ),
    );
  }

  Widget _buildModernBanner(AppointmentController value) {
    if (value.bannerList.isEmpty) {
      return SizedBox(
        width: double.infinity,
        height: 180,
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.blue[400]!, Colors.purple[400]!],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Center(
            child: Text(
              'Welcome to Salon Owner'.tr,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      );
    }

    return SizedBox(
      width: double.infinity,
      height: 180,
      child: CarouselSlider(
        options: CarouselOptions(
          height: 180,
          viewportFraction: 1.0,
          padEnds: false,
          disableCenter: true,
          autoPlay: value.bannerList.length > 1,
          autoPlayInterval: const Duration(seconds: 6),
          autoPlayAnimationDuration: const Duration(milliseconds: 800),
          enlargeCenterPage: false,
          enableInfiniteScroll: value.bannerList.length > 1,
          pauseAutoPlayOnTouch: true,
        ),
        items: value.bannerList.map((banner) {
          return GestureDetector(
            onTap: () => value.onBanner(banner.link.toString()),
            child: SizedBox(
              width: double.infinity,
              height: 180,
              child: AppNetImage(
               path: banner.cover,
                fit: BoxFit.cover,
                width: double.infinity,
                height: 180,
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildCompactAppointmentCard(
      dynamic appointment, int index, AppointmentController value) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => value.onAppointment(appointment.id as int),
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header with user info and status
                _buildCardHeader(appointment, value),
                const SizedBox(height: 12),

                // Appointment details in compact format
                _buildCompactDetails(appointment),

                // Services and packages
                if (_hasServicesOrPackages(appointment)) ...[
                  const SizedBox(height: 12),
                  _buildServicesCompact(appointment, value),
                ],

                const SizedBox(height: 12),

                // Footer with total and date
                _buildCardFooter(appointment, value),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCardHeader(dynamic appointment, AppointmentController value) {
    return Row(
      children: [
        // User avatar
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey[200]!, width: 1),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(11),
            child: AppNetImage(
             path: appointment.userInfo?.cover,
              fit: BoxFit.cover,
              placeholder: Container(
                color: Colors.grey[100],
                child: Icon(Icons.person, color: Colors.grey[400], size: 24),
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),

        // User info
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${appointment.userInfo?.firstName ?? ''} ${appointment.userInfo?.lastName ?? ''}',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 2),
              Text(
                'ID #${appointment.id}',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),

        // Status badge
        _buildStatusBadge(appointment, value),
      ],
    );
  }

  Widget _buildStatusBadge(dynamic appointment, AppointmentController value) {
    final status = appointment.status as int;
    final statusColor = value.statusColors[status] ?? Colors.blue;
    final statusText = (value.statusName[status] ?? 'Unknown').tr;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: statusColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: statusColor.withOpacity(0.3)),
      ),
      child: Text(
        statusText,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: statusColor,
        ),
      ),
    );
  }

  Widget _buildCompactDetails(dynamic appointment) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          // Location
          Expanded(
            flex: 2,
            child: Row(
              children: [
                Icon(Icons.location_on_outlined,
                    size: 16, color: Colors.grey[600]),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    appointment.appointmentsTo == 1
                        ? '${appointment.address?.house ?? ''} ${appointment.address?.address ?? ''}'
                            .trim()
                        : 'At Business'.tr,
                    style: const TextStyle(
                        fontSize: 12, fontWeight: FontWeight.w500),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),

          Container(
            width: 1,
            height: 20,
            color: Colors.grey[300],
            margin: const EdgeInsets.symmetric(horizontal: 12),
          ),

          // Date & Time
          Row(
            children: [
              Icon(Icons.schedule_outlined, size: 16, color: Colors.grey[600]),
              const SizedBox(width: 6),
              Text(
                '${appointment.saveDate ?? ''}\n${appointment.slot ?? ''}',
                textAlign: TextAlign.right,
                style:
                    const TextStyle(fontSize: 11, fontWeight: FontWeight.w500),
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildServicesCompact(
      dynamic appointment, AppointmentController value) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[200]!),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Services
          if (appointment.items?.services?.isNotEmpty == true) ...[
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(3),
                  decoration: BoxDecoration(
                    color: Colors.blue[50],
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Icon(Icons.design_services,
                      size: 12, color: Colors.blue[600]),
                ),
                const SizedBox(width: 6),
                Text(
                  'Services'.tr + ' (${appointment.items.services.length})',
                  style: const TextStyle(
                      fontSize: 12, fontWeight: FontWeight.w600),
                ),
              ],
            ),
            const SizedBox(height: 8),
            ...appointment.items.services
                .take(2)
                .map((service) => _buildServiceRowCompact(service, value))
                .toList(),
            if (appointment.items.services.length > 2)
              Text(
                '+${appointment.items.services.length - 2} ' + 'and more'.tr,
                style: TextStyle(fontSize: 11, color: Colors.grey[600]),
              ),
          ],

          // Packages
          if (appointment.items?.packages?.isNotEmpty == true) ...[
            if (appointment.items?.services?.isNotEmpty == true)
              const SizedBox(height: 12),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(3),
                  decoration: BoxDecoration(
                    color: Colors.green[50],
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Icon(Icons.card_giftcard,
                      size: 12, color: Colors.green[600]),
                ),
                const SizedBox(width: 6),
                Text(
                  'Packages'.tr + ' (${appointment.items.packages.length})',
                  style: const TextStyle(
                      fontSize: 12, fontWeight: FontWeight.w600),
                ),
              ],
            ),
            const SizedBox(height: 8),
            ...appointment.items.packages
                .take(2)
                .map((package) => _buildPackageRowCompact(package, value))
                .toList(),
            if (appointment.items.packages.length > 2)
              Text(
                '+${appointment.items.packages.length - 2} ' + 'and more'.tr,
                style: TextStyle(fontSize: 11, color: Colors.grey[600]),
              ),
          ],
        ],
      ),
    );
  }

  Widget _buildServiceRowCompact(dynamic service, AppointmentController value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          const SizedBox(width: 4),
          Expanded(
            child: Text(
              service.name?.toString() ?? '',
              style: const TextStyle(fontSize: 11),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          _buildGenderIcon(service.gender),
          const SizedBox(width: 8),
          _buildPriceText(service.price, service.off, value),
        ],
      ),
    );
  }

  Widget _buildPackageRowCompact(dynamic package, AppointmentController value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          const SizedBox(width: 4),
          Expanded(
            child: Text(
              package.name?.toString() ?? '',
              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          _buildPriceText(package.price, package.off, value),
        ],
      ),
    );
  }

  Widget _buildGenderIcon(int? gender) {
    IconData icon;
    Color color;

    switch (gender) {
      case 0:
        icon = Icons.child_care;
        color = Colors.orange;
        break;
      case 1:
        icon = Icons.male;
        color = Colors.blue;
        break;
      case 2:
        icon = Icons.female;
        color = Colors.pink;
        break;
      default:
        icon = Icons.family_restroom;
        color = Colors.purple;
    }

    return Icon(icon, size: 12, color: color);
  }

  Widget _buildPriceText(dynamic originalPrice, dynamic discountedPrice,
      AppointmentController value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        if (originalPrice != discountedPrice)
          Text(
            value.currencySide == 'left'
                ? '${value.currencySymbol}${originalPrice}'
                : '${originalPrice}${value.currencySymbol}',
            style: const TextStyle(
              fontSize: 9,
              decoration: TextDecoration.lineThrough,
              color: Colors.grey,
            ),
          ),
        Text(
          value.currencySide == 'left'
              ? '${value.currencySymbol}${discountedPrice}'
              : '${discountedPrice}${value.currencySymbol}',
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }

  Widget _buildCardFooter(dynamic appointment, AppointmentController value) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.blue[25],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Total Amount'.tr,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          Text(
            value.currencySide == 'left'
                ? '${value.currencySymbol}${appointment.grandTotal}'
                : '${appointment.grandTotal}${value.currencySymbol}',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.blue,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(String message, AppointmentController value) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(20),
              ),
              child: Icon(
                Icons.calendar_today_outlined,
                size: 48,
                color: Colors.grey[400],
              ),
            ),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.black54,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Your appointments will appear here'.tr,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  bool _hasServicesOrPackages(dynamic appointment) {
    return (appointment.items?.services?.isNotEmpty == true) ||
        (appointment.items?.packages?.isNotEmpty == true);
  }
}

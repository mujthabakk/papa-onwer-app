import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:ultimate_salon_owner_flutter/app/controller/locale_controller.dart';
import 'package:ultimate_salon_owner_flutter/app/controller/profile_business_controller.dart';
import 'package:ultimate_salon_owner_flutter/app/util/app_image.dart';
import 'package:ultimate_salon_owner_flutter/app/util/theme.dart';

class ProfileCategoriesScreen extends StatefulWidget {
  const ProfileCategoriesScreen({Key? key}) : super(key: key);
  @override
  State<ProfileCategoriesScreen> createState() => _ProfileCategoriesState();
}

class _ProfileCategoriesState extends State<ProfileCategoriesScreen> {
  @override
  Widget build(BuildContext context) {
    return GetBuilder<LocaleController>(builder: (_) {
      return GetBuilder<ProfileCategoriesController>(
      builder: (value) {
        return GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: Scaffold(
            backgroundColor: const Color(0xFFF8F9FA),
            body: value.apiCalled == false
                ? const Center(
                    child: CircularProgressIndicator(
                        color: ThemeProvider.appColor),
                  )
                : CustomScrollView(
                    slivers: [
                      // Modern Header with Profile Image
                      SliverAppBar(
                        backgroundColor: Colors.transparent,
                        elevation: 0,
                        expandedHeight: 220,
                        floating: false,
                        pinned: true,
                        leading: Container(
                          margin: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.9),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: IconButton(
                            onPressed: () => Get.back(),
                            icon: const Icon(
                              Icons.arrow_back,
                              color: Colors.black87,
                            ),
                          ),
                        ),
                        flexibleSpace: FlexibleSpaceBar(
                          background: Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  ThemeProvider.appColor,
                                  ThemeProvider.appColor.withOpacity(0.8),
                                ],
                              ),
                            ),
                            child: Stack(
                              children: [
                                // Background Image
                                Container(
                                  decoration: const BoxDecoration(
                                    image: DecorationImage(
                                      image: AssetImage('assets/images/h4.jpg'),
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                                // Dark Overlay
                                Container(
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      begin: Alignment.topCenter,
                                      end: Alignment.bottomCenter,
                                      colors: [
                                        Colors.black.withOpacity(0.3),
                                        Colors.black.withOpacity(0.6),
                                      ],
                                    ),
                                  ),
                                ),
                                // Profile Image
                                Positioned(
                                  bottom: 20,
                                  left: 0,
                                  right: 0,
                                  child: Column(
                                    children: [
                                      GestureDetector(
                                        onTap: () {
                                          showCupertinoModalPopup<void>(
                                            context: context,
                                            builder: (BuildContext context) =>
                                                CupertinoActionSheet(
                                              title: Text('Choose From'.tr),
                                              actions: <CupertinoActionSheetAction>[
                                                CupertinoActionSheetAction(
                                                  isDefaultAction: true,
                                                  onPressed: () {
                                                    Navigator.pop(context);
                                                    value.selectFromGallery(
                                                        'camera');
                                                  },
                                                  child: Text('Camera'.tr),
                                                ),
                                                CupertinoActionSheetAction(
                                                  onPressed: () {
                                                    Navigator.pop(context);
                                                    value.selectFromGallery(
                                                        'gallery');
                                                  },
                                                  child: Text('Gallery'.tr),
                                                ),
                                                CupertinoActionSheetAction(
                                                  isDestructiveAction: true,
                                                  onPressed: () {
                                                    Navigator.pop(context);
                                                  },
                                                  child: Text('Cancel'.tr),
                                                )
                                              ],
                                            ),
                                          );
                                        },
                                        child: Stack(
                                          children: [
                                            Container(
                                              decoration: BoxDecoration(
                                                shape: BoxShape.circle,
                                                border: Border.all(
                                                  color: Colors.white,
                                                  width: 4,
                                                ),
                                                boxShadow: [
                                                  BoxShadow(
                                                    color: Colors.black
                                                        .withOpacity(0.2),
                                                    blurRadius: 10,
                                                    offset: const Offset(0, 5),
                                                  ),
                                                ],
                                              ),
                                              child: ClipRRect(
                                                borderRadius:
                                                    BorderRadius.circular(50),
                                                child: SizedBox.fromSize(
                                                  size:
                                                      const Size.fromRadius(45),
                                                  child: AppNetImage(
                                                    path: value.cover,
                                                    errorAsset:
                                                        'assets/images/notfound.png',
                                                    fit: BoxFit.cover,
                                                  ),
                                                ),
                                              ),
                                            ),
                                            Positioned(
                                              bottom: 0,
                                              right: 0,
                                              child: Container(
                                                padding:
                                                    const EdgeInsets.all(6),
                                                decoration: BoxDecoration(
                                                  color: ThemeProvider.appColor,
                                                  shape: BoxShape.circle,
                                                  border: Border.all(
                                                    color: Colors.white,
                                                    width: 2,
                                                  ),
                                                ),
                                                child: const Icon(
                                                  Icons.camera_alt,
                                                  color: Colors.white,
                                                  size: 16,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(height: 12),
                                      Text('Business Profile'.tr,
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      // Content
                      SliverToBoxAdapter(
                        child: Container(
                          color: const Color(0xFFF8F9FA),
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Business Information Section
                              _buildSection(
                                title: 'Business Information'.tr,
                                icon: Icons.business,
                                children: [
                                  _buildTextField(
                                    label: 'Business Name'.tr,
                                    controller: value.salonNameTextEditor,
                                    hint: 'Enter Salon Name'.tr,
                                  ),
                                  const SizedBox(height: 16),
                                  _buildTextField(
                                    label: 'About Us'.tr,
                                    controller: value.aboutTextEditor,
                                    hint: 'About Us'.tr,
                                    maxLines: 3,
                                  ),
                                  const SizedBox(height: 16),
                                  _buildTextField(
                                    label: 'Website'.tr,
                                    controller: value.websiteTextEditor,
                                    hint: 'Enter Website'.tr,
                                  ),
                                  const SizedBox(height: 16),
                                  _buildTextField(
                                    label: 'WhatApp Number'.tr,
                                    controller: value.whatsappTextEditor,
                                    hint: 'Enter WhatsApp Number'.tr,
                                  ),
                                ],
                              ),
                              const SizedBox(height: 24),

                              // Location Section
                              _buildSection(
                                title: 'Location Details'.tr,
                                icon: Icons.location_on,
                                children: [
                                  _buildTextField(
                                    label: 'Address'.tr,
                                    controller: value.addressTextEditor,
                                    hint: 'Enter Address..'.tr,
                                    maxLines: 3,
                                  ),
                                  const SizedBox(height: 16),
                                  _buildDropdownField(
                                    label: 'City'.tr,
                                    value: value.profileInfo.cityData!.name
                                                    .toString() ==
                                                '' ||
                                            value.profileInfo.cityData!.name!
                                                .isEmpty
                                        ? 'Select'.tr
                                        : value.profileInfo.cityData!.name
                                            .toString(),
                                    onTap: () => value.onSelectCities(),
                                  ),
                                  const SizedBox(height: 16),
                                  _buildTextField(
                                    label: 'Pincode'.tr,
                                    controller: value.zipCodeTextEditor,
                                    hint: 'Pincode'.tr,
                                  ),
                                  const SizedBox(height: 16),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: _buildTextFieldCordinates(
                                          label: 'Latitude'.tr,
                                          controller: value.latTextEditor,
                                          hint: 'Latitude'.tr,
                                        ),
                                      ),
                                      const SizedBox(width: 16),
                                      Expanded(
                                        child: _buildTextFieldCordinates(
                                          label: 'Longitude'.tr,
                                          controller: value.lngTextEditor,
                                          hint: 'Longitude'.tr,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 16),
                                  ElevatedButton.icon(
                                      onPressed: () {
                                        value.getCurrentLocation();
                                      },
                                      icon: const Icon(Icons.gps_fixed_rounded),
                                      label: Text('Get Cordinates'.tr)),
                                ],
                              ),
                              const SizedBox(height: 24),

                              // Categories & Facilities Section
                              _buildSection(
                                title: 'Categories & Facilities'.tr,
                                icon: Icons.category,
                                children: [
                                  _buildDropdownField(
                                    label: 'Categories'.tr,
                                    value: value.profileInfo.webCatesData !=
                                                null &&
                                            value.profileInfo.webCatesData!
                                                .isNotEmpty
                                        ? '${value.profileInfo.webCatesData!.length} categories selected'
                                        : 'No categories selected',
                                    onTap: () => value.onSelectCategories(),
                                    showChevronRight: true,
                                  ),
                                  const SizedBox(height: 16),
                                  _buildDropdownField(
                                    label: 'Facilities'.tr,
                                    value: value.profileInfo
                                                    .fecilitiesCatesData !=
                                                null &&
                                            value.profileInfo
                                                .fecilitiesCatesData!.isNotEmpty
                                        ? '${value.profileInfo.fecilitiesCatesData!.length} facilities selected'
                                        : 'No facilities selected',
                                    onTap: () => value.onSelectFacilities(),
                                    showChevronRight: true,
                                  ),
                                ],
                              ),
                              const SizedBox(height: 24),

                              // Financial Section
                              _buildSection(
                                title: 'Financial Details'.tr,
                                icon: Icons.location_on,
                                children: [
                                  _buildTextField(
                                    label: 'Bank Name'.tr,
                                    controller: value.bankNameTextEditor,
                                    hint: 'Enter Bank Name..'.tr,
                                    maxLines: 1,
                                  ),
                                  const SizedBox(height: 16),
                                  _buildTextField(
                                    label: 'Bank Account Name'.tr,
                                    controller: value.bankCNameTextEditor,
                                    hint: 'Enter Bank Account Name..'.tr,
                                    maxLines: 1,
                                  ),
                                  const SizedBox(height: 16),
                                  _buildTextField(
                                    label: 'Bank IFSC Number'.tr,
                                    controller: value.bankIFSCTextEditor,
                                    hint: 'Enter IFSC Number..'.tr,
                                  ),
                                  const SizedBox(height: 16),
                                  _buildTextField(
                                    label: 'Bank A/C Number'.tr,
                                    controller: value.accNoTextEditor,
                                    hint: 'Enter Bank A/C Number..'.tr,
                                  ),
                                  const SizedBox(height: 16),
                                  _buildTextField(
                                    label: 'GST Number (Optional)'.tr,
                                    controller: value.gstTextEditor,
                                    hint: 'Enter GST Number..'.tr,
                                  ),
                                  const SizedBox(height: 16),
                                  _buildTextField(
                                    label: 'PAN Number'.tr,
                                    controller: value.panTextEditor,
                                    hint: 'Enter PAN Number..'.tr,
                                  ),
                                  const SizedBox(height: 16),
                                ],
                              ),
                              const SizedBox(height: 24),

                              // Service Options Section
                              _buildSection(
                                title: 'Service Options'.tr,
                                icon: Icons.settings,
                                children: [
                                  _buildSwitchTile(
                                    title: 'Have Multiple Stylist ?'.tr,
                                    value: value.haveStylist,
                                    onChanged: (status) =>
                                        value.updateStylist(status),
                                  ),
                                  _buildSwitchTile(
                                    title: 'Have Shop ?'.tr,
                                    value: value.haveShop,
                                    onChanged: (status) =>
                                        value.updateShop(status),
                                  ),
                                  _buildSwitchTile(
                                    title: 'Have Home Service?'.tr,
                                    value: value.haveHome,
                                    onChanged: (status) =>
                                        value.updateHome(status),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 24),

                              // Schedule Section
                              _buildSection(
                                title: 'Business Schedule'.tr,
                                icon: Icons.schedule,
                                children: [
                                  // Holidays
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text('Mark Holidays'.tr,
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.black87,
                                        ),
                                      ),
                                      InkWell(
                                        onTap: () => value.onHoliday(),
                                        child: Container(
                                          padding: const EdgeInsets.all(8),
                                          decoration: BoxDecoration(
                                            color: ThemeProvider.appColor
                                                .withOpacity(0.1),
                                            borderRadius:
                                                BorderRadius.circular(8),
                                          ),
                                          child: const Icon(
                                            Icons.add,
                                            color: ThemeProvider.appColor,
                                            size: 20,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 16),

                                  // Opening Hours
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        'Opening Hours'.tr,
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.black87,
                                        ),
                                      ),
                                      InkWell(
                                        onTap: () => value.onAddNewTiming(),
                                        child: Container(
                                          padding: const EdgeInsets.all(8),
                                          decoration: BoxDecoration(
                                            color: ThemeProvider.appColor
                                                .withOpacity(0.1),
                                            borderRadius:
                                                BorderRadius.circular(8),
                                          ),
                                          child: const Icon(
                                            Icons.add,
                                            color: ThemeProvider.appColor,
                                            size: 20,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 12),

                                  // Time Slots
                                  Column(
                                    children: List.generate(
                                      value.timesList.length,
                                      (index) => Container(
                                        margin:
                                            const EdgeInsets.only(bottom: 8),
                                        padding: const EdgeInsets.all(12),
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius:
                                              BorderRadius.circular(8),
                                          border: Border.all(
                                            color: Colors.grey.shade200,
                                          ),
                                        ),
                                        child: Row(
                                          children: [
                                            Container(
                                              width: 8,
                                              height: 8,
                                              decoration: const BoxDecoration(
                                                color: Colors.green,
                                                shape: BoxShape.circle,
                                              ),
                                            ),
                                            const SizedBox(width: 12),
                                            Expanded(
                                              flex: 2,
                                              child: Text(
                                                value.getDayName(value
                                                    .timesList[index]
                                                    .day as int),
                                                style: const TextStyle(
                                                  color: ThemeProvider.appColor,
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                            ),
                                            Expanded(
                                              flex: 3,
                                              child: Text(
                                                '${value.timesList[index].openTime} - ${value.timesList[index].closeTime}',
                                                style: const TextStyle(
                                                  color: Colors.black87,
                                                  fontSize: 14,
                                                ),
                                              ),
                                            ),
                                            TextButton(
                                              onPressed: () {
                                                value.onEditTime(
                                                  value.getDayName(value
                                                      .timesList[index]
                                                      .day as int),
                                                  value
                                                      .timesList[index].openTime
                                                      .toString(),
                                                  value.timesList[index]
                                                      .closeTime
                                                      .toString(),
                                                );
                                              },
                                              style: TextButton.styleFrom(
                                                backgroundColor:
                                                    Colors.orange.shade50,
                                                foregroundColor:
                                                    Colors.orange.shade700,
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                  horizontal: 12,
                                                  vertical: 6,
                                                ),
                                                minimumSize: Size.zero,
                                                tapTargetSize:
                                                    MaterialTapTargetSize
                                                        .shrinkWrap,
                                              ),
                                              child: Text(
                                                'Edit'.tr,
                                                style: const TextStyle(
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 100), // Space for FAB
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
            // Modern Floating Action Button
            floatingActionButton: Container(
              width: double.infinity,
              margin: const EdgeInsets.symmetric(horizontal: 20),
              child: FloatingActionButton.extended(
                onPressed: () => value.updateSalon(),
                backgroundColor: ThemeProvider.appColor,
                elevation: 8,
                extendedPadding: const EdgeInsets.symmetric(vertical: 16),
                label: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.check_circle,
                      color: Colors.white,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'SUBMIT'.tr,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            floatingActionButtonLocation:
                FloatingActionButtonLocation.centerFloat,
          ),
        );
      },
    );
    });
  }

  Widget _buildSection({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Icon(
                  icon,
                  size: 20,
                  color: ThemeProvider.appColor,
                ),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: children,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    required String hint,
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          maxLines: maxLines,
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.grey.shade50,
            hintText: hint,
            hintStyle: TextStyle(
              color: Colors.grey.shade500,
              fontSize: 14,
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: ThemeProvider.appColor),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTextFieldCordinates({
    required String label,
    required TextEditingController controller,
    required String hint,
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'[0-9.-]')),
          ],
          maxLines: maxLines,
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.grey.shade50,
            hintText: hint,
            hintStyle: TextStyle(
              color: Colors.grey.shade500,
              fontSize: 14,
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: ThemeProvider.appColor),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDropdownField({
    required String label,
    required String value,
    required VoidCallback onTap,
    bool showChevronRight = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(8),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    value,
                    style: TextStyle(
                      fontSize: 14,
                      color: value.contains('Select') || value.contains('No ')
                          ? Colors.grey.shade500
                          : Colors.black87,
                    ),
                  ),
                ),
                Icon(
                  showChevronRight ? Icons.chevron_right : Icons.expand_more,
                  color: Colors.grey.shade500,
                  size: 20,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSwitchTile({
    required String title,
    required bool value,
    required Function(bool) onChanged,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.black87,
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: Colors.white,
            activeTrackColor: Colors.green,
            inactiveThumbColor: Colors.white,
            inactiveTrackColor: Colors.grey.shade300,
          ),
        ],
      ),
    );
  }
}

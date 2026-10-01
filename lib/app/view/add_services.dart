import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:skeletons/skeletons.dart';
import 'package:ultimate_salon_owner_flutter/app/controller/add_services_controller.dart';
import 'package:ultimate_salon_owner_flutter/app/util/app_image.dart';
import 'package:ultimate_salon_owner_flutter/app/util/tax_helper.dart';
import 'package:ultimate_salon_owner_flutter/app/util/theme.dart';

class AddServicesScreen extends StatefulWidget {
  const AddServicesScreen({Key? key}) : super(key: key);

  @override
  State<AddServicesScreen> createState() => _AddServicesScreenState();
}

class _AddServicesScreenState extends State<AddServicesScreen> {
  @override
  Widget build(BuildContext context) {
    return GetBuilder<AddServicesController>(builder: (value) {
      return GestureDetector(
        onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
        child: Scaffold(
          backgroundColor: Colors.grey[50],
          appBar: AppBar(
            backgroundColor: ThemeProvider.appColor,
            elevation: 0,
            centerTitle: true,
            title: Text(
              value.editType == 0 ? 'Add Service'.tr : 'Update Service'.tr,
              style: const TextStyle(
                color: ThemeProvider.whiteColor,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            leading: IconButton(
              icon: const Icon(
                Icons.arrow_back,
                color: ThemeProvider.whiteColor,
              ),
              onPressed: () {
                Get.back();
              },
            ),
            actions: [
              IconButton(
                icon: const Icon(
                  Icons.info_outline,
                  color: ThemeProvider.whiteColor,
                ),
                onPressed: () {
                  _showInfoModal(context);
                },
              ),
            ],
          ),
          body: value.apiCalled == false
              ? _buildLoadingSkeleton()
              : SafeArea(
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Main Image Section
                          _buildMainImageSection(value, context),

                          const SizedBox(height: 25),

                          // Form Fields Section
                          _buildFormCard(value, context),
                        ],
                      ),
                    ),
                  ),
                ),
          bottomNavigationBar: _buildBottomButton(value, context),
        ),
      );
    });
  }

  Widget _buildLoadingSkeleton() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16),
          Center(
            child: SkeletonAvatar(
              style: SkeletonAvatarStyle(
                width: 150,
                height: 150,
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          const SizedBox(height: 30),
          const SkeletonLine(
            style: SkeletonLineStyle(height: 22, width: 150),
          ),
          const SizedBox(height: 16),
          SkeletonItem(
            child: Column(
              children: List.generate(
                5,
                (index) => Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: SkeletonLine(
                    style: SkeletonLineStyle(
                      height: 55,
                      width: double.infinity,
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),
          const SkeletonLine(
            style: SkeletonLineStyle(height: 22, width: 170),
          ),
          const SizedBox(height: 16),
          SkeletonItem(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: List.generate(
                3,
                (index) => SkeletonAvatar(
                  style: SkeletonAvatarStyle(
                    width: 100,
                    height: 100,
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 40),
          SkeletonLine(
            style: SkeletonLineStyle(
              height: 50,
              width: double.infinity,
              borderRadius: BorderRadius.circular(30),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMainImageSection(
      AddServicesController value, BuildContext context) {
    return Center(
      child: Column(
        children: [
          // Main Image
          Container(
            height: 180,
            width: 180,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey[300]!),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  spreadRadius: 1,
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ],
              color: Colors.white,
            ),
            child: Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: SizedBox.fromSize(
                    size: const Size.fromRadius(90),
                    child: AppImage.isValidPath(value.cover)
                        ? Image.network(
                      AppImage.url(value.cover)!,
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) {
                          return child;
                        } else {
                          return Center(
                            child: CircularProgressIndicator(
                              color: ThemeProvider.appColor,
                              value: loadingProgress.expectedTotalBytes != null
                                  ? loadingProgress.cumulativeBytesLoaded /
                                      (loadingProgress.expectedTotalBytes ?? 1)
                                  : null,
                            ),
                          );
                        }
                      },
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            color: Colors.grey[100],
                          ),
                          width: 180,
                          height: 180,
                          child: Icon(
                            Icons.image_not_supported_outlined,
                            color: Colors.grey[400],
                            size: 50,
                          ),
                        );
                      },
                      fit: BoxFit.cover,
                      width: 180,
                      height: 180,
                    )
                        : Image.asset(
                            'assets/images/placeholder.jpeg',
                            fit: BoxFit.cover,
                            width: 180,
                            height: 180,
                          ),
                  ),
                ),
                // Edit Button
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    height: 45,
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.6),
                      borderRadius: const BorderRadius.only(
                        bottomLeft: Radius.circular(12),
                        bottomRight: Radius.circular(12),
                      ),
                    ),
                    child: InkWell(
                      onTap: () {
                        _showImagePickerOptions(context, value);
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.camera_alt,
                            color: Colors.white,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Photo'.tr,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Recommended Size - 512x512'.tr,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFormCard(AddServicesController value, BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            offset: const Offset(0, 2),
            blurRadius: 10,
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Service Information'.tr,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),

            // Categories
            Visibility(
              visible: !value.action.contains('edit'),
              child: Column(
                children: [
                  _buildDropdownField(
                    title: 'Categories'.tr,
                    value: value.selectedCategoryName.isEmpty
                        ? 'Select Categories'.tr
                        : value.selectedCategoryName,
                    onTap: () => value.onServiceCategories(),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),

            // Service Name
            _buildDropdownField(
              title: 'Service Name'.tr,
              value: value.selectedServiceName.isEmpty
                  ? 'Select Service'.tr
                  : value.selectedServiceName,
              onTap: () {
                final catId =
                    int.tryParse(value.selectedCategoryId.toString()) ?? 0;
                if (catId <= 0) {
                  Get.snackbar(
                    'Category Required'.tr,
                    'Please select a category first'.tr,
                    snackPosition: SnackPosition.BOTTOM,
                    backgroundColor: Colors.redAccent,
                    colorText: Colors.white,
                    margin: const EdgeInsets.all(12),
                  );
                  return;
                }
                value.onServiceNames(catId);
              },
            ),
            const SizedBox(height: 16),

            // Price and Discount Section
            _buildPriceSection(value),
            const SizedBox(height: 16),

            // Service Type
            _buildDropdownField(
              title: 'Service Type'.tr,
              value: _getServiceTypeText(value.selectedType),
              onTap: () => _showServiceTypeModal(context, value),
            ),
            const SizedBox(height: 16),

            // Duration (hours + minutes, numbers only)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Service Duration'.tr,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[800],
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: _buildTextField(
                        title: 'Hours'.tr,
                        controller: value.durationHoursEditor,
                        hintText: '0',
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                        suffixIcon: const Icon(Icons.schedule,
                            color: ThemeProvider.appColor),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildTextField(
                        title: 'Minutes'.tr,
                        controller: value.durationMinutesEditor,
                        hintText: '0',
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                        suffixIcon: const Icon(Icons.timer,
                            color: ThemeProvider.appColor),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Description
            _buildTextField(
              title: 'Description'.tr,
              controller: value.descriptionsTextEditor,
              hintText: 'Enter service description'.tr,
              maxLines: 5,
            ),
            const SizedBox(height: 16),

            // Status
            _buildDropdownField(
              title: 'Status'.tr,
              value: value.selectedStatus == 1 ? 'Available'.tr : 'Hidden'.tr,
              onTap: () => _showStatusModal(context, value),
              iconColor: value.selectedStatus == 1
                  ? ThemeProvider.greenColor
                  : Colors.grey,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPriceSection(AddServicesController value) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              flex: 3,
              child: _buildTextField(
                title: 'Service Price'.tr,
                controller: value.priceTextEditor,
                hintText: 'Enter price'.tr,
                keyboardType: TextInputType.number,
                onChanged: (txt) => value.onRealPrice(txt),
                prefixText: '${value.currencySymbol} ',
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              flex: 2,
              child: _buildTextField(
                title: 'Discount %'.tr,
                controller: value.discountTextEditor,
                hintText: 'Discount'.tr,
                keyboardType: TextInputType.number,
                onChanged: (txt) => value.onDiscountPrice(txt),
                prefixIcon: Icon(Icons.percent, color: Colors.grey[600]),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        _buildTextField(
          title: 'Sell Price'.tr,
          controller: value.offTextEditor,
          hintText: 'Calculated sell price'.tr,
          enabled: false,
          fillColor: Colors.grey[100],
          prefixText: '${value.currencySymbol} ',
        ),
        if (TaxHelper.isAvailable && value.offTextEditor.text.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 12.0, left: 4.0),
            child: Text(
              '${'Final amount (incl. tax ${value.tax}%) -'.tr} ${value.currencySymbol}${value.finalPriceWithTax}',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildGallerySection(
      AddServicesController value, BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            offset: const Offset(0, 2),
            blurRadius: 10,
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Service Gallery'.tr,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: ThemeProvider.appColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${value.gallery.length} Images'.tr,
                  style: TextStyle(
                    color: ThemeProvider.appColor,
                    fontWeight: FontWeight.w500,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          GridView.count(
            primary: false,
            crossAxisCount: 3,
            mainAxisSpacing: 10,
            crossAxisSpacing: 10,
            shrinkWrap: true,
            childAspectRatio: 1,
            padding: EdgeInsets.zero,
            children: List.generate(
              value.gallery.length,
              (index) {
                return _buildGalleryItem(value, index, context);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGalleryItem(
      AddServicesController value, int index, BuildContext context) {
    return InkWell(
      onTap: () {
        _showGalleryImageOptions(context, value, index);
      },
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.grey[300]!),
        ),
        child: Stack(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: AppNetImage(
               path: value.gallery[index].toString(),
                fit: BoxFit.cover,
                width: double.infinity,
                height: double.infinity,
              ),
            ),
            Positioned(
              top: 0,
              right: 0,
              child: Container(
                decoration: const BoxDecoration(
                  color: ThemeProvider.appColor,
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(10),
                    topRight: Radius.circular(10),
                  ),
                ),
                padding: const EdgeInsets.all(6),
                child: const Icon(
                  Icons.edit,
                  color: Colors.white,
                  size: 16,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomButton(AddServicesController value, BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 1,
            blurRadius: 10,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: SafeArea(
        bottom: true,
        child: value.action == 'new'
            ? ElevatedButton(
                onPressed: () => value.onSubmit(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: ThemeProvider.appColor,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: Text(
                  'CREATE SERVICE'.tr,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              )
            : ElevatedButton(
                onPressed: () => value.onUpdateService(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: ThemeProvider.greenColor,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: Text(
                  'UPDATE SERVICE'.tr,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
      ),
    );
  }

  // Reusable UI Components
  Widget _buildTextField({
    required String title,
    required TextEditingController controller,
    required String hintText,
    int maxLines = 1,
    bool enabled = true,
    Color? fillColor,
    Widget? prefixIcon,
    Widget? suffixIcon,
    String? prefixText,
    TextInputType keyboardType = TextInputType.text,
    List<TextInputFormatter>? inputFormatters,
    Function(String)? onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.grey[800],
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: fillColor ?? Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey[300]!),
          ),
          child: TextField(
            controller: controller,
            decoration: InputDecoration(
              hintText: hintText,
              hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
              border: InputBorder.none,
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
              prefixIcon: prefixIcon,
              prefixIconConstraints: const BoxConstraints(
                minWidth: 0,
                minHeight: 0,
              ),
              prefixText: prefixText,
              prefixStyle: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: Colors.black87,
              ),
              suffixIcon: suffixIcon,
              isDense: true,
            ),
            enabled: enabled,
            maxLines: maxLines,
            keyboardType: keyboardType,
            inputFormatters: inputFormatters,
            onChanged: onChanged,
            style: TextStyle(
              color: enabled ? Colors.black : Colors.grey[700],
              fontSize: 15,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDropdownField({
    required String title,
    required String value,
    required VoidCallback onTap,
    Color? iconColor,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.grey[800],
          ),
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey[300]!),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 15,
                    color: iconColor ?? Colors.black,
                  ),
                ),
                Icon(
                  Icons.keyboard_arrow_down,
                  color: iconColor ?? Colors.grey[600],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // Helper methods
  String _getServiceTypeText(int type) {
    switch (type) {
      case 0:
        return 'Kids';
      case 1:
        return 'Male';
      case 2:
        return 'Female';
      case 3:
        return 'Family';
      default:
        return 'Unknown';
    }
  }

  // Modal Dialogs
  void _showImagePickerOptions(
      BuildContext context, AddServicesController value) {
    showCupertinoModalPopup<void>(
      context: context,
      builder: (BuildContext context) => CupertinoActionSheet(
        title: Text(
          'Choose From'.tr,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        actions: <CupertinoActionSheetAction>[
          CupertinoActionSheetAction(
            isDefaultAction: true,
            onPressed: () {
              Navigator.pop(context);
              value.selectFromGallery('camera');
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.camera_alt, color: ThemeProvider.appColor),
                const SizedBox(width: 10),
                Text(
                  'Camera'.tr,
                  style: const TextStyle(
                    color: ThemeProvider.appColor,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
          CupertinoActionSheetAction(
            onPressed: () {
              Navigator.pop(context);
              value.selectFromGallery('gallery');
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.photo_library, color: ThemeProvider.appColor),
                const SizedBox(width: 10),
                Text(
                  'Gallery'.tr,
                  style: const TextStyle(
                    color: ThemeProvider.appColor,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
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
  }

  void _showGalleryImageOptions(
      BuildContext context, AddServicesController value, int index) {
    showCupertinoModalPopup<void>(
      context: context,
      builder: (BuildContext context) => CupertinoActionSheet(
        title: Text(
          'Choose From'.tr,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        actions: <CupertinoActionSheetAction>[
          CupertinoActionSheetAction(
            isDefaultAction: true,
            onPressed: () {
              Navigator.pop(context);
              value.selectFromGalleryOthers('camera', index);
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.camera_alt, color: ThemeProvider.appColor),
                const SizedBox(width: 10),
                Text(
                  'Camera'.tr,
                  style: const TextStyle(
                    color: ThemeProvider.appColor,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
          CupertinoActionSheetAction(
            onPressed: () {
              Navigator.pop(context);
              value.selectFromGalleryOthers('gallery', index);
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.photo_library, color: ThemeProvider.appColor),
                const SizedBox(width: 10),
                Text(
                  'Gallery'.tr,
                  style: const TextStyle(
                    color: ThemeProvider.appColor,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
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
  }

  void _showServiceTypeModal(
      BuildContext context, AddServicesController value) {
    showCupertinoModalPopup<void>(
      context: context,
      builder: (BuildContext context) => CupertinoActionSheet(
        title: Text(
          'Select Type'.tr,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        actions: <CupertinoActionSheetAction>[
          _buildServiceTypeOption(context, value, 0, 'Kids', Icons.child_care),
          _buildServiceTypeOption(context, value, 1, 'Male', Icons.man),
          _buildServiceTypeOption(context, value, 2, 'Female', Icons.woman),
          _buildServiceTypeOption(
              context, value, 3, 'Family', Icons.family_restroom),
          CupertinoActionSheetAction(
            isDestructiveAction: true,
            onPressed: () {
              Navigator.pop(context);
            },
            child: Text('Cancel'.tr),
          ),
        ],
      ),
    );
  }

  CupertinoActionSheetAction _buildServiceTypeOption(
    BuildContext context,
    AddServicesController value,
    int typeValue,
    String label,
    IconData icon,
  ) {
    return CupertinoActionSheetAction(
      onPressed: () {
        value.updateType(typeValue);
        Navigator.pop(context);
      },
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: ThemeProvider.appColor),
          const SizedBox(width: 10),
          Text(
            label,
            style: const TextStyle(
              color: ThemeProvider.appColor,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  void _showStatusModal(BuildContext context, AddServicesController value) {
    showCupertinoModalPopup<void>(
      context: context,
      builder: (BuildContext context) => CupertinoActionSheet(
        title: Text(
          'Choose Status'.tr,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        actions: <CupertinoActionSheetAction>[
          CupertinoActionSheetAction(
            onPressed: () {
              value.updateStatus(1);
              Navigator.pop(context);
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.visibility, color: ThemeProvider.greenColor),
                const SizedBox(width: 10),
                Text(
                  'Available'.tr,
                  style: const TextStyle(
                    color: ThemeProvider.greenColor,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
          CupertinoActionSheetAction(
            onPressed: () {
              value.updateStatus(0);
              Navigator.pop(context);
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.visibility_off, color: Colors.grey),
                const SizedBox(width: 10),
                Text(
                  'Hidden'.tr,
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
          CupertinoActionSheetAction(
            isDestructiveAction: true,
            onPressed: () {
              Navigator.pop(context);
            },
            child: Text('Cancel'.tr),
          ),
        ],
      ),
    );
  }

  void _showInfoModal(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          title: Text(
            'Service Information'.tr,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: ThemeProvider.appColor,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildInfoItem(Icons.image,
                  'Add a clear, high-quality image (512x512px) that represents your service well.'),
              const SizedBox(height: 10),
              _buildInfoItem(Icons.category,
                  'Select the appropriate category and service name that best matches your offering.'),
              const SizedBox(height: 10),
              _buildInfoItem(Icons.attach_money,
                  'Set a competitive price and attractive discount to appeal to customers.'),
              const SizedBox(height: 10),
              _buildInfoItem(Icons.description,
                  'Write a detailed description highlighting the benefits and features of your service.'),
              const SizedBox(height: 10),
              _buildInfoItem(Icons.photo_library,
                  'Add multiple gallery images to showcase different aspects of your service.'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(
                'Got it'.tr,
                style: const TextStyle(
                  color: ThemeProvider.appColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildInfoItem(IconData icon, String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          color: ThemeProvider.appColor,
          size: 18,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(fontSize: 14),
          ),
        ),
      ],
    );
  }
}

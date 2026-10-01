import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:ultimate_salon_owner_flutter/app/controller/add_packages_controller.dart';
import 'package:ultimate_salon_owner_flutter/app/util/app_image.dart';
import 'package:ultimate_salon_owner_flutter/app/util/tax_helper.dart';
import 'package:ultimate_salon_owner_flutter/app/util/theme.dart';

class AddPackagesScreen extends StatefulWidget {
  const AddPackagesScreen({Key? key}) : super(key: key);

  @override
  State<AddPackagesScreen> createState() => _AddPackagesScreenState();
}

class _AddPackagesScreenState extends State<AddPackagesScreen> {
  @override
  Widget build(BuildContext context) {
    return GetBuilder<AddPackagesController>(
      builder: (value) {
        return GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: Scaffold(
            backgroundColor: Colors.grey[50],
            appBar: AppBar(
              backgroundColor: ThemeProvider.appColor,
              iconTheme: const IconThemeData(color: ThemeProvider.whiteColor),
              centerTitle: true,
              elevation: 0,
              title: Text(
                value.editType == 0 ? 'Add Package' : 'Update Package',
                style: const TextStyle(
                  color: ThemeProvider.whiteColor,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              actions: [
                Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: IconButton(
                    icon: const Icon(Icons.help_outline),
                    onPressed: () {
                      // Show help tooltip
                      showModalBottomSheet(
                        context: context,
                        shape: const RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.vertical(top: Radius.circular(20)),
                        ),
                        builder: (context) => Container(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Package Creation Tips'.tr,
                                style: TextStyle(
                                    fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 16),
                              buildHelpItem(Icons.image,
                                  'Upload a high-quality image (512x512)'),
                              buildHelpItem(Icons.description,
                                  'Add a detailed description'),
                              buildHelpItem(Icons.attach_money,
                                  'Set competitive pricing'),
                              const SizedBox(height: 20),
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton(
                                  onPressed: () => Navigator.pop(context),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: ThemeProvider.appColor,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(30),
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 12),
                                  ),
                                  child: Text('Got it!'.tr),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
            body: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(30),
                  topRight: Radius.circular(30),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, -5),
                  ),
                ],
              ),
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Package Image Section
                      _buildSectionTitle('Package Image'),
                      const SizedBox(height: 10),
                      Center(
                        child: GestureDetector(
                          onTap: () => _showImageSourceOptions(context, value),
                          child: Stack(
                            children: [
                              Container(
                                height: 140,
                                width: 140,
                                decoration: BoxDecoration(
                                  color: Colors.grey[100],
                                  borderRadius: BorderRadius.circular(15),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.grey.withOpacity(0.2),
                                      blurRadius: 8,
                                      offset: const Offset(0, 3),
                                    ),
                                  ],
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(15),
                                  child: AppNetImage(
                                   path: value.cover.toString(),
                                    fit: BoxFit.cover,
                                    placeholder: Center(
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Icon(
                                            Icons.image_outlined,
                                            size: 40,
                                            color: Colors.grey[400],
                                          ),
                                          const SizedBox(height: 8),
                                          Text(
                                            'Add Image'.tr,
                                            style: TextStyle(
                                              color: Colors.grey[600],
                                              fontSize: 12,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              Positioned(
                                bottom: 0,
                                right: 0,
                                child: Container(
                                  padding: const EdgeInsets.all(8),
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
                                    size: 18,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Text('Recommended Size - 512x512'.tr,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Package Details Section
                      _buildSectionTitle('Package Details'),
                      const SizedBox(height: 16),

                      // Package Name Field
                      _buildTextField(
                        controller: value.packagesNameTextEditor,
                        hintText: 'Package Name'.tr,
                        icon: Icons.card_giftcard,
                      ),
                      const SizedBox(height: 16),

                      // Services Selection
                      _buildSelectionField(
                        title: 'Services'.tr,
                        subtitle: 'Select services included in this package'.tr,
                        icon: Icons.spa,
                        value: value.savedServices.isEmpty
                            ? null
                            : value.savedServices.join(', '),
                        onTap: () => value.onSelectPackages(),
                      ),
                      const SizedBox(height: 16),

                      // Specialist Selection (conditional)
                      if (value.userType == true)
                        Column(
                          children: [
                            _buildSelectionField(
                              title: 'Specialist'.tr,
                              subtitle: 'Select specialists for this package'.tr,
                              icon: Icons.person,
                              value: value.savedSpecialist.isEmpty
                                  ? null
                                  : value.savedSpecialist.join(', '),
                              onTap: () => value.onSelectSpecialist(),
                            ),
                            const SizedBox(height: 16),
                          ],
                        ),

                      // Service Type Selection
                      // _buildSelectionField(
                      //   title: 'Service Type'.tr,
                      //   subtitle: 'Select who this package is for'.tr,
                      //   icon: Icons.people_alt,
                      //   value: _getServiceTypeText(value.selectedType),
                      //   onTap: () => _showServiceTypeOptions(context, value),
                      // ),
                      // const SizedBox(height: 24),

                      // Pricing Section
                      _buildSectionTitle('Pricing Information'),
                      const SizedBox(height: 16),

                      // Three columns layout for pricing
                      Row(
                        children: [
                          Expanded(
                            child: _buildTextField(
                              controller: value.priceTextEditor,
                              hintText: 'Original Price'.tr,
                              prefixText: '${value.currencySymbol} ',
                              onChanged: (txt) => value.onRealPrice(txt),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildTextField(
                              controller: value.discountTextEditor,
                              hintText: 'Discount %'.tr,
                              icon: Icons.discount,
                              onChanged: (txt) => value.onDiscountPrice(txt),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      _buildTextField(
                        controller: value.sellPriceTextEditor,
                        hintText: 'Final Selling Price'.tr,
                        prefixText: '${value.currencySymbol} ',
                        readOnly: true,
                        labelColor: ThemeProvider.appColor,
                      ),
                      if (TaxHelper.isAvailable &&
                          value.sellPriceTextEditor.text.isNotEmpty)
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
                      const SizedBox(height: 24),

                      // Additional Information Section
                      _buildSectionTitle('Additional Information'),
                      const SizedBox(height: 16),

                      // Duration Field (hours + minutes, numbers only)
                      Row(
                        children: [
                          Expanded(
                            child: _buildTextField(
                              controller: value.durationHoursEditor,
                              hintText: 'Hours'.tr,
                              icon: Icons.schedule,
                              keyboardType: TextInputType.number,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                              ],
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildTextField(
                              controller: value.durationMinutesEditor,
                              hintText: 'Minutes'.tr,
                              icon: Icons.timer,
                              keyboardType: TextInputType.number,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Description Field
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Description'.tr,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: Colors.grey[700],
                            ),
                          ),
                          const SizedBox(height: 8),
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.grey[50],
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.grey[300]!),
                            ),
                            child: TextField(
                              controller: value.descriptionTextEditor,
                              maxLines: 5,
                              decoration: InputDecoration(
                                hintText: 'Describe what\'.trs included in this package...',
                                hintStyle: TextStyle(
                                  color: Colors.grey[400],
                                  fontSize: 14,
                                ),
                                contentPadding: const EdgeInsets.all(16),
                                border: InputBorder.none,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
            ),
            bottomNavigationBar: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, -5),
                  ),
                ],
              ),
              child: SafeArea(
                bottom: true,
                child: ElevatedButton(
                  onPressed: () {
                    value.action == 'new' ? value.onSave() : value.onUpdate();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: value.action == 'new'
                        ? ThemeProvider.appColor
                        : ThemeProvider.greenColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    elevation: 0,
                  ),
                  child: Text(
                    value.action == 'new' ? 'CREATE PACKAGE' : 'UPDATE PACKAGE',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  // Helper Methods
  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: ThemeProvider.appColor,
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    IconData? icon,
    Widget? prefix,
    String? prefixText,
    Function(String)? onChanged,
    bool readOnly = false,
    Color? labelColor,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        readOnly: readOnly,
        keyboardType: keyboardType ??
            (prefixText != null
                ? const TextInputType.numberWithOptions(decimal: true)
                : TextInputType.text),
        inputFormatters: inputFormatters,
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: TextStyle(
            color: Colors.grey[400],
            fontSize: 14,
          ),
          prefixText: prefixText,
          prefixStyle: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: labelColor ?? Colors.black87,
          ),
          prefixIcon: prefix ??
              (icon == null
                  ? null
                  : Icon(
                      icon,
                      color: labelColor ?? Colors.grey[500],
                      size: 20,
                    )),
          prefixIconConstraints: const BoxConstraints(
            minWidth: 0,
            minHeight: 0,
          ),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          border: InputBorder.none,
        ),
      ),
    );
  }

  Widget _buildSelectionField({
    required String title,
    required String subtitle,
    required IconData icon,
    required VoidCallback onTap,
    String? value,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.grey[50],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey[300]!),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: Colors.grey[500],
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    value ?? subtitle,
                    style: TextStyle(
                      fontSize: 13,
                      color: value != null ? Colors.black87 : Colors.grey[500],
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios,
              color: Colors.grey,
              size: 16,
            ),
          ],
        ),
      ),
    );
  }

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
        return 'Select Type';
    }
  }

  void _showImageSourceOptions(
      BuildContext context, AddPackagesController controller,
      {bool isGallery = false, int index = 0}) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Select Image Source'.tr,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildImageSourceOption(
                  context: context,
                  icon: Icons.camera_alt,
                  title: 'Camera'.tr,
                  onTap: () {
                    Navigator.pop(context);
                    if (isGallery) {
                      controller.selectFromGalleryOthers('camera', index);
                    } else {
                      controller.selectFromGallery('camera');
                    }
                  },
                ),
                _buildImageSourceOption(
                  context: context,
                  icon: Icons.photo_library,
                  title: 'Gallery'.tr,
                  onTap: () {
                    Navigator.pop(context);
                    if (isGallery) {
                      controller.selectFromGalleryOthers('gallery', index);
                    } else {
                      controller.selectFromGallery('gallery');
                    }
                  },
                ),
              ],
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: TextButton(
                onPressed: () => Navigator.pop(context),
                style: TextButton.styleFrom(
                  foregroundColor: Colors.red,
                ),
                child: Text('Cancel'.tr),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImageSourceOption({
    required BuildContext context,
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: ThemeProvider.appColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: ThemeProvider.appColor,
              size: 30,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: const TextStyle(fontSize: 14),
          ),
        ],
      ),
    );
  }

  void _showServiceTypeOptions(
      BuildContext context, AddPackagesController controller) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Select Service Type'.tr,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            _buildServiceTypeOption(
              icon: Icons.child_care,
              title: 'Kids'.tr,
              description: 'Services tailored for children',
              onTap: () {
                controller.updateType(0);
                Navigator.pop(context);
              },
            ),
            const Divider(),
            _buildServiceTypeOption(
              icon: Icons.man,
              title: 'Male'.tr,
              description: 'Services designed for men',
              onTap: () {
                controller.updateType(1);
                Navigator.pop(context);
              },
            ),
            const Divider(),
            _buildServiceTypeOption(
              icon: Icons.woman,
              title: 'Female'.tr,
              description: 'Services designed for women',
              onTap: () {
                controller.updateType(2);
                Navigator.pop(context);
              },
            ),
            const Divider(),
            _buildServiceTypeOption(
              icon: Icons.family_restroom,
              title: 'Family'.tr,
              description: 'Services suitable for the whole family',
              onTap: () {
                controller.updateType(3);
                Navigator.pop(context);
              },
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  Widget _buildServiceTypeOption({
    required IconData icon,
    required String title,
    required String description,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: ThemeProvider.appColor),
      title: Text(title),
      subtitle: Text(description),
      onTap: onTap,
    );
  }

  Widget buildHelpItem(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(icon, size: 20, color: ThemeProvider.appColor),
          const SizedBox(width: 12),
          Expanded(
            child: Text(text),
          ),
        ],
      ),
    );
  }
}

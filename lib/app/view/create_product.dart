import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ultimate_salon_owner_flutter/app/controller/create_products_controller.dart';
import 'package:ultimate_salon_owner_flutter/app/util/app_image.dart';
import 'package:ultimate_salon_owner_flutter/app/util/currency_helper.dart';
import 'package:ultimate_salon_owner_flutter/app/util/theme.dart';

class CreateProductsScreen extends StatefulWidget {
  const CreateProductsScreen({Key? key}) : super(key: key);

  @override
  State<CreateProductsScreen> createState() => _CreateProductsScreenState();
}

class _CreateProductsScreenState extends State<CreateProductsScreen> {
  @override
  Widget build(BuildContext context) {
    return GetBuilder<CreateProductsController>(
      builder: (value) {
        return GestureDetector(
          onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
          child: Scaffold(
            backgroundColor: Colors.grey[50],
            appBar: AppBar(
              backgroundColor: ThemeProvider.appColor,
              elevation: 0,
              centerTitle: true,
              title: Text(
                value.type == 'create'
                    ? 'Create Product'.tr
                    : 'Update Product'.tr,
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
                    Icons.help_outline,
                    color: ThemeProvider.whiteColor,
                  ),
                  onPressed: () {
                    _showHelpDialog(context);
                  },
                ),
              ],
            ),
            body: value.apiCalled == true
                ? SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Main Form Section
                          _buildMainFormSection(value, context),

                          const SizedBox(height: 24),

                          // Gallery Section
                          _buildGallerySection(value, context),

                          const SizedBox(height: 24),

                          // Product Size Options
                          _buildProductSizeOptions(value),

                          const SizedBox(height: 24),

                          // Expiry Date Section
                          _buildExpiryDateSection(value),
                        ],
                      ),
                    ),
                  )
                : const Center(
                    child: CircularProgressIndicator(
                      color: ThemeProvider.appColor,
                    ),
                  ),
            bottomNavigationBar: _buildBottomButton(value),
          ),
        );
      },
    );
  }

  Widget _buildMainFormSection(
      CreateProductsController value, BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Product Image
          Center(
            child: Stack(
              children: [
                GestureDetector(
                  onTap: () {
                    _showImagePickerOptions(context, value);
                  },
                  child: Container(
                    height: 140,
                    width: 140,
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(color: Colors.grey[300]!),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(15),
                      child: AppNetImage(
                        path: value.cover,
                        fit: BoxFit.cover,
                        height: 140,
                        width: 140,
                        placeholder: Center(
                          child: Icon(
                            Icons.image_not_supported_outlined,
                            color: Colors.grey[400],
                            size: 40,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    height: 35,
                    width: 35,
                    decoration: BoxDecoration(
                      color: ThemeProvider.appColor,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
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
          Center(
            child: Padding(
              padding: const EdgeInsets.only(top: 5, bottom: 20),
              child: Text(
                'Recommended Size - 512x512'.tr,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
          ),

          // Categories Dropdown
          _buildDropdownField(
            title: 'Categories'.tr,
            value: value.selectedCateName.isEmpty
                ? 'Select Categories'.tr
                : value.selectedCateName,
            onTap: () => value.onShopCategories(),
          ),
          const SizedBox(height: 16),

          // Subcategories Dropdown
          _buildDropdownField(
            title: 'Select Subcategories'.tr,
            value: value.selectedSubName.isEmpty
                ? 'Sub Categories'.tr
                : value.selectedSubName,
            onTap: () => value.onShopSubCategories(),
          ),
          const SizedBox(height: 16),

          // Product Name Field
          _buildTextField(
            controller: value.productNameTextEditor,
            label: 'Product Name'.tr,
            hint: 'Enter product name'.tr,
            prefixIcon: const Icon(Icons.inventory_2_outlined,
                color: ThemeProvider.appColor),
          ),
          const SizedBox(height: 16),

          // Price Fields Section
          _buildPriceSection(value),
          const SizedBox(height: 16),

          // Product Status Options
          // _buildStatusOptions(value),
        ],
      ),
    );
  }

  Widget _buildPriceSection(CreateProductsController value) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              flex: 3,
              child: _buildTextField(
                controller: value.productsPriceTextEditor,
                label: 'Product Price'.tr,
                hint: 'Enter price'.tr,
                prefixIcon: Icon(Icons.currency_rupee, color: Colors.grey[600]),
                keyboardType: TextInputType.number,
                onChanged: (txt) => value.onRealPrice(txt),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              flex: 2,
              child: _buildTextField(
                controller: value.discountTextEditor,
                label: 'Discount %'.tr,
                hint: 'Discount'.tr,
                prefixIcon: Icon(Icons.percent, color: Colors.grey[600]),
                keyboardType: TextInputType.number,
                onChanged: (txt) => value.onDiscountPrice(txt),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        _buildTextField(
          controller: value.sellPriceTextEditor,
          label: 'Sell Price'.tr,
          hint: 'Calculated sell price'.tr,
          prefixIcon: Icon(
            Icons.currency_rupee,
            color: ThemeProvider.appColor.withOpacity(0.7),
          ),
          enabled: false,
          fillColor: Colors.grey[100],
        ),
        if (value.sellPriceTextEditor.text.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 12.0, left: 4.0),
            child: Text(
              '${'Final amount (incl. tax 18%) -'.tr} ${CurrencyHelper.format(value.finalPriceWithTax)}',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        const SizedBox(height: 16),
        _buildTextField(
          controller: value.hsnCodeTextEditor,
          label: 'HSN Code'.tr,
          hint: 'Enter Product HSN Code'.tr,
          prefixIcon: Icon(
            Icons.code,
            color: ThemeProvider.appColor.withOpacity(0.7),
          ),
          enabled: true,
        ),
        const SizedBox(height: 16),
        _buildTextFieldLarge(
          controller: value.descriptionTextEditor,
          label: 'Description'.tr,
          hint: '\n\nEnter Product Description'.tr,
          prefixIcon: Icon(
            Icons.text_fields,
            color: ThemeProvider.appColor.withOpacity(0.7),
          ),
          enabled: true,
        ),
        const SizedBox(height: 16),
        _buildTextFieldLarge(
          controller: value.disclaimerTextEditor,
          label: 'Disclaimer'.tr,
          hint: '\n\nEnter Product Disclaimer'.tr,
          prefixIcon: Icon(
            Icons.info,
            color: ThemeProvider.appColor.withOpacity(0.7),
          ),
          enabled: true,
        ),
      ],
    );
  }

  Widget _buildStatusOptions(CreateProductsController value) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildToggleOptionCard(
                title: 'In Offers'.tr,
                value: value.selectedOfferStatus == 1,
                icon: Icons.local_offer_outlined,
                color: ThemeProvider.greenColor,
                onTap: () {
                  _showStatusPicker(
                      context,
                      'In Offers'.tr,
                      value.selectedOfferStatus,
                      (int status) => value.updateOfferStatus(status));
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildToggleOptionCard(
                title: 'In Stock'.tr,
                value: value.selectedStackStatus == 1,
                icon: Icons.inventory,
                color: ThemeProvider.greenColor,
                onTap: () {
                  _showStatusPicker(
                      context,
                      'In Stock'.tr,
                      value.selectedStackStatus,
                      (int status) => value.updateStackStatus(status));
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildToggleOptionCard(
                title: 'In Home'.tr,
                value: value.inHome,
                icon: Icons.home_outlined,
                color: ThemeProvider.greenColor,
                onTap: () => value.updateinHome(!value.inHome),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildToggleOptionCard(
                title: 'In Single'.tr,
                value: value.inSingle,
                icon: Icons.single_bed,
                color: ThemeProvider.greenColor,
                onTap: () => value.updateinSingle(!value.inSingle),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildGallerySection(
      CreateProductsController value, BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
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
                'Product Gallery'.tr,
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
      CreateProductsController value, int index, BuildContext context) {
    return GestureDetector(
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
                path: value.gallery[index],
                fit: BoxFit.cover,
                height: double.infinity,
                width: double.infinity,
                placeholder: Center(
                  child: Icon(
                    Icons.image_not_supported_outlined,
                    color: Colors.grey[400],
                  ),
                ),
              ),
            ),
            Positioned(
              top: 0,
              right: 0,
              child: Container(
                decoration: const BoxDecoration(
                  color: ThemeProvider.appColor,
                  borderRadius: BorderRadius.only(
                    topRight: Radius.circular(10),
                    bottomLeft: Radius.circular(10),
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

  Widget _buildProductSizeOptions(CreateProductsController value) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Product Size Options',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),

          // Product Size Options
          _buildSizeOption(
            value: value,
            title: 'In Gram'.tr,
            isEnabled: value.inGrams,
            toggleCallback: (status) => value.updateinGrams(status),
            controller: value.gramTextEditor,
            hint: 'Gram Value'.tr,
            icon: Icons.line_weight,
          ),

          const Divider(height: 24),

          _buildSizeOption(
            value: value,
            title: 'In KG'.tr,
            isEnabled: value.inKG,
            toggleCallback: (status) => value.updateinKG(status),
            controller: value.kgTextEditor,
            hint: 'KG Value'.tr,
            icon: Icons.fitness_center,
          ),

          const Divider(height: 24),

          _buildSizeOption(
            value: value,
            title: 'In Liter'.tr,
            isEnabled: value.inLiter,
            toggleCallback: (status) => value.updateinLiter(status),
            controller: value.literTextEditor,
            hint: 'Liter Value'.tr,
            icon: Icons.local_drink_outlined,
          ),

          const Divider(height: 24),

          _buildSizeOption(
            value: value,
            title: 'In PCs'.tr,
            isEnabled: value.inPCs,
            toggleCallback: (status) => value.updateinPCs(status),
            controller: value.pcsTextEditor,
            hint: 'PCs Value'.tr,
            icon: Icons.category_outlined,
          ),

          const Divider(height: 24),

          _buildSizeOption(
            value: value,
            title: 'In ML'.tr,
            isEnabled: value.inML,
            toggleCallback: (status) => value.updateinML(status),
            controller: value.mlTextEditor,
            hint: 'ML Value'.tr,
            icon: Icons.water_drop_outlined,
          ),
        ],
      ),
    );
  }

  Widget _buildSizeOption({
    required CreateProductsController value,
    required String title,
    required bool isEnabled,
    required Function(bool) toggleCallback,
    required TextEditingController controller,
    required String hint,
    required IconData icon,
  }) {
    return Column(
      children: [
        Row(
          children: [
            Icon(icon, color: ThemeProvider.appColor),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Switch(
              value: isEnabled,
              activeColor: ThemeProvider.appColor,
              onChanged: toggleCallback,
            ),
          ],
        ),
        if (isEnabled)
          Padding(
            padding: const EdgeInsets.only(top: 8, left: 34),
            child: TextField(
              controller: controller,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                hintText: hint,
                hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
                filled: true,
                fillColor: Colors.grey[50],
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: Colors.grey[300]!),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: Colors.grey[300]!),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: ThemeProvider.appColor),
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildExpiryDateSection(CreateProductsController value) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Product Expiry',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          InkWell(
            onTap: () async {
              value.openTimePicker();
            },
            borderRadius: BorderRadius.circular(10),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey[300]!),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  const Icon(Icons.calendar_today,
                      color: ThemeProvider.appColor),
                  const SizedBox(width: 16),
                  Text(
                    'Expiry Date'.tr,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: ThemeProvider.appColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '${value.expDate.day}/${value.expDate.month}/${value.expDate.year}',
                      style: const TextStyle(
                        color: ThemeProvider.appColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomButton(CreateProductsController value) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: SafeArea(
        bottom: true,
        child: value.type == 'create'
            ? ElevatedButton(
                onPressed: () => value.saveProducts(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: ThemeProvider.appColor,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  elevation: 0,
                ),
                child: Text(
                  'CREATE PRODUCT'.tr,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              )
            : ElevatedButton(
                onPressed: () => value.updateProduct(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: ThemeProvider.greenColor,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  elevation: 0,
                ),
                child: Text(
                  'UPDATE PRODUCT'.tr,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
      ),
    );
  }

  Widget _buildTextFieldLarge({
    required TextEditingController controller,
    required String label,
    required String hint,
    Widget? prefixIcon,
    TextInputType keyboardType = TextInputType.text,
    bool enabled = true,
    Color? fillColor,
    Function(String)? onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.grey[800],
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          enabled: enabled,
          maxLines: 5,
          keyboardType: keyboardType,
          onChanged: onChanged,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
            prefixIcon: prefixIcon,
            filled: true,
            fillColor: fillColor ?? Colors.white,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: ThemeProvider.appColor),
            ),
            disabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
          ),
        ),
      ],
    );
  }

  // Helper UI Components
  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    Widget? prefixIcon,
    TextInputType keyboardType = TextInputType.text,
    bool enabled = true,
    Color? fillColor,
    Function(String)? onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.grey[800],
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          enabled: enabled,
          keyboardType: keyboardType,
          onChanged: onChanged,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
            prefixIcon: prefixIcon,
            filled: true,
            fillColor: fillColor ?? Colors.white,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: ThemeProvider.appColor),
            ),
            disabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: Colors.grey[300]!),
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
          borderRadius: BorderRadius.circular(10),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey[300]!),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 14,
                    color: value.contains('Select')
                        ? Colors.grey[500]
                        : Colors.black,
                  ),
                ),
                Icon(
                  Icons.keyboard_arrow_down,
                  color: Colors.grey[600],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildToggleOptionCard({
    required String title,
    required bool value,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
        decoration: BoxDecoration(
          color: value ? color.withOpacity(0.1) : Colors.grey[100],
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: value ? color.withOpacity(0.5) : Colors.grey[300]!,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: value ? color : Colors.grey[500],
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: value ? color : Colors.grey[700],
              ),
            ),
            const SizedBox(height: 5),
            Container(
              height: 18,
              width: 40,
              decoration: BoxDecoration(
                color: value ? color : Colors.grey[300],
                borderRadius: BorderRadius.circular(10),
              ),
              child: Center(
                child: Text(
                  value ? 'ON'.tr : 'OFF'.tr,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Dialog Helpers
  void _showImagePickerOptions(
      BuildContext context, CreateProductsController value) {
    showCupertinoModalPopup<void>(
      context: context,
      builder: (BuildContext context) => CupertinoActionSheet(
        title: Text(
          'Choose Image Source'.tr,
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
                    color: Color.fromARGB(219, 182, 177, 177),
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
          ),
        ],
      ),
    );
  }

  void _showGalleryImageOptions(
      BuildContext context, CreateProductsController value, int index) {
    showCupertinoModalPopup<void>(
      context: context,
      builder: (BuildContext context) => CupertinoActionSheet(
        title: Text(
          'Change Gallery Image'.tr,
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
          ),
        ],
      ),
    );
  }

  void _showStatusPicker(BuildContext context, String title, int currentStatus,
      Function(int) onStatusChanged) {
    showCupertinoModalPopup<void>(
      context: context,
      builder: (BuildContext context) => CupertinoActionSheet(
        title: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        actions: <CupertinoActionSheetAction>[
          CupertinoActionSheetAction(
            onPressed: () {
              onStatusChanged(1);
              Navigator.pop(context);
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.visibility,
                  color: currentStatus == 1
                      ? ThemeProvider.greenColor
                      : ThemeProvider.appColor,
                ),
                const SizedBox(width: 10),
                Text(
                  'Available'.tr,
                  style: TextStyle(
                    color: currentStatus == 1
                        ? ThemeProvider.greenColor
                        : ThemeProvider.appColor,
                    fontSize: 16,
                  ),
                ),
                if (currentStatus == 1)
                  const Padding(
                    padding: EdgeInsets.only(left: 10),
                    child: Icon(
                      Icons.check_circle,
                      color: ThemeProvider.greenColor,
                      size: 18,
                    ),
                  ),
              ],
            ),
          ),
          CupertinoActionSheetAction(
            onPressed: () {
              onStatusChanged(0);
              Navigator.pop(context);
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.visibility_off,
                  color:
                      currentStatus == 0 ? Colors.grey : ThemeProvider.appColor,
                ),
                const SizedBox(width: 10),
                Text(
                  'Hide'.tr,
                  style: TextStyle(
                    color: currentStatus == 0
                        ? Colors.grey
                        : ThemeProvider.appColor,
                    fontSize: 16,
                  ),
                ),
                if (currentStatus == 0)
                  const Padding(
                    padding: EdgeInsets.only(left: 10),
                    child: Icon(
                      Icons.check_circle,
                      color: Colors.grey,
                      size: 18,
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

  void _showHelpDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          title: Row(
            children: [
              const Icon(
                Icons.help_outline,
                color: ThemeProvider.appColor,
                size: 24,
              ),
              const SizedBox(width: 10),
              Text(
                'Product Information'.tr,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHelpItem(
                  Icons.photo_library,
                  'Images'.tr,
                  'Add a clear main image and additional gallery images.'.tr,
                ),
                const Divider(),
                _buildHelpItem(
                  Icons.category,
                  'Categories'.tr,
                  'Select the appropriate category and subcategory for better discoverability.'
                      .tr,
                ),
                const Divider(),
                _buildHelpItem(
                  Icons.attach_money,
                  'Pricing'.tr,
                  'Set a competitive price and appropriate discount percentage.'
                      .tr,
                ),
                const Divider(),
                _buildHelpItem(
                  Icons.local_offer,
                  'Visibility'.tr,
                  'Control where your product appears by toggling the display options.'
                      .tr,
                ),
                const Divider(),
                _buildHelpItem(
                  Icons.inventory_2,
                  'Size Options'.tr,
                  'Enable relevant size options (Gram, KG, Liter, etc.) for your product.'
                      .tr,
                ),
                const Divider(),
                _buildHelpItem(
                  Icons.calendar_today,
                  'Expiry Date'.tr,
                  'Set the expiry date for products with limited shelf life.'
                      .tr,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'Got it'.tr,
                style: const TextStyle(
                  color: ThemeProvider.appColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildHelpItem(IconData icon, String title, String description) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            color: ThemeProvider.appColor,
            size: 20,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(
                    color: Colors.grey[700],
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

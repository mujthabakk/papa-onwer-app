import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ultimate_salon_owner_flutter/app/product/controller/create_products_controller.dart';
import 'package:ultimate_salon_owner_flutter/app/util/app_image.dart';
import 'package:ultimate_salon_owner_flutter/app/util/currency_helper.dart';
import 'package:ultimate_salon_owner_flutter/app/util/tax_helper.dart';
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
                  fontFamily: 'semibold',
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
                          // Main Form Section (includes front/back/side gallery)
                          _buildMainFormSection(value, context),

                          const SizedBox(height: 24),

                          _buildReturnPaymentSection(value),
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
          // PDF: main product gallery — front / back / side (+ optional extras)
          _buildMainProductImages(value, context),
          const SizedBox(height: 20),

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
          _buildTextField(
            controller: value.colorTextEditor,
            label: 'Color'.tr,
            hint: 'BLACK',
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildDropdownField(
                  title: 'Unit'.tr,
                  value: value.selectedMeasurementLabel,
                  onTap: () => value.pickMeasurement(),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildTextField(
                  controller: value.measurementValueTextEditor,
                  label: 'Amount'.tr,
                  hint: '100',
                  keyboardType: TextInputType.number,
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(top: 6, left: 4),
            child: Text(
              'Amount is size (e.g. 100 ml). Not the sell price.'.tr,
              style: TextStyle(
                  fontFamily: 'regular', fontSize: 11, color: Colors.grey[600]),
            ),
          ),
          const SizedBox(height: 16),

          // Price Fields Section
          _buildPriceSection(value),
          const SizedBox(height: 16),
          _buildVariantsSection(value),
          const SizedBox(height: 16),

          // Product Status Options
          // _buildStatusOptions(value),
        ],
      ),
    );
  }

  Widget _buildVariantsSection(CreateProductsController value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                'Variants'.tr,
                style: const TextStyle(
                    fontFamily: 'semibold',
                    fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ),
            TextButton.icon(
              onPressed: value.addVariant,
              icon: const Icon(Icons.add, color: ThemeProvider.appColor),
              label: Text('Add Variant'.tr,
                  style: const TextStyle(fontFamily: 'regular', color: ThemeProvider.appColor)),
            ),
          ],
        ),
        Text(
          'Optional. Each variant needs its own Unit + Amount (e.g. 100 ml vs 200 ml).'.tr,
          style: TextStyle(
              fontFamily: 'regular', fontSize: 12, color: Colors.grey[600]),
        ),
        const SizedBox(height: 8),
        ...List.generate(value.variants.length, (index) {
          final row = value.variants[index];
          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey[300]!),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        '${'Variant'.tr} ${index + 1}',
                        style: const TextStyle(
                          fontFamily: 'semibold',
                          fontSize: 14,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () => value.removeVariant(index),
                      icon: const Icon(Icons.delete_outline, color: Colors.red),
                    ),
                  ],
                ),
                _buildTextField(
                  controller: row.name,
                  label: 'Name'.tr,
                  hint: '100 ml Black',
                ),
                const SizedBox(height: 8),
                _buildTextField(
                  controller: row.color,
                  label: 'Color'.tr,
                  hint: 'BLACK',
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: _buildDropdownField(
                        title: 'Unit'.tr,
                        value: value.measurementLabel(row.measurementId),
                        onTap: () =>
                            value.pickMeasurement(variantIndex: index),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _buildTextField(
                        controller: row.measurementValue,
                        label: 'Amount'.tr,
                        hint: '100',
                        keyboardType: TextInputType.number,
                      ),
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 4, left: 2),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Amount only (not sell price).'.tr,
                      style: TextStyle(
                          fontFamily: 'regular',
                          fontSize: 11,
                          color: Colors.grey[600]),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: _buildTextField(
                        controller: row.originalPrice,
                        label: 'Original'.tr,
                        hint: '79900',
                        keyboardType: TextInputType.number,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _buildTextField(
                        controller: row.sellPrice,
                        label: 'Sell Price'.tr,
                        hint: '74900',
                        keyboardType: TextInputType.number,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: _buildTextField(
                        controller: row.discount,
                        label: 'Discount'.tr,
                        hint: '5000',
                        keyboardType: TextInputType.number,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _buildTextField(
                        controller: row.inStock,
                        label: 'Stock'.tr,
                        hint: '10',
                        keyboardType: TextInputType.number,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Variant photos (front / back / side)'.tr,
                    style: TextStyle(
                        fontFamily: 'regular',
                        fontSize: 12,
                        color: Colors.grey[600]),
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  children: List.generate(3, (viewIndex) {
                    const views = ['front', 'back', 'side'];
                    final label = views[viewIndex];
                    final pathIndex =
                        CreateProductsController.galleryViews.indexOf(label);
                    final galleryIndex = pathIndex >= 0 ? pathIndex : viewIndex;
                    final path = galleryIndex < row.gallery.length
                        ? row.gallery[galleryIndex]
                        : '';
                    return Expanded(
                      child: Padding(
                        padding: EdgeInsets.only(
                            right: viewIndex == 2 ? 0 : 6),
                        child: GestureDetector(
                          onTap: () => value.pickVariantImage(index,
                              viewIndex: galleryIndex),
                          child: Column(
                            children: [
                              Container(
                                height: 52,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(8),
                                  border:
                                      Border.all(color: Colors.grey[300]!),
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: AppNetImage(
                                    path: path,
                                    fit: BoxFit.cover,
                                    placeholder: Icon(Icons.add,
                                        color: Colors.grey[400]),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(label.tr,
                                  style: const TextStyle(
                                      fontFamily: 'regular', fontSize: 11)),
                            ],
                          ),
                        ),
                      ),
                    );
                  }),
                ),
              ],
            ),
          );
        }),
      ],
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
                label: 'Original'.tr,
                hint: '79900',
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
                label: 'Discount'.tr,
                hint: '5000',
                prefixIcon: Icon(Icons.currency_rupee, color: Colors.grey[600]),
                keyboardType: TextInputType.number,
                onChanged: (txt) => value.onDiscountPrice(txt),
              ),
            ),
          ],
        ),
        Padding(
          padding: const EdgeInsets.only(top: 6, left: 4),
          child: Text(
            'Discount is amount off (e.g. 5000), not percent. Sell Price is separate from Amount/Unit.'.tr,
            style: TextStyle(
                fontFamily: 'regular', fontSize: 11, color: Colors.grey[600]),
          ),
        ),
        const SizedBox(height: 16),
        _buildTextField(
          controller: value.sellPriceTextEditor,
          label: 'Sell Price'.tr,
          hint: '74900',
          prefixIcon: Icon(
            Icons.currency_rupee,
            color: ThemeProvider.appColor.withOpacity(0.7),
          ),
          keyboardType: TextInputType.number,
          onChanged: (txt) => value.onSellPriceChanged(txt),
        ),
        const SizedBox(height: 16),
        _buildTextField(
          controller: value.stockQtyTextEditor,
          label: 'Stock'.tr,
          hint: 'Quantity on hand'.tr,
          prefixIcon: Icon(Icons.inventory_2_outlined, color: Colors.grey[600]),
          keyboardType: TextInputType.number,
        ),
        if (TaxHelper.isAvailable && value.sellPriceTextEditor.text.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 12.0, left: 4.0),
            child: Text(
              '${'Final amount (incl. tax 18%) -'.tr} ${CurrencyHelper.format(value.finalPriceWithTax)}',
              style: TextStyle(
                fontFamily: 'medium',
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

  Widget _buildReturnPaymentSection(CreateProductsController value) {
    final options = value.paymentMethodOptions.isNotEmpty
        ? value.paymentMethodOptions
        : [
            {'code': 'cod', 'name': 'Cash on Delivery', 'label': 'COD'},
            {'code': 'online', 'name': 'Online Payment', 'label': 'Online'},
          ];
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
          Text(
            'Return & Payment'.tr,
            style: const TextStyle(
              fontFamily: 'bold',
              fontSize: 16,
              color: ThemeProvider.blackColor,
            ),
          ),
          const SizedBox(height: 12),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: Text('Returnable'.tr, style: const TextStyle(fontFamily: 'medium')),
            value: value.returnable,
            activeColor: ThemeProvider.golden,
            onChanged: (v) => value.setReturnable(v),
          ),
          if (value.returnable) ...[
            TextField(
              controller: value.returnDaysTextEditor,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Return days'.tr,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onChanged: (_) => value.update(),
            ),
            const SizedBox(height: 12),
          ],
          Text(
            'Accepted payment methods'.tr,
            style: const TextStyle(fontFamily: 'medium', fontSize: 14),
          ),
          const SizedBox(height: 8),
          ...options.map((row) {
            final code =
                (row['code'] ?? row['type'] ?? '').toString().toLowerCase();
            final label =
                (row['label'] ?? row['name'] ?? code).toString();
            return CheckboxListTile(
              contentPadding: EdgeInsets.zero,
              dense: true,
              title: Text(label, style: const TextStyle(fontFamily: 'regular')),
              value: value.selectedPaymentMethods.contains(code),
              activeColor: ThemeProvider.golden,
              onChanged: (checked) =>
                  value.togglePaymentMethod(code, checked == true),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildMainProductImages(
      CreateProductsController value, BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                'Product images'.tr,
                style: const TextStyle(
                  fontFamily: 'bold',
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            TextButton.icon(
              onPressed: value.addExtraGallerySlot,
              icon: const Icon(Icons.add_photo_alternate_outlined, size: 18),
              label: Text('Add image'.tr,
                  style: const TextStyle(fontFamily: 'medium', fontSize: 13)),
              style: TextButton.styleFrom(
                foregroundColor: ThemeProvider.appColor,
                padding: EdgeInsets.zero,
                visualDensity: VisualDensity.compact,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          'Add Front, Back and Side photos (API gallery). Front is used as cover.'.tr,
          style: TextStyle(
            fontFamily: 'regular',
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
        const SizedBox(height: 12),
        LayoutBuilder(
          builder: (context, constraints) {
            const gap = 10.0;
            final count = value.gallery.length.clamp(1, 6);
            final width =
                (constraints.maxWidth - gap * (count > 3 ? 2 : count - 1)) /
                    (count > 3 ? 3 : count);
            return Wrap(
              spacing: gap,
              runSpacing: gap,
              children: List.generate(value.gallery.length, (index) {
                return SizedBox(
                  width: width.clamp(90, 140),
                  child: _buildGalleryItem(value, index, context),
                );
              }),
            );
          },
        ),
        const SizedBox(height: 8),
        Text(
          'Recommended Size - 512x512'.tr,
          style: TextStyle(
            fontFamily: 'regular',
            fontSize: 12,
            color: Colors.grey[600],
            fontStyle: FontStyle.italic,
          ),
        ),
      ],
    );
  }

  String _galleryViewLabel(int index) {
    if (index < CreateProductsController.galleryViews.length) {
      final view = CreateProductsController.galleryViews[index];
      return view[0].toUpperCase() + view.substring(1);
    }
    return '${'Image'.tr} ${index + 1}';
  }

  Widget _buildGalleryItem(
      CreateProductsController value, int index, BuildContext context) {
    final hasImage =
        index < value.gallery.length && value.gallery[index].trim().isNotEmpty;
    return AspectRatio(
      aspectRatio: 1,
      child: GestureDetector(
        onTap: () => _showGalleryImageOptions(context, value, index),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: hasImage
                  ? ThemeProvider.appColor.withOpacity(0.35)
                  : Colors.grey[300]!,
              width: hasImage ? 1.5 : 1,
            ),
          ),
          child: Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: hasImage
                    ? AppNetImage(
                        path: value.gallery[index],
                        fit: BoxFit.cover,
                        height: double.infinity,
                        width: double.infinity,
                        placeholder: Center(
                          child: Icon(Icons.image_outlined,
                              color: Colors.grey[400]),
                        ),
                      )
                    : Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.add_a_photo_outlined,
                                color: Colors.grey[400], size: 28),
                            const SizedBox(height: 6),
                            Text(
                              'Add'.tr,
                              style: TextStyle(
                                fontFamily: 'regular',
                                fontSize: 11,
                                color: Colors.grey[500],
                              ),
                            ),
                          ],
                        ),
                      ),
              ),
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 5),
                  decoration: const BoxDecoration(
                    color: Colors.black54,
                    borderRadius: BorderRadius.vertical(
                      bottom: Radius.circular(12),
                    ),
                  ),
                  child: Text(
                    _galleryViewLabel(index),
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontFamily: 'bold',
                    ),
                  ),
                ),
              ),
              if (hasImage)
                Positioned(
                  top: 4,
                  right: 4,
                  child: InkWell(
                    onTap: () => value.clearGalleryImage(index),
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: Colors.black54,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.close,
                          color: Colors.white, size: 14),
                    ),
                  ),
                ),
            ],
          ),
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
              fontFamily: 'bold',
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
                  fontFamily: 'medium',
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
                hintStyle: TextStyle(fontFamily: 'regular', color: Colors.grey[400], fontSize: 14),
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
              fontFamily: 'bold',
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
                      fontFamily: 'medium',
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
                        fontFamily: 'medium',
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
                    fontFamily: 'bold',
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
                    fontFamily: 'bold',
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
            fontFamily: 'semibold',
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
            hintStyle: TextStyle(fontFamily: 'regular', color: Colors.grey[400], fontSize: 14),
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
            fontFamily: 'semibold',
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
            hintStyle: TextStyle(fontFamily: 'regular', color: Colors.grey[400], fontSize: 14),
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
            fontFamily: 'semibold',
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
              children: [
                Expanded(
                  child: Text(
                    value,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontFamily: 'regular',
                      fontSize: 14,
                      color: value.contains('Select')
                          ? Colors.grey[500]
                          : Colors.black,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
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
                fontFamily: 'medium',
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
                    fontFamily: 'bold',
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
            fontFamily: 'bold',
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
                    fontFamily: 'regular',
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
                    fontFamily: 'regular',
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
    final label = _galleryViewLabel(index);
    showCupertinoModalPopup<void>(
      context: context,
      builder: (BuildContext context) => CupertinoActionSheet(
        title: Text(
          '${'Add photo'.tr} — $label',
          style: const TextStyle(
            fontFamily: 'bold',
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
                    fontFamily: 'regular',
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
                    fontFamily: 'regular',
                    color: ThemeProvider.appColor,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
          if (index < value.gallery.length &&
              value.gallery[index].trim().isNotEmpty)
            CupertinoActionSheetAction(
              isDestructiveAction: true,
              onPressed: () {
                Navigator.pop(context);
                value.clearGalleryImage(index);
              },
              child: Text('Remove photo'.tr),
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
            fontFamily: 'bold',
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
                    fontFamily: 'regular',
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
                    fontFamily: 'regular',
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
                  fontFamily: 'bold',
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
                  fontFamily: 'bold',
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
                    fontFamily: 'bold',
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(
                    fontFamily: 'regular',
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

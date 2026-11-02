import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ultimate_salon_owner_flutter/app/backend/models/city_model.dart';
import 'package:ultimate_salon_owner_flutter/app/backend/models/country_model.dart';
import 'package:ultimate_salon_owner_flutter/app/product/controller/product_signup_controller.dart';
import 'package:ultimate_salon_owner_flutter/app/util/app_image.dart';
import 'package:ultimate_salon_owner_flutter/app/util/theme.dart';

class ProductSignupScreen extends StatelessWidget {
  const ProductSignupScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ProductSignupController>(
      builder: (value) {
        return Scaffold(
          backgroundColor: ThemeProvider.whiteColor,
          appBar: AppBar(
            backgroundColor: ThemeProvider.appColor,
            iconTheme: const IconThemeData(color: ThemeProvider.whiteColor),
            centerTitle: true,
            title: Text(
              'Product Seller Signup'.tr,
              style: ThemeProvider.titleStyle,
            ),
          ),
          bottomNavigationBar: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: SizedBox(
                height: 52,
                child: ElevatedButton(
                  onPressed: value.submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: ThemeProvider.appColor,
                    foregroundColor: ThemeProvider.whiteColor,
                  ),
                  child: Text('Submit Request'.tr),
                ),
              ),
            ),
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _uploadImageBox(
                  context: context,
                  imageUrl: AppImage.url(value.cover),
                  label: 'Upload Image'.tr,
                  hint: 'Tap to upload profile / shop photo'.tr,
                  onTap: () => _pick(context, (src) => value.pickImage(1, src)),
                ),
                const SizedBox(height: 12),
                _field(value.firstName, 'First name'.tr),
                _field(value.lastName, 'Last name'.tr),
                _field(value.email, 'Email'.tr,
                    type: TextInputType.emailAddress),
                Row(
                  children: [
                    Expanded(
                      child: _dropdown<SignupCountryModel>(
                        label: 'Country'.tr,
                        value: value.selectedCountry,
                        items: value.countries,
                        itemLabel: (c) => c.name,
                        onChanged: (c) {
                          if (c != null) value.onCountryChanged(c);
                        },
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(bottom: 10, right: 8),
                      child: Text(value.countryCode,
                          style: const TextStyle(fontFamily: 'bold')),
                    ),
                    Expanded(
                      child: _field(value.mobile, 'Mobile'.tr,
                          type: TextInputType.phone),
                    ),
                  ],
                ),
                _field(value.password, 'Password'.tr, obscure: value.passwordVisible),
                _field(value.confirmPassword, 'Confirm password'.tr,
                    obscure: value.passwordVisible),
                Align(
                  alignment: Alignment.centerLeft,
                  child: TextButton(
                    onPressed: value.togglePassword,
                    child: Text(value.passwordVisible
                        ? 'Show password'.tr
                        : 'Hide password'.tr),
                  ),
                ),
                _field(value.storeName, 'Store name'.tr),
                _field(value.about, 'About'.tr, maxLines: 3),
                _field(value.address, 'Address'.tr, maxLines: 2),
                _field(value.zipcode, 'Zipcode'.tr),
                if (value.states.isNotEmpty)
                  _dropdown<ProductSignupState>(
                    label: 'State'.tr,
                    value: value.selectedState,
                    items: value.states,
                    itemLabel: (s) => s.name,
                    onChanged: (s) {
                      if (s != null) value.onStateChanged(s);
                    },
                  ),
                _dropdown<CityModal>(
                  label: 'City'.tr,
                  value: value.cities.contains(value.selectedCity)
                      ? value.selectedCity
                      : null,
                  items: value.cities,
                  itemLabel: (c) => c.name ?? '',
                  onChanged: (c) {
                    if (c != null) value.onCityChanged(c);
                  },
                ),
                Row(
                  children: [
                    Expanded(child: _field(value.lat, 'Latitude'.tr)),
                    const SizedBox(width: 8),
                    Expanded(child: _field(value.lng, 'Longitude'.tr)),
                  ],
                ),
                TextButton.icon(
                  onPressed: value.getCurrentLocation,
                  icon: const Icon(Icons.my_location),
                  label: Text('Get current location'.tr),
                ),
                DropdownButtonFormField<String>(
                  value: value.selectedGender,
                  decoration: _dec('Gender'.tr),
                  items: ['Male', 'Female', 'Others']
                      .map((g) => DropdownMenuItem(value: g, child: Text(g.tr)))
                      .toList(),
                  onChanged: (g) {
                    if (g != null) value.changeGender(g);
                  },
                ),
                const SizedBox(height: 8),
                _field(value.whatsapp, 'WhatsApp number'.tr,
                    type: TextInputType.phone),
                _field(value.pan, 'PAN'.tr),
                _field(value.vat, 'VAT / GST'.tr),
                _field(value.bankName, 'Bank name'.tr),
                _field(value.bankIfsc, 'IFSC'.tr),
                _field(value.bankAccount, 'Account number'.tr),
                _field(value.bankCustomer, 'Account holder'.tr),
                const SizedBox(height: 8),
                _uploadImageBox(
                  context: context,
                  imageUrl: AppImage.url(value.idProof),
                  label: 'ID proof'.tr,
                  hint: 'Tap to upload ID proof front'.tr,
                  onTap: () => _pick(context, (src) => value.pickImage(2, src)),
                ),
                const SizedBox(height: 8),
                _uploadImageBox(
                  context: context,
                  imageUrl: AppImage.url(value.idProofBack),
                  label: 'ID proof back'.tr,
                  hint: 'Tap to upload ID proof back'.tr,
                  onTap: () => _pick(context, (src) => value.pickImage(3, src)),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  InputDecoration _dec(String label) {
    return InputDecoration(
      labelText: label,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
    );
  }

  Widget _field(TextEditingController c, String label,
      {TextInputType? type, bool obscure = false, int maxLines = 1}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: TextFormField(
        controller: c,
        keyboardType: type,
        obscureText: obscure && maxLines == 1,
        maxLines: obscure ? 1 : maxLines,
        decoration: _dec(label),
      ),
    );
  }

  Widget _dropdown<T>({
    required String label,
    required T? value,
    required List<T> items,
    required String Function(T) itemLabel,
    required ValueChanged<T?> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: DropdownButtonFormField<T>(
        value: items.contains(value) ? value : null,
        decoration: _dec(label),
        isExpanded: true,
        items: items
            .map((e) => DropdownMenuItem<T>(
                  value: e,
                  child: Text(itemLabel(e), overflow: TextOverflow.ellipsis),
                ))
            .toList(),
        onChanged: onChanged,
      ),
    );
  }

  Widget _uploadImageBox({
    required BuildContext context,
    required String label,
    required String hint,
    required VoidCallback onTap,
    String? imageUrl,
    double height = 140,
  }) {
    final hasImage = imageUrl != null && imageUrl.trim().isNotEmpty;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        height: height,
        decoration: BoxDecoration(
          color: const Color(0xFFF8F8F8),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: hasImage
                ? ThemeProvider.appColor
                : ThemeProvider.greyColor.withOpacity(0.35),
            width: hasImage ? 1.5 : 1,
          ),
        ),
        clipBehavior: Clip.antiAlias,
        child: hasImage
            ? Stack(
                fit: StackFit.expand,
                children: [
                  Image.network(
                    imageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) =>
                        _uploadPlaceholder(label, hint),
                  ),
                  Container(
                    alignment: Alignment.bottomCenter,
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    color: Colors.black45,
                    child: Text(
                      'Change Image'.tr,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontFamily: 'bold',
                      ),
                    ),
                  ),
                ],
              )
            : _uploadPlaceholder(label, hint),
      ),
    );
  }

  Widget _uploadPlaceholder(String label, String hint) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: ThemeProvider.appColor.withOpacity(0.08),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.cloud_upload_outlined,
            color: ThemeProvider.appColor,
            size: 24,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontFamily: 'bold',
            color: ThemeProvider.blackColor,
          ),
        ),
        const SizedBox(height: 4),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Text(
            hint,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontFamily: 'regular',
              fontSize: 11,
              color: ThemeProvider.greyColor,
            ),
          ),
        ),
      ],
    );
  }

  void _pick(BuildContext context, void Function(String source) onPick) {
    showCupertinoModalPopup<void>(
      context: context,
      builder: (ctx) => CupertinoActionSheet(
        title: Text('Choose From'.tr),
        actions: [
          CupertinoActionSheetAction(
            child: Text('Gallery'.tr),
            onPressed: () {
              Navigator.pop(ctx);
              onPick('gallery');
            },
          ),
          CupertinoActionSheetAction(
            child: Text('Camera'.tr),
            onPressed: () {
              Navigator.pop(ctx);
              onPick('camera');
            },
          ),
        ],
        cancelButton: CupertinoActionSheetAction(
          child: Text('Cancel'.tr),
          onPressed: () => Navigator.pop(ctx),
        ),
      ),
    );
  }
}

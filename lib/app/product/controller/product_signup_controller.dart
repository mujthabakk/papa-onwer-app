import 'package:flutter/material.dart';
import 'package:flutter_otp_text_field/flutter_otp_text_field.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:ultimate_salon_owner_flutter/app/backend/api/handler.dart';
import 'package:ultimate_salon_owner_flutter/app/backend/models/city_model.dart';
import 'package:ultimate_salon_owner_flutter/app/backend/models/country_model.dart';
import 'package:ultimate_salon_owner_flutter/app/controller/locale_controller.dart';
import 'package:ultimate_salon_owner_flutter/app/helper/router.dart';
import 'package:ultimate_salon_owner_flutter/app/product/api/product_auth_parse.dart';
import 'package:ultimate_salon_owner_flutter/app/util/theme.dart';
import 'package:ultimate_salon_owner_flutter/app/util/toast.dart';

class ProductSignupState {
  final int id;
  final String name;

  ProductSignupState({required this.id, required this.name});

  factory ProductSignupState.fromJson(Map<String, dynamic> json) {
    return ProductSignupState(
      id: int.tryParse(json['id']?.toString() ?? '') ?? 0,
      name: json['name']?.toString() ?? '',
    );
  }
}

class ProductSignupController extends GetxController implements GetxService {
  final ProductAuthParser parser;
  ProductSignupController({required this.parser});

  final firstName = TextEditingController();
  final lastName = TextEditingController();
  final email = TextEditingController();
  final password = TextEditingController();
  final confirmPassword = TextEditingController();
  final mobile = TextEditingController();
  final storeName = TextEditingController();
  final about = TextEditingController();
  final address = TextEditingController();
  final zipcode = TextEditingController();
  final lat = TextEditingController();
  final lng = TextEditingController();
  final pan = TextEditingController();
  final vat = TextEditingController();
  final bankName = TextEditingController();
  final bankIfsc = TextEditingController();
  final bankAccount = TextEditingController();
  final bankCustomer = TextEditingController();
  final whatsapp = TextEditingController();

  String countryCode = '+91';
  String cover = '';
  String idProof = '';
  String idProofBack = '';
  String selectedGender = 'Male';
  bool passwordVisible = true;
  bool apiCalled = false;
  int smsId = 1;
  String otpCode = '';

  List<SignupCountryModel> countries = [];
  SignupCountryModel? selectedCountry;
  List<ProductSignupState> states = [];
  ProductSignupState? selectedState;
  List<CityModal> cities = [];
  CityModal selectedCity = CityModal();

  @override
  void onInit() {
    super.onInit();
    parser.getSignupForm();
    loadCountries();
  }

  @override
  void onClose() {
    firstName.dispose();
    lastName.dispose();
    email.dispose();
    password.dispose();
    confirmPassword.dispose();
    mobile.dispose();
    storeName.dispose();
    about.dispose();
    address.dispose();
    zipcode.dispose();
    lat.dispose();
    lng.dispose();
    pan.dispose();
    vat.dispose();
    bankName.dispose();
    bankIfsc.dispose();
    bankAccount.dispose();
    bankCustomer.dispose();
    whatsapp.dispose();
    super.onClose();
  }

  List _listOf(Map<String, dynamic> map, List<String> keys) {
    for (final key in keys) {
      if (map[key] is List) return map[key] as List;
    }
    return const [];
  }

  Future<void> loadCountries() async {
    String country = 'IN';
    String lang = 'en';
    if (Get.isRegistered<LocaleController>()) {
      final locale = Get.find<LocaleController>();
      if (locale.countryCode.isNotEmpty) country = locale.countryCode;
      if (locale.languageCode.isNotEmpty) lang = locale.languageCode;
    }
    final response =
        await parser.getActiveCountries(country: country, lang: lang);
    apiCalled = true;
    if (response.statusCode == 200) {
      final myMap = Map<String, dynamic>.from(response.body);
      countries = [];
      final seen = <String>{};
      for (final data in _listOf(myMap, ['countries', 'data'])) {
        if (data is! Map) continue;
        final parsed =
            SignupCountryModel.fromJson(Map<String, dynamic>.from(data));
        final key =
            parsed.countryCode.isNotEmpty ? parsed.countryCode : parsed.code;
        if (key.isEmpty || seen.contains(key)) continue;
        seen.add(key);
        countries.add(parsed);
      }
      if (selectedCountry == null && countries.isNotEmpty) {
        var match = countries.first;
        if (Get.isRegistered<LocaleController>()) {
          final code = Get.find<LocaleController>().countryCode.toUpperCase();
          final found = countries.where((c) =>
              c.code.toUpperCase() == code || c.isoCode.toUpperCase() == code);
          if (found.isNotEmpty) match = found.first;
        }
        await onCountryChanged(match);
        return;
      }
    }
    update();
  }

  Future<void> onCountryChanged(SignupCountryModel country) async {
    selectedCountry = country;
    if (country.countryCode.isNotEmpty) {
      countryCode = country.countryCode.startsWith('+')
          ? country.countryCode
          : '+${country.countryCode}';
    }
    selectedState = null;
    selectedCity = CityModal();
    states = [];
    cities = [];
    update();
    await loadStates();
  }

  Future<void> loadStates() async {
    final code = selectedCountry?.code ?? 'IN';
    final response = await parser.getActiveStates(code);
    states = [];
    if (response.statusCode == 200) {
      final myMap = Map<String, dynamic>.from(response.body);
      for (final data in _listOf(myMap, ['states', 'data'])) {
        if (data is! Map) continue;
        final parsed =
            ProductSignupState.fromJson(Map<String, dynamic>.from(data));
        if (parsed.id != 0) states.add(parsed);
      }
      if (states.isNotEmpty) {
        await onStateChanged(states.first);
        return;
      }
    }
    await loadCities();
  }

  Future<void> onStateChanged(ProductSignupState state) async {
    selectedState = state;
    selectedCity = CityModal();
    cities = [];
    update();
    await loadCities();
  }

  Future<void> loadCities() async {
    final code = selectedCountry?.code ?? 'IN';
    final response =
        await parser.getActiveCities(code, stateId: selectedState?.id);
    cities = [];
    if (response.statusCode == 200) {
      final myMap = Map<String, dynamic>.from(response.body);
      for (final data in _listOf(myMap, ['cities', 'data'])) {
        if (data is! Map) continue;
        try {
          cities.add(CityModal.fromJson(Map<String, dynamic>.from(data)));
        } catch (_) {}
      }
      if (cities.isNotEmpty) selectedCity = cities.first;
    }
    update();
  }

  void onCityChanged(CityModal city) {
    selectedCity = city;
    update();
  }

  void togglePassword() {
    passwordVisible = !passwordVisible;
    update();
  }

  void changeGender(String value) {
    selectedGender = value;
    update();
  }

  Future<void> pickImage(int type, String kind) async {
    final picked = await ImagePicker().pickImage(
      source: kind == 'gallery' ? ImageSource.gallery : ImageSource.camera,
      imageQuality: 25,
    );
    if (picked == null) return;
    _showLoader();
    final response = await parser.uploadImage(picked);
    _closeLoader();
    if (response.statusCode == 200 &&
        response.body['data'] != null &&
        response.body['data'] != '') {
      final body = response.body['data'];
      final name = body['image_name']?.toString() ?? '';
      if (name.isEmpty) return;
      if (type == 1) {
        cover = name;
      } else if (type == 2) {
        idProof = name;
      } else {
        idProofBack = name;
      }
      update();
    } else {
      ApiChecker.checkApi(response);
    }
  }

  Future<void> getCurrentLocation() async {
    final enabled = await Geolocator.isLocationServiceEnabled();
    if (!enabled) {
      await Geolocator.openLocationSettings();
      return;
    }
    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      showToast('Location permission is required'.tr);
      return;
    }
    try {
      final position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
      lat.text = position.latitude.toString();
      lng.text = position.longitude.toString();
      update();
    } catch (e) {
      showToast('Failed to get current location'.tr);
    }
  }

  Future<void> submit() async {
    if (firstName.text.trim().isEmpty || lastName.text.trim().isEmpty) {
      showToast('First name and last name are required'.tr);
      return;
    }
    if (!GetUtils.isEmail(email.text.trim())) {
      showToast('Email is not valid'.tr);
      return;
    }
    if (mobile.text.trim().isEmpty) {
      showToast('Mobile is required'.tr);
      return;
    }
    if (password.text.isEmpty || password.text != confirmPassword.text) {
      showToast('Password does not match'.tr);
      return;
    }
    if (storeName.text.trim().isEmpty) {
      showToast('Store name is required'.tr);
      return;
    }
    if (selectedCountry == null) {
      showToast('Country is required'.tr);
      return;
    }
    if (selectedCity.id == null) {
      showToast('City is required'.tr);
      return;
    }

    _showLoader();
    final phoneRes = await parser.checkPhoneExist({
      'country_code': countryCode.replaceAll('+', ''),
      'mobile': mobile.text.trim(),
    });
    if (phoneRes.statusCode != 200) {
      _closeLoader();
      _showApiError(phoneRes);
      return;
    }

    final emailRes = await parser.verifyEmail({'email': email.text.trim()});
    _closeLoader();
    if (emailRes.statusCode == 200) {
      final myMap = Map<String, dynamic>.from(emailRes.body);
      smsId = int.tryParse(myMap['otp_id']?.toString() ?? '') ?? smsId;
      _openOtpModal();
      return;
    }
    _showApiError(emailRes);
  }

  void _openOtpModal() {
    otpCode = '';
    final dialogWidth = (Get.width - 48).clamp(280.0, 420.0);
    final fieldWidth = ((dialogWidth - 56) / 6).clamp(28.0, 40.0);
    Get.dialog(
      Dialog(
        insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        backgroundColor: ThemeProvider.whiteColor,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 20, 16, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Verification'.tr,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontFamily: 'bold',
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: ThemeProvider.appColor,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'We have sent verification code on'.tr,
                textAlign: TextAlign.center,
                style: const TextStyle(fontFamily: 'regular', fontSize: 14, color: Colors.black87),
              ),
              const SizedBox(height: 6),
              Text(
                email.text.trim(),
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontFamily: 'bold',
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 20),
              FittedBox(
                fit: BoxFit.scaleDown,
                child: OtpTextField(
                  numberOfFields: 6,
                  fieldWidth: fieldWidth,
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  borderColor: Colors.black26,
                  focusedBorderColor: ThemeProvider.appColor,
                  showFieldAsBox: true,
                  keyboardType: TextInputType.number,
                  onCodeChanged: (String code) {
                    otpCode = code;
                  },
                  onSubmit: (String verificationCode) {
                    otpCode = verificationCode;
                    confirmOtpAndSignup();
                  },
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 45,
                child: ElevatedButton(
                  onPressed: () {
                    if (otpCode.length >= 6) {
                      confirmOtpAndSignup();
                    } else {
                      showToast('Please enter OTP'.tr);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: ThemeProvider.appColor,
                    foregroundColor: ThemeProvider.whiteColor,
                  ),
                  child: Text('Verify'.tr),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> confirmOtpAndSignup() async {
    if (otpCode.length < 6) {
      showToast('Enter OTP'.tr);
      return;
    }
    _showLoader();
    final otpRes = await parser.confirmEmailOtp({
      'id': smsId,
      'otp': otpCode,
      'email': email.text.trim(),
    });
    if (otpRes.statusCode != 200) {
      _closeLoader();
      _showApiError(otpRes);
      return;
    }
    await _createAccount();
  }

  Future<void> _createAccount() async {
    final body = {
      'type': 'product',
      'first_name': firstName.text.trim(),
      'last_name': lastName.text.trim(),
      'email': email.text.trim(),
      'password': password.text,
      'country_code': countryCode,
      'mobile': mobile.text.trim(),
      'cover': cover.isEmpty ? 'uploads/images/dummy.jpg' : cover,
      'gender': selectedGender == 'Male' ? 1 : 0,
      'name': storeName.text.trim(),
      'about': about.text.trim(),
      'address': address.text.trim(),
      'lat': lat.text.trim().isEmpty ? '0' : lat.text.trim(),
      'lng': lng.text.trim().isEmpty ? '0' : lng.text.trim(),
      'zipcode': zipcode.text.trim(),
      'country': selectedCountry?.code ?? 'IN',
      if (selectedState != null) 'state_id': selectedState!.id,
      'cid': selectedCity.id,
      if (pan.text.trim().isNotEmpty) 'pan': pan.text.trim(),
      if (vat.text.trim().isNotEmpty) 'vat': vat.text.trim(),
      if (bankName.text.trim().isNotEmpty) 'bank_name': bankName.text.trim(),
      if (bankIfsc.text.trim().isNotEmpty) 'bank_ifsc': bankIfsc.text.trim(),
      if (bankAccount.text.trim().isNotEmpty)
        'bank_account_number': bankAccount.text.trim(),
      if (bankCustomer.text.trim().isNotEmpty)
        'bank_customer_name': bankCustomer.text.trim(),
      if (idProof.isNotEmpty) 'id_proof': idProof,
      if (idProofBack.isNotEmpty) 'id_proof_back': idProofBack,
      if (whatsapp.text.trim().isNotEmpty)
        'whatsapp_number': whatsapp.text.trim(),
    };
    final response = await parser.signup(body);
    _closeLoader();
    while (Get.isDialogOpen == true) {
      Get.back();
    }
    if (response.statusCode == 200) {
      Get.offAllNamed(AppRouter.getInitialRoute());
      Future.delayed(const Duration(milliseconds: 350), () {
        Get.dialog(
          AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            title: Text(
              'Success!\nAwaiting Review'.tr,
              textAlign: TextAlign.center,
            ),
            content: Text(
              'Your request is submitted.\nYou can start using your account once admin approval is completed.'
                  .tr,
              textAlign: TextAlign.center,
            ),
            actions: [
              TextButton(
                onPressed: () => Get.back(),
                child: Text(
                  'Okay'.tr,
                  style: const TextStyle(
                    color: ThemeProvider.appColor,
                    fontFamily: 'bold',
                  ),
                ),
              ),
            ],
          ),
          barrierDismissible: false,
        );
      });
      return;
    }
    _showApiError(response);
  }

  void _showApiError(Response response) {
    try {
      final myMap = Map<String, dynamic>.from(response.body);
      final message =
          (myMap['error'] ?? myMap['message'] ?? 'Something went wrong').toString();
      showToast(message.tr);
    } catch (_) {
      ApiChecker.checkApi(response);
    }
  }

  void _showLoader() {
    Get.dialog(
      const SimpleDialog(
        children: [
          Padding(
            padding: EdgeInsets.all(16),
            child: Row(
              children: [
                CircularProgressIndicator(color: ThemeProvider.appColor),
                SizedBox(width: 16),
                Text('Please wait'),
              ],
            ),
          ),
        ],
      ),
      barrierDismissible: false,
    );
  }

  void _closeLoader() {
    if (Get.isDialogOpen == true) Get.back();
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_otp_text_field/flutter_otp_text_field.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:ultimate_salon_owner_flutter/app/backend/api/handler.dart';
import 'package:ultimate_salon_owner_flutter/app/backend/models/add_profile_model.dart';
import 'package:ultimate_salon_owner_flutter/app/backend/models/city_model.dart';
import 'package:ultimate_salon_owner_flutter/app/backend/models/country_model.dart';
import 'package:ultimate_salon_owner_flutter/app/backend/parse/signup_parse.dart';
import 'package:image_picker/image_picker.dart';
import 'package:ultimate_salon_owner_flutter/app/controller/locale_controller.dart';
import 'package:ultimate_salon_owner_flutter/app/controller/register_categories_controller.dart';
import 'package:ultimate_salon_owner_flutter/app/helper/router.dart';
import 'package:ultimate_salon_owner_flutter/app/util/constants.dart';
import 'package:ultimate_salon_owner_flutter/app/util/currency_helper.dart';
import 'package:ultimate_salon_owner_flutter/app/util/theme.dart';
import 'package:ultimate_salon_owner_flutter/app/util/toast.dart';
import 'package:url_launcher/url_launcher.dart';

class SignUpController extends GetxController implements GetxService {
  final SignUpParser parser;
  int currentView = 1;
  int type = 1; // 1 = salon // 0 = individual

  final emailTextEditor = TextEditingController();
  final firstNameTextEditor = TextEditingController();
  final lastNameTextEditor = TextEditingController();
  final mobileTextEditor = TextEditingController();
  String countryCodeMobile = '+91';
  final passwordTextEditor = TextEditingController();
  final confirmPasswordTextEditor = TextEditingController();
  String cover = '';
  String id_proof = '';
  String id_proof_back = '';

  final lat = TextEditingController();
  final lng = TextEditingController();
  final name = TextEditingController();
  final feeStart = TextEditingController();
  final zipcode = TextEditingController();

  final gstNumber = TextEditingController();
  final panNumber = TextEditingController();

  final bankName = TextEditingController();
  final accountName = TextEditingController();
  final accountNumber = TextEditingController();
  final ifscCode = TextEditingController();
  final executiveId = TextEditingController();
  final teamsize = TextEditingController();
  final whatsapp = TextEditingController();

  bool passwordVisible = true;
  String otpCode = '';
  bool _pendingRegisterAfterOtp = false;
  final descriptionsTextEditor = TextEditingController();
  final addressTextEditor = TextEditingController();

  List<CityModal> _cityList = <CityModal>[];
  List<CityModal> get cityList => _cityList;

  CityModal _selectedCity = CityModal();
  CityModal get selectedCity => _selectedCity;

  List<SignupCountryModel> _countryList = <SignupCountryModel>[];
  List<SignupCountryModel> get countryList => _countryList;

  SignupCountryModel? _selectedCountry;
  SignupCountryModel? get selectedCountry => _selectedCountry;

  bool emailVerified = false;
  bool phoneVerified = false;
  int smsId = 1;
  RxBool isLogin = false.obs;
  String smsName = AppConstants.defaultSMSGateway;
  bool apiCalled = false;

  String selectedGender = 'Male';
  String selectedHow = 'Executive';

  String get currencySymbol {
    if (Get.isRegistered<LocaleController>()) {
      return CurrencyHelper.current(Get.find<LocaleController>().prefs).symbol;
    }
    return CurrencyHelper.current(parser.sharedPreferencesManager).symbol;
  }

  List<String> genderList = ['Male', 'Female', 'Others'];
  List<String> howList = [
    'Executive',
    'Google',
    'Social Media',
    'Friends',
    'Ads',
    'News Paper',
    'Others'
  ];

  List<AddProfileModel> _servedCategoriesList = <AddProfileModel>[];
  List<AddProfileModel> get servedCategoriesList => _servedCategoriesList;

  // User Agreement variables
  RxBool hasAgreedToTerms = false.obs;
  bool _agreementDialogShown = false;

  SignUpController({required this.parser});
  @override
  void onInit() {
    super.onInit();
    smsName = parser.getSMSName();
    loadActiveCountries();
    // Show user agreement dialog after a small delay
    Future.delayed(const Duration(milliseconds: 50), () {
      if (!_agreementDialogShown) {
        showUserAgreementDialog();
      }
    });
  }

  // Show User Agreement Dialog
  void showUserAgreementDialog() {
    _agreementDialogShown = true;

    Get.dialog(
      PopScope(
        canPop: false,
        child: AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          title: Row(
            children: [
              Icon(
                Icons.description,
                color: Colors.blue,
                size: 24,
              ),
              const SizedBox(width: 8),
              const Text(
                'User Agreement',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Terms and Conditions',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'By continuing, you agree to the Papa Bear Partner Terms and Conditions for listing and selling services on our platform.',
                style: TextStyle(
                  fontSize: 14,
                  height: 1.4,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 8),
              TextButton(
                onPressed: _showFullAgreementSheet,
                style: TextButton.styleFrom(
                  padding: EdgeInsets.zero,
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: const Text(
                  'Read full agreement',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Obx(() => CheckboxListTile(
                    title: const Text(
                      'I agree to the Terms and Conditions',
                      style: TextStyle(fontSize: 14),
                    ),
                    value: hasAgreedToTerms.value,
                    onChanged: (value) {
                      hasAgreedToTerms.value = value ?? false;
                    },
                    controlAffinity: ListTileControlAffinity.leading,
                    contentPadding: EdgeInsets.zero,
                    activeColor: ThemeProvider.appColor,
                  )),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                // Go back - exit the signup page
                Get.back(); // Close dialog
                Get.back(); // Exit signup page
              },
              child: const Text(
                'Decline',
                style: TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            Obx(() => ElevatedButton(
                  onPressed: hasAgreedToTerms.value
                      ? () {
                          Get.back(); // Close dialog and proceed
                        }
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: ThemeProvider.appColor,
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: ThemeProvider.greyColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    'Accept & Continue',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                )),
          ],
        ),
      ),
      barrierDismissible: false, // Prevent dismissing by tapping outside
    );
  }

  void _showFullAgreementSheet() {
    Get.bottomSheet(
      Container(
        height: Get.height * 0.85,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  const Expanded(
                    child: Text(
                      'User Agreement',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Get.back(),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: _buildAgreementText(),
              ),
            ),
          ],
        ),
      ),
      isScrollControlled: true,
    );
  }

  Widget _buildAgreementText() {
    return const Text(
      '''E-COMMERCE SERVICES AGREEMENT

This document is an electronic record in terms of the Information Technology Act, 2000 and rules made
thereunder, and the provisions pertaining to electronic records in various statutes as amended by the
Information Technology Act, 2000. This electronic record is generated by a computer system and does not
require any physical or digital signatures.

E-COMMERCE SERVICES AGREEMENT
This E-Commerce Services Agreement (hereinafter referred to as "Agreement") is made on the day of your
acceptance of this Agreement from your designated electronic mail address or in any other form of
electronic record including, if applicable or provided, clicking on the check box or “I Agree” / “Accept”
button or by any other means which constitutes your acceptance of this Agreement (“Execution Date”)
by and between:
You, the details of which are provided by you on the Papa Bear Private Limited platform, a natural or
juristic person competent to enter into valid and legally binding contracts under applicable Indian laws
inter alia, a person of legally sound mind, not adjudicated bankrupt and equal to or more than 18 years of
age on the Execution Date. If you are a juristic person, then the person accepting this Agreement
represents that such person is duly authorized by you to bind you to this Agreement and the designated
electronic mail address is valid and subsisting and allotted by you to such person (hereinafter referred to
as the “Vendor” or “Service Provider Partner,” which expression shall unless repugnant to the context or
meaning thereof, include its successors, legal representatives, permitted assigns, etc.), of the One Part;
AND
Papa Bear, a Private limited Company concern having its principal place of business at Njanikkal Building,
Brahmapuram (P.O), Ernakulam, Kerala, India, Pin-682303, bearing GSTIN: 32COPA4075A1Z4, and
operating the website www.papabear4u.com, and App Phone: 9562121333 (hereinafter referred to as the
“Platform” or “Papa Bear,” which expression shall, unless repugnant to the context or meaning thereof,
include its representatives and permitted assigns), of the Other Part.
Papa Bear and the Vendor are hereinafter individually referred to as a “Party” and collectively as the
“Parties.”
RECITALS
1. The Vendor is engaged in the business of offering beauty and wellness services at its premises, and
wishes to market such services online through the Platform;
2. Papa Bear is engaged in the business of facilitating beauty and wellnessservicesthrough its proprietary
online booking platform for end customers;

3. The Vendor is desirous of availing the services of Papa Bear for the promotion and booking of
appointments and services offered by the Vendor through the Platform;
4. Papa Bear has agreed to list and market the Vendor’s services on the Platform and provide certain
ancillary services subject to the terms and conditions set forth herein;
NOW THEREFORE, in consideration of the mutual covenants and promisessetforth herein and other good
and valuable consideration,the sufficiency of which is hereby acknowledged,the Parties agree asfollows:
1. DEFINITIONS
1.1 "Agreement" means this E-Commerce Services Agreement including all schedules, annexures and
policies referenced herein.
1.2 "End Customer" means any individual or entity who books services via the Platform.
1.3 "Platform" means the online and mobile application operated by Papa Bear for the listing and booking
of beauty and wellness services.
1.4 "Service Fees" means the charges levied by Papa Bear to the Vendor for use of the Platform and
associated services, as specified in the Commercial Terms.
1.5 "Vendor Content" means all text, logos, images, business details, pricing, and service descriptions
provided by the Vendor for use on the Platform.
2. APPOINTMENT AND SCOPE
2.1 The Vendor hereby appoints Papa Bear as a non-exclusive service facilitator for promoting and
enabling booking of the Vendor’s services.
2.2 Papa Bear shall provide access to its platform and may, at its discretion, provide marketing, customer
support, and payment processing services.
2.3 Papa Bear reserves the right to accept or reject service listings at its sole discretion.
3. SERVICE FEES AND PAYMENTS
3.1 Papa Bear shall be entitled to a service fee on each booked appointment through the Platform, as per
separate Commercial Terms.
3.2 All payments due to the Vendor shall be settled periodically after deduction of applicable fees and
taxes.
3.3 The Vendorshall issue tax invoices and remit applicable GST or other statutory dues.
3.4 GST on Platform Fees: Papa Bear shall be solely responsible for the payment of any applicable GST on
the booking charges or service fees it receives from the Customer for the use of the Papa Bear app and its
platform services.

3.5 No Liability for Cross GST Obligations: Papa Bearshall not be held liable for any GST obligations arising
out of the services rendered by the shop Owner to the Customer, and vice versa.
4. STATUTORY COMPLIANCES AND SERVICE RESPONSIBILITY
4.1 The Vendor shall be solely responsible for ensuring that all statutory compliances, licenses,
registrations, permits, and approvals applicable to the operation of their business and the provision of
services are duly obtained and maintained at all times.
4.2 In the event that a Customer is dissatisfied with, or raises any complaint regarding, the services
rendered by the Vendor (including quality, conduct, hygiene, or any other aspect), the Vendor shall be
solely responsible for resolving such grievances to the Customer’s satisfaction.
4.3 Papa Bear shall not be liable for any claims, losses, damages, or legal actions arising out of or relating
to the services provided by the Vendor to Customers.
4.4 The Vendor agrees to indemnify and hold harmless Papa Bear from any liability, claims, or costs
(including legal fees)thatmay arise in connection with the Vendor’sservices orstatutory non-compliance.
5. INVOICING, FEES, AND TAXATION
5.1 Upon successful completion of a service booking, Papa Bear shall collect the full amount from the
Customer, including the service charges and applicable Goods and Services Tax (GST) as per prevailing
government rates.
5.2 Papa Bearshall be entitled to retain a commission fee of 10% ofthe service charges including GST from
the amount collected.
5.3 The remaining balance, after deduction of Papa Bear’s commission, shall be remitted to the Vendor.
5.4 All invoices generated through the Papa Bear app shall reflect the applicable GST component in
accordance with the percentage prescribed by the relevant government authorities at the time of
transaction.
5.5 The Vendor shall be responsible for maintaining their own tax compliance, including payment of any
taxes on the amounts received, other than the GST collected by Papa Bear on the Customer’s payment.
5.6 The vendors has to provide their GST number to the Papa bear App itself.
5.7 The vendors with premium membership has the only right to collect cash on service. All others has
to pay via App itself.

6. CANCELLATION AND REFUNDS

6.1 In the event that a Customer is unable to appear for the scheduled appointment or wishes to cancel
the booking for any reason, the Customer shall be entitled to a full refund of the booking amount paid.
6.2 The refund process shall be initiated promptly upon receipt of the Customer’s cancellation request,
and the amount shall be credited back to the original mode of payment within [7] working days(or specify
your preferred time frame).
6.3 The Vendor agrees and acknowledges that no service charges, penalties, or deductions shall be levied
on such cancellations initiated by Customers.
6.4 Papa Bear shall facilitate the refund process but shall not be responsible for any delays caused due to
technical or banking issues beyond its control.
7. PRODUCT SALES BY PREMIUM VENDORS
7.1 Vendors holding a Premium Membership shall have the right to list and sell their products through
the Papa Bear app platform.
7.2 Papa Bear acts solely as a facilitator by connecting Customers with Vendors and providing a platform
for transactions.
7.3 The Vendor shall be solely responsible for the packaging, shipment, transport, and timely delivery of
the products to the Customer.
7.4 All risks, liabilities, and obligations arising from the sale, including but not limited to product quality,
warranty, returns, and customer grievances, shall solely vest with the Vendor.
7.5 Papa Bear shall collect the payment for the product from the Customer on behalf of the Vendor and
remit it to the Vendor after deducting applicable platform fees (if any).
7.6 Papa Bear shall not be liable for any loss, damage, defect, delay, or failure in delivery of the products
sold by the Vendor.
8. VENDOR OBLIGATIONS
8.1 The Vendor affirms legal authority and necessary licenses to offer services.
8.2 The Vendor shall provide accurate service details, pricing, and schedules.
8.3 The Vendorshall fulfill bookings with professional standards.
8.4 Misleading or fraudulent conduct on the Platform is prohibited.

9. INTELLECTUAL PROPERTY
9.1 All Platform IP remains the sole property of Papa Bear.

9.2 The Vendor grants Papa Bear a non-exclusive license to use its content for the Platform.
9.3 Unauthorized use of Papa Bear branding is prohibited.

10. CONFIDENTIALITY
10.1 Each Party agrees to keep the other Party’s confidential information secure.
10.2 Disclosure is permitted only to fulfill obligations under this Agreement.
10.3 Confidentiality obligationssurvive termination.

11. INDEMNITY
11.1 The Vendor shall indemnify Papa Bear against claims or losses arising from
11.2 breach of this Agreement
11.3 booking failures
11.4 legal violations
11.5 fraudulent or negligent conduct.

12. LIMITATION OF LIABILITY
12.1 Papa Bear shall not be liable for indirect or consequential damages.
12.2 Papa Bear’s liability is capped at the total service fees earned in the 3 months preceding the claim.

13. TERM AND TERMINATION
13.1 This Agreement is effective from the Execution Date until terminated.
13.2 Either Party may terminate with 30 days’ written notice.
13.3 Papa Bear may terminate immediately for material breach or misconduct.
13.4 Upon termination, all outstanding dues become immediately payable.

15. DISPUTE RESOLUTION

15.1 Parties shall first attempt resolution through good faith discussions.
15.2 Failing which, disputes shall be referred to arbitration in Ernakulam, Kerala under the Arbitration and
Conciliation Act, 1996.
15.3 The courts at Ernakulam shall have exclusive jurisdiction.
16. Advertisements, Promotions, and Discounts
16.1 Vendors shall have the ability to offer discounts on their services to Customers through the Papa
Bear app platform. The Vendor shall be solely responsible for setting, managing, and honoring such
discount offers.
16.2 Vendors holding a Premium Membership shall be entitled to run promotional campaigns and display
advertisements within the Papa Bear app, subject to the terms and conditions determined by Papa Bear.
16.3 The charges applicable for advertisements and promotional placements shall be decided solely by
the Papa Bear authorities and shall be communicated to the Vendor in advance.
16.4 All promotional content must comply with the standards, guidelines, and approval process prescribed
by Papa Bear.
16.5 Papa Bear reserves the right to reject, remove, or modify any promotional material at its sole
discretion without assigning any reason.

17. NOTICES
17.1 Notices shall be sent to:
Papa Bear: Njanikkal Building, Brahmapuram (P.O), Ernakulam, Kerala, 682303. Phone: 9562121333.
Vendor: Address as provided during registration.

18. MISCELLANEOUS
18.1 Entire Agreement: Thisis the complete understanding between the Parties.
18.2 Assignment: Not permitted without written consent.
18.3 Severability: Invalid terms shall not affect the rest.
18.4 Amendments: Only through written mutual consent.
18.5 No Waiver: Delay or failure to enforce rights does not constitute waiver.

IN WITNESS WHEREOF, the Parties have accepted and agreed to the terms and conditionsset forth above.''',
      style: TextStyle(
        fontSize: 12,
        height: 1.4,
        color: Colors.black87,
      ),
    );
  }

  // Method to check if user can proceed (for form validation)
  bool canProceedWithSignup() {
    return hasAgreedToTerms.value;
  }

  // Override onClose to reset agreement status
  @override
  void onClose() {
    hasAgreedToTerms.value = false;
    _agreementDialogShown = false;
    super.onClose();
  }

  Future<void> loadActiveCountries() async {
    String country = 'IN';
    String lang = 'en';
    if (Get.isRegistered<LocaleController>()) {
      final locale = Get.find<LocaleController>();
      if (locale.countryCode.isNotEmpty) country = locale.countryCode;
      if (locale.languageCode.isNotEmpty) lang = locale.languageCode;
    }
    Response response =
        await parser.getActiveCountries(country: country, lang: lang);
    apiCalled = true;
    if (response.statusCode == 200) {
      final myMap = Map<String, dynamic>.from(response.body);
      List? body = myMap['countries'] is List
          ? myMap['countries'] as List
          : (myMap['data'] is List ? myMap['data'] as List : null);
      _countryList = [];
      final seen = <String>{};
      if (body != null) {
        for (final data in body) {
          if (data is! Map) continue;
          final parsed =
              SignupCountryModel.fromJson(Map<String, dynamic>.from(data));
          final key = parsed.countryCode.isNotEmpty
              ? parsed.countryCode
              : parsed.code;
          if (key.isEmpty || seen.contains(key)) continue;
          seen.add(key);
          _countryList.add(parsed);
        }
      }
      if (Get.isRegistered<LocaleController>()) {
        Get.find<LocaleController>().applyCurrencyFromApi(myMap);
      }
      if (_selectedCountry == null && _countryList.isNotEmpty) {
        SignupCountryModel match = _countryList.first;
        if (Get.isRegistered<LocaleController>()) {
          final code =
              Get.find<LocaleController>().countryCode.toUpperCase();
          final found = _countryList.where(
              (c) => c.code.toUpperCase() == code || c.isoCode.toUpperCase() == code);
          if (found.isNotEmpty) match = found.first;
        }
        onCountryChanged(match, fetchCities: true);
      } else {
        update();
      }
    } else {
      ApiChecker.checkApi(response);
      update();
    }
  }

  Future<void> openCountryCodePicker() async {
    if (_countryList.isEmpty) {
      await loadActiveCountries();
      if (_countryList.isEmpty) return;
    }
    Get.bottomSheet(
      SafeArea(
        child: Container(
          constraints: BoxConstraints(maxHeight: Get.height * 0.5),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              const SizedBox(height: 10),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  'Select Country Code'.tr,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: _countryList.length,
                  itemBuilder: (context, index) {
                    final country = _countryList[index];
                    final selected =
                        countryCodeMobile == country.countryCode;
                    return ListTile(
                      title: Text(country.name),
                      trailing: Text(
                        country.countryCode,
                        style: const TextStyle(fontWeight: FontWeight.w700),
                      ),
                      selected: selected,
                      onTap: () {
                        onCountryChanged(country);
                        Get.back();
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> fetchCitiesForCountry(String countryCode) async {
    Response response = await parser.getActiveCities(countryCode);
    if (response.statusCode == 200) {
      final myMap = Map<String, dynamic>.from(response.body);
      final body = myMap['data'];
      _cityList = [];
      if (body is List) {
        for (final data in body) {
          _cityList.add(CityModal.fromJson(Map<String, dynamic>.from(data)));
        }
      }
      _selectedCity = _cityList.isNotEmpty ? _cityList.first : CityModal();
    } else {
      ApiChecker.checkApi(response);
    }
    update();
  }

  void onCountryChanged(SignupCountryModel country, {bool fetchCities = true}) {
    _selectedCountry = country;
    if (country.countryCode.isNotEmpty) {
      countryCodeMobile = country.countryCode;
    }
    if (Get.isRegistered<LocaleController>() && country.code.isNotEmpty) {
      final locale = Get.find<LocaleController>();
      if (locale.countryCode.toUpperCase() != country.code.toUpperCase()) {
        locale.changeCountry(country.code);
      }
    }
    if (fetchCities) {
      fetchCitiesForCountry(country.code.isNotEmpty ? country.code : 'IN');
    } else {
      update();
    }
  }

  Future<void> getHomeCities() async {
    await fetchCitiesForCountry(_selectedCountry?.code ?? 'IN');
  }

  String _textOrDummy(String value, [String fallback = 'NA']) {
    final trimmed = value.trim();
    return trimmed.isEmpty ? fallback : trimmed;
  }

  int _intOrZero(String value) {
    return int.tryParse(value.trim()) ?? 0;
  }

  String _categoriesPayload() {
    final savedList = servedCategoriesList
        .where((element) => element.isChecked == true)
        .map((element) => element.id.toString())
        .toList();
    return savedList.isEmpty ? '1' : savedList.join(',');
  }

  Map<String, dynamic> _buildRegisterBody() {
    final shopName = type == 1
        ? name.text.trim()
        : _textOrDummy(name.text, _textOrDummy(firstNameTextEditor.text, 'NA'));

    return {
      'email': emailTextEditor.text.trim(),
      'first_name': _textOrDummy(firstNameTextEditor.text, 'Partner'),
      'last_name': _textOrDummy(lastNameTextEditor.text, 'User'),
      'mobile': mobileTextEditor.text.trim(),
      'country_code': _textOrDummy(countryCodeMobile, '+91'),
      'country': _selectedCountry?.code ?? 'IN',
      'password': passwordTextEditor.text,
      'categories': _categoriesPayload(),
      'lat': lat.text.trim().isEmpty ? '0' : lat.text.trim(),
      'lng': lng.text.trim().isEmpty ? '0' : lng.text.trim(),
      'fee_start': _intOrZero(feeStart.text),
      'about': _textOrDummy(descriptionsTextEditor.text),
      'cid': selectedCity.id?.toString() ?? '0',
      'zipcode': _textOrDummy(zipcode.text, '000000'),
      'address': _textOrDummy(addressTextEditor.text),
      'extra_field': 'NA',
      'status': 1,
      'cover': cover.isEmpty ? 'uploads/images/dummy.jpg' : cover,
      'gender': selectedGender == 'Male' ? 1 : 0,
      'type': type == 1 ? 'salon' : 'individual',
      'name': shopName,
      'id_proof': id_proof,
      'id_proof_back':
          id_proof_back.isEmpty ? id_proof : id_proof_back,
      'bank_ifsc': _textOrDummy(ifscCode.text),
      'bank_name': _textOrDummy(bankName.text),
      'pan': _textOrDummy(panNumber.text),
      'vat': _textOrDummy(gstNumber.text),
      'bank_customer_name': _textOrDummy(accountName.text),
      'bank_account_number': _textOrDummy(accountNumber.text),
      'heard_us_from': _textOrDummy(selectedHow),
      'executive_id': _textOrDummy(executiveId.text, '0'),
      'whatsapp_number': whatsapp.text.trim(),
      'team_size': _textOrDummy(teamsize.text, '0'),
    };
  }

  void getCurrentLocation() async {
    print('get location');
    LocationPermission permission;

    // Check if location services are enabled.
    bool serviceEnabled = await Geolocator
        .isLocationServiceEnabled(); // This line might be causing the error
    if (!serviceEnabled) {
      // Location services are not enabled, ask the user to enable them.
      await Geolocator.openLocationSettings();
      return;
    }

    // Check if the app has permission to access location.
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // Permissions are denied, handle accordingly.
        Get.snackbar(
          "Permission Denied",
          "Location permission is required to fetch coordinates.",
          backgroundColor: Colors.red,
        );
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Permissions are denied forever, handle accordingly.
      Get.snackbar(
        "Permission Denied",
        "Location permissions are permanently denied. Enable them from settings.",
        backgroundColor: Colors.red,
      );
      return;
    }

    // Get the current location.
    try {
      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);

      // Update the latitude and longitude fields in the controller.
      lat.text = position.latitude.toString();
      lng.text = position.longitude.toString();

      update();
    } catch (e) {
      Get.snackbar(
          backgroundColor: Colors.red,
          "Error",
          "Failed to get current location: $e");
    }
  }

  void saveCategory(List<AddProfileModel> list) {
    _servedCategoriesList = [];
    for (var element in list) {
      if (element.isChecked == true) {
        _servedCategoriesList.add(element);
      }
    }
    update();
  }

  void updateType(int number) {
    type = number;
    update();
  }

  void onNext() {
    currentView = currentView + 1;
    update();
  }

  void onBack() {
    currentView = currentView - 1;
    update();
  }

  void onBackRoutes() {
    var context = Get.context as BuildContext;
    Navigator.of(context).pop(true);
  }

  void selectFromGallery(int type, String kind) async {
    debugPrint(kind);
    final pickedFile = await ImagePicker().pickImage(
        source: kind == 'gallery' ? ImageSource.gallery : ImageSource.camera,
        imageQuality: 25);
    debugPrint(pickedFile.toString());
    if (pickedFile != null) {
      Get.dialog(
          SimpleDialog(
            children: [
              Row(
                children: [
                  const SizedBox(
                    width: 30,
                  ),
                  const CircularProgressIndicator(
                    color: ThemeProvider.appColor,
                  ),
                  const SizedBox(
                    width: 30,
                  ),
                  SizedBox(
                      child: Text(
                    "Please wait".tr,
                    style: const TextStyle(fontFamily: 'bold'),
                  )),
                ],
              )
            ],
          ),
          barrierDismissible: false);
      Response response = await parser.uploadImage(pickedFile);
      Get.back();
      if (response.statusCode == 200) {
        if (response.body['data'] != null && response.body['data'] != '') {
          dynamic body = response.body["data"];
          if (body['image_name'] != null && body['image_name'] != '') {
            if (type == 1) {
              cover = body['image_name'];
            } else if (type == 2) {
              id_proof = body['image_name'];
            } else {
              id_proof_back = body['image_name'];
            }

            debugPrint(cover);
            debugPrint(id_proof);
            debugPrint(id_proof_back);
            update();
          }
        }
      } else {
        ApiChecker.checkApi(response);
      }
    }
  }

  Future<void> verifyEmail() async {
    debugPrint('verify email');
    if (!GetUtils.isEmail(emailTextEditor.text)) {
      showToast("Email is not valid".tr);
      return;
    }

    Get.dialog(
        SimpleDialog(
          children: [
            Row(
              children: [
                const SizedBox(
                  width: 30,
                ),
                const CircularProgressIndicator(
                  color: ThemeProvider.appColor,
                ),
                const SizedBox(
                  width: 30,
                ),
                SizedBox(
                    child: Text(
                  "Please wait".tr,
                  style: const TextStyle(fontFamily: 'bold'),
                )),
              ],
            )
          ],
        ),
        barrierDismissible: false);
    var body = {
      "email": emailTextEditor.text,
    };
    var response = await parser.verifyEmail(body);
    Get.back();
    debugPrint(response.bodyString);
    if (response.statusCode == 200) {
      Map<String, dynamic> myMap = Map<String, dynamic>.from(response.body);
      if (myMap['data'] != '' && myMap['data'] == true) {
        smsId = myMap['otp_id'];
        FocusManager.instance.primaryFocus?.unfocus();
        onEmailModal();
      } else {
        if (myMap['success'] == false && myMap['status'] == 500) {
          debugPrint(myMap['message'.tr]);
          showToast(myMap['message'.tr]);
        } else {
          showToast('Something went wrong while signup'.tr);
        }
      }
    } else if (response.statusCode == 401) {
      showToast('Something went wrong while signup'.tr);
      update();
    } else if (response.statusCode == 500) {
      Map<String, dynamic> myMap = Map<String, dynamic>.from(response.body);
      if (myMap['message'] != '') {
        showToast(myMap['message'.tr]);
      } else {
        showToast('Something went wrong'.tr);
      }
      update();
    } else {
      ApiChecker.checkApi(response);
      update();
    }
    update();
  }

  void onEmailModal() {
    otpCode = '';
    openOTPModal(emailTextEditor.text.trim());
  }

  void openOTPModal(String target, {String type = 'email', String way = 'email'}) {
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
                way == 'mobile' ? 'Verify Mobile OTP'.tr : 'Verify OTP'.tr,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: ThemeProvider.appColor,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'We have sent verification code on'.tr,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 14, color: Colors.black87),
              ),
              const SizedBox(height: 6),
              Text(
                target,
                textAlign: TextAlign.center,
                style: const TextStyle(
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
                    onOtpSubmit(type, way);
                  },
                ),
              ),
              const SizedBox(height: 20),
              Obx(
                () => SizedBox(
                  width: double.infinity,
                  height: 45,
                  child: ElevatedButton(
                    onPressed: isLogin.value
                        ? null
                        : () {
                            if (otpCode.length >= 6) {
                              onOtpSubmit(type, way);
                            } else {
                              showToast('Please enter OTP'.tr);
                            }
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: ThemeProvider.appColor,
                      foregroundColor: ThemeProvider.whiteColor,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: isLogin.value
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: ThemeProvider.whiteColor,
                            ),
                          )
                        : Text('Verify'.tr),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      barrierDismissible: false,
    );
  }

  Future<void> onOtpSubmit(String type, String way) async {
    if (otpCode.length < 6) {
      showToast('Please enter OTP'.tr);
      return;
    }
    isLogin.value = true;
    update();
    var param = {
      'id': smsId,
      'otp': otpCode,
      'type': type,
      'mobile': mobileTextEditor.text,
      'email': emailTextEditor.text,
    };
    Response response = await parser.verifyOTP(param);
    debugPrint(response.bodyString.toString());
    isLogin.value = false;

    if (response.statusCode == 200) {
      Map<String, dynamic> myMap = Map<String, dynamic>.from(response.body);
      bool isSuccess = myMap['success'] == true || myMap['success'] == 'true';
      bool hasData = myMap['data'] != null && myMap['data'] != '';

      if (isSuccess || hasData) {
        if (Get.isDialogOpen == true) {
          Get.back();
        }
        if (way == 'email') {
          emailVerified = true;
        } else {
          phoneVerified = true;
        }
        update();
        if (_pendingRegisterAfterOtp &&
            (way == 'email' || way == 'mobile')) {
          _pendingRegisterAfterOtp = false;
          await _submitRegisterRequest();
        } else if (way == 'email') {
          successToast('Your Email is Verified'.tr);
        } else {
          successToast('Your Phone Number is Verified');
        }
      } else {
        update();
        showToast(_apiMessage(response, fallback: 'Invalid OTP'.tr));
      }
    } else {
      update();
      showToast(_apiMessage(response, fallback: 'Invalid OTP'.tr));
    }
  }

  void openLink() async {
    var url = Uri.parse('https://www.mapcoordinates.net/en');
    if (!await launchUrl(
      url,
      mode: LaunchMode.externalApplication,
    )) {
      throw 'Could not launch $url'.tr;
    }
  }

  void saveCountryCode(String code) {
    countryCodeMobile = '+$code';
    update();
  }

  Future<void> verifyPhone() async {
    debugPrint('verifyPhone');
    debugPrint(smsName);
    if (mobileTextEditor.text == '' || mobileTextEditor.text.isEmpty) {
      showToast('Phone number is required'.tr);
      return;
    }
    if (smsName == '2') {
      Get.dialog(
          SimpleDialog(
            children: [
              Row(
                children: [
                  const SizedBox(
                    width: 30,
                  ),
                  const CircularProgressIndicator(
                    color: ThemeProvider.appColor,
                  ),
                  const SizedBox(
                    width: 30,
                  ),
                  SizedBox(
                      child: Text(
                    "Please wait".tr,
                    style: const TextStyle(fontFamily: 'bold'),
                  )),
                ],
              )
            ],
          ),
          barrierDismissible: false);
      var param = {
        'country_code': countryCodeMobile,
        'mobile': mobileTextEditor.text
      };
      Response response = await parser.checkPhoneExist(param);
      Get.back();
      if (response.statusCode == 200) {
        Map<String, dynamic> myMap = Map<String, dynamic>.from(response.body);
        if (myMap['data'] != '' && myMap['data'] == true) {
          FocusManager.instance.primaryFocus?.unfocus();
          Get.toNamed(AppRouter.getFirebaseAuthRoutes(), arguments: [
            countryCodeMobile,
            mobileTextEditor.text,
            'register'
          ]);
        } else {
          showToast('Something went wrong while signup'.tr);
        }
        update();
      } else if (response.statusCode == 401) {
        Map<String, dynamic> myMap = Map<String, dynamic>.from(response.body);
        if (myMap['message'] != '') {
          showToast(myMap['message'.tr]);
        } else {
          showToast('Something went wrong'.tr);
        }
        update();
      } else if (response.statusCode == 500) {
        Map<String, dynamic> myMap = Map<String, dynamic>.from(response.body);
        if (myMap['message'] != '') {
          showToast(myMap['message'.tr]);
        } else {
          showToast('Something went wrong'.tr);
        }
        update();
      } else {
        ApiChecker.checkApi(response);
        update();
      }
      update();
    } else {
      debugPrint('sms');
      var param = {
        'country_code': countryCodeMobile,
        'mobile': mobileTextEditor.text
      };
      Response response = await parser.verifyPhone(param);
      if (response.statusCode == 200) {
        Map<String, dynamic> myMap = Map<String, dynamic>.from(response.body);
        if (myMap['data'] != '' && myMap['data'] == true) {
          smsId = myMap['otp_id'];
          FocusManager.instance.primaryFocus?.unfocus();
          sendSMS('phone');
        } else {
          showToast('Something went wrong while signup'.tr);
        }
        update();
      } else if (response.statusCode == 401) {
        Map<String, dynamic> myMap = Map<String, dynamic>.from(response.body);
        if (myMap['message'] != '') {
          showToast(myMap['message'.tr]);
        } else {
          showToast('Something went wrong'.tr);
        }
        update();
      } else if (response.statusCode == 500) {
        Map<String, dynamic> myMap = Map<String, dynamic>.from(response.body);
        if (myMap['message'] != '') {
          showToast(myMap['message'.tr]);
        } else {
          showToast('Something went wrong'.tr);
        }
        update();
      } else {
        ApiChecker.checkApi(response);
        update();
      }
      update();
    }
  }

  void sendSMS(String type) {
    openOTPModal(
      countryCodeMobile.toString() + mobileTextEditor.text.toString(),
      type: type,
      way: 'mobile',
    );
  }

  void togglePasswordBtn() {
    passwordVisible = !passwordVisible;
    update();
  }

  void saveGender(String gender) {
    selectedGender = gender;
    update();
  }

  void saveHow(String how) {
    selectedHow = how;
    if (selectedHow != 'Executive') {
      executiveId.clear();
    }
    update();
  }

  bool get showExecutiveId => selectedHow == 'Executive';

  void onCategoriesList() {
    debugPrint('open category');
    Get.delete<RegisterCategoriesController>(force: true);
    Get.toNamed(AppRouter.getRegisterCategoriesRoutes(),
        arguments: [_servedCategoriesList]);
  }

  void onCityChanged(CityModal city) {
    _selectedCity = city;
    update();
  }

  void verifyPhoneFromFirebase() {
    phoneVerified = true;
    update();
    if (_pendingRegisterAfterOtp) {
      _pendingRegisterAfterOtp = false;
      _submitRegisterRequest();
    }
  }

  void showValidationDialog(String message) {
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.0),
        ),
        backgroundColor: ThemeProvider.whiteColor,
        title: Row(
          children: [
            Icon(
              Icons.error_outline,
              color: Colors.redAccent,
              size: 28,
            ),
            SizedBox(width: 10),
            Text(
              'Validation Error',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: ThemeProvider.appColor,
              ),
            ),
          ],
        ),
        content: Text(
          message,
          style: TextStyle(fontSize: 16, color: Colors.black87),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Get.back(); // Close the dialog
            },
            style: TextButton.styleFrom(
              backgroundColor: ThemeProvider.appColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text(
              'OK',
              style: TextStyle(color: ThemeProvider.whiteColor),
            ),
          ),
        ],
      ),
    );
  }

  void _closeLoadingDialog() {
    if (Get.isDialogOpen == true) {
      Get.back();
    }
  }

  String _apiMessage(Response response, {required String fallback}) {
    if (response.body is Map) {
      final map = Map<String, dynamic>.from(response.body);
      final message = map['message']?.toString().trim() ?? '';
      if (message.isNotEmpty) return message;
      final error = map['error']?.toString().trim() ?? '';
      if (error.isNotEmpty) return error;
      final errors = map['errors'];
      if (errors is Map) {
        for (final value in errors.values) {
          if (value is List && value.isNotEmpty) {
            return value.first.toString();
          }
          if (value is String && value.trim().isNotEmpty) {
            return value;
          }
        }
      }
    }
    if (response.statusText != null &&
        response.statusText!.trim().isNotEmpty &&
        response.statusText != 'OK') {
      return response.statusText!;
    }
    return fallback;
  }

  Future<String?> _sendRegisterPhoneOtp() async {
    try {
      final response = await parser.verifyPhone({
        'country_code': countryCodeMobile,
        'mobile': mobileTextEditor.text.trim(),
      });
      if (response.body is Map) {
        final myMap = Map<String, dynamic>.from(response.body);
        if (response.statusCode == 200 &&
            myMap['success'] != false &&
            (myMap['data'] == true || myMap['otp_id'] != null)) {
          smsId = int.tryParse(myMap['otp_id']?.toString() ?? '') ?? smsId;
          return null;
        }
        return _apiMessage(
          response,
          fallback: 'Something went wrong while sending OTP'.tr,
        );
      }
      return _apiMessage(
        response,
        fallback: 'Something went wrong while sending OTP'.tr,
      );
    } catch (_) {
      return 'Something went wrong while sending OTP'.tr;
    }
  }

  bool _isNotFoundMessage(dynamic message) {
    final text = (message ?? '').toString().toLowerCase();
    return text.contains('data_not_found') || text.contains('data not found');
  }

  Future<String?> _phoneAvailabilityError() async {
    try {
      final param = {
        'country_code': countryCodeMobile,
        'mobile': mobileTextEditor.text.trim(),
      };
      final response = await parser.checkPhoneExist(param);
      if (response.body is Map) {
        final myMap = Map<String, dynamic>.from(response.body);
        if (myMap['data'] == true || _isNotFoundMessage(myMap['message'])) {
          return null;
        }
        if (response.statusCode == 200 && myMap['success'] != false) {
          return null;
        }
        return _apiMessage(
          response,
          fallback: 'Mobile is already registered'.tr,
        );
      }
      if (response.statusCode == 200) {
        return null;
      }
      return _apiMessage(
        response,
        fallback: 'Mobile is already registered'.tr,
      );
    } catch (_) {
      return 'Something went wrong while verifying phone'.tr;
    }
  }

  Future<void> onRegister() async {
    if (!hasAgreedToTerms.value) {
      showValidationDialog('Please accept the Terms and Conditions'.tr);
      return;
    }
    if (mobileTextEditor.text.trim().isEmpty) {
      showValidationDialog('Mobile number is required'.tr);
      return;
    }
    if (emailTextEditor.text.trim().isEmpty) {
      showValidationDialog('Email is required'.tr);
      return;
    }
    if (!GetUtils.isEmail(emailTextEditor.text.trim())) {
      showValidationDialog('Email is not valid'.tr);
      return;
    }
    if (type == 1 && name.text.trim().isEmpty) {
      showValidationDialog('Shop name is required'.tr);
      return;
    }
    if (_selectedCountry == null) {
      showValidationDialog('Country is required'.tr);
      return;
    }
    if (selectedCity.id == null) {
      showValidationDialog('City is required'.tr);
      return;
    }
    if (whatsapp.text.trim().isEmpty) {
      showValidationDialog('WhatsApp number is required'.tr);
      return;
    }
    if (passwordTextEditor.text.isEmpty) {
      showValidationDialog('Password is required'.tr);
      return;
    }
    if (confirmPasswordTextEditor.text.isEmpty) {
      showValidationDialog('Confirm password is required'.tr);
      return;
    }
    if (passwordTextEditor.text != confirmPasswordTextEditor.text) {
      showValidationDialog('Password does not match'.tr);
      return;
    }

    Get.dialog(
        SimpleDialog(
          children: [
            Row(
              children: [
                const SizedBox(
                  width: 30,
                ),
                const CircularProgressIndicator(
                  color: ThemeProvider.appColor,
                ),
                const SizedBox(
                  width: 30,
                ),
                SizedBox(
                    child: Text(
                  "Please wait".tr,
                  style: const TextStyle(fontFamily: 'bold'),
                )),
              ],
            )
          ],
        ),
        barrierDismissible: false);

    final phoneError = await _phoneAvailabilityError();
    if (phoneError != null) {
      _closeLoadingDialog();
      showValidationDialog(phoneError);
      return;
    }

    _pendingRegisterAfterOtp = true;
    if (smsName == '2') {
      _closeLoadingDialog();
      FocusManager.instance.primaryFocus?.unfocus();
      Get.toNamed(AppRouter.getFirebaseAuthRoutes(), arguments: [
        countryCodeMobile,
        mobileTextEditor.text,
        'register'
      ]);
      return;
    }

    final phoneOtpError = await _sendRegisterPhoneOtp();
    if (phoneOtpError != null) {
      _closeLoadingDialog();
      _pendingRegisterAfterOtp = false;
      showValidationDialog(phoneOtpError);
      return;
    }

    _closeLoadingDialog();
    FocusManager.instance.primaryFocus?.unfocus();
    otpCode = '';
    openOTPModal(
      '$countryCodeMobile${mobileTextEditor.text.trim()}',
      type: 'phone',
      way: 'mobile',
    );
  }

  Future<void> _submitRegisterRequest() async {
    Get.dialog(
        SimpleDialog(
          children: [
            Row(
              children: [
                const SizedBox(
                  width: 30,
                ),
                const CircularProgressIndicator(
                  color: ThemeProvider.appColor,
                ),
                const SizedBox(
                  width: 30,
                ),
                SizedBox(
                    child: Text(
                  "Please wait".tr,
                  style: const TextStyle(fontFamily: 'bold'),
                )),
              ],
            )
          ],
        ),
        barrierDismissible: false);

    final body = _buildRegisterBody();
    debugPrint(body.toString());
    var response = await parser.saveMyRequest(body);
    _closeLoadingDialog();
    debugPrint(response.bodyString);

    final savedOk = response.statusCode == 200 &&
        !(response.body is Map &&
            Map<String, dynamic>.from(response.body)['success'] == false);
    if (savedOk) {
      Get.generalDialog(
          pageBuilder: (context, __, ___) => AlertDialog(
                title: const Text('Success!\n Awaiting Review'),
                content: const Text(
                    'Your request is submitted\nYou can start use your account once our approval is completed'),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                      onBackRoutes();
                    },
                    child: Text(
                      'Okay'.tr,
                      style: const TextStyle(
                          color: ThemeProvider.appColor, fontFamily: 'bold'),
                    ),
                  )
                ],
              ));
    } else {
      showValidationDialog(
        _apiMessage(response, fallback: 'Something went wrong'.tr),
      );
    }
    update();
  }
}

// Alternative: Separate User Agreement Page (if you prefer a full page instead of dialog)
class UserAgreementPage extends StatelessWidget {
  final VoidCallback onAccept;
  final VoidCallback onDecline;

  const UserAgreementPage({
    Key? key,
    required this.onAccept,
    required this.onDecline,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final RxBool hasAgreed = false.obs;

    return Scaffold(
      appBar: AppBar(
        title: const Text('User Agreement'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        automaticallyImplyLeading: false, // Remove back button
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Terms and Conditions',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 20),
                    _buildFullAgreementContent(),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Obx(() => CheckboxListTile(
                  title: const Text(
                    'I have read and agree to the Terms and Conditions',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  value: hasAgreed.value,
                  onChanged: (value) {
                    hasAgreed.value = value ?? false;
                  },
                  controlAffinity: ListTileControlAffinity.leading,
                  activeColor: Colors.blue,
                )),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: onDecline,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.red,
                      side: const BorderSide(color: Colors.red),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: const Text(
                      'Decline',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Obx(() => ElevatedButton(
                        onPressed: hasAgreed.value ? onAccept : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        child: const Text(
                          'Accept & Continue',
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                      )),
                ),
              ],
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildFullAgreementContent() {
    return const Text(
      '''This document is an electronic record in terms of the Information Technology Act, 2000 and rules made
thereunder, and the provisions pertaining to electronic records in various statutes as amended by the
Information Technology Act, 2000. This electronic record is generated by a computer system and does
not require any physical or digital signatures.

E-COMMERCE SERVICES AGREEMENT
This E-Commerce Services Agreement (hereinafter referred to as &quot;Agreement&quot;) is made on the day of
your acceptance of this Agreement from your designated electronic mail address or in any other form of
electronic record including, if applicable or provided, clicking on the check box or “I Agree” / “Accept”
button or by any other means which constitutes your acceptance of this Agreement (“Execution Date”)
by and between:
You, the details of which are provided by you on the Papa Bear platform, a natural or juristic person
competent to enter into valid and legally binding contracts under applicable Indian laws inter alia, a
person of legally sound mind, not adjudicated bankrupt and equal to or more than 18 years of age on
the Execution Date. If you are a juristic person, then the person accepting this Agreement represents
that such person is duly authorized by you to bind you to this Agreement and the designated electronic
mail address is valid and subsisting and allotted by you to such person (hereinafter referred to as the
“Vendor” or “Service Provider Partner,” which expression shall unless repugnant to the context or
meaning thereof, include its successors, legal representatives, permitted assigns, etc.), of the One Part;
AND
Papa Bear, a proprietorship concern having its principal place of business at Njanikkal Building,
Brahmapuram (P.O), Ernakulam, Kerala, India, Pin-682303, bearing GSTIN: 32COPA4075A1Z4, and
operating the website www.papabear4u.com, and App Phone: 9562121333 (hereinafter referred to as
the “Platform” or “Papa Bear,” which expression shall, unless repugnant to the context or meaning
thereof, include its representatives and permitted assigns), of the Other Part.
Papa Bear and the Vendor are hereinafter individually referred to as a “Party” and collectively as the
“Parties.”
RECITALS
1. The Vendor is engaged in the business of offering beauty and wellness services at its premises, and
wishes to market such services online through the Platform;
2. Papa Bear is engaged in the business of facilitating beauty and wellness services through its
proprietary online booking platform for end customers;

3. The Vendor is desirous of availing the services of Papa Bear for the promotion and booking of
appointments and services offered by the Vendor through the Platform;
4. Papa Bear has agreed to list and market the Vendor’s services on the Platform and provide certain
ancillary services subject to the terms and conditions set forth herein;
NOW THEREFORE, in consideration of the mutual covenants and promises set forth herein and other
good and valuable consideration, the sufficiency of which is hereby acknowledged, the Parties agree as
follows:
1. DEFINITIONS
1.1 &quot;Agreement&quot; means this E-Commerce Services Agreement including all schedules, annexures and
policies referenced herein.
1.2 &quot;End Customer&quot; means any individual or entity who books services via the Platform.
1.3 &quot;Platform&quot; means the online and mobile application operated by Papa Bear for the listing and
booking of beauty and wellness services.
1.4 &quot;Service Fees&quot; means the charges levied by Papa Bear to the Vendor for use of the Platform and
associated services, as specified in the Commercial Terms.
1.5 &quot;Vendor Content&quot; means all text, logos, images, business details, pricing, and service descriptions
provided by the Vendor for use on the Platform.
2. APPOINTMENT AND SCOPE
2.1 The Vendor hereby appoints Papa Bear as a non-exclusive service facilitator for promoting and
enabling booking of the Vendor’s services.
2.2 Papa Bear shall provide access to its platform and may, at its discretion, provide marketing,
customer support, and payment processing services.
2.3 Papa Bear reserves the right to accept or reject service listings at its sole discretion.
3. SERVICE FEES AND PAYMENTS
3.1 Papa Bear shall be entitled to a service fee on each booked appointment through the Platform, as
per separate Commercial Terms.
3.2 All payments due to the Vendor shall be settled periodically after deduction of applicable fees and
taxes.
3.3 The Vendor shall issue tax invoices and remit applicable GST or other statutory dues.

3.4 GST on Platform Fees: Papa Bear shall be solely responsible for the payment of any applicable GST
on the booking charges or service fees it receives from the Customer for the use of the Papa Bear app
and its platform services.
3.5 No Liability for Cross GST Obligations: Papa Bear shall not be held liable for any GST obligations
arising out of the services rendered by the shop Owner to the Customer, and vice versa.
4. STATUTORY COMPLIANCES AND SERVICE RESPONSIBILITY
4.1 The Vendor shall be solely responsible for ensuring that all statutory compliances, licenses,
registrations, permits, and approvals applicable to the operation of their business and the provision of
services are duly obtained and maintained at all times.
4.2 In the event that a Customer is dissatisfied with, or raises any complaint regarding, the services
rendered by the Vendor (including quality, conduct, hygiene, or any other aspect), the Vendor shall be
solely responsible for resolving such grievances to the Customer’s satisfaction.
4.3 Papa Bear shall not be liable for any claims, losses, damages, or legal actions arising out of or relating
to the services provided by the Vendor to Customers.
4.4 The Vendor agrees to indemnify and hold harmless Papa Bear from any liability, claims, or costs
(including legal fees) that may arise in connection with the Vendor’s services or statutory non-
compliance.
5. INVOICING, FEES, AND TAXATION
5.1 Upon successful completion of a service booking, Papa Bear shall collect the full amount from the
Customer, including the service charges and applicable Goods and Services Tax (GST) as per prevailing
government rates.
5.2 Papa Bear shall be entitled to retain a commission fee of 5% of the service charges including GST
from the amount collected.
5.3 The remaining balance, after deduction of Papa Bear’s commission, shall be remitted to the Vendor.
5.4 All invoices generated through the Papa Bear app shall reflect the applicable GST component in
accordance with the percentage prescribed by the relevant government authorities at the time of
transaction.
5.5 The Vendor shall be responsible for maintaining their own tax compliance, including payment of any
taxes on the amounts received, other than the GST collected by Papa Bear on the Customer’s payment.
5.6 The vendors has to provide their GST number to the Papa bear App itself.
5.7 The vendors with premium membership has the only right to collect cash on service. All others has
to pay via App itself.

6. CANCELLATION AND REFUNDS
6.1 In the event that a Customer is unable to appear for the scheduled appointment or wishes to cancel
the booking for any reason, the Customer shall be entitled to a full refund of the booking amount paid.
6.2 The refund process shall be initiated promptly upon receipt of the Customer’s cancellation request,
and the amount shall be credited back to the original mode of payment within [7] working days (or
specify your preferred time frame).
6.3 The Vendor agrees and acknowledges that no service charges, penalties, or deductions shall be
levied on such cancellations initiated by Customers.
6.4 Papa Bear shall facilitate the refund process but shall not be responsible for any delays caused due
to technical or banking issues beyond its control.
7. PRODUCT SALES BY PREMIUM VENDORS
7.1 Vendors holding a Premium Membership shall have the right to list and sell their products through
the Papa Bear app platform.
7.2 Papa Bear acts solely as a facilitator by connecting Customers with Vendors and providing a
platform for transactions.
7.3 The Vendor shall be solely responsible for the packaging, shipment, transport, and timely delivery
of the products to the Customer.
7.4 All risks, liabilities, and obligations arising from the sale, including but not limited to product
quality, warranty, returns, and customer grievances, shall solely vest with the Vendor.
7.5 Papa Bear shall collect the payment for the product from the Customer on behalf of the Vendor and
remit it to the Vendor after deducting applicable platform fees (if any).
7.6 Papa Bear shall not be liable for any loss, damage, defect, delay, or failure in delivery of the
products sold by the Vendor.
8. VENDOR OBLIGATIONS
8.1 The Vendor affirms legal authority and necessary licenses to offer services.
8.2 The Vendor shall provide accurate service details, pricing, and schedules.
8.3 The Vendor shall fulfill bookings with professional standards.
8.4 Misleading or fraudulent conduct on the Platform is prohibited.

9. INTELLECTUAL PROPERTY
9.1 All Platform IP remains the sole property of Papa Bear.
9.2 The Vendor grants Papa Bear a non-exclusive license to use its content for the Platform.
9.3 Unauthorized use of Papa Bear branding is prohibited.

10. CONFIDENTIALITY
10.1 Each Party agrees to keep the other Party’s confidential information secure.
10.2 Disclosure is permitted only to fulfill obligations under this Agreement.
10.3 Confidentiality obligations survive termination.

11. INDEMNITY
11.1 The Vendor shall indemnify Papa Bear against claims or losses arising from
11.2 breach of this Agreement
11.3 booking failures
11.4 legal violations
11.5 fraudulent or negligent conduct.

12. LIMITATION OF LIABILITY
12.1 Papa Bear shall not be liable for indirect or consequential damages.
12.2 Papa Bear’s liability is capped at the total service fees earned in the 3 months preceding the claim.

13. TERM AND TERMINATION
13.1 This Agreement is effective from the Execution Date until terminated.
13.2 Either Party may terminate with 30 days’ written notice.
13.3 Papa Bear may terminate immediately for material breach or misconduct.
13.4 Upon termination, all outstanding dues become immediately payable.

15. DISPUTE RESOLUTION
15.1 Parties shall first attempt resolution through good faith discussions.
15.2 Failing which, disputes shall be referred to arbitration in Ernakulam, Kerala under the Arbitration
and Conciliation Act, 1996.
15.3 The courts at Ernakulam shall have exclusive jurisdiction.
16. Advertisements, Promotions, and Discounts
16.1 Vendors shall have the ability to offer discounts on their services to Customers through the Papa
Bear app platform. The Vendor shall be solely responsible for setting, managing, and honoring such
discount offers.
16.2 Vendors holding a Premium Membership shall be entitled to run promotional campaigns and
display advertisements within the Papa Bear app, subject to the terms and conditions determined by
Papa Bear.
16.3 The charges applicable for advertisements and promotional placements shall be decided solely by
the Papa Bear authorities and shall be communicated to the Vendor in advance.
16.4 All promotional content must comply with the standards, guidelines, and approval process
prescribed by Papa Bear.
16.5 Papa Bear reserves the right to reject, remove, or modify any promotional material at its sole
discretion without assigning any reason.

17. NOTICES
17.1 Notices shall be sent to:
Papa Bear: Njanikkal Building, Brahmapuram (P.O), Ernakulam, Kerala, 682303. Phone: 9562121333.
Vendor: Address as provided during registration.

18. MISCELLANEOUS
18.1 Entire Agreement: This is the complete understanding between the Parties.
18.2 Assignment: Not permitted without written consent.
18.3 Severability: Invalid terms shall not affect the rest.

18.4 Amendments: Only through written mutual consent.
18.5 No Waiver: Delay or failure to enforce rights does not constitute waiver.

IN WITNESS WHEREOF, the Parties have accepted and agreed to the terms and conditions set forth
above.''',
      style: TextStyle(
        fontSize: 14,
        height: 1.5,
        color: Colors.black87,
      ),
    );
  }
}

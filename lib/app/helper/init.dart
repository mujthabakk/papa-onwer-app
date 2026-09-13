import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ultimate_salon_owner_flutter/app/backend/api/api.dart';
import 'package:ultimate_salon_owner_flutter/app/backend/parse/add_services_parse.dart';
import 'package:ultimate_salon_owner_flutter/app/backend/parse/add_slot_parse.dart';
import 'package:ultimate_salon_owner_flutter/app/backend/parse/add_timing_parse.dart';
import 'package:ultimate_salon_owner_flutter/app/backend/parse/ads_managing_parse.dart';
import 'package:ultimate_salon_owner_flutter/app/backend/parse/ads_publish_parse.dart';
import 'package:ultimate_salon_owner_flutter/app/backend/parse/analytics_parse.dart';
import 'package:ultimate_salon_owner_flutter/app/backend/parse/cancel_all_parse.dart';
import 'package:ultimate_salon_owner_flutter/app/backend/parse/cities_categories_parse.dart';
import 'package:ultimate_salon_owner_flutter/app/backend/parse/complaint_parse.dart';
import 'package:ultimate_salon_owner_flutter/app/backend/parse/coupons_parse.dart';
import 'package:ultimate_salon_owner_flutter/app/backend/parse/timed_offers_parse.dart';
import 'package:ultimate_salon_owner_flutter/app/backend/parse/connect_links_parse.dart';
import 'package:ultimate_salon_owner_flutter/app/backend/parse/firebase_parse.dart';
import 'package:ultimate_salon_owner_flutter/app/backend/parse/individual_categories_parse.dart';
import 'package:ultimate_salon_owner_flutter/app/backend/parse/individual_cities_parse.dart';
import 'package:ultimate_salon_owner_flutter/app/backend/parse/individual_profile_parse.dart';
import 'package:ultimate_salon_owner_flutter/app/backend/parse/notification_parser.dart';
import 'package:ultimate_salon_owner_flutter/app/backend/parse/packages_specialist_parse.dart';
import 'package:ultimate_salon_owner_flutter/app/backend/parse/payment_parse.dart';
import 'package:ultimate_salon_owner_flutter/app/backend/services/payment_socket_service.dart';
import 'package:ultimate_salon_owner_flutter/app/backend/services/connectivity_service.dart';
import 'package:ultimate_salon_owner_flutter/app/backend/parse/premium_parse.dart';
import 'package:ultimate_salon_owner_flutter/app/backend/parse/upgrade_parse.dart';
import 'package:ultimate_salon_owner_flutter/app/backend/parse/previous_appointments_parse.dart';
import 'package:ultimate_salon_owner_flutter/app/backend/parse/product_order_details_parse.dart';
import 'package:ultimate_salon_owner_flutter/app/backend/parse/register_categories_parse.dart';
import 'package:ultimate_salon_owner_flutter/app/backend/parse/salon_categories_parse.dart';
import 'package:ultimate_salon_owner_flutter/app/backend/parse/add_packages_parse.dart';
import 'package:ultimate_salon_owner_flutter/app/backend/parse/add_stylist_parse.dart';
import 'package:ultimate_salon_owner_flutter/app/backend/parse/app_pages_parse.dart';
import 'package:ultimate_salon_owner_flutter/app/backend/parse/appointment_parse.dart';
import 'package:ultimate_salon_owner_flutter/app/backend/parse/calendar_parse.dart';
import 'package:ultimate_salon_owner_flutter/app/backend/parse/chat_parse.dart';
import 'package:ultimate_salon_owner_flutter/app/backend/parse/contact_us_parse.dart';
import 'package:ultimate_salon_owner_flutter/app/backend/parse/create_products_parse.dart';
import 'package:ultimate_salon_owner_flutter/app/backend/parse/profile_categories_parser.dart';
import 'package:ultimate_salon_owner_flutter/app/backend/parse/gallary_parse.dart';
import 'package:ultimate_salon_owner_flutter/app/backend/parse/history_parse.dart';
import 'package:ultimate_salon_owner_flutter/app/backend/parse/inbox_parse.dart';
import 'package:ultimate_salon_owner_flutter/app/backend/parse/locale_parse.dart';
import 'package:ultimate_salon_owner_flutter/app/backend/parse/languages_parse.dart';
import 'package:ultimate_salon_owner_flutter/app/controller/locale_controller.dart';
import 'package:ultimate_salon_owner_flutter/app/backend/parse/login_parse.dart';
import 'package:ultimate_salon_owner_flutter/app/backend/parse/order_details_parse.dart';
import 'package:ultimate_salon_owner_flutter/app/backend/parse/packages_parse.dart';
import 'package:ultimate_salon_owner_flutter/app/backend/parse/products_parse.dart';
import 'package:ultimate_salon_owner_flutter/app/backend/parse/profile_parse.dart';
import 'package:ultimate_salon_owner_flutter/app/backend/parse/review_parse.dart';
import 'package:ultimate_salon_owner_flutter/app/backend/parse/packages_categories.dart';
import 'package:ultimate_salon_owner_flutter/app/backend/parse/service_categories_parse.dart';
import 'package:ultimate_salon_owner_flutter/app/backend/parse/service_names_parse.dart';
import 'package:ultimate_salon_owner_flutter/app/backend/parse/services_parse.dart';
import 'package:ultimate_salon_owner_flutter/app/backend/parse/slot_parse.dart';
import 'package:ultimate_salon_owner_flutter/app/backend/parse/splash_parse.dart';
import 'package:ultimate_salon_owner_flutter/app/backend/parse/stylist_categories_parse.dart';
import 'package:ultimate_salon_owner_flutter/app/backend/parse/shop_categories_parse.dart';
import 'package:ultimate_salon_owner_flutter/app/backend/parse/shop_subcategories_parse.dart';
import 'package:ultimate_salon_owner_flutter/app/backend/parse/signup_parse.dart';
import 'package:ultimate_salon_owner_flutter/app/backend/parse/stylist_parse.dart';
import 'package:ultimate_salon_owner_flutter/app/backend/parse/tabs_parse.dart';
import 'package:ultimate_salon_owner_flutter/app/backend/parse/verify_parse.dart';
import 'package:ultimate_salon_owner_flutter/app/backend/parse/withdrawals_parse.dart';
import 'package:ultimate_salon_owner_flutter/app/controller/previous_appointments_controller.dart';
import 'package:ultimate_salon_owner_flutter/app/env.dart';
import 'package:ultimate_salon_owner_flutter/app/helper/shared_pref.dart';

import '../backend/parse/facilities_parse.dart';
import '../backend/parse/holiday_parse.dart';

class MainBinding extends Bindings {
  @override
  Future<void> dependencies() async {
    final sharedPref = await SharedPreferences.getInstance();
    Get.put(
      SharedPreferencesManager(sharedPreferences: sharedPref),
      permanent: true,
    );

    Get.lazyPut(() => ApiService(
          appBaseUrl: Environments.apiBaseURL,
          sharedPreferencesManager: Get.find<SharedPreferencesManager>(),
        ));

    Get.put(
      LocaleController(
        parser: LocaleParser(
          apiService: Get.find<ApiService>(),
          sharedPreferencesManager: Get.find<SharedPreferencesManager>(),
        ),
        prefs: Get.find<SharedPreferencesManager>(),
      ),
      permanent: true,
    );

    Get.lazyPut(
      () => PaymentParser(
        apiService: Get.find(),
        sharedPreferencesManager: Get.find(),
      ),
      fenix: true,
    );

    Get.put(
      PaymentSocketService(
        parser: Get.find<PaymentParser>(),
        prefs: Get.find<SharedPreferencesManager>(),
      ),
      permanent: true,
    );

    await Get.putAsync<ConnectivityService>(
      () async => ConnectivityService().init(),
      permanent: true,
    );

    // Parser LazyLoad

    Get.lazyPut(
        () => LoginParser(
            apiService: Get.find(), sharedPreferencesManager: Get.find()),
        fenix: true);

    Get.lazyPut(
        () => VerifyParser(
            apiService: Get.find(), sharedPreferencesManager: Get.find()),
        fenix: true);

    Get.lazyPut(
        () => SignUpParser(
            apiService: Get.find(), sharedPreferencesManager: Get.find()),
        fenix: true);

    Get.lazyPut(
        () => TabsParser(
            apiService: Get.find(), sharedPreferencesManager: Get.find()),
        fenix: true);

    Get.lazyPut(
        () => AppointmentParser(
            apiService: Get.find(), sharedPreferencesManager: Get.find()),
        fenix: true);

    Get.lazyPut(
        () => CalendarsParser(
            apiService: Get.find(), sharedPreferencesManager: Get.find()),
        fenix: true);

    Get.lazyPut(
        () => InboxParser(
            apiService: Get.find(), sharedPreferencesManager: Get.find()),
        fenix: true);

    Get.lazyPut(
        () => ProfileParser(
            apiService: Get.find(), sharedPreferencesManager: Get.find()),
        fenix: true);

    Get.lazyPut(
        () => OrderDetailsParser(
            apiService: Get.find(), sharedPreferencesManager: Get.find()),
        fenix: true);

    Get.lazyPut(
        () => ChatParser(
            apiService: Get.find(), sharedPreferencesManager: Get.find()),
        fenix: true);

    Get.lazyPut(
        () => HistoryParser(
            apiService: Get.find(), sharedPreferencesManager: Get.find()),
        fenix: true);

    Get.lazyPut(
        () => StylistParser(
            apiService: Get.find(), sharedPreferencesManager: Get.find()),
        fenix: true);

    Get.lazyPut(
        () => AddStylistParser(
            apiService: Get.find(), sharedPreferencesManager: Get.find()),
        fenix: true);

    Get.lazyPut(
        () => StylistCategoriesParser(
            apiService: Get.find(), sharedPreferencesManager: Get.find()),
        fenix: true);

    Get.lazyPut(
        () => ProfileCategoriesParse(
            apiService: Get.find(), sharedPreferencesManager: Get.find()),
        fenix: true);

    Get.lazyPut(
        () => GallaryParser(
            apiService: Get.find(), sharedPreferencesManager: Get.find()),
        fenix: true);

    Get.lazyPut(
        () => ReviewParser(
            apiService: Get.find(), sharedPreferencesManager: Get.find()),
        fenix: true);

    Get.lazyPut(
        () => LanguagesParser(
            apiService: Get.find(), sharedPreferencesManager: Get.find()),
        fenix: true);

    Get.lazyPut(
        () => ContactUsParser(
            apiService: Get.find(), sharedPreferencesManager: Get.find()),
        fenix: true);

    Get.lazyPut(
        () => AppPagesParser(
            apiService: Get.find(), sharedPreferencesManager: Get.find()),
        fenix: true);

    Get.lazyPut(
        () => PackagesParser(
            apiService: Get.find(), sharedPreferencesManager: Get.find()),
        fenix: true);

    Get.lazyPut(
        () => AddPackagesParser(
            apiService: Get.find(), sharedPreferencesManager: Get.find()),
        fenix: true);

    Get.lazyPut(
        () => PackagesCategoriesParser(
            apiService: Get.find(), sharedPreferencesManager: Get.find()),
        fenix: true);

    Get.lazyPut(
        () => ProductsParser(
            apiService: Get.find(), sharedPreferencesManager: Get.find()),
        fenix: true);

    Get.lazyPut(
        () => CreateProductsParser(
            apiService: Get.find(), sharedPreferencesManager: Get.find()),
        fenix: true);

    Get.lazyPut(
        () => ShopCategoriesParser(
            apiService: Get.find(), sharedPreferencesManager: Get.find()),
        fenix: true);

    Get.lazyPut(
        () => ShopSubCategoriesParser(
            apiService: Get.find(), sharedPreferencesManager: Get.find()),
        fenix: true);

    Get.lazyPut(
        () => SalonCategoriesParser(
            apiService: Get.find(), sharedPreferencesManager: Get.find()),
        fenix: true);

    Get.lazyPut(
        () => CitiesCategoriesParser(
            apiService: Get.find(), sharedPreferencesManager: Get.find()),
        fenix: true);

    Get.lazyPut(
        () => AddTimingParser(
            apiService: Get.find(), sharedPreferencesManager: Get.find()),
        fenix: true);

    Get.lazyPut(
        () => ComplaintParser(
            apiService: Get.find(), sharedPreferencesManager: Get.find()),
        fenix: true);

    Get.lazyPut(
        () => SlotParser(
            apiService: Get.find(), sharedPreferencesManager: Get.find()),
        fenix: true);

    Get.lazyPut(
        () => AddSlotParser(
            apiService: Get.find(), sharedPreferencesManager: Get.find()),
        fenix: true);

    Get.lazyPut(
        () => AdsPublishParser(
            apiService: Get.find(), sharedPreferencesManager: Get.find()),
        fenix: true);

    Get.lazyPut(
        () => AdsManagingParser(
            apiService: Get.find(), sharedPreferencesManager: Get.find()),
        fenix: true);

    Get.lazyPut(
        () => CouponsParser(
            apiService: Get.find(), sharedPreferencesManager: Get.find()),
        fenix: true);

    Get.lazyPut(
        () => TimedOffersParser(
            apiService: Get.find(), sharedPreferencesManager: Get.find()),
        fenix: true);

    Get.lazyPut(
        () => ConnectLinksParser(
            apiService: Get.find(), sharedPreferencesManager: Get.find()),
        fenix: true);

    Get.lazyPut(
        () => WithdrawalsParser(
            apiService: Get.find(), sharedPreferencesManager: Get.find()),
        fenix: true);

    Get.lazyPut(
        () => AddServicesParser(
            apiService: Get.find(), sharedPreferencesManager: Get.find()),
        fenix: true);

    Get.lazyPut(
        () => ServicesParser(
            apiService: Get.find(), sharedPreferencesManager: Get.find()),
        fenix: true);

    Get.lazyPut(
        () => ServicesCategorisParser(
            apiService: Get.find(), sharedPreferencesManager: Get.find()),
        fenix: true);

    Get.lazyPut(
        () => FacilitiesParser(
            apiService: Get.find(), sharedPreferencesManager: Get.find()),
        fenix: true);

    Get.lazyPut(
        () => HolidayParser(
            apiService: Get.find(), sharedPreferencesManager: Get.find()),
        fenix: true);

    Get.lazyPut(
        () => ServicesNamesParser(
            apiService: Get.find(), sharedPreferencesManager: Get.find()),
        fenix: true);

    Get.lazyPut(
        () => PackagesSpecialistParser(
            apiService: Get.find(), sharedPreferencesManager: Get.find()),
        fenix: true);

    Get.lazyPut(
        () => IndividualProfileParser(
            apiService: Get.find(), sharedPreferencesManager: Get.find()),
        fenix: true);

    Get.lazyPut(
        () => IndividualProfileCategoriesParser(
            apiService: Get.find(), sharedPreferencesManager: Get.find()),
        fenix: true);

    Get.lazyPut(
        () => IndividualCitiesParser(
            apiService: Get.find(), sharedPreferencesManager: Get.find()),
        fenix: true);

    Get.lazyPut(
        () => SplashParser(
            apiService: Get.find(), sharedPreferencesManager: Get.find()),
        fenix: true);

    Get.lazyPut(
        () => AnalyticsParser(
            apiService: Get.find(), sharedPreferencesManager: Get.find()),
        fenix: true);

    Get.lazyPut(
        () => CancelAllParser(
            apiService: Get.find(), sharedPreferencesManager: Get.find()),
        fenix: true);

    Get.lazyPut(
        () => FirebaseParser(
            apiService: Get.find(), sharedPreferencesManager: Get.find()),
        fenix: true);

    Get.lazyPut(
        () => PremiumParser(
            apiService: Get.find(), sharedPreferencesManager: Get.find()),
        fenix: true);

    Get.lazyPut(
        () => UpgradeParser(
            apiService: Get.find(), sharedPreferencesManager: Get.find()),
        fenix: true);

    Get.lazyPut(
        () => PreviousAppointmentsParser(
            apiService: Get.find(), sharedPreferencesManager: Get.find()),
        fenix: true);

    Get.lazyPut(
        () => ProductOrderDetailsParse(
            apiService: Get.find(), sharedPreferencesManager: Get.find()),
        fenix: true);

    Get.lazyPut(
        () => RegisterCategoriesParser(
            apiService: Get.find(), sharedPreferencesManager: Get.find()),
        fenix: true);

    Get.lazyPut(
        () => NotificationParser(
            apiService: Get.find(), sharedPreferencesManager: Get.find()),
        fenix: true);

    Get.lazyPut(() => PreviousAppointmentController(parser: Get.find()));
  }
}

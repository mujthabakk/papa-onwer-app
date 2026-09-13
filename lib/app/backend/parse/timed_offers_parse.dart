import 'package:ultimate_salon_owner_flutter/app/backend/api/api.dart';
import 'package:ultimate_salon_owner_flutter/app/helper/shared_pref.dart';
import 'package:get/get.dart';
import 'package:ultimate_salon_owner_flutter/app/util/constants.dart';

class TimedOffersParser {
  static const String _getPartnerCampaigns =
      'api/v1/timed_offers/getPartnerCampaigns';
  static const String _partnerCreate = 'api/v1/timed_offers/partnerCreate';
  static const String _partnerUpdate = 'api/v1/timed_offers/partnerUpdate';
  static const String _getPartnerItems = 'api/v1/timed_offers/getPartnerItems';
  static const String _updateItem = 'api/v1/timed_offers/updateItem';
  static const String _removeItem = 'api/v1/timed_offers/removeItem';

  final SharedPreferencesManager sharedPreferencesManager;
  final ApiService apiService;

  TimedOffersParser(
      {required this.sharedPreferencesManager, required this.apiService});

  String get token => sharedPreferencesManager.getString('token') ?? '';

  int get uid => int.tryParse(getUID()) ?? 0;

  Future<Response> getPartnerCampaigns() async {
    return apiService.postPrivate(
      _getPartnerCampaigns,
      {"uid": uid},
      token,
    );
  }

  Future<Response> getPartnerServices() async {
    return apiService.postPrivate(
      AppConstants.couponsGetPartnerServices,
      {"uid": uid},
      token,
    );
  }

  Future<Response> getPartnerItems(int campaignId) async {
    return apiService.postPrivate(
      _getPartnerItems,
      {"uid": uid, "campaign_id": campaignId},
      token,
    );
  }

  Future<Response> partnerCreate(dynamic body) async {
    return apiService.postPrivate(_partnerCreate, body, token);
  }

  Future<Response> partnerUpdate(dynamic body) async {
    return apiService.postPrivate(_partnerUpdate, body, token);
  }

  Future<Response> updateItem(dynamic body) async {
    return apiService.postPrivate(_updateItem, body, token);
  }

  Future<Response> removeItem(dynamic body) async {
    return apiService.postPrivate(_removeItem, body, token);
  }

  String getUID() {
    return sharedPreferencesManager.getString('uid') ?? '0';
  }
}

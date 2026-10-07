import 'package:image_picker/image_picker.dart';
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
  static const String _getPartnerOffer = 'api/v1/timed_offers/getPartnerOffer';
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

  Future<Response> getPartnerOffer({int? campaignId}) async {
    final query = campaignId == null
        ? '?uid=$uid'
        : '?uid=$uid&campaign_id=$campaignId';
    final getRes =
        await apiService.getPrivate('$_getPartnerOffer$query', token);
    if (getRes.statusCode == 200) return getRes;
    return apiService.postPrivate(
      _getPartnerOffer,
      {
        "uid": uid,
        if (campaignId != null) "campaign_id": campaignId,
      },
      token,
    );
  }

  Future<Response> partnerCreate(dynamic body, {XFile? image}) async {
    if (image != null) {
      return apiService.postPrivateMultipart(
        _partnerCreate,
        Map<String, dynamic>.from(body),
        token,
        file: image,
      );
    }
    return apiService.postPrivate(_partnerCreate, body, token);
  }

  Future<Response> partnerUpdate(dynamic body, {XFile? image}) async {
    if (image != null) {
      return apiService.postPrivateMultipart(
        _partnerUpdate,
        Map<String, dynamic>.from(body),
        token,
        file: image,
      );
    }
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

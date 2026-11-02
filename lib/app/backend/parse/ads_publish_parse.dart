import 'package:image_picker/image_picker.dart';
import 'package:ultimate_salon_owner_flutter/app/backend/api/api.dart';
import 'package:ultimate_salon_owner_flutter/app/helper/shared_pref.dart';
import 'package:get/get.dart';
import 'package:ultimate_salon_owner_flutter/app/util/constants.dart';

class AdsPublishParser {
  final SharedPreferencesManager sharedPreferencesManager;
  final ApiService apiService;

  AdsPublishParser(
      {required this.sharedPreferencesManager, required this.apiService});

  String get token => sharedPreferencesManager.getString('token') ?? '';

  Future<Response> onSubmit(dynamic body) async {
    var response =
        await apiService.postPrivate(AppConstants.createAds, body, token);
    if (response.statusCode == 200) return response;
    return apiService.postPrivate(AppConstants.partnerAdsCreate, body, token);
  }

  int? getCityId() {
    final cid = sharedPreferencesManager.getString('cid') ??
        sharedPreferencesManager.getString('city_id');
    if (cid == null || cid.isEmpty || cid == 'null') return null;
    return int.tryParse(cid);
  }

  Future<int?> resolveCityId() async {
    final cached = getCityId();
    if (cached != null && cached > 0) return cached;
    final uid = getUID();
    final endpoint = getType()
        ? AppConstants.getSalonById
        : AppConstants.getIndividualById;
    final response = await apiService.postPrivate(endpoint, {'id': uid}, token);
    if (response.statusCode != 200) return null;
    final data = response.body['data'] ?? response.body['salon'] ?? response.body;
    if (data is! Map) return null;
    final raw = data['cid'] ?? data['city_id'];
    final parsed = int.tryParse('${raw ?? ''}');
    if (parsed == null || parsed <= 0) return null;
    sharedPreferencesManager.putString('cid', parsed.toString());
    sharedPreferencesManager.putString('city_id', parsed.toString());
    return parsed;
  }

  Future<Response> getServiceByID(var body) async {
    var response = await apiService.postPrivate(AppConstants.getServiceByID,
        body, sharedPreferencesManager.getString('token') ?? '');
    return response;
  }

  Future<Response> onUpdateService(var body) async {
    var response = await apiService.postPrivate(AppConstants.updateService,
        body, sharedPreferencesManager.getString('token') ?? '');
    return response;
  }

  Future<Response> uploadImage(XFile data) async {
    return await apiService
        .uploadFiles(AppConstants.uploadImage, [MultipartBody('image', data)]);
  }

  String getUID() {
    return sharedPreferencesManager.getString('uid') ?? '0';
  }

  bool getType() {
    return sharedPreferencesManager.getString('type') == 'salon' ? true : false;
  }
}

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ultimate_salon_owner_flutter/app/backend/api/handler.dart';
import 'package:ultimate_salon_owner_flutter/app/backend/models/coupons_model.dart';
import 'package:ultimate_salon_owner_flutter/app/backend/models/timed_offer_model.dart';
import 'package:ultimate_salon_owner_flutter/app/backend/parse/timed_offers_parse.dart';
import 'package:ultimate_salon_owner_flutter/app/util/app_loader.dart';
import 'package:ultimate_salon_owner_flutter/app/util/toast.dart';

class TimedOffersController extends GetxController implements GetxService {
  final TimedOffersParser parser;

  var isLoading = true.obs;
  var loadingItems = false.obs;
  var loadingServices = false.obs;
  var campaigns = <TimedCampaignModel>[].obs;
  var campaignItems = <TimedOfferItemModel>[].obs;
  var partnerServices = <OfferServiceModel>[].obs;
  TimedCampaignModel? selectedCampaign;
  TimedPartnerOfferModel? partnerOffer;

  TimedOffersController({required this.parser});

  @override
  void onInit() {
    super.onInit();
    fetchCampaigns();
    fetchPartnerServices();
  }

  Future<void> fetchCampaigns() async {
    isLoading.value = true;
    try {
      final response = await parser.getPartnerCampaigns();
      if (response.statusCode == 200 && response.body['data'] is List) {
        campaigns.value = (response.body['data'] as List)
            .whereType<Map>()
            .map((item) =>
                TimedCampaignModel.fromJson(Map<String, dynamic>.from(item)))
            .toList();
        if (selectedCampaign != null) {
          selectedCampaign = campaigns.firstWhereOrNull(
                  (item) => item.id == selectedCampaign!.id) ??
              selectedCampaign;
        }
        if (partnerOffer != null) {
          _syncCampaignDiscount(partnerOffer!);
        }
      } else {
        Get.snackbar('Error', 'Failed to fetch limited offers',
            backgroundColor: Colors.red, snackPosition: SnackPosition.BOTTOM);
      }
    } catch (e) {
      Get.snackbar('Error', e.toString());
    } finally {
      isLoading.value = false;
      update();
    }
  }

  Future<void> fetchPartnerServices() async {
    loadingServices.value = true;
    try {
      final response = await parser.getPartnerServices();
      if (response.statusCode == 200 && response.body['data'] is List) {
        partnerServices.value = (response.body['data'] as List)
            .whereType<Map>()
            .map((item) =>
                OfferServiceModel.fromJson(Map<String, dynamic>.from(item)))
            .where((service) => service.status == 1)
            .toList();
      }
    } catch (_) {
      partnerServices.clear();
    } finally {
      loadingServices.value = false;
      update();
    }
  }

  Future<void> openCampaign(TimedCampaignModel campaign) async {
    selectedCampaign = campaign;
    partnerOffer = null;
    campaignItems.clear();
    update();
    await fetchCampaignItems(campaign.id);
  }

  Future<void> fetchCampaignItems(int campaignId) async {
    loadingItems.value = true;
    update();
    try {
      final response = await parser.getPartnerItems(campaignId);
      if (response.statusCode == 200 && response.body['data'] is List) {
        campaignItems.value = (response.body['data'] as List)
            .whereType<Map>()
            .map((item) =>
                TimedOfferItemModel.fromJson(Map<String, dynamic>.from(item)))
            .toList();
      } else if (response.statusCode == 200 && response.body['data'] is Map) {
        partnerOffer = TimedPartnerOfferModel.fromJson(
            Map<String, dynamic>.from(response.body['data']));
        campaignItems.value = partnerOffer!.services
            .map((service) => TimedOfferItemModel(
                  id: service.id,
                  name: service.name,
                  image: '',
                  duration: service.duration,
                  originalPrice: service.price,
                  offerPrice: service.price,
                  amount: service.price,
                ))
            .toList();
      }
    } catch (_) {
      campaignItems.clear();
    } finally {
      loadingItems.value = false;
      update();
    }
  }

  Map<String, dynamic> _offerBody(
    TimedPartnerOfferModel offer, {
    bool includeServices = true,
  }) {
    return {
      "uid": parser.uid,
      "campaign_id": offer.campaignId,
      if (offer.name.isNotEmpty) "name": offer.name,
      if (offer.shortDescription.isNotEmpty)
        "short_descriptions": offer.shortDescription,
      if (offer.code.isNotEmpty) "code": offer.code,
      "type": offer.type,
      if (offer.discount > 0) "discount": offer.discount,
      if (offer.upto > 0) "upto": offer.upto,
      if (offer.startDate.isNotEmpty) "start_date": offer.startDate,
      if (offer.expire.isNotEmpty) "expire": offer.expire,
      if (offer.startTime.isNotEmpty) "start_time": offer.startTime,
      if (offer.endTime.isNotEmpty) "end_time": offer.endTime,
      if (offer.maxUsage > 0) "max_usage": offer.maxUsage,
      "min_cart_value": 100,
      if (includeServices) "service_ids": offer.serviceIdsPayload,
    };
  }

  Future<T> _withLoader<T>(Future<T> Function() action) async {
    return AppLoader.run(action);
  }

  void _applyOfferResponse(dynamic data, {String? message}) {
    if (data is Map) {
      partnerOffer = TimedPartnerOfferModel.fromJson(
          Map<String, dynamic>.from(data));
      _syncCampaignDiscount(partnerOffer!);
    }
    if (message != null && message.isNotEmpty) {
      successToast(message);
    }
  }

  void _syncCampaignDiscount(TimedPartnerOfferModel offer) {
    final index = campaigns.indexWhere((item) => item.id == offer.campaignId);
    if (index == -1) return;
    campaigns[index] = campaigns[index].copyWith(
      discountType: offer.isPercent ? 'percentage' : 'flat',
      discountValue: offer.discount,
    );
    campaigns.refresh();
    if (selectedCampaign?.id == offer.campaignId) {
      selectedCampaign = campaigns[index];
    }
  }

  Future<bool> createPartnerOffer(TimedPartnerOfferModel offer) async {
    return _withLoader(() async {
      final response = await parser.partnerCreate(_offerBody(offer));
      if (response.statusCode == 200 && response.body['success'] == true) {
        _applyOfferResponse(response.body['data']);
        await fetchCampaigns();
        await fetchCampaignItems(offer.campaignId);
        return true;
      }
      ApiChecker.checkApi(response);
      return false;
    });
  }

  Future<bool> updatePartnerOffer(
    TimedPartnerOfferModel offer, {
    bool includeServices = true,
  }) async {
    return _withLoader(() async {
      final response = await parser
          .partnerUpdate(_offerBody(offer, includeServices: includeServices));
      if (response.statusCode == 200 && response.body['success'] == true) {
        _applyOfferResponse(response.body['data']);
        await fetchCampaigns();
        await fetchCampaignItems(offer.campaignId);
        return true;
      }
      ApiChecker.checkApi(response);
      return false;
    });
  }

  Future<void> togglePartnerStatus(TimedCampaignModel campaign) async {
    final nextStatus = campaign.status == 1 ? 0 : 1;
    final response = await parser.partnerUpdate({
      "uid": parser.uid,
      "campaign_id": campaign.id,
      "status": nextStatus,
    });
    if (response.statusCode == 200 && response.body['success'] == true) {
      final index = campaigns.indexWhere((item) => item.id == campaign.id);
      if (index != -1) {
        campaigns[index] = campaign.copyWith(status: nextStatus);
        campaigns.refresh();
      }
      if (selectedCampaign?.id == campaign.id) {
        selectedCampaign = selectedCampaign!.copyWith(status: nextStatus);
      }
      successToast(nextStatus == 1 ? 'Offer activated' : 'Offer deactivated');
      update();
    } else {
      ApiChecker.checkApi(response);
    }
  }

  Future<bool> updateItemPrice({
    required int itemId,
    required num offerPrice,
    int? stock,
  }) async {
    return _withLoader(() async {
      final body = {
        "id": itemId,
        "uid": parser.uid,
        "offer_price": offerPrice,
        if (stock != null) "stock": stock,
      };
      final response = await parser.updateItem(body);
      if (response.statusCode == 200 && response.body['success'] == true) {
        successToast('Item updated');
        if (selectedCampaign != null) {
          await fetchCampaignItems(selectedCampaign!.id);
        }
        return true;
      }
      ApiChecker.checkApi(response);
      return false;
    });
  }

  Future<void> removeItem(int itemId) async {
    final success = await _withLoader(() async {
      final response = await parser.removeItem({
        "id": itemId,
        "uid": parser.uid,
      });
      if (response.statusCode == 200 && response.body['success'] == true) {
        campaignItems.removeWhere((item) => item.id == itemId);
        if (selectedCampaign != null) {
          selectedCampaign = selectedCampaign!
              .copyWith(myItemsCount: campaignItems.length);
          final index =
              campaigns.indexWhere((item) => item.id == selectedCampaign!.id);
          if (index != -1) {
            campaigns[index] = selectedCampaign!;
            campaigns.refresh();
          }
        }
        update();
        return true;
      }
      ApiChecker.checkApi(response);
      return false;
    });
    if (success) {
      Get.back(result: true);
    }
  }

  Set<int> matchedServiceIds() {
    final names = campaignItems.map((item) => item.name.toLowerCase()).toSet();
    return partnerServices
        .where((service) => names.contains(service.name.toLowerCase()))
        .map((service) => service.id)
        .toSet();
  }

  void onBack() {
    Navigator.of(Get.context as BuildContext).pop(true);
  }
}

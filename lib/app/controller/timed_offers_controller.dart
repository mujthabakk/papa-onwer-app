import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:ultimate_salon_owner_flutter/app/backend/api/handler.dart';
import 'package:ultimate_salon_owner_flutter/app/backend/models/coupons_model.dart';
import 'package:ultimate_salon_owner_flutter/app/backend/models/timed_offer_model.dart';
import 'package:ultimate_salon_owner_flutter/app/backend/parse/timed_offers_parse.dart';
import 'package:ultimate_salon_owner_flutter/app/helper/shared_pref.dart';
import 'package:ultimate_salon_owner_flutter/app/util/app_loader.dart';
import 'package:ultimate_salon_owner_flutter/app/util/currency_helper.dart';
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
      if (response.statusCode == 200 && response.body is Map) {
        final body = Map<String, dynamic>.from(response.body);
        final code = body['currencyCode']?.toString() ??
            body['currency']?.toString();
        final symbol = body['currencySymbol']?.toString();
        if (code != null &&
            code.isNotEmpty &&
            Get.isRegistered<SharedPreferencesManager>()) {
          CurrencyHelper.save(
            Get.find<SharedPreferencesManager>(),
            CurrencyHelper.fromCurrencyCode(code, symbol: symbol),
          );
        }
        if (body['data'] is List) {
          partnerServices.value = (body['data'] as List)
              .whereType<Map>()
              .map((item) =>
                  OfferServiceModel.fromJson(Map<String, dynamic>.from(item)))
              .where((service) => service.status == 1)
              .toList();
        }
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
      if (response.statusCode == 200 && response.body is Map) {
        final body = Map<String, dynamic>.from(response.body);
        _applyPartnerOfferFromBody(body, campaignId);
        final data = body['data'];
        if (data is List) {
          final maps = data
              .whereType<Map>()
              .map((item) => Map<String, dynamic>.from(item))
              .toList();
          if (_isWrappedOfferList(maps)) {
            _applyPartnerOfferList(maps, campaignId);
          } else {
            campaignItems.value = maps
                .map((item) => TimedOfferItemModel.fromJson(item))
                .toList();
          }
        } else if (data is Map) {
          final map = Map<String, dynamic>.from(data);
          partnerOffer ??= TimedPartnerOfferModel.fromJson(map);
          final items = map['items'] ?? map['services'] ?? map['data'];
          if (items is List) {
            campaignItems.value = items
                .whereType<Map>()
                .map((item) => TimedOfferItemModel.fromJson(
                    Map<String, dynamic>.from(item)))
                .toList();
          } else if (partnerOffer!.services.isNotEmpty) {
            campaignItems.value = partnerOffer!.services
                .map((service) => TimedOfferItemModel(
                      id: service.id,
                      name: service.name,
                      image: service.cover,
                      duration: service.duration.round(),
                      originalPrice: service.price,
                      offerPrice: service.offerPrice,
                      amount: service.offerPrice,
                      type: service.offerType,
                      discount: service.discount,
                      discountText: service.discountText,
                      startDate: service.startDate,
                      expire: service.expire,
                    ))
                .toList();
          }
        }
      }
      await _loadPartnerOfferList(campaignId);
    } catch (_) {
      campaignItems.clear();
    } finally {
      loadingItems.value = false;
      update();
    }
  }

  Future<void> _loadPartnerOfferList(int campaignId) async {
    try {
      final response = await parser.getPartnerOffer(campaignId: campaignId);
      if (response.statusCode != 200 || response.body is! Map) return;
      final data = (response.body as Map)['data'];
      if (data is! List) return;
      final maps = data
          .whereType<Map>()
          .map((item) => Map<String, dynamic>.from(item))
          .toList();
      if (_isWrappedOfferList(maps)) {
        _applyPartnerOfferList(maps, campaignId);
      }
    } catch (_) {}
  }

  bool _isWrappedOfferList(List<Map<String, dynamic>> maps) {
    if (maps.isEmpty) return false;
    final first = maps.first;
    return first['data'] is Map || first.containsKey('services');
  }

  void _applyPartnerOfferList(List<Map<String, dynamic>> blocks, int campaignId) {
    final lines = <TimedOfferServiceLine>[];
    final items = <TimedOfferItemModel>[];
    String name = '';
    String shortDescription = '';
    String code = '';
    int maxUsage = 0;
    int status = 1;
    String image = '';
    String cover = '';

    for (final block in blocks) {
      final nested = block['data'] is Map
          ? Map<String, dynamic>.from(block['data'] as Map)
          : <String, dynamic>{};
      if (name.isEmpty) name = nested['name']?.toString() ?? '';
      if (shortDescription.isEmpty) {
        shortDescription = nested['short_descriptions']?.toString() ?? '';
      }
      if (code.isEmpty) code = nested['code']?.toString() ?? '';
      if (image.isEmpty) {
        image = nested['image']?.toString() ?? nested['cover']?.toString() ?? '';
      }
      if (cover.isEmpty) {
        cover = nested['cover']?.toString() ?? nested['image']?.toString() ?? '';
      }
      if (maxUsage == 0) {
        maxUsage = int.tryParse('${nested['max_usage'] ?? 0}') ?? 0;
      }
      if (nested['status'] != null) {
        status = int.tryParse('${nested['status']}') ?? status;
      }
      final servicesRaw =
          block['services'] ?? block['items'] ?? nested['services'];
      final serviceMaps = servicesRaw is List
          ? servicesRaw.whereType<Map>().toList()
          : const <Map>[];
      final rows = serviceMaps.isNotEmpty
          ? serviceMaps
          : (nested.isNotEmpty ? [nested] : const <Map>[]);
      for (final raw in rows) {
        final map = Map<String, dynamic>.from(raw);
        map.putIfAbsent('type', () => nested['type']);
        map.putIfAbsent('discount', () => nested['discount']);
        map.putIfAbsent('start_date', () => nested['start_date']);
        map.putIfAbsent(
          'expire',
          () => nested['expire'] ?? nested['expire_date'] ?? nested['end_date'],
        );
        final line = TimedOfferServiceLine.fromJson(map);
        if (line.id <= 0) continue;
        lines.add(line);
        items.add(TimedOfferItemModel.fromJson(map));
      }
    }

    if (lines.isEmpty) return;
    partnerOffer = TimedPartnerOfferModel(
      campaignId: campaignId,
      name: name,
      shortDescription: shortDescription,
      code: code,
      maxUsage: maxUsage,
      status: status,
      serviceIds: lines.map((line) => line.id).toList(),
      serviceOffers: lines,
      image: image,
      cover: cover,
    );
    _syncCampaignDiscount(partnerOffer!);
    if (campaignItems.isNotEmpty) {
      campaignItems.value = campaignItems.map((existing) {
        TimedOfferServiceLine? line;
        TimedOfferItemModel? incoming;
        for (final item in items) {
          if (item.id == existing.id ||
              (item.name.isNotEmpty &&
                  item.name.toLowerCase() == existing.name.toLowerCase())) {
            incoming = item;
            break;
          }
        }
        for (final candidate in lines) {
          if (candidate.id == existing.id) {
            line = candidate;
            break;
          }
        }
        if (incoming == null && line == null) return existing;
        return TimedOfferItemModel(
          id: existing.id,
          name: existing.name,
          image: existing.image,
          duration: existing.duration,
          amount: existing.amount,
          offerPrice: existing.offerPrice,
          originalPrice: existing.originalPrice,
          stock: existing.stock,
          isSoldOut: existing.isSoldOut,
          canBuy: existing.canBuy,
          type: incoming?.type ?? line?.type ?? existing.type,
          discount: incoming?.discount ?? line?.discount ?? existing.discount,
          discountText: incoming?.discountText.isNotEmpty == true
              ? incoming!.discountText
              : existing.discountText,
          startDate: (incoming?.startDate ?? line?.startDate ?? existing.startDate),
          expire: (incoming?.expire ?? line?.expire ?? existing.expire),
          location: existing.location,
        );
      }).toList();
    } else if (items.isNotEmpty) {
      campaignItems.value = items;
    }
  }

  void _applyPartnerOfferFromBody(Map<String, dynamic> body, int campaignId) {
    Map<String, dynamic>? offer;
    final candidates = [
      body['offer'],
      body['partner_offer'],
      body['partnerOffer'],
      if (body['data'] is Map) (body['data'] as Map)['offer'],
      if (body['data'] is Map) (body['data'] as Map)['partner_offer'],
      if (body['data'] is Map) body['data'],
    ];
    for (final candidate in candidates) {
      if (candidate is Map &&
          (candidate.containsKey('max_usage') ||
              candidate.containsKey('max_users') ||
              candidate.containsKey('start_date') ||
              candidate.containsKey('expire') ||
              candidate.containsKey('expire_date') ||
              candidate.containsKey('name') ||
              candidate.containsKey('discount') ||
              candidate.containsKey('service_ids'))) {
        offer = Map<String, dynamic>.from(candidate);
        break;
      }
    }
    if (offer == null) return;
    offer.putIfAbsent('campaign_id', () => campaignId);
    partnerOffer = TimedPartnerOfferModel.fromJson(offer);
    _syncCampaignDiscount(partnerOffer!);
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
      if (offer.maxUsage > 0) "max_usage": offer.maxUsage,
      "min_cart_value": 100,
      if (includeServices)
        "service_ids": offer.serviceOffers.isNotEmpty
            ? offer.serviceOffers.map((line) => line.id).toList()
            : offer.serviceIdsPayload,
      if (includeServices && offer.serviceOffers.isNotEmpty)
        "services": offer.serviceOffers.map((line) => line.toJson()).toList(),
    };
  }

  Future<T> _withLoader<T>(Future<T> Function() action) async {
    return AppLoader.run(action);
  }

  void _applyOfferResponse(dynamic data, {String? message}) {
    if (data is List) {
      final maps = data
          .whereType<Map>()
          .map((item) => Map<String, dynamic>.from(item))
          .toList();
      if (_isWrappedOfferList(maps) && selectedCampaign != null) {
        _applyPartnerOfferList(maps, selectedCampaign!.id);
      }
    } else if (data is Map) {
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
      discountType: offer.campaignDiscountType,
      discountValue: offer.discount,
    );
    campaigns.refresh();
    if (selectedCampaign?.id == offer.campaignId) {
      selectedCampaign = campaigns[index];
    }
  }

  Future<bool> createPartnerOffer(
    TimedPartnerOfferModel offer, {
    XFile? image,
  }) async {
    return _withLoader(() async {
      final response =
          await parser.partnerCreate(_offerBody(offer), image: image);
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
    XFile? image,
  }) async {
    return _withLoader(() async {
      final response = await parser.partnerUpdate(
        _offerBody(offer, includeServices: includeServices),
        image: image,
      );
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
    await _withLoader(() async {
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
        successToast('Service removed');
        update();
        return true;
      }
      ApiChecker.checkApi(response);
      return false;
    });
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

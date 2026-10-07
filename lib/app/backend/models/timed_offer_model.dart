import 'package:ultimate_salon_owner_flutter/app/backend/models/coupons_model.dart';
import 'package:ultimate_salon_owner_flutter/app/util/currency_helper.dart';

class TimedCampaignModel {
  final int id;
  final String name;
  final String discountType;
  final num discountValue;
  final String scheduleType;
  final String dailyStartTime;
  final String dailyEndTime;
  final bool isLive;
  final bool hasEnded;
  final String statusText;
  final int myItemsCount;
  final int status;
  final String startDate;
  final String expireDate;
  final int maxUsage;
  final String image;
  final String cover;

  TimedCampaignModel({
    required this.id,
    required this.name,
    this.discountType = '',
    this.discountValue = 0,
    this.scheduleType = 'daily',
    this.dailyStartTime = '',
    this.dailyEndTime = '',
    this.isLive = false,
    this.hasEnded = false,
    this.statusText = '',
    this.myItemsCount = 0,
    this.status = 1,
    this.startDate = '',
    this.expireDate = '',
    this.maxUsage = 0,
    this.image = '',
    this.cover = '',
  });

  String get displayImage => _mediaUrl(image, cover);

  bool get hasJoined => myItemsCount > 0;

  String get displayDiscount {
    if (discountType.toLowerCase() == 'mixed') return 'Per service';
    return timedDiscountLabel(type: discountType, value: discountValue);
  }

  TimedCampaignModel copyWith({
    int? myItemsCount,
    int? status,
    String? discountType,
    num? discountValue,
  }) {
    return TimedCampaignModel(
      id: id,
      name: name,
      discountType: discountType ?? this.discountType,
      discountValue: discountValue ?? this.discountValue,
      scheduleType: scheduleType,
      dailyStartTime: dailyStartTime,
      dailyEndTime: dailyEndTime,
      isLive: isLive,
      hasEnded: hasEnded,
      statusText: statusText,
      myItemsCount: myItemsCount ?? this.myItemsCount,
      status: status ?? this.status,
      startDate: startDate,
      expireDate: expireDate,
      maxUsage: maxUsage,
      image: image,
      cover: cover,
    );
  }

  factory TimedCampaignModel.fromJson(Map<String, dynamic> json) {
    return TimedCampaignModel(
      id: _toInt(json['id']),
      name: json['name']?.toString() ?? '',
      discountType: _discountTypeString(json['discount_type'] ?? json['type']),
      discountValue: _toNum(json['discount_value'] ?? json['discount']),
      scheduleType: json['schedule_type']?.toString() ?? 'daily',
      dailyStartTime: json['daily_start_time']?.toString() ?? '',
      dailyEndTime: json['daily_end_time']?.toString() ?? '',
      isLive: _toBool(json['is_live']),
      hasEnded: _toBool(json['has_ended']),
      statusText: json['status_text']?.toString() ?? '',
      myItemsCount: _toInt(json['my_items_count']),
      status: _toInt(json['status'], 1),
      startDate: _dateOnly(
        json['start_date'] ?? json['from_date'] ?? json['valid_from'],
      ),
      expireDate: _dateOnly(
        json['expire'] ??
            json['expire_date'] ??
            json['expiry_date'] ??
            json['end_date'],
      ),
      maxUsage: _toInt(
        json['max_usage'] ?? json['max_users'] ?? json['max_user'],
      ),
      image: _mediaUrl(json['image'], json['cover']),
      cover: _mediaUrl(json['cover'], json['image']),
    );
  }
}

class TimedOfferLocation {
  final String address;
  final String lat;
  final String lng;

  TimedOfferLocation({
    this.address = '',
    this.lat = '',
    this.lng = '',
  });

  factory TimedOfferLocation.fromJson(Map<String, dynamic>? json) {
    if (json == null) return TimedOfferLocation();
    return TimedOfferLocation(
      address: json['address']?.toString() ?? '',
      lat: json['lat']?.toString() ?? '',
      lng: json['lng']?.toString() ?? '',
    );
  }
}

class TimedOfferItemModel {
  final int id;
  final String name;
  final String image;
  final int duration;
  final num amount;
  final num offerPrice;
  final num originalPrice;
  final int stock;
  final bool isSoldOut;
  final bool canBuy;
  final int type;
  final num discount;
  final String discountText;
  final String startDate;
  final String expire;
  final TimedOfferLocation location;

  TimedOfferItemModel({
    required this.id,
    required this.name,
    this.image = '',
    this.duration = 0,
    this.amount = 0,
    this.offerPrice = 0,
    this.originalPrice = 0,
    this.stock = 0,
    this.isSoldOut = false,
    this.canBuy = true,
    this.type = 1,
    this.discount = 0,
    this.discountText = '',
    this.startDate = '',
    this.expire = '',
    TimedOfferLocation? location,
  }) : location = location ?? TimedOfferLocation();

  num get displayPrice => offerPrice != 0 ? offerPrice : amount;

  factory TimedOfferItemModel.fromJson(Map<String, dynamic> json) {
    return TimedOfferItemModel(
      id: _toInt(json['id']),
      name: json['name']?.toString() ?? '',
      image: _mediaUrl(json['image'], json['cover']),
      duration: _toInt(json['duration']),
      amount: _toNum(json['amount']),
      offerPrice: _toNum(json['offer_price']),
      originalPrice: _toNum(json['original_price']),
      stock: _toInt(json['stock']),
      isSoldOut: _toBool(json['is_sold_out']),
      canBuy: _toBool(json['can_buy'], true),
      type: _discountTypeToInt(json['type'] ?? json['offer_type']),
      discount: _toNum(json['discount']),
      discountText: json['discount_text']?.toString() ?? '',
      startDate: _dateOnly(json['start_date'] ?? json['startDate']),
      expire: _dateOnly(
        json['expire'] ?? json['expire_date'] ?? json['end_date'],
      ),
      location: json['location'] is Map
          ? TimedOfferLocation.fromJson(
              Map<String, dynamic>.from(json['location']))
          : TimedOfferLocation(),
    );
  }
}

class TimedOfferSchedule {
  final String type;
  final String startTime;
  final String endTime;
  final String startDate;
  final String endDate;
  final String expireDate;

  TimedOfferSchedule({
    this.type = 'daily',
    this.startTime = '',
    this.endTime = '',
    this.startDate = '',
    this.endDate = '',
    this.expireDate = '',
  });

  factory TimedOfferSchedule.fromJson(Map<String, dynamic>? json) {
    if (json == null) return TimedOfferSchedule();
    return TimedOfferSchedule(
      type: json['type']?.toString() ?? 'daily',
      startTime: json['start_time']?.toString() ?? '',
      endTime: json['end_time']?.toString() ?? '',
      startDate: json['start_date']?.toString() ?? '',
      endDate: json['end_date']?.toString() ?? '',
      expireDate: json['expire_date']?.toString() ?? '',
    );
  }
}

class TimedOfferServiceLine {
  final int id;
  final int type;
  final num discount;
  final num offerPrice;
  final String startDate;
  final String expire;

  TimedOfferServiceLine({
    required this.id,
    this.type = 1,
    this.discount = 0,
    this.offerPrice = 0,
    this.startDate = '',
    this.expire = '',
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type == 2 ? 2 : 1,
      'discount': discount,
      if (startDate.isNotEmpty) 'start_date': startDate,
      if (expire.isNotEmpty) 'expire': expire,
    };
  }

  factory TimedOfferServiceLine.fromJson(Map<String, dynamic> json) {
    return TimedOfferServiceLine(
      id: _toInt(json['id'] ?? json['service_id']),
      type: _discountTypeToInt(json['type'] ?? json['offer_type']),
      discount: _toNum(json['discount'] ?? json['discount_value']),
      offerPrice: _toNum(json['offer_price']),
      startDate: _dateOnly(
        json['start_date'] ?? json['startDate'] ?? json['from_date'],
      ),
      expire: _dateOnly(
        json['expire'] ??
            json['expire_date'] ??
            json['end_date'] ??
            json['expiry_date'],
      ),
    );
  }
}

class TimedPartnerOfferModel {
  final int id;
  final int campaignId;
  final String name;
  final String shortDescription;
  final String code;
  final int type;
  final int discount;
  final int upto;
  final String startDate;
  final String expire;
  final String startTime;
  final String endTime;
  final int maxUsage;
  final int minCartValue;
  final int status;
  final bool applyAllServices;
  final List<int> serviceIds;
  final List<OfferServiceModel> services;
  final List<TimedOfferServiceLine> serviceOffers;
  final TimedOfferSchedule schedule;
  final String image;
  final String cover;

  TimedPartnerOfferModel({
    this.id = 0,
    required this.campaignId,
    this.name = '',
    this.shortDescription = '',
    this.code = '',
    this.type = 1,
    this.discount = 0,
    this.upto = 0,
    this.startDate = '',
    this.expire = '',
    this.startTime = '',
    this.endTime = '',
    this.maxUsage = 0,
    this.minCartValue = 0,
    this.status = 1,
    this.applyAllServices = false,
    this.serviceIds = const [],
    this.services = const [],
    this.serviceOffers = const [],
    this.image = '',
    this.cover = '',
    TimedOfferSchedule? schedule,
  }) : schedule = schedule ?? TimedOfferSchedule();

  String get displayImage => _mediaUrl(image, cover);

  bool get isPercent => type != 2;

  bool get hasMixedServiceOffers {
    final types = serviceOffers.map((line) => line.type == 2 ? 2 : 1).toSet();
    return types.length > 1;
  }

  String get campaignDiscountType {
    if (hasMixedServiceOffers) return 'mixed';
    if (serviceOffers.length == 1) {
      return serviceOffers.first.type == 2 ? 'flat' : 'percentage';
    }
    return isPercent ? 'percentage' : 'flat';
  }

  String get displayDiscount => timedDiscountLabel(
        type: campaignDiscountType,
        value: discount,
      );

  dynamic get serviceIdsPayload {
    if (applyAllServices) return 'ALL';
    return serviceIds;
  }

  factory TimedPartnerOfferModel.fromJson(Map<String, dynamic> json) {
    final rawIds = json['service_ids'];
    final applyAll = rawIds?.toString().toUpperCase() == 'ALL';
    return TimedPartnerOfferModel(
      id: _toInt(json['id']),
      campaignId: _toInt(json['campaign_id'] ?? json['id']),
      name: json['name']?.toString() ?? '',
      shortDescription: json['short_descriptions']?.toString() ?? '',
      code: json['code']?.toString() ?? '',
      type: _discountTypeToInt(json['discount_type'] ?? json['type']),
      discount: _toInt(json['discount_value'] ?? json['discount']),
      upto: _toInt(json['upto']),
      startDate: _dateOnly(
        json['start_date'] ??
            json['startDate'] ??
            json['from_date'] ??
            json['valid_from'] ??
            (json['schedule'] is Map
                ? (json['schedule'] as Map)['start_date']
                : null),
      ),
      expire: _dateOnly(
        json['expire'] ??
            json['expire_date'] ??
            json['expiry_date'] ??
            json['end_date'] ??
            json['valid_to'] ??
            json['to_date'] ??
            (json['schedule'] is Map
                ? ((json['schedule'] as Map)['expire_date'] ??
                    (json['schedule'] as Map)['end_date'] ??
                    (json['schedule'] as Map)['expire'])
                : null),
      ),
      startTime: _firstText(json, const [
        'start_time',
        'daily_start_time',
      ], nested: const ['schedule', 'start_time']),
      endTime: _firstText(json, const [
        'end_time',
        'daily_end_time',
      ], nested: const ['schedule', 'end_time']),
      maxUsage: _toInt(
        json['max_usage'] ??
            json['maxUsage'] ??
            json['max_users'] ??
            json['max_user'] ??
            json['usage_limit'] ??
            json['max_limit'],
      ),
      minCartValue: _toInt(json['min_cart_value']),
      status: _toInt(json['status'], 1),
      applyAllServices: applyAll,
      serviceIds: applyAll ? const [] : _parseServiceIds(rawIds),
      services: _parseServices(json['services'] ?? json['items']),
      serviceOffers: _parseServiceOffers(json['services'] ?? json['items']),
      image: _mediaUrl(json['image'], json['cover']),
      cover: _mediaUrl(json['cover'], json['image']),
      schedule: json['schedule'] is Map
          ? TimedOfferSchedule.fromJson(
              Map<String, dynamic>.from(json['schedule']))
          : TimedOfferSchedule(),
    );
  }

  TimedPartnerOfferModel copyWith({
    int? status,
    List<int>? serviceIds,
    bool? applyAllServices,
  }) {
    return TimedPartnerOfferModel(
      id: id,
      campaignId: campaignId,
      name: name,
      shortDescription: shortDescription,
      code: code,
      type: type,
      discount: discount,
      upto: upto,
      startDate: startDate,
      expire: expire,
      startTime: startTime,
      endTime: endTime,
      maxUsage: maxUsage,
      minCartValue: minCartValue,
      status: status ?? this.status,
      applyAllServices: applyAllServices ?? this.applyAllServices,
      serviceIds: serviceIds ?? this.serviceIds,
      services: services,
      serviceOffers: serviceOffers,
      image: image,
      cover: cover,
      schedule: schedule,
    );
  }
}

String _mediaUrl(dynamic image, [dynamic cover]) {
  for (final value in [image, cover]) {
    final text = value?.toString().trim() ?? '';
    if (text.isEmpty) continue;
    final lower = text.toLowerCase();
    if (lower == 'null' || lower == 'undefined' || lower == 'none') continue;
    return text;
  }
  return '';
}

String timedDiscountLabel({required String type, required num value}) {
  if (type.toLowerCase() == 'mixed') return 'Per service';
  if (value <= 0) return '';
  final amount = value % 1 == 0 ? value.toInt().toString() : value.toString();
  final kind = type.toLowerCase().trim();
  final isFlat =
      kind == 'flat' || kind == 'amount' || kind == 'fixed' || kind == '2';
  if (isFlat) return '${CurrencyHelper.format(value)} OFF';
  return '$amount% OFF';
}

int _discountTypeToInt(dynamic value) {
  if (value is num) {
    return value.toInt() == 2 ? 2 : 1;
  }
  final text = value?.toString().toLowerCase().trim() ?? '';
  if (text == 'flat' || text == 'amount' || text == 'fixed' || text == '2') {
    return 2;
  }
  return 1;
}

String _discountTypeString(dynamic value) {
  final text = value?.toString().toLowerCase().trim() ?? '';
  if (text == 'mixed') return 'mixed';
  return _discountTypeToInt(value) == 2 ? 'flat' : 'percentage';
}

int _toInt(dynamic value, [int fallback = 0]) {
  if (value == null) return fallback;
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.tryParse(value.toString()) ?? fallback;
}

String _firstText(
  Map<String, dynamic> json,
  List<String> keys, {
  List<String>? nested,
}) {
  for (final key in keys) {
    final value = json[key]?.toString().trim() ?? '';
    if (value.isNotEmpty && value.toLowerCase() != 'null') return value;
  }
  if (nested != null && nested.length >= 2 && json[nested[0]] is Map) {
    final inner = Map<String, dynamic>.from(json[nested[0]] as Map);
    final value = inner[nested[1]]?.toString().trim() ?? '';
    if (value.isNotEmpty && value.toLowerCase() != 'null') return value;
  }
  return '';
}

String _dateOnly(dynamic value) {
  final raw = value?.toString().trim() ?? '';
  if (raw.isEmpty || raw.toLowerCase() == 'null') return '';
  final parsed = DateTime.tryParse(raw);
  if (parsed != null) {
    final y = parsed.year.toString().padLeft(4, '0');
    final m = parsed.month.toString().padLeft(2, '0');
    final d = parsed.day.toString().padLeft(2, '0');
    return '$y-$m-$d';
  }
  final match = RegExp(r'(\d{4}-\d{2}-\d{2})').firstMatch(raw);
  return match?.group(1) ?? raw;
}

num _toNum(dynamic value, [num fallback = 0]) {
  if (value == null) return fallback;
  if (value is num) return value;
  return num.tryParse(value.toString()) ?? fallback;
}

bool _toBool(dynamic value, [bool fallback = false]) {
  if (value == null) return fallback;
  if (value is bool) return value;
  if (value is num) return value != 0;
  final text = value.toString().toLowerCase();
  if (text == 'true' || text == '1') return true;
  if (text == 'false' || text == '0') return false;
  return fallback;
}

List<int> _parseServiceIds(dynamic value) {
  if (value == null) return const [];
  if (value is List) {
    return value.map(_toInt).where((id) => id > 0).toList();
  }
  final text = value.toString().trim();
  if (text.isEmpty || text.toUpperCase() == 'ALL') return const [];
  return text
      .split(',')
      .map((item) => _toInt(item.trim()))
      .where((id) => id > 0)
      .toList();
}

List<OfferServiceModel> _parseServices(dynamic value) {
  if (value is! List) return const [];
  return value
      .whereType<Map>()
      .map((item) =>
          OfferServiceModel.fromJson(Map<String, dynamic>.from(item)))
      .toList();
}

List<TimedOfferServiceLine> _parseServiceOffers(dynamic value) {
  if (value is! List) return const [];
  return value
      .whereType<Map>()
      .map((item) =>
          TimedOfferServiceLine.fromJson(Map<String, dynamic>.from(item)))
      .where((item) => item.id > 0)
      .toList();
}

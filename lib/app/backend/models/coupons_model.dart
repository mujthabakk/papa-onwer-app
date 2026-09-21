class OfferPartnerModel {
  final int id;
  final String name;

  OfferPartnerModel({required this.id, required this.name});

  factory OfferPartnerModel.fromJson(Map<String, dynamic> json) {
    return OfferPartnerModel(
      id: _toInt(json['id']),
      name: json['name']?.toString() ?? '',
    );
  }
}

class OfferServiceModel {
  final int id;
  final int uid;
  final int serviceId;
  final String name;
  final double price;
  final double off;
  final double duration;
  final double discount;
  final int status;
  final int cateId;
  final String cover;

  OfferServiceModel({
    required this.id,
    this.uid = 0,
    this.serviceId = 0,
    required this.name,
    this.price = 0,
    this.off = 0,
    this.duration = 0,
    this.discount = 0,
    this.status = 1,
    this.cateId = 0,
    this.cover = '',
  });

  /// Discounted / offer price from API (`off`), else price after % discount.
  double get offerPrice {
    if (off > 0) return off;
    if (discount > 0 && price > 0) {
      return price - ((price * discount) / 100);
    }
    return price;
  }

  bool get hasDiscount =>
      discount > 0 || (off > 0 && off < price);

  factory OfferServiceModel.fromJson(Map<String, dynamic> json) {
    return OfferServiceModel(
      id: _toInt(json['id']),
      uid: _toInt(json['uid']),
      serviceId: _toInt(json['service_id']),
      name: json['name']?.toString() ?? '',
      price: _toDouble(json['price']),
      off: _toDouble(json['off']),
      duration: _toDouble(json['duration']),
      discount: _toDouble(json['discount']),
      status: _toInt(json['status'], 1),
      cateId: _toInt(json['cate_id']),
      cover: json['cover']?.toString() ?? '',
    );
  }
}

class CouponModel {
  final int id;
  final String name;
  final String shortDescription;
  final String code;
  final int type;
  final int discount;
  final int upto;
  final String startDate;
  final String expire;
  final int maxUsage;
  final int minCartValue;
  final int status;
  final String couponScope;
  final bool applyAllServices;
  final List<int> serviceIds;
  final List<OfferServiceModel> services;
  final List<OfferPartnerModel> salons;
  final List<OfferPartnerModel> freelancers;

  CouponModel({
    required this.id,
    required this.name,
    required this.shortDescription,
    required this.code,
    required this.type,
    required this.discount,
    required this.upto,
    this.startDate = '',
    required this.expire,
    required this.maxUsage,
    required this.minCartValue,
    required this.status,
    this.couponScope = '',
    this.applyAllServices = false,
    this.serviceIds = const [],
    this.services = const [],
    this.salons = const [],
    this.freelancers = const [],
  });

  bool get isPercent => type == 1;

  dynamic get serviceIdsPayload {
    if (applyAllServices) return 'ALL';
    return serviceIds;
  }

  factory CouponModel.fromJson(Map<String, dynamic> json) {
    final rawIds = json['service_ids'];
    final applyAll = rawIds?.toString().toUpperCase() == 'ALL';
    return CouponModel(
      id: _toInt(json['id']),
      name: json['name']?.toString() ?? '',
      shortDescription: json['short_descriptions']?.toString() ?? '',
      code: json['code']?.toString() ?? '',
      type: _toInt(json['type'], 1),
      discount: _toInt(json['discount']),
      upto: _toInt(json['upto']),
      startDate: json['start_date']?.toString() ?? '',
      expire: json['expire']?.toString() ?? '',
      maxUsage: _toInt(json['max_usage']),
      minCartValue: _toInt(json['min_cart_value']),
      status: _toInt(json['status'], 1),
      couponScope: json['coupon_scope']?.toString() ?? '',
      applyAllServices: applyAll,
      serviceIds: applyAll ? const [] : _parseServiceIds(rawIds),
      services: _parseServices(json['services']),
      salons: _parsePartners(json['salons']),
      freelancers: _parsePartners(json['freelancers']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'short_descriptions': shortDescription,
      'code': code,
      'type': type,
      'discount': discount,
      'upto': upto,
      'start_date': startDate,
      'expire': expire,
      'max_usage': maxUsage,
      'min_cart_value': minCartValue,
      'status': status,
      'coupon_scope': couponScope,
      'service_ids': serviceIdsPayload,
    };
  }

  CouponModel copyWith({int? status}) {
    return CouponModel(
      id: id,
      name: name,
      shortDescription: shortDescription,
      code: code,
      type: type,
      discount: discount,
      upto: upto,
      startDate: startDate,
      expire: expire,
      maxUsage: maxUsage,
      minCartValue: minCartValue,
      status: status ?? this.status,
      couponScope: couponScope,
      applyAllServices: applyAllServices,
      serviceIds: serviceIds,
      services: services,
      salons: salons,
      freelancers: freelancers,
    );
  }
}

int _toInt(dynamic value, [int fallback = 0]) {
  if (value == null) return fallback;
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.tryParse(value.toString()) ?? fallback;
}

double _toDouble(dynamic value, [double fallback = 0]) {
  if (value == null || value == '' || value == 'null') return fallback;
  if (value is double) return value;
  if (value is num) return value.toDouble();
  return double.tryParse(value.toString()) ?? fallback;
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
      .map((item) => OfferServiceModel.fromJson(Map<String, dynamic>.from(item)))
      .toList();
}

List<OfferPartnerModel> _parsePartners(dynamic value) {
  if (value is! List) return const [];
  return value
      .whereType<Map>()
      .map((item) => OfferPartnerModel.fromJson(Map<String, dynamic>.from(item)))
      .toList();
}

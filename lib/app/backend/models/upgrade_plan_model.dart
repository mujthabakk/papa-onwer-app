class UpgradePlanFeatureItem {
  final String key;
  final String label;
  final String type;
  final bool enabled;
  final dynamic value;
  final String display;

  UpgradePlanFeatureItem({
    this.key = '',
    this.label = '',
    this.type = 'boolean',
    this.enabled = false,
    this.value,
    this.display = '',
  });

  factory UpgradePlanFeatureItem.fromJson(Map<String, dynamic> json) {
    return UpgradePlanFeatureItem(
      key: json['key']?.toString() ?? '',
      label: json['label']?.toString() ?? '',
      type: json['type']?.toString() ?? 'boolean',
      enabled: _toBool(json['enabled']),
      value: json['value'],
      display: json['display']?.toString() ?? '',
    );
  }
}

class UpgradeCrmModule {
  final String key;
  final String label;
  final List<String> items;

  UpgradeCrmModule({
    this.key = '',
    this.label = '',
    this.items = const [],
  });

  factory UpgradeCrmModule.fromJson(String key, Map<String, dynamic> json) {
    final rawItems = json['items'];
    return UpgradeCrmModule(
      key: key,
      label: json['label']?.toString() ?? key,
      items: rawItems is List
          ? rawItems.map((e) => e.toString()).where((e) => e.isNotEmpty).toList()
          : const [],
    );
  }
}

class UpgradePlanModel {
  final int id;
  final String code;
  final String name;
  final String title;
  final String description;
  final num amount;
  final String currency;
  final String currencySymbol;
  final String billingPeriod;
  final int durationDays;
  final List<String> features;
  final List<String> includedSummary;
  final List<UpgradePlanFeatureItem> featureList;
  final List<UpgradeCrmModule> crmModules;
  final String? badge;
  final int sortOrder;

  UpgradePlanModel({
    required this.id,
    this.code = '',
    this.name = '',
    this.title = '',
    this.description = '',
    this.amount = 0,
    this.currency = 'INR',
    this.currencySymbol = '',
    this.billingPeriod = '',
    this.durationDays = 0,
    this.features = const [],
    this.includedSummary = const [],
    this.featureList = const [],
    this.crmModules = const [],
    this.badge,
    this.sortOrder = 0,
  });

  /// Short preview list used on the plan card.
  List<String> get previewFeatures {
    if (includedSummary.isNotEmpty) return includedSummary;
    if (features.isNotEmpty) return features;
    return featureList
        .where((f) => f.enabled)
        .map((f) => f.display.isNotEmpty && f.display != 'YES'
            ? '${f.label} (${f.display})'
            : f.label)
        .toList();
  }

  String get priceLabel {
    final formatted = amount.toStringAsFixed(amount % 1 == 0 ? 0 : 2);
    final symbol = currencySymbol.trim();
    if (symbol.isNotEmpty) return '$symbol $formatted';
    if (currency.toUpperCase() == 'INR') return '₹$formatted';
    return '$currency $formatted';
  }

  String get validityLabel {
    if (durationDays >= 365) {
      final years = (durationDays / 365).floor();
      return 'Valid for $years year${years == 1 ? '' : 's'}';
    }
    if (durationDays >= 30) {
      final months = (durationDays / 30).floor();
      return 'Valid for $months month${months == 1 ? '' : 's'}';
    }
    if (durationDays > 0) {
      return 'Valid for $durationDays days';
    }
    if (billingPeriod.toLowerCase() == 'monthly') {
      return 'Valid for 1 month';
    }
    return billingPeriod.isNotEmpty ? billingPeriod : '';
  }

  factory UpgradePlanModel.fromJson(Map<String, dynamic> json) {
    final included = _parseStringList(
      json['included_summary'] ??
          (json['plan_details'] is Map
              ? (json['plan_details'] as Map)['included_summary']
              : null),
    );

    final featureItems = _parseFeatureList(
      json['feature_list'] ??
          (json['plan_details'] is Map
              ? (json['plan_details'] as Map)['feature_list']
              : null),
    );

    final crm = _parseCrmModules(
      json['crm_modules'] ??
          (json['plan_details'] is Map
              ? (json['plan_details'] as Map)['crm_modules']
              : null),
    );

    // Keep legacy `features` as string list for older UI paths.
    final legacyFeatures = included.isNotEmpty
        ? included
        : _parseFeatures(json['features']);

    return UpgradePlanModel(
      id: _toInt(json['id']),
      code: json['code']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      amount: _toNum(json['amount']),
      currency: json['currency']?.toString() ?? 'INR',
      currencySymbol: json['currencySymbol']?.toString() ??
          json['currency_symbol']?.toString() ??
          '',
      billingPeriod: json['billing_period']?.toString() ?? '',
      durationDays: _toInt(json['duration_days']),
      features: legacyFeatures,
      includedSummary: included,
      featureList: featureItems,
      crmModules: crm,
      badge: json['badge']?.toString(),
      sortOrder: _toInt(json['sort_order']),
    );
  }

  static List<UpgradePlanModel> extractAvailablePlans(dynamic body) {
    if (body is! Map) return const [];
    final map = Map<String, dynamic>.from(body);
    List? list;
    if (map['available_plans'] is List) {
      list = map['available_plans'] as List;
    } else if (map['data'] is Map) {
      final data = Map<String, dynamic>.from(map['data'] as Map);
      if (data['available_plans'] is List) {
        list = data['available_plans'] as List;
      }
    }
    if (list == null) return const [];
    return list
        .whereType<Map>()
        .map((item) =>
            UpgradePlanModel.fromJson(Map<String, dynamic>.from(item)))
        .toList()
      ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
  }
}

class UpgradePaymentLinkModel {
  final int orderId;
  final int uid;
  final int planId;
  final String planName;
  final num amount;
  final String currency;
  final String paymentLink;
  final String paymentLinkId;
  final String status;

  UpgradePaymentLinkModel({
    required this.orderId,
    this.uid = 0,
    this.planId = 0,
    this.planName = '',
    this.amount = 0,
    this.currency = 'INR',
    this.paymentLink = '',
    this.paymentLinkId = '',
    this.status = 'pending',
  });

  factory UpgradePaymentLinkModel.fromJson(Map<String, dynamic> json) {
    return UpgradePaymentLinkModel(
      orderId: _toInt(json['order_id']),
      uid: _toInt(json['uid']),
      planId: _toInt(json['plan_id']),
      planName: json['plan_name']?.toString() ?? '',
      amount: _toNum(json['amount']),
      currency: json['currency']?.toString() ?? 'INR',
      paymentLink: json['payment_link']?.toString() ?? '',
      paymentLinkId: json['payment_link_id']?.toString() ?? '',
      status: json['status']?.toString() ?? 'pending',
    );
  }
}

class UpgradeVerifyModel {
  final int orderId;
  final String paymentStatus;
  final bool isPremium;
  final String? upgradeExpiresAt;
  final num amount;
  final int planId;

  UpgradeVerifyModel({
    required this.orderId,
    this.paymentStatus = 'pending',
    this.isPremium = false,
    this.upgradeExpiresAt,
    this.amount = 0,
    this.planId = 0,
  });

  bool get isPaid => paymentStatus.toLowerCase() == 'paid';

  factory UpgradeVerifyModel.fromJson(Map<String, dynamic> json) {
    return UpgradeVerifyModel(
      orderId: _toInt(json['order_id']),
      paymentStatus: json['payment_status']?.toString() ?? 'pending',
      isPremium: _toBool(json['is_premium']),
      upgradeExpiresAt: json['upgrade_expires_at']?.toString(),
      amount: _toNum(json['amount']),
      planId: _toInt(json['plan_id']),
    );
  }
}

int _toInt(dynamic value, [int fallback = 0]) {
  if (value == null) return fallback;
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.tryParse(value.toString()) ?? fallback;
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
  if (text == 'true' || text == '1' || text == 'yes') return true;
  if (text == 'false' || text == '0' || text == 'no') return false;
  return fallback;
}

List<String> _parseFeatures(dynamic value) {
  if (value is List) {
    return value
        .map((item) => item.toString())
        .where((item) => item.isNotEmpty)
        .toList();
  }
  return const [];
}

List<String> _parseStringList(dynamic value) {
  if (value is! List) return const [];
  return value
      .map((item) => item.toString())
      .where((item) => item.isNotEmpty)
      .toList();
}

List<UpgradePlanFeatureItem> _parseFeatureList(dynamic value) {
  if (value is! List) return const [];
  return value
      .whereType<Map>()
      .map((item) =>
          UpgradePlanFeatureItem.fromJson(Map<String, dynamic>.from(item)))
      .toList();
}

List<UpgradeCrmModule> _parseCrmModules(dynamic value) {
  if (value is! Map) return const [];
  final modules = <UpgradeCrmModule>[];
  value.forEach((key, raw) {
    if (raw is Map) {
      modules.add(
        UpgradeCrmModule.fromJson(
          key.toString(),
          Map<String, dynamic>.from(raw),
        ),
      );
    }
  });
  return modules;
}

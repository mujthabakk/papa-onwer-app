import 'package:ultimate_salon_owner_flutter/app/helper/shared_pref.dart';

class PartnerPlanModel {
  final int? id;
  final String? code;
  final String? name;
  final String? title;
  final String? country;
  final String? planAccess;
  final bool isPremium;
  final int upgrade;
  final String? upgradeDate;
  final String? upgradeExpiresAt;
  final bool isExpired;
  final int daysRemaining;
  final String releasedAccess;

  const PartnerPlanModel({
    this.id,
    this.code,
    this.name,
    this.title,
    this.country,
    this.planAccess,
    this.isPremium = false,
    this.upgrade = 0,
    this.upgradeDate,
    this.upgradeExpiresAt,
    this.isExpired = false,
    this.daysRemaining = 0,
    this.releasedAccess = 'all',
  });

  bool get isActivePremium => isPremium && !isExpired;

  String get displayName {
    final titled = (title ?? '').trim();
    if (titled.isNotEmpty) return titled;
    final named = (name ?? '').trim();
    if (named.isNotEmpty) return named;
    final coded = (code ?? '').trim();
    if (coded.isNotEmpty) {
      return '${coded[0].toUpperCase()}${coded.substring(1)}';
    }
    return isActivePremium ? 'Premium' : '';
  }

  factory PartnerPlanModel.fromJson(Map<String, dynamic> json) {
    return PartnerPlanModel(
      id: _toInt(json['id']),
      code: _toNullableString(json['code']),
      name: _toNullableString(json['name']),
      title: _toNullableString(json['title']),
      country: _toNullableString(json['country']),
      planAccess: _toNullableString(json['plan_access']),
      isPremium: _toBool(json['is_premium']) || _toInt(json['upgrade']) == 1,
      upgrade: _toInt(json['upgrade']) ?? 0,
      upgradeDate: _toNullableString(json['upgrade_date']),
      upgradeExpiresAt: _toNullableString(json['upgrade_expires_at']),
      isExpired: _toBool(json['is_expired']),
      daysRemaining: _toInt(json['days_remaining']) ?? 0,
      releasedAccess: _toNullableString(json['released_access']) ?? 'all',
    );
  }

  static PartnerPlanModel? extract(dynamic body) {
    if (body is! Map) return null;
    final map = Map<String, dynamic>.from(body);
    final candidates = <dynamic>[
      map['plan'],
      map['data'] is Map ? (map['data'] as Map)['plan'] : null,
      map['user'] is Map ? (map['user'] as Map)['plan'] : null,
    ];
    for (final raw in candidates) {
      if (raw is Map) {
        return PartnerPlanModel.fromJson(Map<String, dynamic>.from(raw));
      }
    }
    return null;
  }

  void save(SharedPreferencesManager prefs) {
    prefs.putBool('premium', isActivePremium);
    prefs.putString('plan_code', code ?? '');
    prefs.putString('plan_name', displayName);
    prefs.putString('plan_title', title ?? '');
    prefs.putString('plan_country', country ?? '');
    prefs.putString('plan_access', planAccess ?? '');
    prefs.putString('plan_upgrade_date', upgradeDate ?? '');
    prefs.putString('plan_expires_at', upgradeExpiresAt ?? '');
    prefs.putBool('plan_is_expired', isExpired);
    prefs.putInt('plan_days_remaining', daysRemaining);
    prefs.putString('released_access', releasedAccess);
    prefs.putInt('plan_id', id ?? 0);
  }

  static PartnerPlanModel load(SharedPreferencesManager prefs) {
    return PartnerPlanModel(
      id: prefs.getInt('plan_id'),
      code: _emptyToNull(prefs.getString('plan_code')),
      name: _emptyToNull(prefs.getString('plan_name')),
      title: _emptyToNull(prefs.getString('plan_title')),
      country: _emptyToNull(prefs.getString('plan_country')),
      planAccess: _emptyToNull(prefs.getString('plan_access')),
      isPremium: prefs.getBool('premium'),
      upgrade: prefs.getBool('premium') ? 1 : 0,
      upgradeDate: _emptyToNull(prefs.getString('plan_upgrade_date')),
      upgradeExpiresAt: _emptyToNull(prefs.getString('plan_expires_at')),
      isExpired: prefs.getBool('plan_is_expired'),
      daysRemaining: prefs.getInt('plan_days_remaining') ?? 0,
      releasedAccess: prefs.getString('released_access') ?? 'all',
    );
  }

  static void clear(SharedPreferencesManager prefs) {
    for (final key in [
      'premium',
      'plan_code',
      'plan_name',
      'plan_title',
      'plan_country',
      'plan_access',
      'plan_upgrade_date',
      'plan_expires_at',
      'plan_is_expired',
      'plan_days_remaining',
      'released_access',
      'plan_id',
    ]) {
      prefs.clearKey(key);
    }
  }

  static String? _emptyToNull(String? value) {
    final t = (value ?? '').trim();
    return t.isEmpty ? null : t;
  }

  static String? _toNullableString(dynamic value) {
    if (value == null) return null;
    final t = value.toString().trim();
    if (t.isEmpty || t.toLowerCase() == 'null') return null;
    return t;
  }

  static int? _toInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    return int.tryParse(value.toString());
  }

  static bool _toBool(dynamic value) {
    if (value == true || value == 1) return true;
    if (value == false || value == 0 || value == null) return false;
    final t = value.toString().toLowerCase();
    return t == 'true' || t == '1';
  }
}

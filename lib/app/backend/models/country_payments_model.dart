class CountryPaymentMethod {
  final int id;
  final String type;
  final String name;

  CountryPaymentMethod({
    this.id = 0,
    this.type = '',
    this.name = '',
  });

  factory CountryPaymentMethod.fromJson(Map<String, dynamic> json) {
    return CountryPaymentMethod(
      id: int.tryParse('${json['id'] ?? 0}') ?? 0,
      type: json['type']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
    );
  }

  bool get isCod => type.toLowerCase() == 'cod' || id == 1;
  bool get isOnline => type.toLowerCase() == 'online' || id == 5;
}

class CountryPaymentsModel {
  final String country;
  final bool codEnabled;
  final bool onlineEnabled;
  final bool codAvailable;
  final bool onlineAvailable;
  final int defaultPayMethod;
  final String message;
  final List<CountryPaymentMethod> methods;

  CountryPaymentsModel({
    this.country = '',
    this.codEnabled = true,
    this.onlineEnabled = true,
    this.codAvailable = true,
    this.onlineAvailable = true,
    this.defaultPayMethod = 0,
    this.message = '',
    this.methods = const [],
  });

  bool get showCod =>
      codEnabled &&
      (methods.isEmpty || methods.any((m) => m.isCod));

  bool get showOnline =>
      onlineEnabled &&
      (methods.isEmpty || methods.any((m) => m.isOnline));

  factory CountryPaymentsModel.fromJson(Map<String, dynamic> json) {
    final raw = json['methods'];
    return CountryPaymentsModel(
      country: json['country']?.toString() ?? '',
      codEnabled: _flag(json['cod_enabled'], true),
      onlineEnabled: _flag(json['online_enabled'], true),
      codAvailable: _flag(json['cod_available'], true),
      onlineAvailable: _flag(json['online_available'], true),
      defaultPayMethod: int.tryParse('${json['default_pay_method'] ?? 0}') ?? 0,
      message: json['message']?.toString() ?? '',
      methods: raw is List
          ? raw
              .whereType<Map>()
              .map((e) =>
                  CountryPaymentMethod.fromJson(Map<String, dynamic>.from(e)))
              .toList()
          : const [],
    );
  }
}

bool _flag(dynamic value, bool fallback) {
  if (value == null) return fallback;
  if (value is bool) return value;
  if (value is int) return value == 1;
  final text = value.toString().toLowerCase();
  return text == '1' || text == 'true' || text == 'yes';
}

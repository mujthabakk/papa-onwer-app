class SignupCountryModel {
  final int id;
  final String name;
  final String code;
  final String isoCode;
  final String countryCode;

  SignupCountryModel({
    required this.id,
    required this.name,
    this.code = '',
    this.isoCode = '',
    this.countryCode = '',
  });

  factory SignupCountryModel.fromJson(Map<String, dynamic> json) {
    return SignupCountryModel(
      id: _toInt(json['id']),
      name: json['name']?.toString() ?? '',
      code: json['code']?.toString() ?? json['iso_code']?.toString() ?? '',
      isoCode: json['iso_code']?.toString() ?? json['code']?.toString() ?? '',
      countryCode: json['country_code']?.toString() ?? '',
    );
  }
}

int _toInt(dynamic value, [int fallback = 0]) {
  if (value == null) return fallback;
  if (value is int) return value;
  return int.tryParse(value.toString()) ?? fallback;
}

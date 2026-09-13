import 'dart:convert';

class ConnectLinksModel {
  int? id;
  int? uid;
  String? name;
  String? mobile;
  String? email;
  String? website;
  String? instagram;
  String? youtube;
  String? facebook;
  String? whatsapp;
  String? twitter;
  String? linkedin;
  bool callEnabled;
  bool chatEnabled;

  ConnectLinksModel({
    this.id,
    this.uid,
    this.name,
    this.mobile,
    this.email,
    this.website,
    this.instagram,
    this.youtube,
    this.facebook,
    this.whatsapp,
    this.twitter,
    this.linkedin,
    this.callEnabled = true,
    this.chatEnabled = true,
  });

  factory ConnectLinksModel.fromJson(Map<String, dynamic> json) {
    final model = ConnectLinksModel(
      id: _toInt(json['id']),
      uid: _toInt(json['uid']),
      name: json['name']?.toString(),
      mobile: json['mobile']?.toString(),
      email: json['email']?.toString(),
      website: json['website']?.toString(),
      instagram: json['instagram']?.toString(),
      youtube: json['youtube']?.toString(),
      facebook: json['facebook']?.toString(),
      whatsapp: json['whatsapp']?.toString() ?? json['whatsapp_number']?.toString(),
      twitter: json['twitter']?.toString(),
      linkedin: json['linkedin']?.toString(),
      callEnabled: _parseBool(json['call_enabled'], true),
      chatEnabled: _parseBool(json['chat_enabled'], true),
    );

    if (json['social_links'] is Map) {
      _applySocialMap(model, Map<String, dynamic>.from(json['social_links']));
    }

    final extraField = json['extra_field'];
    if (extraField != null && extraField.toString().isNotEmpty && extraField != 'NA') {
      try {
        final decoded = jsonDecode(extraField.toString());
        if (decoded is Map) {
          _applySocialMap(model, Map<String, dynamic>.from(decoded));
        }
      } catch (_) {}
    }

    return model;
  }

  Map<String, dynamic> toUpdateBody() {
    return {
      'id': id,
      'website': _value(website),
      'instagram': _value(instagram),
      'youtube': _value(youtube),
      'facebook': _value(facebook),
      'whatsapp': _value(whatsapp),
      'twitter': _value(twitter),
      'linkedin': _value(linkedin),
      'call_enabled': callEnabled,
      'chat_enabled': chatEnabled,
    };
  }

  static void _applySocialMap(
      ConnectLinksModel model, Map<String, dynamic> map) {
    model.instagram ??= map['instagram']?.toString();
    model.youtube ??= map['youtube']?.toString();
    model.facebook ??= map['facebook']?.toString();
    model.whatsapp ??=
        map['whatsapp']?.toString() ?? map['whatsapp_number']?.toString();
    model.twitter ??= map['twitter']?.toString();
    model.linkedin ??= map['linkedin']?.toString();
    if (map.containsKey('call_enabled')) {
      model.callEnabled = _parseBool(map['call_enabled'], model.callEnabled);
    }
    if (map.containsKey('chat_enabled')) {
      model.chatEnabled = _parseBool(map['chat_enabled'], model.chatEnabled);
    }
  }

  static String _value(String? value) => value?.trim() ?? '';

  static int? _toInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    return int.tryParse(value.toString());
  }

  static bool _parseBool(dynamic value, bool fallback) {
    if (value == null) return fallback;
    if (value is bool) return value;
    if (value is int) return value == 1;
    final text = value.toString().toLowerCase();
    if (text == '1' || text == 'true') return true;
    if (text == '0' || text == 'false') return false;
    return fallback;
  }
}

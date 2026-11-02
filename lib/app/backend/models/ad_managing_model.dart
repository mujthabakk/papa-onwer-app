import 'package:get/get.dart';

class AdsManagingModel {
  int? id;
  int? position;
  var title = ''.obs;
  num? price;
  double? lat;
  double? lng;
  var cover = ''.obs;
  DateTime? from;
  String? link = '';
  DateTime? to;
  int? type;
  String? clickAction;
  String? value;

  AdsManagingModel({
    this.id,
    this.position,
    required this.title,
    this.price,
    this.lat,
    this.lng,
    required this.cover,
    this.link,
    this.from,
    this.to,
    this.type,
    this.clickAction,
    this.value,
  });

  AdsManagingModel.fromJson(Map<String, dynamic> json) {
    id = int.tryParse('${json['id'] ?? ''}');
    position = int.tryParse('${json['position'] ?? 0}') ?? 0;
    title.value = json['title']?.toString() ?? '';
    price = num.tryParse('${json['price'] ?? 0}') ?? 0;
    lat = double.tryParse('${json['lat'] ?? ''}');
    lng = double.tryParse('${json['lng'] ?? ''}');
    cover.value = json['cover']?.toString() ?? '';
    from = DateTime.tryParse(
        '${json['from'] ?? json['start_date'] ?? ''}');
    type = int.tryParse('${json['type'] ?? ''}');
    clickAction = json['click_action']?.toString();
    value = json['value']?.toString();
    final rawLink = json['link']?.toString() ?? '';
    final isLinkAd = (clickAction ?? '').toLowerCase() == 'link' || type == 5;
    link = isLinkAd
        ? (rawLink.isNotEmpty ? rawLink : (value ?? ''))
        : '';
    to = DateTime.tryParse(
        '${json['to'] ?? json['expiry_date'] ?? ''}');
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['position'] = position;
    data['title'] = title;
    data['price'] = price;
    data['lat'] = lat;
    data['lng'] = lng;
    data['cover'] = cover;
    data['link'] = link;
    data['from'] = from?.toIso8601String();
    data['to'] = to?.toIso8601String();
    return data;
  }
}

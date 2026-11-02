/*Papabear*/
class BannerModel {
  int? id;
  String? cover;
  String? link;
  String? title;
  int? status;
  int? type;
  String? value;
  String? clickAction;
  String? country;
  int? cityId;
  String? cityName;
  String? startDate;
  String? expiryDate;

  BannerModel({
    this.id,
    this.cover,
    this.link,
    this.title,
    this.status,
    this.type,
    this.value,
    this.clickAction,
    this.country,
    this.cityId,
    this.cityName,
    this.startDate,
    this.expiryDate,
  });

  BannerModel.fromJson(Map<String, dynamic> json) {
    id = int.tryParse('${json['id'] ?? ''}');
    cover = json['cover']?.toString();
    link = json['link']?.toString();
    title = json['title']?.toString();
    status = int.tryParse('${json['status'] ?? 1}') ?? 1;
    type = int.tryParse('${json['type'] ?? ''}');
    value = json['value']?.toString();
    clickAction = json['click_action']?.toString();
    country = json['country']?.toString();
    cityId = int.tryParse('${json['city_id'] ?? ''}');
    cityName = json['city_name']?.toString();
    startDate = (json['start_date'] ?? json['from'])?.toString();
    expiryDate = (json['expiry_date'] ?? json['to'])?.toString();
  }

  bool get isLinkAd {
    final action = (clickAction ?? '').toLowerCase();
    return action == 'link' || type == 5;
  }

  bool get isSalonProfile => !isLinkAd && type == 2;
  bool get isFreelancerProfile => !isLinkAd && type == 1;

  String get openUrl {
    final href = (link ?? '').trim();
    if (href.isNotEmpty && href.toLowerCase() != 'null') return href;
    return (value ?? '').trim();
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'cover': cover,
      'link': link,
      'title': title,
      'status': status,
      'type': type,
      'value': value,
      'click_action': clickAction,
      'country': country,
      'city_id': cityId,
      'city_name': cityName,
      'start_date': startDate,
      'expiry_date': expiryDate,
    };
  }
}

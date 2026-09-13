import 'package:get/get.dart';

class WithdrawalsModel {
  int? id;
  int? position;
  var title = ''.obs;
  int? price;
  double? lat;
  double? lng;
  var cover = ''.obs;
  DateTime? from;
  DateTime? to;

  WithdrawalsModel({
    this.id,
    this.position,
    required this.title,
    this.price,
    this.lat,
    this.lng,
    required this.cover,
    this.from,
    this.to,
  });

  WithdrawalsModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];

    position = int.parse(json['position'].toString());
    title.value = json['title'];
    price = int.parse(json['price'].toString());
    lat = double.parse(json['lat'].toString());
    lng = double.parse(json['lng'].toString());
    cover.value = json['cover'];
    from = DateTime.parse(json['from']);
    to = DateTime.parse(json['to']);
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
    data['from'] = from?.toIso8601String();
    data['to'] = to?.toIso8601String();
    return data;
  }
}

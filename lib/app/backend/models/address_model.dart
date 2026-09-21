/*Papabear*/
class AddressModel {
  int? id;
  int? uid;
  int? title;
  String? address;
  String? house;
  String? landmark;
  String? pincode;
  String? lat;
  String? lng;
  String? extraField;
  int? status;

  AddressModel(
      {this.id,
      this.uid,
      this.title,
      this.address,
      this.house,
      this.landmark,
      this.pincode,
      this.lat,
      this.lng,
      this.extraField,
      this.status});

  AddressModel.fromJson(Map<String, dynamic> json) {
    id = int.tryParse('${json['id'] ?? ''}');
    uid = int.tryParse('${json['uid'] ?? ''}');
    title = int.tryParse('${json['title'] ?? ''}');
    address = json['address']?.toString();
    house = json['house']?.toString();
    landmark = json['landmark']?.toString();
    pincode = json['pincode']?.toString();
    lat = json['lat']?.toString();
    lng = json['lng']?.toString();
    extraField = json['extra_field']?.toString();
    status = int.tryParse('${json['status'] ?? ''}');
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['uid'] = uid;
    data['title'] = title;
    data['address'] = address;
    data['house'] = house;
    data['landmark'] = landmark;
    data['pincode'] = pincode;
    data['lat'] = lat;
    data['lng'] = lng;
    data['extra_field'] = extraField;
    data['status'] = status;
    return data;
  }
}

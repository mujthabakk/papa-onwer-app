// models/facility.dart
class FacilityModel {
  int? id;
  String? name;
  int? status;
  bool? isChecked;

  FacilityModel({
    this.id,
    this.name,
    this.status,
    this.isChecked,
  });

  FacilityModel.fromJson(Map<String, dynamic> json) {
    id = int.parse(json['id'].toString());
    name = json['name'];
    status = int.parse(json['status'].toString());
    isChecked = json['isChecked'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['name'] = name;
    data['status'] = status;
    data['isChecked'] = isChecked;

    return data;
  }
}

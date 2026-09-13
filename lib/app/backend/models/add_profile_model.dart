class AddProfileModel {
  int? id;
  String? name;
  String? cover;
  String? extraField;
  bool? isChecked;
  int? status;

  AddProfileModel({
    this.id,
    this.name,
    this.cover,
    this.extraField,
    this.status,
    this.isChecked,
  });

  AddProfileModel.fromJson(Map<String, dynamic> json) {
    id = json['id'] != null ? int.parse(json['id'].toString()) : null;
    name = json['name'];
    cover = json['cover'];
    extraField = json['extra_field'];
    status =
        json['status'] != null ? int.parse(json['status'].toString()) : null;
    isChecked = json['isChecked'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['name'] = name;
    data['cover'] = cover;
    data['extra_field'] = extraField;
    data['status'] = status;
    data['isChecked'] = isChecked;
    return data;
  }
}

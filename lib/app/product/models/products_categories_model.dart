/*Papabear*/
class ProductsCategoriesModel {
  int? id;
  String? name;
  String? cover;
  String? extraField;
  int? status;

  ProductsCategoriesModel(
      {this.id, this.name, this.cover, this.extraField, this.status});

  ProductsCategoriesModel.fromJson(Map<String, dynamic> json) {
    id = int.tryParse('${json['id'] ?? ''}');
    name = json['name']?.toString();
    cover = json['cover']?.toString();
    extraField = json['extra_field']?.toString();
    status = int.tryParse('${json['status'] ?? 1}') ?? 1;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['name'] = name;
    data['cover'] = cover;
    data['extra_field'] = extraField;
    data['status'] = status;
    return data;
  }
}

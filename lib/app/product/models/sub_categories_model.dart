/*Papabear*/
class SubCategoriesModel {
  int? id;
  String? name;
  String? cover;
  int? cateId;
  String? extraField;
  int? status;

  SubCategoriesModel(
      {this.id,
      this.name,
      this.cover,
      this.cateId,
      this.extraField,
      this.status});

  SubCategoriesModel.fromJson(Map<String, dynamic> json) {
    id = int.tryParse('${json['id'] ?? ''}');
    name = json['name']?.toString();
    cover = json['cover']?.toString();
    cateId = int.tryParse('${json['cate_id'] ?? ''}');
    extraField = json['extra_field']?.toString();
    status = int.tryParse('${json['status'] ?? 1}') ?? 1;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['name'] = name;
    data['cover'] = cover;
    data['cate_id'] = cateId;
    data['extra_field'] = extraField;
    data['status'] = status;
    return data;
  }
}

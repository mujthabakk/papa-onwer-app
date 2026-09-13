/*Papabear*/
class BannerModel {
  int? id;
  String? cover;
  String? link;
  String? title;
  int? status;

  BannerModel({this.id, this.cover, this.link, this.title, this.status});

  BannerModel.fromJson(Map<String, dynamic> json) {
    id = int.parse(json['id'].toString());
    cover = json['cover'];
    link = json['link'];
    title = json['title'];
    status = int.parse(json['status'].toString());
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['cover'] = cover;
    data['link'] = link;
    data['title'] = title;
    data['status'] = status;
    return data;
  }
}

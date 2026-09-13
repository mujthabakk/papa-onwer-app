class SlotsModel {
  String? startTime;
  String? endTime;
  String? available;

  SlotsModel({this.startTime, this.endTime, this.available});

  SlotsModel.fromJson(Map<String, dynamic> json) {
    startTime = json['start_time'];
    endTime = json['end_time'];
    available = json['available'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['start_time'] = startTime;
    data['end_time'] = endTime;
    data['available'] = available;

    return data;
  }
}

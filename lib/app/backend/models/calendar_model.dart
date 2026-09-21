/*Papabear*/
class CalendarModel {
  int? count;
  String? dayName;
  String? day;
  double? total;

  CalendarModel({this.count, this.dayName, this.day, this.total});

  CalendarModel.fromJson(Map<String, dynamic> json) {
    count = int.tryParse('${json['count'] ?? 0}') ?? 0;
    dayName = json['day_name']?.toString() ?? json['dayName']?.toString();
    day = json['day']?.toString();
    total = double.tryParse('${json['total'] ?? 0}') ?? 0;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['count'] = count;
    data['day_name'] = dayName;
    data['day'] = day;
    data['total'] = total;
    return data;
  }
}

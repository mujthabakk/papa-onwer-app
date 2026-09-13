class MonthAnalyticsModel {
  int? count;
  int? dayName;
  int? day;
  num? total;
  num? codTotal;
  num? onlineTotal;

  MonthAnalyticsModel(
      {this.count,
      this.dayName,
      this.day,
      this.total,
      this.codTotal,
      this.onlineTotal});

  MonthAnalyticsModel.fromJson(Map<String, dynamic> json) {
    count = int.parse(json['count'].toString());
    dayName = int.parse(json['day_name'].toString());
    day = int.parse(json['day'].toString());
    total = num.parse(json['total'].toString());
    codTotal = num.parse(json['COD_total'].toString());
    onlineTotal = num.parse(json['Online_total'].toString());
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['count'] = count;
    data['day_name'] = dayName;
    data['day'] = day;
    data['total'] = total;
    data['COD_total'] = codTotal;
    data['Online_total'] = onlineTotal;
    return data;
  }
}

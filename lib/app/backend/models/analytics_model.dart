import 'package:jiffy/jiffy.dart';

class AnalyticsModel {
  int? count;
  String? dayName;
  String? day;
  num? total;
  num? codTotal;
  num? onlineTotal;

  AnalyticsModel(
      {this.count,
      this.dayName,
      this.day,
      this.total,
      this.codTotal,
      this.onlineTotal});

  AnalyticsModel.fromJson(Map<String, dynamic> json) {
    count = int.parse(json['count'].toString());
    dayName = Jiffy.parse(json['day_name'].toString()).format(pattern: 'EEEE, dd');
    day = Jiffy.parse(json['day'].toString()).yMMMMd;
    total = num.parse(json['total'].toString());
    codTotal = num.parse(json['COD_total'].toString());
    onlineTotal = double.parse(json['Online_total'].toString());
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

import 'package:ultimate_salon_owner_flutter/app/util/slot_time.dart';

class TimingModel {
  int? day;
  String? openTime;
  String? closeTime;

  TimingModel({this.day, this.openTime, this.closeTime});

  TimingModel.fromJson(Map<String, dynamic> json) {
    day = int.tryParse(json['day']?.toString() ?? '') ?? 0;
    openTime = SlotTime.to12Hour(json['open_time']?.toString());
    closeTime = SlotTime.to12Hour(json['close_time']?.toString());
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['day'] = day;
    data['open_time'] = SlotTime.to12Hour(openTime);
    data['close_time'] = SlotTime.to12Hour(closeTime);
    return data;
  }

  String get displayRange {
    final open = SlotTime.to12Hour(openTime);
    final close = SlotTime.to12Hour(closeTime);
    if (open.isEmpty && close.isEmpty) return '';
    return '$open - $close';
  }
}

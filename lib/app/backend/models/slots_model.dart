import 'package:ultimate_salon_owner_flutter/app/util/slot_time.dart';

class SlotsModel {
  String? startTime;
  String? endTime;
  String? available;

  SlotsModel({this.startTime, this.endTime, this.available});

  SlotsModel.fromJson(Map<String, dynamic> json) {
    startTime = SlotTime.to12Hour(json['start_time']?.toString());
    endTime = SlotTime.to12Hour(json['end_time']?.toString());
    available = json['available']?.toString();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['start_time'] = SlotTime.to12Hour(startTime);
    data['end_time'] = SlotTime.to12Hour(endTime);
    data['available'] = available;
    return data;
  }

  String get displayLabel {
    final start = SlotTime.to12Hour(startTime);
    final end = SlotTime.to12Hour(endTime);
    final qty = available ?? '';
    return '$start to $end - available: $qty';
  }
}

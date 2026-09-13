import 'dart:convert';

import 'package:ultimate_salon_owner_flutter/app/backend/models/service_cart_model.dart';

class Employee {
  final int? id;
  final int? salonUid;
  final String? cateId;
  final String? serviceId;
  final String? firstName;
  final String? lastName;
  final String? cover;
  final String? extraField;
  final int? status;

  Employee({
    this.id,
    this.salonUid,
    this.cateId,
    this.serviceId,
    this.firstName,
    this.lastName,
    this.cover,
    this.extraField,
    this.status,
  });

  factory Employee.fromJson(Map<String, dynamic> json) {
    return Employee(
      id: json['id'] as int?,
      salonUid: json['salon_uid'] as int?,
      cateId: json['cate_id'] as String?,
      serviceId: json['service_id'] as String?,
      firstName: json['first_name'] as String?,
      lastName: json['last_name'] as String?,
      cover: json['cover'] as String?,
      extraField: json['extra_field'] as String?,
      status: json['status'] as int?,
    );
  }
}

class PreviousAppointmentModel {
  final int? id;
  final int? uid;
  final String? name;
  final int? status;

  final int? freelancerId;
  final int? salonId;
  final ServiceCartModel? items; // Replace 'items' with 'serviceCart'
  final double? grandTotal;
  final String? saveDate;
  final Employee? employee;
  final String? remarks;
  final String? reminderDate;
  final String? reminderDescription;

  PreviousAppointmentModel({
    this.id,
    this.uid,
    this.freelancerId,
    this.status,
    this.name,
    this.salonId,
    this.items, // Change to 'serviceCart'
    this.grandTotal,
    this.saveDate,
    this.employee,
    this.remarks,
    this.reminderDate,
    this.reminderDescription,
  });

  factory PreviousAppointmentModel.fromJson(Map<String, dynamic> json) {
    // Check if serviceCart is a String that needs to be parsed
    var serviceCartData = json['items'];
    ServiceCartModel? serviceCart = serviceCartData is String
        ? ServiceCartModel.fromJson(
            jsonDecode(serviceCartData)) // Parse JSON string if it's a string
        : serviceCartData != null
            ? ServiceCartModel.fromJson(
                serviceCartData) // Parse directly if it's already a map
            : null;

    return PreviousAppointmentModel(
      id: json['id'] as int?,
      uid: json['uid'] as int?,
      status: json['status'] as int?,
      name: json['customer_name'] as String?,
      freelancerId: json['freelancer_id'] as int?,
      salonId: json['salon_id'] as int?,
      items: serviceCart, // Updated to correctly parse serviceCart
      grandTotal: double.parse(json['grand_total'].toString()),
      saveDate: json['save_date'] as String?,
      employee:
          json['employee'] != null ? Employee.fromJson(json['employee']) : null,
      remarks: json['remarks'] as String?,
      reminderDate: json['reminder_date'] as String?,
      reminderDescription: json['reminder_description'] as String?,
    );
  }
}

class ServicesModelNew {
  int? id;
  int? uid;
  int? cateId;
  String? name;
  String? cover;
  double? duration;
  double? price;
  int? gender;
  double? off;
  double? discount;
  String? descriptions;
  String? images;
  String? extraField;
  int? status;
  late bool? isChecked;
  WebCatesData? webCatesData;

  ServicesModelNew({
    this.id,
    this.uid,
    this.cateId,
    this.name,
    this.cover,
    this.duration,
    this.price,
    this.gender,
    this.off,
    this.discount,
    this.descriptions,
    this.images,
    this.extraField,
    this.status,
    this.isChecked = false,
    this.webCatesData,
  });

  ServicesModelNew.fromJson(Map<String, dynamic> json) {
    id = int.parse(json['id'].toString());
    uid = int.parse(json['uid'].toString());
    cateId = int.parse(json['cate_id'].toString());
    name = json['name'];
    cover = json['cover'];
    duration = double.parse(json['duration'].toString());
    price = double.parse(json['price'].toString());
    gender = int.parse(json['gender'].toString());
    off = double.parse(json['off'].toString());
    discount = double.parse(json['discount'].toString());
    descriptions = json['descriptions'];
    images = json['images'];
    extraField = json['extra_field'];
    status = int.parse(json['status'].toString());
    webCatesData = json['web_cates_data'] != null
        ? WebCatesData.fromJson(json['web_cates_data'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['uid'] = uid;
    data['cate_id'] = cateId;
    data['name'] = name;
    data['cover'] = cover;
    data['duration'] = duration;
    data['price'] = price;
    data['gender'] = gender;
    data['off'] = off;
    data['discount'] = discount;
    data['descriptions'] = descriptions;
    data['images'] = images;
    data['extra_field'] = extraField;
    data['isChecked'] = isChecked;
    data['status'] = status;
    if (webCatesData != null) {
      data['web_cates_data'] = webCatesData!.toJson();
    }
    return data;
  }
}

class WebCatesData {
  int? id;
  String? name;
  String? cover;
  String? extraField;
  int? status;

  WebCatesData({this.id, this.name, this.cover, this.extraField, this.status});

  WebCatesData.fromJson(Map<String, dynamic> json) {
    id = int.parse(json['id'].toString());
    name = json['name'];
    cover = json['cover'];
    extraField = json['extra_field'];
    status = int.parse(json['status'].toString());
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

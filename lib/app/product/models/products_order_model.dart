/*Papabear*/
import 'dart:convert';

import 'package:jiffy/jiffy.dart';
import 'package:ultimate_salon_owner_flutter/app/backend/models/address_model.dart';
import 'package:ultimate_salon_owner_flutter/app/product/models/product_list_model.dart';

class ProductSalonModel {
  int? id;
  int? uid;
  int? freelancerId;
  int? salonId;
  String? dateTime;
  int? paidMethod;
  String? orderTo;
  List<ProductsListModel>? orders;
  String? notes;
  AddressModel? address;
  double? total;
  double? tax;
  double? grandTotal;
  double? discount;
  String? driverId;
  double? deliveryCharge;
  int? walletUsed;
  double? walletPrice;
  String? couponCode;
  String? extra;
  String? payKey;
  int? status;
  int? payStatus;
  String? extraField;
  String? createdAt;
  String? type;
  String? section;
  String? customer;
  String? item;
  String? deliveryType;
  SalonInfo? salonInfo;
  FreelancerInfo? freelancerInfo;
  UserModel? userInfo;
  ProductSalonModel(
      {this.id,
      this.uid,
      this.freelancerId,
      this.salonId,
      this.dateTime,
      this.paidMethod,
      this.orderTo,
      this.orders,
      this.notes,
      this.address,
      this.total,
      this.tax,
      this.grandTotal,
      this.discount,
      this.driverId,
      this.deliveryCharge,
      this.walletUsed,
      this.walletPrice,
      this.couponCode,
      this.extra,
      this.payKey,
      this.status,
      this.payStatus,
      this.extraField,
      this.createdAt,
      this.type,
      this.salonInfo,
      this.freelancerInfo,
      this.userInfo});

  static int _int(dynamic value) => int.tryParse('${value ?? 0}') ?? 0;
  static double _double(dynamic value) =>
      double.tryParse('${value ?? 0}') ?? 0;

  ProductSalonModel.fromJson(Map<String, dynamic> json) {
    id = _int(json['id'] ?? json['order_id']);
    uid = _int(json['uid']);
    freelancerId = _int(json['freelancer_id']);
    salonId = _int(json['salon_id']);
    dateTime = (json['date_time'] ?? json['delivery_at'] ?? json['delivery_date'])
        ?.toString();
    paidMethod = _int(json['paid_method']);
    orderTo = (json['order_to'] ?? json['delivery_type'])?.toString();
    section = json['section']?.toString();
    customer = json['customer']?.toString();
    item = json['item']?.toString();
    deliveryType = json['delivery_type']?.toString();
    if (json.containsKey('orders') &&
        json['orders'] != null &&
        json['orders'] != 'NA' &&
        json['orders'] != '') {
      try {
        orders = <ProductsListModel>[];
        var order = json['orders'] is String
            ? jsonDecode(json['orders'])
            : json['orders'];
        if (order is List) {
          for (final element in order) {
            if (element is Map) {
              orders!.add(ProductsListModel.fromJson(
                  Map<String, dynamic>.from(element)));
            }
          }
        }
      } catch (_) {
        orders = [];
      }
    }
    notes = json['notes']?.toString();
    try {
      if (json['address'] is Map) {
        address = AddressModel.fromJson(
            Map<String, dynamic>.from(json['address']));
      } else if (json['address'] != null &&
          json['address'].toString().isNotEmpty &&
          json['address'] != 'NA') {
        address = AddressModel.fromJson(jsonDecode(json['address']));
      }
    } catch (_) {
      address = null;
    }
    total = _double(json['total'] ?? json['amount']);
    tax = _double(json['tax']);
    grandTotal = _double(json['grand_total'] ?? json['amount']);
    discount = _double(json['discount']);
    driverId = json['driver_id']?.toString();
    deliveryCharge = _double(json['delivery_charge']);
    walletUsed = _int(json['wallet_used']);
    walletPrice = _double(json['wallet_price'] ?? json['paid_amount']);
    couponCode = json['coupon_code']?.toString();
    extra = json['extra']?.toString();
    payKey = json['pay_key']?.toString();
    status = _int(json['status']);
    payStatus = _int(json['payStatus'] ?? json['pay_status']);
    extraField = json['extra_field']?.toString();
    final created = json['created_at'] ?? json['ordered_at'];
    try {
      createdAt = created != null
          ? Jiffy.parse(created.toString()).yMMMMd
          : '';
    } catch (_) {
      createdAt = created?.toString() ?? '';
    }
    type = json['type']?.toString();
    if (json.containsKey('salonInfo')) {
      salonInfo = json['salonInfo'] != null
          ? SalonInfo.fromJson(json['salonInfo'])
          : null;
    }

    if (json.containsKey('freelancerInfo')) {
      freelancerInfo = json['freelancerInfo'] != null
          ? FreelancerInfo.fromJson(json['freelancerInfo'])
          : null;
    }

    if (json.containsKey('userInfo')) {
      userInfo = json['userInfo'] != null
          ? UserModel.fromJson(json['userInfo'])
          : null;
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['uid'] = uid;
    data['freelancer_id'] = freelancerId;
    data['salon_id'] = salonId;
    data['date_time'] = dateTime;
    data['paid_method'] = paidMethod;
    data['order_to'] = orderTo;
    data['orders'] = orders;
    data['notes'] = notes;
    data['address'] = address;
    data['total'] = total;
    data['tax'] = tax;
    data['grand_total'] = grandTotal;
    data['discount'] = discount;
    data['driver_id'] = driverId;
    data['delivery_charge'] = deliveryCharge;
    data['wallet_used'] = walletUsed;
    data['wallet_price'] = walletPrice;
    data['coupon_code'] = couponCode;
    data['extra'] = extra;
    data['pay_key'] = payKey;
    data['status'] = status;
    data['payStatus'] = payStatus;
    data['extra_field'] = extraField;
    data['created_at'] = createdAt;
    data['type'] = type;
    if (salonInfo != null) {
      data['salonInfo'] = salonInfo!.toJson();
    }
    return data;
  }
}

class SalonInfo {
  String? name;
  String? cover;
  String? address;

  SalonInfo({this.name, this.cover, this.address});

  SalonInfo.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    cover = json['cover'];
    address = json['address'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['name'] = name;
    data['cover'] = cover;
    data['address'] = address;
    return data;
  }
}

class FreelancerInfo {
  int? id;
  String? firstName;
  String? lastName;
  String? cover;
  String? type;

  FreelancerInfo(
      {this.id, this.firstName, this.lastName, this.cover, this.type});

  FreelancerInfo.fromJson(Map<String, dynamic> json) {
    id = int.parse(json['id'].toString());
    firstName = json['first_name'];
    lastName = json['last_name'];
    cover = json['cover'];
    type = json['type'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['first_name'] = firstName;
    data['last_name'] = lastName;
    data['cover'] = cover;
    data['type'] = type;
    return data;
  }
}

class UserModel {
  int? id;
  String? firstName;
  String? lastName;
  String? cover;

  UserModel({this.id, this.firstName, this.lastName, this.cover});

  UserModel.fromJson(Map<String, dynamic> json) {
    id = int.parse(json['id'].toString());
    firstName = json['first_name'];
    lastName = json['last_name'];
    cover = json['cover'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['first_name'] = firstName;
    data['last_name'] = lastName;
    data['cover'] = cover;
    return data;
  }
}

/*Papabear*/
import 'dart:convert';

import 'package:jiffy/jiffy.dart';
import 'package:ultimate_salon_owner_flutter/app/backend/models/address_model.dart';
import 'package:ultimate_salon_owner_flutter/app/product/models/product_list_model.dart';

class ProductOrderDetailsModel {
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
  String? statusLabel;
  String? extraField;
  String? createdAt;
  String? type;
  String? courier;
  String? trackingNumber;
  String? trackingUrl;
  String? shippedAt;
  String? estimatedDelivery;
  String? deliveredAt;
  List<OrderTrackingEvent> timeline = [];
  SalonInfo? salonInfo;
  FreelancerInfo? freelancerInfo;
  UserModel? userInfo;
  ProductOrderDetailsModel(
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
      this.statusLabel,
      this.extraField,
      this.createdAt,
      this.type,
      this.courier,
      this.trackingNumber,
      this.trackingUrl,
      this.shippedAt,
      this.estimatedDelivery,
      this.deliveredAt,
      List<OrderTrackingEvent>? timeline,
      this.salonInfo,
      this.freelancerInfo,
      this.userInfo})
      : timeline = timeline ?? [];

  ProductOrderDetailsModel.fromJson(Map<String, dynamic> json) {
    id = int.tryParse('${json['id'] ?? json['order_id'] ?? 0}') ?? 0;
    uid = int.tryParse('${json['uid'] ?? 0}') ?? 0;
    freelancerId = int.tryParse('${json['freelancer_id'] ?? 0}') ?? 0;
    salonId = int.tryParse('${json['salon_id'] ?? 0}') ?? 0;
    dateTime = json['date_time']?.toString();
    paidMethod = int.tryParse('${json['paid_method'] ?? 0}') ?? 0;
    orderTo = json['order_to']?.toString();
    orders = <ProductsListModel>[];
    final rawOrders = json['orders'];
    if (rawOrders != null && rawOrders != 'NA' && rawOrders != '') {
      try {
        dynamic orderList = rawOrders;
        if (rawOrders is String) {
          orderList = jsonDecode(rawOrders);
        }
        if (orderList is List) {
          for (final element in orderList) {
            if (element is Map) {
              orders!.add(ProductsListModel.fromJson(
                  Map<String, dynamic>.from(element)));
            }
          }
        }
      } catch (_) {
        orders = <ProductsListModel>[];
      }
    }
    notes = json['notes']?.toString();
    address = null;
    final rawAddress = json['address'];
    if (rawAddress != null &&
        rawAddress.toString().isNotEmpty &&
        rawAddress != 'NA') {
      try {
        final map = rawAddress is String
            ? jsonDecode(rawAddress)
            : rawAddress;
        if (map is Map) {
          address = AddressModel.fromJson(Map<String, dynamic>.from(map));
        }
      } catch (_) {
        address = null;
      }
    }
    total = double.tryParse('${json['total'] ?? 0}') ?? 0;
    tax = double.tryParse('${json['tax'] ?? 0}') ?? 0;
    grandTotal = double.tryParse('${json['grand_total'] ?? 0}') ?? 0;
    discount = double.tryParse('${json['discount'] ?? 0}') ?? 0;
    driverId = json['driver_id']?.toString();
    deliveryCharge =
        double.tryParse('${json['delivery_charge'] ?? 0}') ?? 0;
    walletUsed = int.tryParse('${json['wallet_used'] ?? 0}') ?? 0;
    walletPrice = double.tryParse('${json['wallet_price'] ?? 0}') ?? 0;
    couponCode = json['coupon_code']?.toString();
    extra = json['extra']?.toString();
    payKey = json['pay_key']?.toString();
    status = int.tryParse('${json['status'] ?? 0}') ?? 0;
    payStatus = int.tryParse(
            '${json['payStatus'] ?? json['pay_status'] ?? 0}') ??
        0;
    statusLabel = json['status_label']?.toString();
    extraField = json['extra_field']?.toString();
    createdAt = '';
    if (json['created_at'] != null) {
      try {
        createdAt = Jiffy.parse(json['created_at'].toString()).yMMMMd;
      } catch (_) {
        createdAt = json['created_at'].toString();
      }
    }
    type = json['type']?.toString();
    _applyTracking(json);
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

  void applyTrackingPayload(Map<String, dynamic> json) {
    if (json['status'] != null) {
      status = int.tryParse('${json['status']}') ?? status;
    }
    if (json['status_label'] != null) {
      statusLabel = json['status_label']?.toString();
    }
    _applyTracking(json);
  }

  void _applyTracking(Map<String, dynamic> json) {
    Map<String, dynamic>? tracking;
    final rawTracking = json['tracking'];
    if (rawTracking is Map) {
      tracking = Map<String, dynamic>.from(rawTracking);
    } else if (extraField != null &&
        extraField!.isNotEmpty &&
        extraField != 'null') {
      try {
        final parsed = jsonDecode(extraField!);
        if (parsed is Map && parsed['tracking'] is Map) {
          tracking = Map<String, dynamic>.from(parsed['tracking']);
        }
      } catch (_) {}
    }

    courier = (json['courier'] ?? tracking?['courier'])?.toString() ?? courier;
    trackingNumber = (json['tracking_number'] ??
            json['awb'] ??
            tracking?['tracking_number'] ??
            tracking?['awb'])
        ?.toString();
    trackingUrl =
        (json['tracking_url'] ?? tracking?['tracking_url'])?.toString();
    shippedAt = (json['shipped_at'] ?? tracking?['shipped_at'])?.toString();
    estimatedDelivery = (json['estimated_delivery'] ??
            tracking?['estimated_delivery'])
        ?.toString();
    deliveredAt =
        (json['delivered_at'] ?? tracking?['delivered_at'])?.toString();

    final rawTimeline = json['timeline'] ?? tracking?['timeline'];
    if (rawTimeline is List) {
      timeline = rawTimeline
          .whereType<Map>()
          .map((row) =>
              OrderTrackingEvent.fromJson(Map<String, dynamic>.from(row)))
          .toList();
    }
  }

  bool get hasTracking =>
      (courier ?? '').isNotEmpty ||
      (trackingNumber ?? '').isNotEmpty ||
      (trackingUrl ?? '').isNotEmpty ||
      timeline.isNotEmpty;

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

class OrderTrackingEvent {
  int status;
  String label;
  String at;
  String note;

  OrderTrackingEvent({
    this.status = 0,
    this.label = '',
    this.at = '',
    this.note = '',
  });

  factory OrderTrackingEvent.fromJson(Map<String, dynamic> json) {
    return OrderTrackingEvent(
      status: int.tryParse('${json['status'] ?? 0}') ?? 0,
      label: json['label']?.toString() ?? '',
      at: json['at']?.toString() ?? '',
      note: json['note']?.toString() ?? '',
    );
  }
}

class UserModel {
  int? id;
  String? firstName;
  String? lastName;
  String? email;
  String? countryCode;
  String? mobile;
  String? cover;
  int? gender;
  String? type;
  String? fcmToken;
  String? stripeKey;
  String? extraField;
  int? status;
  String? createdAt;
  String? updatedAt;

  UserModel(
      {this.id,
      this.firstName,
      this.lastName,
      this.email,
      this.countryCode,
      this.mobile,
      this.cover,
      this.gender,
      this.type,
      this.fcmToken,
      this.stripeKey,
      this.extraField,
      this.status,
      this.createdAt,
      this.updatedAt});

  UserModel.fromJson(Map<String, dynamic> json) {
    id = int.parse(json['id'].toString());
    firstName = json['first_name'];
    lastName = json['last_name'];
    email = json['email'];
    countryCode = json['country_code'];
    mobile = json['mobile'];
    cover = json['cover'];
    gender = int.parse(json['gender'].toString());
    type = json['type'];
    fcmToken = json['fcm_token'];
    stripeKey = json['stripe_key'];
    extraField = json['extra_field'];
    status = int.parse(json['status'].toString());
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['first_name'] = firstName;
    data['last_name'] = lastName;
    data['email'] = email;
    data['country_code'] = countryCode;
    data['mobile'] = mobile;
    data['cover'] = cover;
    data['gender'] = gender;
    data['type'] = type;
    data['fcm_token'] = fcmToken;
    data['stripe_key'] = stripeKey;
    data['extra_field'] = extraField;
    data['status'] = status;
    data['created_at'] = createdAt;
    data['updated_at'] = updatedAt;
    return data;
  }
}

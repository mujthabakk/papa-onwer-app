import 'dart:convert';

import 'package:jiffy/jiffy.dart';
import 'package:ultimate_salon_owner_flutter/app/backend/models/address_model.dart';
import 'package:ultimate_salon_owner_flutter/app/backend/models/service_cart_model.dart';

class AppointmentModel {
  int? id;
  int? uid;
  int? freelancerId;
  int? salonId;
  int? specialistId;
  int? appointmentsTo;
  AddressModel? address;
  ServiceCartModel? items;
  int? couponId;
  String? coupon;
  double? discount;
  double? distanceCost;
  double? total;
  double? serviceTax;
  double? grandTotal;
  int? payMethod;
  String? paid;
  String? saveDate;
  String? slot;
  int? walletUsed;
  double? walletPrice;
  String? notes;
  String? createdAt;
  String? extraField;
  int? status;
  SalonInfo? salonInfo;
  IndividualInfo? individualInfo;
  UserModel? userInfo;
  AppointmentModel(
      {this.id,
      this.uid,
      this.freelancerId,
      this.salonId,
      this.specialistId,
      this.appointmentsTo,
      this.address,
      this.items,
      this.couponId,
      this.coupon,
      this.discount,
      this.distanceCost,
      this.total,
      this.serviceTax,
      this.grandTotal,
      this.payMethod,
      this.paid,
      this.saveDate,
      this.slot,
      this.walletUsed,
      this.walletPrice,
      this.notes,
      this.extraField,
      this.status,
      this.createdAt,
      this.salonInfo,
      this.individualInfo,
      this.userInfo});

  AppointmentModel.fromJson(Map<String, dynamic> json) {
    id = _toInt(json['id']);
    uid = _toInt(json['uid']);
    freelancerId = _toInt(json['freelancer_id'] ?? json['freelancerId']);
    salonId = _toInt(json['salon_id'] ?? json['salonId']);
    specialistId = _toInt(json['specialist_id'] ?? json['specialistId']);
    appointmentsTo = _toInt(json['appointments_to'] ?? json['appointmentsTo']);
    address = _parseAddress(json['address']);
    items = _parseItems(json['items']);
    couponId = _toInt(json['coupon_id'] ?? json['couponId']);
    coupon = _toStr(json['coupon']);
    discount = _toDouble(json['discount']);
    distanceCost = _toDouble(json['distance_cost'] ?? json['distanceCost']);
    total = _toDouble(json['total']);
    serviceTax = _toDouble(
        json['serviceTax'] ?? json['service_tax'] ?? json['tax']);
    grandTotal = _toDouble(json['grand_total'] ?? json['grandTotal']);
    payMethod = _toInt(json['pay_method'] ?? json['payMethod']);
    paid = _toStr(json['paid']);
    saveDate = _formatDate(json['save_date'] ?? json['saveDate']);
    slot = _toStr(json['slot']);
    walletUsed = _toInt(json['wallet_used'] ?? json['walletUsed']);
    walletPrice = _toDouble(json['wallet_price'] ?? json['walletPrice']);
    notes = _toStr(json['notes']);
    extraField = _toStr(json['extra_field'] ?? json['extraField']);
    status = _toInt(json['status']) ?? 0;
    createdAt = _toStr(json['created_at'] ?? json['createdAt']);
    salonInfo = _parseSalonInfo(
        json['salonInfo'] ?? json['salon_info'] ?? json['salon']);
    individualInfo = _parseIndividualInfo(
        json['individualInfo'] ?? json['individual_info']);
    userInfo = _parseUserInfo(json['userInfo'] ?? json['user_info'] ?? json['user']);
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['uid'] = uid;
    data['freelancer_id'] = freelancerId;
    data['salon_id'] = salonId;
    data['specialist_id'] = specialistId;
    data['appointments_to'] = appointmentsTo;
    data['address'] = address;
    data['items'] = items;
    data['coupon_id'] = couponId;
    data['coupon'] = coupon;
    data['discount'] = discount;
    data['distance_cost'] = distanceCost;
    data['total'] = total;
    data['serviceTax'] = serviceTax;
    data['grand_total'] = grandTotal;
    data['pay_method'] = payMethod;
    data['paid'] = paid;
    data['save_date'] = saveDate;
    data['slot'] = slot;
    data['wallet_used'] = walletUsed;
    data['wallet_price'] = walletPrice;
    data['notes'] = notes;
    data['extra_field'] = extraField;
    data['status'] = status;
    data['created_at'] = createdAt;
    if (salonInfo != null) {
      data['salonInfo'] = salonInfo!.toJson();
    }
    return data;
  }
}

class SalonInfo {
  int? id;
  int? uid;
  String? name;
  String? cover;
  String? categories;
  String? address;
  String? lat;
  String? lng;
  int? cid;
  String? about;
  double? rating;
  int? totalRating;
  String? website;
  String? timing;
  String? images;
  String? zipcode;
  int? serviceAtHome;
  int? verified;
  int? inHome;
  int? popular;
  int? haveShop;
  int? haveStylist;
  String? extraField;
  int? status;

  SalonInfo(
      {this.id,
      this.uid,
      this.name,
      this.cover,
      this.categories,
      this.address,
      this.lat,
      this.lng,
      this.cid,
      this.about,
      this.rating,
      this.totalRating,
      this.website,
      this.timing,
      this.images,
      this.zipcode,
      this.serviceAtHome,
      this.verified,
      this.inHome,
      this.popular,
      this.haveShop,
      this.haveStylist,
      this.extraField,
      this.status});

  SalonInfo.fromJson(Map<String, dynamic> json) {
    id = _toInt(json['id']);
    uid = _toInt(json['uid']);
    name = _toStr(json['name']);
    cover = _toStr(json['cover']);
    categories = _toStr(json['categories']);
    address = _toStr(json['address']);
    lat = _toStr(json['lat']);
    lng = _toStr(json['lng']);
    cid = _toInt(json['cid']);
    about = _toStr(json['about']);
    rating = _toDouble(json['rating']);
    totalRating = _toInt(json['total_rating'] ?? json['totalRating']);
    website = _toStr(json['website']);
    timing = _toStr(json['timing']);
    images = _toStr(json['images']);
    zipcode = _toStr(json['zipcode']);
    serviceAtHome = _toInt(json['service_at_home']);
    verified = _toInt(json['verified']);
    inHome = _toInt(json['in_home']);
    popular = _toInt(json['popular']);
    haveShop = _toInt(json['have_shop']);
    haveStylist = _toInt(json['have_stylist']);
    extraField = _toStr(json['extra_field']);
    status = _toInt(json['status']);
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['uid'] = uid;
    data['name'] = name;
    data['cover'] = cover;
    data['categories'] = categories;
    data['address'] = address;
    data['lat'] = lat;
    data['lng'] = lng;
    data['cid'] = cid;
    data['about'] = about;
    data['rating'] = rating;
    data['total_rating'] = totalRating;
    data['website'] = website;
    data['timing'] = timing;
    data['images'] = images;
    data['zipcode'] = zipcode;
    data['service_at_home'] = serviceAtHome;
    data['verified'] = verified;
    data['in_home'] = inHome;
    data['popular'] = popular;
    data['have_shop'] = haveShop;
    data['have_stylist'] = haveStylist;
    data['extra_field'] = extraField;
    data['status'] = status;
    return data;
  }
}

class IndividualInfo {
  int? id;
  int? uid;
  String? background;
  String? categories;
  String? address;
  String? lat;
  String? lng;
  String? cid;
  String? about;
  double? rating;
  double? feeStart;
  int? totalRating;
  String? website;
  String? timing;
  String? images;
  String? zipcode;
  int? verified;
  int? inHome;
  int? popular;
  int? haveShop;
  String? extraField;
  int? status;
  String? createdAt;
  String? updatedAt;
  String? firstName;
  String? lastName;

  IndividualInfo(
      {this.id,
      this.uid,
      this.background,
      this.categories,
      this.address,
      this.lat,
      this.lng,
      this.cid,
      this.about,
      this.rating,
      this.feeStart,
      this.totalRating,
      this.website,
      this.timing,
      this.images,
      this.zipcode,
      this.verified,
      this.inHome,
      this.popular,
      this.haveShop,
      this.extraField,
      this.status,
      this.createdAt,
      this.updatedAt,
      this.firstName,
      this.lastName});

  IndividualInfo.fromJson(Map<String, dynamic> json) {
    id = _toInt(json['id']);
    uid = _toInt(json['uid']);
    background = _toStr(json['background']);
    categories = _toStr(json['categories']);
    address = _toStr(json['address']);
    lat = _toStr(json['lat']);
    lng = _toStr(json['lng']);
    cid = _toStr(json['cid']);
    about = _toStr(json['about']);
    rating = _toDouble(json['rating']);
    feeStart = _toDouble(json['fee_start']);
    totalRating = _toInt(json['total_rating']);
    website = _toStr(json['website']);
    timing = _toStr(json['timing']);
    images = _toStr(json['images']);
    zipcode = _toStr(json['zipcode']);
    verified = _toInt(json['verified']);
    inHome = _toInt(json['in_home']);
    popular = _toInt(json['popular']);
    haveShop = _toInt(json['have_shop']);
    extraField = _toStr(json['extra_field']);
    status = _toInt(json['status']);
    createdAt = _toStr(json['created_at']);
    updatedAt = _toStr(json['updated_at']);
    firstName = _toStr(json['first_name'] ?? json['firstName']);
    lastName = _toStr(json['last_name'] ?? json['lastName']);
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['uid'] = uid;
    data['background'] = background;
    data['categories'] = categories;
    data['address'] = address;
    data['lat'] = lat;
    data['lng'] = lng;
    data['cid'] = cid;
    data['about'] = about;
    data['rating'] = rating;
    data['fee_start'] = feeStart;
    data['total_rating'] = totalRating;
    data['website'] = website;
    data['timing'] = timing;
    data['images'] = images;
    data['zipcode'] = zipcode;
    data['verified'] = verified;
    data['in_home'] = inHome;
    data['popular'] = popular;
    data['have_shop'] = haveShop;
    data['extra_field'] = extraField;
    data['status'] = status;
    data['created_at'] = createdAt;
    data['updated_at'] = updatedAt;
    data['first_name'] = firstName;
    data['last_name'] = lastName;
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
    id = _toInt(json['id']);
    firstName = _toStr(json['first_name'] ?? json['firstName']);
    lastName = _toStr(json['last_name'] ?? json['lastName']);
    cover = _toStr(json['cover']);
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

int? _toInt(dynamic value) {
  if (value == null || value == '' || value == 'null') return null;
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.tryParse(value.toString());
}

double? _toDouble(dynamic value) {
  if (value == null || value == '' || value == 'null') return null;
  if (value is double) return value;
  if (value is num) return value.toDouble();
  return double.tryParse(value.toString());
}

String? _toStr(dynamic value) {
  if (value == null || value == 'null') return null;
  final text = value.toString();
  return text.isEmpty ? null : text;
}

dynamic _decodeMaybeJson(dynamic value) {
  if (value == null || value == '' || value == 'null') return null;
  if (value is Map || value is List) return value;
  if (value is String) {
    try {
      return jsonDecode(value);
    } catch (_) {
      return value;
    }
  }
  return value;
}

Map<String, dynamic>? _asMap(dynamic value) {
  final decoded = _decodeMaybeJson(value);
  if (decoded is Map) return Map<String, dynamic>.from(decoded);
  return null;
}

String? _formatDate(dynamic value) {
  final raw = _toStr(value);
  if (raw == null) return null;
  try {
    return Jiffy.parse(raw).yMMMMd;
  } catch (_) {
    return raw;
  }
}

AddressModel _parseAddress(dynamic value) {
  final map = _asMap(value);
  if (map == null) return AddressModel();
  try {
    return AddressModel.fromJson(map);
  } catch (_) {
    return AddressModel();
  }
}

ServiceCartModel _parseItems(dynamic value) {
  final map = _asMap(value);
  if (map == null) return ServiceCartModel();
  try {
    return ServiceCartModel.fromJson(map);
  } catch (_) {
    return ServiceCartModel();
  }
}

SalonInfo? _parseSalonInfo(dynamic value) {
  final map = _asMap(value);
  if (map == null) return null;
  try {
    return SalonInfo.fromJson(map);
  } catch (_) {
    return null;
  }
}

IndividualInfo? _parseIndividualInfo(dynamic value) {
  final map = _asMap(value);
  if (map == null) return null;
  try {
    return IndividualInfo.fromJson(map);
  } catch (_) {
    return null;
  }
}

UserModel? _parseUserInfo(dynamic value) {
  final map = _asMap(value);
  if (map == null) return null;
  try {
    return UserModel.fromJson(map);
  } catch (_) {
    return null;
  }
}

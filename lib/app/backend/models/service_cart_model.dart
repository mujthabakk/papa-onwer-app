import 'package:ultimate_salon_owner_flutter/app/backend/models/packages_details_model.dart';
import 'package:ultimate_salon_owner_flutter/app/backend/models/services_model.dart';

class ServiceCartModel {
  List<ServicesModel>? services;
  List<PackagesDetailsModel>? packages;

  ServiceCartModel({this.services, this.packages});

  ServiceCartModel.fromJson(Map<String, dynamic> json) {
    services = <ServicesModel>[];
    final rawServices = json['services'];
    if (rawServices is List) {
      for (final v in rawServices) {
        if (v is! Map) continue;
        try {
          services!.add(ServicesModel.fromJson(Map<String, dynamic>.from(v)));
        } catch (_) {}
      }
    }

    packages = <PackagesDetailsModel>[];
    final rawPackages = json['packages'];
    if (rawPackages is List) {
      for (final v in rawPackages) {
        if (v is! Map) continue;
        try {
          packages!
              .add(PackagesDetailsModel.fromJson(Map<String, dynamic>.from(v)));
        } catch (_) {}
      }
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (services != null) {
      data['services'] = services!.map((v) => v.toJson()).toList();
    }
    if (packages != null) {
      data['packages'] = packages!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

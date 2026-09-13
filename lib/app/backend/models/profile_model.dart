class ProfileModel {
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

  // Missing fields added
  String? bankName;
  String? bankIfsc;
  String? bankAccountNumber;
  String? bankCustomerName;
  String? whatsappNumber;
  String? filters;
  String? facilities;
  String? pan;
  String? vat;

  List<WebCatesData>? webCatesData;
  List<FecilitiesData>? fecilitiesCatesData;
  CityData? cityData;

  ProfileModel({
    this.id,
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
    this.status,
    this.bankName,
    this.bankIfsc,
    this.bankAccountNumber,
    this.bankCustomerName,
    this.whatsappNumber,
    this.filters,
    this.facilities,
    this.pan,
    this.vat,
    this.webCatesData,
    this.fecilitiesCatesData,
    this.cityData,
  });

  ProfileModel.fromJson(Map<String, dynamic> json) {
    id = int.tryParse(json['id']?.toString() ?? '');
    uid = int.tryParse(json['uid']?.toString() ?? '');
    name = json['name'];
    cover = json['cover'];
    categories = json['categories'];
    address = json['address'];
    lat = json['lat'];
    lng = json['lng'];
    cid = int.tryParse(json['cid']?.toString() ?? '');
    about = json['about'];
    rating = double.tryParse(json['rating']?.toString() ?? '');
    totalRating = int.tryParse(json['total_rating']?.toString() ?? '');
    website = json['website'];
    timing = json['timing'] ?? 'NA';
    images = json['images'] ?? 'NA';
    zipcode = json['zipcode'];
    serviceAtHome = int.tryParse(json['service_at_home']?.toString() ?? '');
    verified = int.tryParse(json['verified']?.toString() ?? '');
    inHome = int.tryParse(json['in_home']?.toString() ?? '');
    popular = int.tryParse(json['popular']?.toString() ?? '');
    haveShop = int.tryParse(json['have_shop']?.toString() ?? '');
    haveStylist = int.tryParse(json['have_stylist']?.toString() ?? '');
    extraField = json['extra_field'];
    status = int.tryParse(json['status']?.toString() ?? '');

    // Missing fields parsing
    bankName = json['bank_name'];
    bankIfsc = json['bank_ifsc'];
    bankAccountNumber = json['bank_account_number'];
    bankCustomerName = json['bank_customer_name'];
    whatsappNumber = json['whatsapp_number'];
    filters = json['filters'];
    facilities = json['facilities'];
    pan = json['pan'];
    vat = json['vat'];

    if (json['web_cates_data'] != null) {
      webCatesData = <WebCatesData>[];
      json['web_cates_data'].forEach((v) {
        webCatesData!.add(WebCatesData.fromJson(v));
      });
    }
    if (json['facilities_data'] != null) {
      fecilitiesCatesData = <FecilitiesData>[];
      json['facilities_data'].forEach((v) {
        fecilitiesCatesData!.add(FecilitiesData.fromJson(v));
      });
    }
    cityData =
        json['city_data'] != null ? CityData.fromJson(json['city_data']) : null;
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

    // Missing fields serialization
    data['bank_name'] = bankName;
    data['bank_ifsc'] = bankIfsc;
    data['bank_account_number'] = bankAccountNumber;
    data['bank_customer_name'] = bankCustomerName;
    data['whatsapp_number'] = whatsappNumber;
    data['filters'] = filters;
    data['facilities'] = facilities;
    data['pan'] = pan;
    data['vat'] = vat;

    if (webCatesData != null) {
      data['web_cates_data'] = webCatesData!.map((v) => v.toJson()).toList();
    }
    if (fecilitiesCatesData != null) {
      data['facilities_data'] =
          fecilitiesCatesData!.map((v) => v.toJson()).toList();
    }
    if (cityData != null) {
      data['city_data'] = cityData!.toJson();
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
    id = int.tryParse(json['id']?.toString() ?? '');
    name = json['name'];
    cover = json['cover'];
    extraField = json['extra_field'];
    status = int.tryParse(json['status']?.toString() ?? '');
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

class FecilitiesData {
  int? id;
  String? name;

  FecilitiesData({this.id, this.name});

  FecilitiesData.fromJson(Map<String, dynamic> json) {
    id = int.tryParse(json['id']?.toString() ?? '');
    name = json['name'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['name'] = name;
    return data;
  }
}

class CityData {
  int? id;
  String? name;
  String? lat;
  String? lng;
  String? country; // Added missing field
  String? extraField;
  int? status;

  CityData({
    this.id,
    this.name,
    this.lat,
    this.lng,
    this.country,
    this.extraField,
    this.status,
  });

  CityData.fromJson(Map<String, dynamic> json) {
    id = int.tryParse(json['id']?.toString() ?? '');
    name = json['name'];
    lat = json['lat'];
    lng = json['lng'];
    country = json['country']; // Added missing field parsing
    extraField = json['extra_field'];
    status = int.tryParse(json['status']?.toString() ?? '');
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['name'] = name;
    data['lat'] = lat;
    data['lng'] = lng;
    data['country'] = country; // Added missing field serialization
    data['extra_field'] = extraField;
    data['status'] = status;
    return data;
  }
}

// Main API Response Model
class ComplaintResponse {
  final List<Complaint> data;
  final bool success;
  final int status;

  const ComplaintResponse({
    required this.data,
    required this.success,
    required this.status,
  });

  factory ComplaintResponse.fromJson(Map<String, dynamic> json) {
    return ComplaintResponse(
      data: (json['data'] as List<dynamic>)
          .map((item) => Complaint.fromJson(item as Map<String, dynamic>))
          .toList(),
      success: json['success'] as bool,
      status: json['status'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'data': data.map((complaint) => complaint.toJson()).toList(),
      'success': success,
      'status': status,
    };
  }
}

// Main Complaint Model
class Complaint {
  final int id;
  final int uid;
  final int orderId;
  final int appointmentId;
  final int complaintsOn;
  final int issueWith;
  final int? driverId;
  final int? freelancerId;
  final int productId;
  final int reasonId;
  final String title;
  final String shortMessage;
  final String images;
  final String? extraField;
  final int status;
  final UserInfo userInfo;
  final StoreInfo storeInfo;
  final StoreUserInfo storeUserInfo;
  final ProductInfo? productInfo;

  const Complaint({
    required this.id,
    required this.uid,
    required this.orderId,
    required this.appointmentId,
    required this.complaintsOn,
    required this.issueWith,
    this.driverId,
    this.freelancerId,
    required this.productId,
    required this.reasonId,
    required this.title,
    required this.shortMessage,
    required this.images,
    this.extraField,
    required this.status,
    required this.userInfo,
    required this.storeInfo,
    required this.storeUserInfo,
    this.productInfo,
  });

  factory Complaint.fromJson(Map<String, dynamic> json) {
    return Complaint(
      id: json['id'] as int,
      uid: json['uid'] as int,
      orderId: json['order_id'] as int,
      appointmentId: json['appointment_id'] as int,
      complaintsOn: json['complaints_on'] as int,
      issueWith: json['issue_with'] as int,
      driverId: json['driver_id'] as int?,
      freelancerId: json['freelancer_id'] as int?,
      productId: json['product_id'] as int,
      reasonId: json['reason_id'] as int,
      title: json['title'] as String,
      shortMessage: json['short_message'] as String,
      images: json['images'] as String,
      extraField: json['extra_field'] as String?,
      status: json['status'] as int,
      userInfo: UserInfo.fromJson(json['userInfo'] as Map<String, dynamic>),
      storeInfo: StoreInfo.fromJson(json['storeInfo'] as Map<String, dynamic>),
      storeUserInfo: StoreUserInfo.fromJson(
          json['storeUiserInfo'] as Map<String, dynamic>),
      productInfo: json['productInfo'] != null
          ? ProductInfo.fromJson(json['productInfo'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'uid': uid,
      'order_id': orderId,
      'appointment_id': appointmentId,
      'complaints_on': complaintsOn,
      'issue_with': issueWith,
      'driver_id': driverId,
      'freelancer_id': freelancerId,
      'product_id': productId,
      'reason_id': reasonId,
      'title': title,
      'short_message': shortMessage,
      'images': images,
      'extra_field': extraField,
      'status': status,
      'userInfo': userInfo.toJson(),
      'storeInfo': storeInfo.toJson(),
      'storeUiserInfo': storeUserInfo.toJson(),
      'productInfo': productInfo?.toJson(),
    };
  }

  // Helper method to parse images as a list
  List<String> get imagesList {
    try {
      // Remove brackets and quotes, then split by comma
      String cleanImages = images.replaceAll(RegExp(r'[\[\]"]'), '');
      return cleanImages
          .split(',')
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty)
          .toList();
    } catch (e) {
      return [];
    }
  }

  // copyWith method for creating modified copies
  Complaint copyWith({
    int? id,
    int? uid,
    int? orderId,
    int? appointmentId,
    int? complaintsOn,
    int? issueWith,
    int? driverId,
    int? freelancerId,
    int? productId,
    int? reasonId,
    String? title,
    String? shortMessage,
    String? images,
    String? extraField,
    int? status,
    UserInfo? userInfo,
    StoreInfo? storeInfo,
    StoreUserInfo? storeUserInfo,
    ProductInfo? productInfo,
  }) {
    return Complaint(
      id: id ?? this.id,
      uid: uid ?? this.uid,
      orderId: orderId ?? this.orderId,
      appointmentId: appointmentId ?? this.appointmentId,
      complaintsOn: complaintsOn ?? this.complaintsOn,
      issueWith: issueWith ?? this.issueWith,
      driverId: driverId ?? this.driverId,
      freelancerId: freelancerId ?? this.freelancerId,
      productId: productId ?? this.productId,
      reasonId: reasonId ?? this.reasonId,
      title: title ?? this.title,
      shortMessage: shortMessage ?? this.shortMessage,
      images: images ?? this.images,
      extraField: extraField ?? this.extraField,
      status: status ?? this.status,
      userInfo: userInfo ?? this.userInfo,
      storeInfo: storeInfo ?? this.storeInfo,
      storeUserInfo: storeUserInfo ?? this.storeUserInfo,
      productInfo: productInfo ?? this.productInfo,
    );
  }
}

// User Info Model
class UserInfo {
  final String email;
  final String firstName;
  final String lastName;
  final String cover;

  const UserInfo({
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.cover,
  });

  factory UserInfo.fromJson(Map<String, dynamic> json) {
    return UserInfo(
      email: json['email'] as String,
      firstName: json['first_name'] as String,
      lastName: json['last_name'] as String,
      cover: json['cover'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'first_name': firstName,
      'last_name': lastName,
      'cover': cover,
    };
  }

  // Helper method to get full name
  String get fullName => '$firstName $lastName';

  UserInfo copyWith({
    String? email,
    String? firstName,
    String? lastName,
    String? cover,
  }) {
    return UserInfo(
      email: email ?? this.email,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      cover: cover ?? this.cover,
    );
  }
}

// Store Info Model
class StoreInfo {
  final String name;
  final String cover;

  const StoreInfo({
    required this.name,
    required this.cover,
  });

  factory StoreInfo.fromJson(Map<String, dynamic> json) {
    return StoreInfo(
      name: json['name'] as String,
      cover: json['cover'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'cover': cover,
    };
  }

  StoreInfo copyWith({
    String? name,
    String? cover,
  }) {
    return StoreInfo(
      name: name ?? this.name,
      cover: cover ?? this.cover,
    );
  }
}

// Store User Info Model
class StoreUserInfo {
  final String email;
  final String cover;

  const StoreUserInfo({
    required this.email,
    required this.cover,
  });

  factory StoreUserInfo.fromJson(Map<String, dynamic> json) {
    return StoreUserInfo(
      email: json['email'] as String,
      cover: json['cover'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'cover': cover,
    };
  }

  StoreUserInfo copyWith({
    String? email,
    String? cover,
  }) {
    return StoreUserInfo(
      email: email ?? this.email,
      cover: cover ?? this.cover,
    );
  }
}

// Product Info Model
class ProductInfo {
  final String name;
  final String cover;

  const ProductInfo({
    required this.name,
    required this.cover,
  });

  factory ProductInfo.fromJson(Map<String, dynamic> json) {
    return ProductInfo(
      name: json['name'] as String,
      cover: json['cover'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'cover': cover,
    };
  }

  ProductInfo copyWith({
    String? name,
    String? cover,
  }) {
    return ProductInfo(
      name: name ?? this.name,
      cover: cover ?? this.cover,
    );
  }
}

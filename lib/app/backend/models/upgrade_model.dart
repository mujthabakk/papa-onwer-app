class SalonUpgradeResponse {
  final bool status;
  final String message;

  SalonUpgradeResponse({required this.status, required this.message});

  factory SalonUpgradeResponse.fromJson(Map<String, dynamic> json) {
    return SalonUpgradeResponse(
      status: json['status'],
      message: json['message'],
    );
  }
}

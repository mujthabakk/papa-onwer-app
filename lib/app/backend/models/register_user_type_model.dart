class RegisterUserType {
  final String type;
  final String label;

  RegisterUserType({required this.type, required this.label});

  factory RegisterUserType.fromJson(Map<String, dynamic> json) {
    return RegisterUserType(
      type: json['type']?.toString() ?? '',
      label: json['label']?.toString() ?? json['type']?.toString() ?? '',
    );
  }

  bool get isSalon => type == 'salon';
  bool get isIndividual => type == 'individual';
  bool get isProduct => type == 'product';
}

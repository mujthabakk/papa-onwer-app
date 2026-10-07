class PaymentOptionsModel {
  final int id;
  final int uid;
  final int bookId;
  final int appointmentId;
  final double amount;
  final String currency;
  final int payMethod;
  final String payMethodLabel;
  final int appointmentStatus;
  final String statusLabel;
  final String paymentStatus;
  final String saveDate;
  final String slot;
  final int salonId;
  final int freelancerId;
  final bool isPaid;
  final bool isPaymentCompleted;
  final bool canPayNow;
  final bool showPayNow;
  final bool showCod;
  final bool codAvailable;
  final bool onlineAvailable;
  final bool paymentRequired;
  final String message;
  final String paymentType;
  final String currencyCode;
  final String currencySymbol;
  final String preferredCountry;

  PaymentOptionsModel({
    this.id = 0,
    this.uid = 0,
    this.bookId = 0,
    this.appointmentId = 0,
    this.amount = 0,
    this.currency = '',
    this.payMethod = 0,
    this.payMethodLabel = '',
    this.appointmentStatus = 0,
    this.statusLabel = '',
    this.paymentStatus = '',
    this.saveDate = '',
    this.slot = '',
    this.salonId = 0,
    this.freelancerId = 0,
    this.isPaid = false,
    this.isPaymentCompleted = false,
    this.canPayNow = false,
    this.showPayNow = false,
    this.showCod = false,
    this.codAvailable = false,
    this.onlineAvailable = false,
    this.paymentRequired = false,
    this.message = '',
    this.paymentType = '',
    this.currencyCode = '',
    this.currencySymbol = '',
    this.preferredCountry = '',
  });

  factory PaymentOptionsModel.fromJson(Map<String, dynamic> json) {
    return PaymentOptionsModel(
      id: _toInt(json['id'] ?? json['book_id'] ?? json['appointment_id']),
      uid: _toInt(json['uid']),
      bookId: _toInt(json['book_id'] ?? json['appointment_id'] ?? json['id']),
      appointmentId:
          _toInt(json['appointment_id'] ?? json['book_id'] ?? json['id']),
      amount: _toDouble(json['amount'] ?? json['grand_total']),
      currency: json['currency']?.toString() ??
          json['currencyCode']?.toString() ??
          '',
      payMethod: _toInt(json['pay_method']),
      payMethodLabel: json['pay_method_label']?.toString() ?? '',
      appointmentStatus: _toInt(
          json['appointment_status'] ?? json['status']),
      statusLabel: json['status_label']?.toString() ?? '',
      paymentStatus: json['payment_status']?.toString() ?? '',
      saveDate: json['save_date']?.toString() ?? '',
      slot: json['slot']?.toString() ?? '',
      salonId: _toInt(json['salon_id']),
      freelancerId: _toInt(json['freelancer_id']),
      isPaid: _parsePaid(json),
      isPaymentCompleted: _parseBool(json['is_payment_completed']) ||
          _parsePaid(json),
      canPayNow: _parseBool(json['can_pay_now']),
      showPayNow: _parseBool(json['show_pay_now']),
      showCod: _parseBool(json['show_cod']),
      codAvailable: _parseBool(json['cod_available'] ?? json['cod_enabled']),
      onlineAvailable:
          _parseBool(json['online_available'] ?? json['online_enabled']),
      paymentRequired: _parseBool(json['payment_required']),
      message: json['message']?.toString() ?? '',
      paymentType: json['payment_type']?.toString() ?? '',
      currencyCode: json['currencyCode']?.toString() ??
          json['currency']?.toString() ??
          '',
      currencySymbol: json['currencySymbol']?.toString() ??
          json['currency_symbol']?.toString() ??
          '',
      preferredCountry: json['preferred_country']?.toString() ?? '',
    );
  }

  PaymentOptionsModel copyWithFlags({
    bool? isPaid,
    bool? canPayNow,
    bool? showPayNow,
    bool? showCod,
    String? paymentStatus,
    String? paymentType,
  }) {
    return PaymentOptionsModel(
      id: id,
      uid: uid,
      bookId: bookId,
      appointmentId: appointmentId,
      amount: amount,
      currency: currency,
      payMethod: payMethod,
      payMethodLabel: payMethodLabel,
      appointmentStatus: appointmentStatus,
      statusLabel: statusLabel,
      paymentStatus: paymentStatus ?? this.paymentStatus,
      saveDate: saveDate,
      slot: slot,
      salonId: salonId,
      freelancerId: freelancerId,
      isPaid: isPaid ?? this.isPaid,
      isPaymentCompleted: isPaid ?? this.isPaymentCompleted,
      canPayNow: canPayNow ?? this.canPayNow,
      showPayNow: showPayNow ?? this.showPayNow,
      showCod: showCod ?? this.showCod,
      codAvailable: codAvailable,
      onlineAvailable: onlineAvailable,
      paymentRequired: paymentRequired,
      message: message,
      paymentType: paymentType ?? this.paymentType,
      currencyCode: currencyCode,
      currencySymbol: currencySymbol,
      preferredCountry: preferredCountry,
    );
  }
}

bool _parsePaid(Map<String, dynamic> json) {
  if (_parseBool(json['is_paid']) || _parseBool(json['is_payment_completed'])) {
    return true;
  }
  final status = json['payment_status']?.toString().toLowerCase() ?? '';
  return status == 'paid';
}

bool _parseBool(dynamic value) {
  if (value is bool) return value;
  if (value is int) return value == 1;
  final text = value?.toString().toLowerCase() ?? '';
  return text == 'true' || text == '1' || text == 'paid';
}

int _toInt(dynamic value, [int fallback = 0]) {
  if (value is int) return value;
  return int.tryParse(value?.toString() ?? '') ?? fallback;
}

double _toDouble(dynamic value, [double fallback = 0]) {
  if (value is double) return value;
  if (value is int) return value.toDouble();
  return double.tryParse(value?.toString() ?? '') ?? fallback;
}

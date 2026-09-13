import 'dart:convert';

class WithdrawalResponse {
  final bool success;
  final List<Withdrawal> withdrawals;
  final num totalAmount;
  final num codCommission;
  final num codCommissionPercentage;

  WithdrawalResponse({
    required this.success,
    required this.withdrawals,
    required this.totalAmount,
    required this.codCommission,
    required this.codCommissionPercentage,
  });

  factory WithdrawalResponse.fromJson(Map<String, dynamic> json) {
    final num parsedTotalAmount = _toNum(json['totalAmount']);
    final num parsedCodCommission = _toNum(json['CODCommission']);
    final num parsedWalletBalance = parsedTotalAmount + parsedCodCommission;
    num parsedCodCommissionPercentage = _toNum(
      json['CODCommissionPercent'] ??
          json['CODCommissionPercentage'] ??
          json['codCommissionPercent'] ??
          json['codCommissionPercentage'] ??
          json['cod_commission_percent'],
    );

    if (parsedCodCommissionPercentage <= 0 && parsedWalletBalance > 0) {
      parsedCodCommissionPercentage =
          (parsedCodCommission * 100) / parsedWalletBalance;
    }

    return WithdrawalResponse(
      success: json['success'] ?? false,
      withdrawals: (json['withdrawals'] as List<dynamic>?)
              ?.map((x) => Withdrawal.fromJson(x))
              .toList() ??
          [],
      totalAmount: parsedTotalAmount,
      codCommission: parsedCodCommission,
      codCommissionPercentage: parsedCodCommissionPercentage,
    );
  }

  static num _toNum(dynamic value) {
    if (value == null) {
      return 0;
    }

    if (value is num) {
      return value;
    }

    if (value is String) {
      final String sanitizedValue = value.replaceAll('%', '').trim();
      return num.tryParse(sanitizedValue) ?? 0;
    }

    return 0;
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'withdrawals': withdrawals.map((x) => x.toJson()).toList(),
      'totalAmount': totalAmount,
      'CODCommission': codCommission,
      'CODCommissionPercent': codCommissionPercentage,
    };
  }
}

class Withdrawal {
  final int id;
  final int uid;
  final num amount;
  final String withdrawalDate;
  final String status;

  Withdrawal({
    required this.id,
    required this.uid,
    required this.amount,
    required this.withdrawalDate,
    required this.status,
  });

  factory Withdrawal.fromJson(Map<String, dynamic> json) {
    return Withdrawal(
      id: json['id'] ?? 0,
      uid: json['uid'] ?? 0,
      amount: json['amount'] ?? 0,
      withdrawalDate: json['withdrawal_date'] ?? '',
      status: json['status'] ?? 'pending',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'uid': uid,
      'amount': amount,
      'withdrawal_date': withdrawalDate,
      'status': status,
    };
  }
}

class ProductHistoryBundle {
  Map<String, int> counts = {};
  Map<String, num> totals = {};
  List<ProductHistoryRow> futureOrders = [];
  List<ProductHistoryRow> currentOrders = [];
  List<ProductHistoryRow> pastDeliveries = [];
  List<ProductHistoryRow> cancelled = [];

  ProductHistoryBundle();

  factory ProductHistoryBundle.fromResponse(Map<String, dynamic> json) {
    final bundle = ProductHistoryBundle();
    final counts = json['counts'] ?? json['history_counts'];
    if (counts is Map) {
      counts.forEach((key, value) {
        bundle.counts[key.toString()] =
            int.tryParse('$value') ?? 0;
      });
    }
    final totals = json['totals'] ?? json['history_totals'];
    if (totals is Map) {
      totals.forEach((key, value) {
        bundle.totals[key.toString()] = num.tryParse('$value') ?? 0;
      });
    }
    final sections = json['sections'] is Map
        ? Map<String, dynamic>.from(json['sections'])
        : (json['data'] is Map
            ? Map<String, dynamic>.from(json['data'])
            : (json['history'] is Map
                ? Map<String, dynamic>.from(json['history'])
                : <String, dynamic>{}));
    bundle.futureOrders = _rows(sections['future_orders']);
    bundle.currentOrders = _rows(sections['current_orders']);
    bundle.pastDeliveries = _rows(sections['past_deliveries']);
    bundle.cancelled = _rows(sections['cancelled']);
    bundle.futureOrders.sort((a, b) => (a.deliveryAt ?? '')
        .compareTo(b.deliveryAt ?? ''));
    return bundle;
  }

  static List<ProductHistoryRow> _rows(dynamic raw) {
    if (raw is! List) return [];
    return raw
        .whereType<Map>()
        .map((row) =>
            ProductHistoryRow.fromJson(Map<String, dynamic>.from(row)))
        .toList();
  }

  int count(String key) {
    if (counts[key] != null) return counts[key]!;
    switch (key) {
      case 'future_orders':
        return futureOrders.length;
      case 'current_orders':
        return currentOrders.length;
      case 'past_deliveries':
        return pastDeliveries.length;
      case 'cancelled':
        return cancelled.length;
      default:
        return futureOrders.length +
            currentOrders.length +
            pastDeliveries.length +
            cancelled.length;
    }
  }

  bool get isEmpty =>
      futureOrders.isEmpty &&
      currentOrders.isEmpty &&
      pastDeliveries.isEmpty &&
      cancelled.isEmpty;
}

class ProductHistoryRow {
  int? orderId;
  String? section;
  String? orderedAt;
  String? deliveryAt;
  String? deliveryDate;
  String? customer;
  String? customerPhone;
  String? seller;
  String? item;
  String? color;
  int? qty;
  num? amount;
  num? paidAmount;
  String? payment;
  int? status;
  String? statusLabel;
  String? deliveryType;
  String? orderTo;
  String? address;

  ProductHistoryRow();

  factory ProductHistoryRow.fromJson(Map<String, dynamic> json) {
    return ProductHistoryRow()
      ..orderId = int.tryParse('${json['order_id'] ?? json['id'] ?? ''}')
      ..section = json['section']?.toString()
      ..orderedAt = json['ordered_at']?.toString()
      ..deliveryAt = json['delivery_at']?.toString()
      ..deliveryDate =
          (json['delivery_date'] ?? json['delivery_at'])?.toString()
      ..customer = json['customer']?.toString()
      ..customerPhone = json['customer_phone']?.toString()
      ..seller = json['seller']?.toString()
      ..item = json['item']?.toString()
      ..color = json['color']?.toString()
      ..qty = int.tryParse('${json['qty'] ?? 1}') ?? 1
      ..amount = num.tryParse('${json['amount'] ?? 0}')
      ..paidAmount = num.tryParse('${json['paid_amount'] ?? 0}')
      ..payment = json['payment']?.toString()
      ..status = int.tryParse('${json['status'] ?? ''}')
      ..statusLabel = json['status_label']?.toString()
      ..deliveryType = json['delivery_type']?.toString()
      ..orderTo = json['order_to']?.toString()
      ..address = json['address']?.toString();
  }
}

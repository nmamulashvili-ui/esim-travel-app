/// Represents a purchase order for an eSIM bundle.
class Order {
  final String id;
  final String bundleId;
  final String region;
  final String dataAmount;
  final int validityDays;
  final double totalUsd;
  final OrderStatus status;
  final DateTime createdAt;
  final String? iccid;

  const Order({
    required this.id,
    required this.bundleId,
    required this.region,
    required this.dataAmount,
    required this.validityDays,
    required this.totalUsd,
    required this.status,
    required this.createdAt,
    this.iccid,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      id: json['id'] as String,
      bundleId: json['bundle_id'] as String,
      region: json['region'] as String,
      dataAmount: json['data_amount'] as String,
      validityDays: json['validity_days'] as int,
      totalUsd: (json['total_usd'] as num).toDouble(),
      status: OrderStatus.values.byName(json['status'] as String),
      createdAt: DateTime.parse(json['created_at'] as String),
      iccid: json['iccid'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'bundle_id': bundleId,
        'region': region,
        'data_amount': dataAmount,
        'validity_days': validityDays,
        'total_usd': totalUsd,
        'status': status.name,
        'created_at': createdAt.toIso8601String(),
        'iccid': iccid,
      };
}

enum OrderStatus { pending, paid, provisioning, active, expired, failed }

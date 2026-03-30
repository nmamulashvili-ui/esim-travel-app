/// Represents a purchasable data bundle for a specific region.
class DataBundle {
  final String id;
  final String region;
  final String regionCode;
  final String dataAmount;
  final int validityDays;
  final double priceUsd;
  final List<String> features;
  final BundleTag? tag;

  const DataBundle({
    required this.id,
    required this.region,
    required this.regionCode,
    required this.dataAmount,
    required this.validityDays,
    required this.priceUsd,
    this.features = const [],
    this.tag,
  });

  /// Price per day for comparison.
  double get pricePerDay => priceUsd / validityDays;

  /// Price per GB (returns 0 for unlimited).
  double get pricePerGb {
    final gb = double.tryParse(
        dataAmount.replaceAll(RegExp(r'[^0-9.]'), ''));
    if (gb == null || gb == 0) return 0;
    return priceUsd / gb;
  }

  factory DataBundle.fromJson(Map<String, dynamic> json) {
    return DataBundle(
      id: json['id'] as String,
      region: json['region'] as String,
      regionCode: json['region_code'] as String,
      dataAmount: json['data_amount'] as String,
      validityDays: json['validity_days'] as int,
      priceUsd: (json['price_usd'] as num).toDouble(),
      features: List<String>.from(json['features'] ?? []),
      tag: json['tag'] != null
          ? BundleTag.values.byName(json['tag'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'region': region,
        'region_code': regionCode,
        'data_amount': dataAmount,
        'validity_days': validityDays,
        'price_usd': priceUsd,
        'features': features,
        'tag': tag?.name,
      };
}

enum BundleTag { popular, bestValue, unlimited }

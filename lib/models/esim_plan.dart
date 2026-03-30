/// Represents a single eSIM data plan available for purchase.
class EsimPlan {
  final String id;
  final String country;
  final String countryCode; // ISO 3166-1 alpha-2
  final String operator;
  final String dataAmount; // e.g. "5 GB"
  final int validityDays;
  final double priceUsd;
  final List<String> features;

  const EsimPlan({
    required this.id,
    required this.country,
    required this.countryCode,
    required this.operator,
    required this.dataAmount,
    required this.validityDays,
    required this.priceUsd,
    this.features = const [],
  });

  /// Ready for future API integration.
  factory EsimPlan.fromJson(Map<String, dynamic> json) {
    return EsimPlan(
      id: json['id'] as String,
      country: json['country'] as String,
      countryCode: json['country_code'] as String,
      operator: json['operator'] as String,
      dataAmount: json['data_amount'] as String,
      validityDays: json['validity_days'] as int,
      priceUsd: (json['price_usd'] as num).toDouble(),
      features: List<String>.from(json['features'] ?? []),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'country': country,
        'country_code': countryCode,
        'operator': operator,
        'data_amount': dataAmount,
        'validity_days': validityDays,
        'price_usd': priceUsd,
        'features': features,
      };
}

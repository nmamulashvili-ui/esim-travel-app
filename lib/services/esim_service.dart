import '../models/esim_plan.dart';

/// Contract for fetching eSIM data.
/// Swap [MockEsimService] for a real HTTP implementation later.
abstract class EsimService {
  Future<List<EsimPlan>> getPlans();
  Future<EsimPlan> getPlanById(String id);
  Future<List<EsimPlan>> searchByCountry(String query);
}

/// In-memory mock that lets you build the full UI without a backend.
class MockEsimService implements EsimService {
  // Simulate network latency so loading states are visible.
  static const _fakeDelay = Duration(milliseconds: 600);

  static final List<EsimPlan> _catalog = [
    const EsimPlan(
      id: 'us-5gb-7d',
      country: 'United States',
      countryCode: 'US',
      operator: 'T-Mobile',
      dataAmount: '5 GB',
      validityDays: 7,
      priceUsd: 11.99,
      features: ['4G/LTE', 'Hotspot included'],
    ),
    const EsimPlan(
      id: 'jp-3gb-15d',
      country: 'Japan',
      countryCode: 'JP',
      operator: 'NTT Docomo',
      dataAmount: '3 GB',
      validityDays: 15,
      priceUsd: 9.49,
      features: ['5G ready', 'Unlimited calls (local)'],
    ),
    const EsimPlan(
      id: 'de-10gb-30d',
      country: 'Germany',
      countryCode: 'DE',
      operator: 'Deutsche Telekom',
      dataAmount: '10 GB',
      validityDays: 30,
      priceUsd: 19.99,
      features: ['5G ready', 'EU roaming'],
    ),
    const EsimPlan(
      id: 'gb-5gb-14d',
      country: 'United Kingdom',
      countryCode: 'GB',
      operator: 'Three',
      dataAmount: '5 GB',
      validityDays: 14,
      priceUsd: 12.49,
      features: ['4G/LTE', 'Tethering'],
    ),
    const EsimPlan(
      id: 'th-unlimited-7d',
      country: 'Thailand',
      countryCode: 'TH',
      operator: 'AIS',
      dataAmount: 'Unlimited',
      validityDays: 7,
      priceUsd: 14.99,
      features: ['Unlimited data', '4G/LTE', '2 GB daily high-speed'],
    ),
    const EsimPlan(
      id: 'tr-20gb-30d',
      country: 'Turkey',
      countryCode: 'TR',
      operator: 'Turkcell',
      dataAmount: '20 GB',
      validityDays: 30,
      priceUsd: 16.99,
      features: ['4G/LTE', 'Social media pass'],
    ),
  ];

  @override
  Future<List<EsimPlan>> getPlans() async {
    await Future.delayed(_fakeDelay);
    return List.unmodifiable(_catalog);
  }

  @override
  Future<EsimPlan> getPlanById(String id) async {
    await Future.delayed(_fakeDelay);
    return _catalog.firstWhere(
      (p) => p.id == id,
      orElse: () => throw Exception('Plan "$id" not found'),
    );
  }

  @override
  Future<List<EsimPlan>> searchByCountry(String query) async {
    await Future.delayed(_fakeDelay);
    final q = query.toLowerCase();
    return _catalog
        .where((p) =>
            p.country.toLowerCase().contains(q) ||
            p.countryCode.toLowerCase() == q)
        .toList();
  }
}

import '../models/data_bundle.dart';

/// Mock bundle catalog. Replace with API call later.
abstract final class BundleCatalog {
  static const regions = <String>[
    'All',
    'Turkey',
    'Europe',
    'USA',
    'Asia',
    'Global',
  ];

  static const regionCodes = <String, String>{
    'Turkey': 'TR',
    'Europe': 'EU',
    'USA': 'US',
    'Asia': 'AS',
    'Global': 'GL',
  };

  static const all = <DataBundle>[
    // ── Turkey ──────────────────────────────────────────
    DataBundle(
      id: 'tr-1gb-7d',
      region: 'Turkey',
      regionCode: 'TR',
      dataAmount: '1 GB',
      validityDays: 7,
      priceUsd: 4.99,
      features: ['4G/LTE', 'Turkcell network'],
    ),
    DataBundle(
      id: 'tr-5gb-15d',
      region: 'Turkey',
      regionCode: 'TR',
      dataAmount: '5 GB',
      validityDays: 15,
      priceUsd: 11.99,
      features: ['4G/LTE', 'Turkcell network', 'Hotspot'],
      tag: BundleTag.bestValue,
    ),
    DataBundle(
      id: 'tr-10gb-30d',
      region: 'Turkey',
      regionCode: 'TR',
      dataAmount: '10 GB',
      validityDays: 30,
      priceUsd: 18.99,
      features: ['4G/LTE', 'Turkcell network', 'Hotspot', 'Social pass'],
      tag: BundleTag.popular,
    ),
    DataBundle(
      id: 'tr-unl-10d',
      region: 'Turkey',
      regionCode: 'TR',
      dataAmount: 'Unlimited',
      validityDays: 10,
      priceUsd: 19.99,
      features: [
        'Unlimited data',
        '5 GB daily high-speed',
        'Turkcell network',
        'Hotspot',
      ],
      tag: BundleTag.unlimited,
    ),

    // ── Europe ──────────────────────────────────────────
    DataBundle(
      id: 'eu-1gb-7d',
      region: 'Europe',
      regionCode: 'EU',
      dataAmount: '1 GB',
      validityDays: 7,
      priceUsd: 5.99,
      features: ['4G/LTE', '30 EU countries'],
    ),
    DataBundle(
      id: 'eu-5gb-15d',
      region: 'Europe',
      regionCode: 'EU',
      dataAmount: '5 GB',
      validityDays: 15,
      priceUsd: 14.99,
      features: ['4G/LTE', '30 EU countries', 'Hotspot'],
      tag: BundleTag.bestValue,
    ),
    DataBundle(
      id: 'eu-unl-10d',
      region: 'Europe',
      regionCode: 'EU',
      dataAmount: 'Unlimited',
      validityDays: 10,
      priceUsd: 24.99,
      features: [
        'Unlimited data',
        '3 GB daily high-speed',
        '30 EU countries',
        'Hotspot',
      ],
      tag: BundleTag.unlimited,
    ),

    // ── USA ─────────────────────────────────────────────
    DataBundle(
      id: 'us-1gb-7d',
      region: 'USA',
      regionCode: 'US',
      dataAmount: '1 GB',
      validityDays: 7,
      priceUsd: 5.49,
      features: ['4G/LTE', 'T-Mobile network'],
    ),
    DataBundle(
      id: 'us-5gb-15d',
      region: 'USA',
      regionCode: 'US',
      dataAmount: '5 GB',
      validityDays: 15,
      priceUsd: 12.99,
      features: ['4G/LTE', 'T-Mobile network', 'Hotspot'],
      tag: BundleTag.popular,
    ),
    DataBundle(
      id: 'us-unl-10d',
      region: 'USA',
      regionCode: 'US',
      dataAmount: 'Unlimited',
      validityDays: 10,
      priceUsd: 22.99,
      features: [
        'Unlimited data',
        '5 GB daily high-speed',
        'T-Mobile network',
        'Hotspot',
      ],
      tag: BundleTag.unlimited,
    ),

    // ── Asia ────────────────────────────────────────────
    DataBundle(
      id: 'as-1gb-7d',
      region: 'Asia',
      regionCode: 'AS',
      dataAmount: '1 GB',
      validityDays: 7,
      priceUsd: 4.49,
      features: ['4G/LTE', '12 countries'],
    ),
    DataBundle(
      id: 'as-5gb-15d',
      region: 'Asia',
      regionCode: 'AS',
      dataAmount: '5 GB',
      validityDays: 15,
      priceUsd: 11.49,
      features: ['4G/LTE', '12 countries', 'Hotspot'],
      tag: BundleTag.bestValue,
    ),
    DataBundle(
      id: 'as-unl-10d',
      region: 'Asia',
      regionCode: 'AS',
      dataAmount: 'Unlimited',
      validityDays: 10,
      priceUsd: 19.99,
      features: [
        'Unlimited data',
        '3 GB daily high-speed',
        '12 countries',
        'Hotspot',
      ],
      tag: BundleTag.unlimited,
    ),

    // ── Global ──────────────────────────────────────────
    DataBundle(
      id: 'gl-1gb-7d',
      region: 'Global',
      regionCode: 'GL',
      dataAmount: '1 GB',
      validityDays: 7,
      priceUsd: 8.99,
      features: ['4G/LTE', '80+ countries'],
    ),
    DataBundle(
      id: 'gl-3gb-30d',
      region: 'Global',
      regionCode: 'GL',
      dataAmount: '3 GB',
      validityDays: 30,
      priceUsd: 19.99,
      features: ['4G/LTE', '80+ countries', 'Hotspot'],
      tag: BundleTag.bestValue,
    ),
    DataBundle(
      id: 'gl-unl-10d',
      region: 'Global',
      regionCode: 'GL',
      dataAmount: 'Unlimited',
      validityDays: 10,
      priceUsd: 34.99,
      features: [
        'Unlimited data',
        '2 GB daily high-speed',
        '80+ countries',
        'Hotspot',
      ],
      tag: BundleTag.unlimited,
    ),
  ];

  /// Filter by region name. 'All' returns everything.
  static List<DataBundle> byRegion(String region) {
    if (region == 'All') return all;
    return all.where((b) => b.region == region).toList();
  }
}

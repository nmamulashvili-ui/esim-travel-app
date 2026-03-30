import 'dart:math';

import '../models/data_bundle.dart';
import '../models/order.dart';
import '../models/user_esim.dart';
import 'bundle_catalog.dart';

// ═══════════════════════════════════════════════════════════
//  Contract — every method the app needs from a backend.
//
//  To swap in a real API later:
//    1. Create `RealApiService implements ApiService`
//    2. Replace `MockApiService()` with `RealApiService(dio)`
//       in app.dart — nothing else changes.
// ═══════════════════════════════════════════════════════════

abstract class ApiService {
  // ── Bundles ──────────────────────────────────────────────
  /// Returns all available bundles, optionally filtered by [region].
  Future<List<DataBundle>> getBundles({String? region});

  /// Returns a single bundle by [id]. Throws if not found.
  Future<DataBundle> getBundleById(String id);

  // ── Orders ───────────────────────────────────────────────
  /// Creates a new order from a [bundle].
  /// In a real implementation this would initiate payment.
  Future<Order> createOrder({required DataBundle bundle});

  /// Returns all orders for the current user.
  Future<List<Order>> getOrders();

  // ── User eSIMs ───────────────────────────────────────────
  /// Returns all eSIMs provisioned to the current user.
  Future<List<UserEsim>> getUserEsims();

  /// Returns a single eSIM by [id]. Throws if not found.
  Future<UserEsim> getUserEsimById(String id);
}

// ═══════════════════════════════════════════════════════════
//  Mock implementation — runs entirely in-memory.
// ═══════════════════════════════════════════════════════════

class MockApiService implements ApiService {
  /// Simulated network latency.
  static const _delay = Duration(milliseconds: 500);

  final _rng = Random();
  int _orderSeq = 1000;

  /// In-memory order store (survives across calls in one session).
  final List<Order> _orders = [];

  /// Mock user eSIMs — pre-populated so the My eSIMs tab has data.
  static final _mockEsims = <UserEsim>[
    UserEsim(
      id: 'e1',
      country: 'Japan',
      countryCode: 'JP',
      operator: 'NTT Docomo',
      dataAmount: '3 GB',
      dataUsed: '1.2 GB',
      totalDays: 15,
      daysLeft: 9,
      isActive: true,
      iccid: '8981100000000000001',
      purchasedAt: DateTime.now().subtract(const Duration(days: 6)),
    ),
    UserEsim(
      id: 'e2',
      country: 'Germany',
      countryCode: 'DE',
      operator: 'Deutsche Telekom',
      dataAmount: '10 GB',
      dataUsed: '10 GB',
      totalDays: 30,
      daysLeft: 0,
      isActive: false,
      iccid: '8949200000000000002',
      purchasedAt: DateTime.now().subtract(const Duration(days: 45)),
    ),
    UserEsim(
      id: 'e3',
      country: 'Turkey',
      countryCode: 'TR',
      operator: 'Turkcell',
      dataAmount: '5 GB',
      dataUsed: '0.8 GB',
      totalDays: 15,
      daysLeft: 12,
      isActive: true,
      iccid: '8990200000000000003',
      purchasedAt: DateTime.now().subtract(const Duration(days: 3)),
    ),
    UserEsim(
      id: 'e4',
      country: 'Thailand',
      countryCode: 'TH',
      operator: 'AIS',
      dataAmount: '5 GB',
      dataUsed: '4.7 GB',
      totalDays: 7,
      daysLeft: 1,
      isActive: true,
      iccid: '8966000000000000004',
      purchasedAt: DateTime.now().subtract(const Duration(days: 6)),
    ),
    UserEsim(
      id: 'e5',
      country: 'United States',
      countryCode: 'US',
      operator: 'T-Mobile',
      dataAmount: '10 GB',
      dataUsed: '10 GB',
      totalDays: 15,
      daysLeft: 0,
      isActive: false,
      iccid: '8901000000000000005',
      purchasedAt: DateTime.now().subtract(const Duration(days: 30)),
    ),
  ];

  // ── Bundles ──────────────────────────────────────────────

  @override
  Future<List<DataBundle>> getBundles({String? region}) async {
    await Future.delayed(_delay);
    if (region == null || region == 'All') {
      return List.unmodifiable(BundleCatalog.all);
    }
    return List.unmodifiable(BundleCatalog.byRegion(region));
  }

  @override
  Future<DataBundle> getBundleById(String id) async {
    await Future.delayed(_delay);
    return BundleCatalog.all.firstWhere(
      (b) => b.id == id,
      orElse: () => throw NotFoundException('Bundle "$id" not found'),
    );
  }

  // ── Orders ───────────────────────────────────────────────

  @override
  Future<Order> createOrder({required DataBundle bundle}) async {
    await Future.delayed(const Duration(milliseconds: 800));

    final order = Order(
      id: 'ORD-${++_orderSeq}',
      bundleId: bundle.id,
      region: bundle.region,
      dataAmount: bundle.dataAmount,
      validityDays: bundle.validityDays,
      totalUsd: bundle.priceUsd,
      status: OrderStatus.paid,
      createdAt: DateTime.now(),
      iccid: _generateIccid(),
    );

    _orders.insert(0, order);
    return order;
  }

  @override
  Future<List<Order>> getOrders() async {
    await Future.delayed(_delay);
    return List.unmodifiable(_orders);
  }

  // ── User eSIMs ───────────────────────────────────────────

  @override
  Future<List<UserEsim>> getUserEsims() async {
    await Future.delayed(_delay);

    // Merge pre-populated mocks with any eSIMs created from orders.
    final fromOrders = _orders
        .where((o) => o.status == OrderStatus.paid && o.iccid != null)
        .map((o) => UserEsim(
              id: o.id,
              country: o.region,
              countryCode: _regionToCode(o.region),
              operator: _regionToOperator(o.region),
              dataAmount: o.dataAmount,
              dataUsed: '0 GB',
              totalDays: o.validityDays,
              daysLeft: o.validityDays,
              isActive: true,
              iccid: o.iccid!,
              purchasedAt: o.createdAt,
            ))
        .toList();

    return List.unmodifiable([...fromOrders, ..._mockEsims]);
  }

  @override
  Future<UserEsim> getUserEsimById(String id) async {
    final all = await getUserEsims();
    return all.firstWhere(
      (e) => e.id == id,
      orElse: () => throw NotFoundException('eSIM "$id" not found'),
    );
  }

  // ── Helpers ──────────────────────────────────────────────

  String _generateIccid() {
    final digits =
        List.generate(16, (_) => _rng.nextInt(10)).join();
    return '899$digits';
  }

  String _regionToCode(String region) => switch (region) {
        'Turkey' => 'TR',
        'Europe' => 'EU',
        'USA' => 'US',
        'Asia' => 'AS',
        'Global' => 'GL',
        _ => 'XX',
      };

  String _regionToOperator(String region) => switch (region) {
        'Turkey' => 'Turkcell',
        'Europe' => 'Multi-carrier EU',
        'USA' => 'T-Mobile',
        'Asia' => 'Multi-carrier Asia',
        'Global' => 'Global eSIM',
        _ => 'Unknown',
      };
}

// ═══════════════════════════════════════════════════════════
//  Exceptions
// ═══════════════════════════════════════════════════════════

class NotFoundException implements Exception {
  final String message;
  const NotFoundException(this.message);

  @override
  String toString() => message;
}

import 'package:flutter/foundation.dart';

import '../models/esim_plan.dart';
import '../services/esim_service.dart';

/// Centralised state for eSIM plans.
/// Wraps [EsimService] so the UI never talks to the service directly.
class PlanProvider extends ChangeNotifier {
  final EsimService _service;

  PlanProvider(this._service);

  // ── State ───────────────────────────────────────────────
  List<EsimPlan> _plans = [];
  List<EsimPlan> get plans => _plans;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _error;
  String? get error => _error;

  String _searchQuery = '';
  String get searchQuery => _searchQuery;

  // ── Derived ─────────────────────────────────────────────
  List<EsimPlan> get filteredPlans {
    if (_searchQuery.isEmpty) return _plans;
    final q = _searchQuery.toLowerCase();
    return _plans
        .where((p) =>
            p.country.toLowerCase().contains(q) ||
            p.countryCode.toLowerCase() == q)
        .toList();
  }

  // ── Actions ─────────────────────────────────────────────
  Future<void> loadPlans() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _plans = await _service.getPlans();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void setSearch(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void clearSearch() {
    _searchQuery = '';
    notifyListeners();
  }
}

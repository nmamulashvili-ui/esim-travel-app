/// Represents a purchased eSIM in the user's account.
class UserEsim {
  final String id;
  final String country;
  final String countryCode;
  final String operator;
  final String dataAmount;
  final String dataUsed;
  final int totalDays;
  final int daysLeft;
  final bool isActive;
  final String iccid;
  final DateTime purchasedAt;

  const UserEsim({
    required this.id,
    required this.country,
    required this.countryCode,
    required this.operator,
    required this.dataAmount,
    required this.dataUsed,
    required this.totalDays,
    required this.daysLeft,
    required this.isActive,
    required this.iccid,
    required this.purchasedAt,
  });

  double get usageFraction {
    final u = double.tryParse(dataUsed.replaceAll(RegExp(r'[^0-9.]'), '')) ?? 0;
    final t = double.tryParse(dataAmount.replaceAll(RegExp(r'[^0-9.]'), '')) ?? 1;
    if (t == 0) return 1;
    return (u / t).clamp(0, 1);
  }

  String get dataRemaining {
    final u = double.tryParse(dataUsed.replaceAll(RegExp(r'[^0-9.]'), '')) ?? 0;
    final t = double.tryParse(dataAmount.replaceAll(RegExp(r'[^0-9.]'), '')) ?? 0;
    return '${(t - u).clamp(0, t).toStringAsFixed(1)} GB';
  }

  /// Computed expiry date.
  DateTime get expiresAt => purchasedAt.add(Duration(days: totalDays));

  /// Formatted expiry string, e.g. "Mar 15, 2025".
  String get expiresFormatted {
    final d = expiresAt;
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return '${months[d.month - 1]} ${d.day}, ${d.year}';
  }

  /// Days elapsed since purchase.
  int get daysUsed => totalDays - daysLeft;
}

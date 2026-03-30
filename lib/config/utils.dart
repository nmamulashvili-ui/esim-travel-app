/// Converts an ISO 3166-1 alpha-2 country code into a flag emoji.
///
/// ```dart
/// flagEmoji('US') // 🇺🇸
/// flagEmoji('JP') // 🇯🇵
/// ```
String flagEmoji(String countryCode) {
  final upper = countryCode.toUpperCase();
  if (upper.length != 2) return '🌐';
  return String.fromCharCodes(
    upper.codeUnits.map((c) => 0x1F1E6 - 0x41 + c),
  );
}

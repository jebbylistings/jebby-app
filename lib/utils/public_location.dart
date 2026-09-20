/// Formats saved addresses as a public "City, ST" line.
class PublicLocation {
  PublicLocation._();

  static const _countryTokens = {
    'usa',
    'us',
    'u.s.',
    'u.s.a.',
    'united states',
    'united states of america',
  };

  /// Returns `City, ST` when the address can be parsed; otherwise [fallback].
  static String cityStateLineOr(String? address, String fallback) {
    return cityStateLine(address) ?? fallback;
  }

  /// Returns `City, ST` when the address can be parsed; otherwise null.
  static String? cityStateLine(String? address) {
    final trimmed = address?.trim() ?? '';
    if (trimmed.isEmpty) return null;

    var parts = trimmed
        .split(',')
        .map((part) => part.trim())
        .where((part) => part.isNotEmpty)
        .toList();

    if (parts.isEmpty) return trimmed;

    if (_countryTokens.contains(parts.last.toLowerCase())) {
      parts = parts.sublist(0, parts.length - 1);
    }

    if (parts.length >= 2) {
      final city = parts[parts.length - 2];
      final state = _stateLabel(parts.last);
      if (city.isNotEmpty && state.isNotEmpty) {
        return '$city, $state';
      }
    }

    return trimmed;
  }

  static String _stateLabel(String statePart) {
    final trimmed = statePart.trim();
    final match = RegExp(r'^([A-Za-z]{2})\b').firstMatch(trimmed);
    if (match != null) return match.group(1)!.toUpperCase();
    final token = trimmed.split(RegExp(r'\s+')).first;
    if (token.length == 2) return token.toUpperCase();
    return token;
  }
}

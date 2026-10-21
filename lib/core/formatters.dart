/// Small helpers that turn raw data into text the user reads.
class Formatters {
  static String price(double value) => '\$${value.toStringAsFixed(2)}';

  /// "men's clothing" -> "Men's clothing"
  static String sentenceCase(String text) {
    final value = text.trim();
    if (value.isEmpty) return value;
    return value[0].toUpperCase() + value.substring(1).toLowerCase();
  }

  /// "7835 new road" -> "7835 New Road"
  static String titleCase(String text) {
    return text
        .trim()
        .split(RegExp(r'\s+'))
        .where((word) => word.isNotEmpty)
        .map((word) => word[0].toUpperCase() + word.substring(1).toLowerCase())
        .join(' ');
  }

  static const _months = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
  ];

  /// "Mar 2, 2026"
  static String date(DateTime date) =>
      '${_months[date.month - 1]} ${date.day}, ${date.year}';

  static String items(int count) => '$count ${count == 1 ? 'item' : 'items'}';
}

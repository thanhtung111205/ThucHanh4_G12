class Formatter {
  const Formatter._();

  static String formatUsd(double value) {
    return '\$${value.toStringAsFixed(2)}';
  }
}

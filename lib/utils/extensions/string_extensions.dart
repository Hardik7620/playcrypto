extension StringExtensions on String {
  String removeLeadingZeros() {
    return replaceFirst(RegExp(r'^0+'), '');
  }
    String toFullDecimal() {
    if (isEmpty) return this;
    final double? value = double.tryParse(this);
    if (value == null) return this;
    // If the string already doesn't use scientific notation, return as is
    if (!contains('e') && !contains('E')) return this;
    // Convert to decimal with high precision, then trim trailing zeros
    String asDecimal = value.toStringAsFixed(20);
    asDecimal = asDecimal.replaceFirst(RegExp(r'0+$'), ''); // Remove trailing zeros
    asDecimal = asDecimal.replaceFirst(RegExp(r'\.$'), ''); // Remove trailing dot
    return asDecimal;
  }
}

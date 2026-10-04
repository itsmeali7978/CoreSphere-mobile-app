class AppNumberToWords {
  static const List<String> _units = [
    "", "One", "Two", "Three", "Four", "Five", "Six", "Seven", "Eight", "Nine",
    "Ten", "Eleven", "Twelve", "Thirteen", "Fourteen", "Fifteen", "Sixteen",
    "Seventeen", "Eighteen", "Nineteen"
  ];

  static const List<String> _tens = [
    "", "", "Twenty", "Thirty", "Forty", "Fifty", "Sixty", "Seventy", "Eighty", "Ninety"
  ];

  /// Converts a decimal amount into words format (e.g. 1250.50 -> "One Thousand Two Hundred Fifty Saudi Riyals and Fifty Halalas")
  static String convertToWords(double amount, {String currency = "Saudi Riyals", String subunit = "Halalas"}) {
    if (amount <= 0) return "Zero $currency";

    int integerPart = amount.truncate();
    int decimalPart = ((amount - integerPart) * 100).round();

    String integerWords = _convertInteger(integerPart);
    String result = "$integerWords $currency";

    if (decimalPart > 0) {
      String decimalWords = _convertInteger(decimalPart);
      result += " and $decimalWords $subunit";
    } else {
      result += " Only";
    }

    return result;
  }

  static String _convertInteger(int number) {
    if (number == 0) return "Zero";
    if (number < 0) return "Minus ${_convertInteger(-number)}";

    if (number < 20) {
      return _units[number];
    }

    if (number < 100) {
      return _tens[number ~/ 10] + (number % 10 != 0 ? " ${_units[number % 10]}" : "");
    }

    if (number < 1000) {
      return "${_units[number ~/ 100]} Hundred" + (number % 100 != 0 ? " ${_convertInteger(number % 100)}" : "");
    }

    if (number < 1000000) {
      return "${_convertInteger(number ~/ 1000)} Thousand" + (number % 1000 != 0 ? " ${_convertInteger(number % 1000)}" : "");
    }

    if (number < 1000000000) {
      return "${_convertInteger(number ~/ 1000000)} Million" + (number % 1000000 != 0 ? " ${_convertInteger(number % 1000000)}" : "");
    }

    return "${_convertInteger(number ~/ 1000000000)} Billion" + (number % 1000000000 != 0 ? " ${_convertInteger(number % 1000000000)}" : "");
  }
}

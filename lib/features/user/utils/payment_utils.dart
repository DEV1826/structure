import 'package:intl/intl.dart';

/// Utility class for payment-related functions
class PaymentUtils {
  /// Format amount to currency string
  static String formatAmount(double amount) {
    return NumberFormat.currency(
      symbol: 'FCFA',
      decimalDigits: 0,
      locale: 'fr_FR',
    ).format(amount);
  }

  /// Format date to a readable string
  static String formatDate(DateTime date) {
    return DateFormat('dd/MM/yyyy HH:mm').format(date);
  }

  /// Generate a transaction reference
  static String generateTransactionReference() {
    final now = DateTime.now();
    final random = DateTime.now().millisecondsSinceEpoch % 10000;
    return 'TXN-${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}-${random.toString().padLeft(4, '0')}';
  }

  /// Validate a phone number for mobile money payment
  static bool isValidPhoneNumber(String phoneNumber) {
    // Simple validation for West African phone numbers
    final regex = RegExp(r'^(\+?225|0)[0-9]{10}$');
    return regex.hasMatch(phoneNumber);
  }

  /// Mask sensitive payment information
  static String maskCardNumber(String cardNumber) {
    if (cardNumber.length <= 4) return cardNumber;
    final lastFour = cardNumber.substring(cardNumber.length - 4);
    return '•••• •••• •••• $lastFour';
  }

  /// Calculate tax amount based on amount and tax rate
  static double calculateTax(double amount, double taxRate) {
    return (amount * taxRate) / 100;
  }

  /// Calculate total amount including tax
  static double calculateTotalWithTax(double amount, double taxRate) {
    return amount + calculateTax(amount, taxRate);
  }

  /// Format amount with currency symbol
  static String formatAmountWithCurrency(double amount, {String currency = 'FCFA'}) {
    return '${amount.toStringAsFixed(2)} $currency';
  }
}

extension StringExtension on String {
  /// Extension method to validate if string is a valid email
  bool get isValidEmail {
    final emailRegExp = RegExp(
      r'^[a-zA-Z0-9.]+@[a-zA-Z0-9]+\.[a-zA-Z]+',
    );
    return emailRegExp.hasMatch(this);
  }
}

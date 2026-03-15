class Payment {
  final String id;
  final String clientName;
  final String serviceName;
  final double amount;
  final DateTime date;
  final String paymentMethod;
  final String receiptUrl; // URL pour le téléchargement du reçu

  Payment({
    required this.id,
    required this.clientName,
    required this.serviceName,
    required this.amount,
    required this.date,
    required this.paymentMethod,
    required this.receiptUrl,
  });

  // Convert from JSON
  factory Payment.fromJson(Map<String, dynamic> json) {
    return Payment(
      id: json['id'] ?? '',
      clientName: json['clientName'] ?? '',
      serviceName: json['serviceName'] ?? '',
      amount: (json['amount'] ?? 0.0).toDouble(),
      date: json['date']?.toDate() ?? DateTime.now(),
      paymentMethod: json['paymentMethod'] ?? '',
      receiptUrl: json['receiptUrl'] ?? '',
    );
  }

  // Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'clientName': clientName,
      'serviceName': serviceName,
      'amount': amount,
      'date': date,
      'paymentMethod': paymentMethod,
      'receiptUrl': receiptUrl,
    };
  }
}

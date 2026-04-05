class Payment {
  final String id;
  final String clientName;
  final String serviceName;
  final double amount;
  final DateTime date;
  final String paymentMethod;
  final String status;
  final String reference;

  Payment({
    required this.id,
    required this.clientName,
    required this.serviceName,
    required this.amount,
    required this.date,
    required this.paymentMethod,
    this.status = 'SUCCESS',
    this.reference = '',
  });

  // Convert from JSON
  factory Payment.fromJson(Map<String, dynamic> json) {
    DateTime parsedDate;
    try {
      final dateStr = json['transactionDate'] ?? json['date'];
      if (dateStr != null) {
        parsedDate = DateTime.parse(dateStr.toString());
      } else {
        parsedDate = DateTime.now();
      }
    } catch (e) {
      parsedDate = DateTime.now();
    }

    return Payment(
      id: json['id']?.toString() ?? '',
      clientName: json['customerName'] ?? json['clientName'] ?? 'Client Inconnu',
      serviceName: json['description'] ?? json['serviceName'] ?? 'Service',
      amount: (json['amount'] ?? 0.0).toDouble(),
      date: parsedDate,
      paymentMethod: json['paymentMethod'] ?? 'N/A',
      status: json['status'] ?? 'SUCCESS',
      reference: json['reference'] ?? '',
    );
  }

  // Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'customerName': clientName,
      'description': serviceName,
      'amount': amount,
      'transactionDate': date.toIso8601String(),
      'paymentMethod': paymentMethod,
      'status': status,
      'reference': reference,
    };
  }
}

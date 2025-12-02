class PaymentData {
  final String orderId;
  final String reference;
  final String paymentLink;
  final double amount;
  final String status;
  final DateTime? paymentDate;
  final String? customerName;
  final String? customerPhone;
  final String? serviceName;
  final String? structureName;

  PaymentData({
    required this.orderId,
    required this.reference,
    required this.paymentLink,
    required this.amount,
    this.status = 'PENDING',
    this.paymentDate,
    this.customerName,
    this.customerPhone,
    this.serviceName,
    this.structureName,
  });

  factory PaymentData.fromJson(Map<String, dynamic> json) {
    return PaymentData(
      orderId: json['orderId'] ?? '',
      reference: json['reference'] ?? '',
      paymentLink: json['paymentLink'] ?? '',
      amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
      status: json['status'] ?? 'PENDING',
      paymentDate: json['paymentDate'] != null
          ? DateTime.parse(json['paymentDate'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'orderId': orderId,
      'reference': reference,
      'paymentLink': paymentLink,
      'amount': amount,
      'status': status,
      'paymentDate': paymentDate?.toIso8601String(),
      'customerName': customerName,
      'customerPhone': customerPhone,
      'serviceName': serviceName,
      'structureName': structureName,
    };
  }
}

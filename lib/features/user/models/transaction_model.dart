import 'package:equatable/equatable.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

enum TransactionStatus {
  pending,
  completed,
  failed,
  cancelled,
}

class TransactionModel extends Equatable {
  final String id;
  final String structureId;
  final String structureName;
  final String serviceId;
  final String serviceName;
  final double amount;
  final DateTime date;
  final TransactionStatus status;
  final String? receiptUrl;
  final String? paymentMethod;
  final String? paymentReference;
  final String? customerPhone;
  final String? customerName;

  const TransactionModel({
    required this.id,
    required this.structureId,
    required this.structureName,
    required this.serviceId,
    required this.serviceName,
    required this.amount,
    required this.date,
    this.status = TransactionStatus.pending,
    this.receiptUrl,
    this.paymentMethod,
    this.paymentReference,
    this.customerPhone,
    this.customerName,
  });

  factory TransactionModel.fromMap(Map<String, dynamic> map) {
    return TransactionModel(
      id: map['id'] as String,
      structureId: map['structureId'] as String,
      structureName: map['structureName'] as String,
      serviceId: map['serviceId'] as String,
      serviceName: map['serviceName'] as String,
      amount: (map['amount'] as num).toDouble(),
      date: (map['date'] as Timestamp).toDate(),
      status: _statusFromString(map['status'] as String?),
      receiptUrl: map['receiptUrl'] as String?,
      paymentMethod: map['paymentMethod'] as String?,
      paymentReference: map['paymentReference'] as String?,
      customerPhone: map['customerPhone'] as String?,
      customerName: map['customerName'] as String?,
    );
  }

  static TransactionStatus _statusFromString(String? status) {
    switch (status?.toLowerCase()) {
      case 'completed':
        return TransactionStatus.completed;
      case 'failed':
        return TransactionStatus.failed;
      case 'cancelled':
        return TransactionStatus.cancelled;
      case 'pending':
      default:
        return TransactionStatus.pending;
    }
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'structureId': structureId,
      'structureName': structureName,
      'serviceId': serviceId,
      'serviceName': serviceName,
      'amount': amount,
      'date': Timestamp.fromDate(date),
      'status': status.toString().split('.').last,
      if (receiptUrl != null) 'receiptUrl': receiptUrl,
      if (paymentMethod != null) 'paymentMethod': paymentMethod,
      if (paymentReference != null) 'paymentReference': paymentReference,
      if (customerPhone != null) 'customerPhone': customerPhone,
      if (customerName != null) 'customerName': customerName,
    };
  }

  String get formattedDate => DateFormat('dd/MM/yyyy HH:mm').format(date);
  String get formattedAmount => '${amount.toStringAsFixed(2)} FCFA';

  TransactionModel copyWith({
    String? id,
    String? structureId,
    String? structureName,
    String? serviceId,
    String? serviceName,
    double? amount,
    DateTime? date,
    TransactionStatus? status,
    String? receiptUrl,
    String? paymentMethod,
    String? paymentReference,
    String? customerPhone,
    String? customerName,
  }) {
    return TransactionModel(
      id: id ?? this.id,
      structureId: structureId ?? this.structureId,
      structureName: structureName ?? this.structureName,
      serviceId: serviceId ?? this.serviceId,
      serviceName: serviceName ?? this.serviceName,
      amount: amount ?? this.amount,
      date: date ?? this.date,
      status: status ?? this.status,
      receiptUrl: receiptUrl ?? this.receiptUrl,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      paymentReference: paymentReference ?? this.paymentReference,
      customerPhone: customerPhone ?? this.customerPhone,
      customerName: customerName ?? this.customerName,
    );
  }

  @override
  List<Object?> get props => [
        id,
        structureId,
        structureName,
        serviceId,
        serviceName,
        amount,
        date,
        status,
        receiptUrl,
        paymentMethod,
        paymentReference,
        customerPhone,
        customerName,
      ];

  @override
  String toString() => 'TransactionModel(id: $id, service: $serviceName, amount: $amount, status: $status)';
}

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/custom_button.dart';
import '../../payment/models/payment_data.dart';

class PaymentSuccessScreen extends StatelessWidget {
  final PaymentData paymentData;

  const PaymentSuccessScreen({super.key, required this.paymentData});

  @override
  Widget build(BuildContext context) {
    final formatter = NumberFormat('#,##0', 'fr_FR');
    final dateFormatter = DateFormat('dd/MM/yyyy à HH:mm', 'fr_FR');

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 40),
              const Icon(Icons.check_circle, color: Colors.green, size: 100),
              const SizedBox(height: 24),
              const Text(
                'Paiement réussi !',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),
              _buildInfoRow('Référence', paymentData.reference),
              const SizedBox(height: 16),
              _buildInfoRow(
                'Montant',
                '${formatter.format(paymentData.amount)} FCFA',
              ),
              if (paymentData.paymentDate != null) ...[
                const SizedBox(height: 16),
                _buildInfoRow(
                  'Date',
                  dateFormatter.format(paymentData.paymentDate!),
                ),
              ],
              if (paymentData.serviceName != null) ...[
                const SizedBox(height: 16),
                _buildInfoRow('Service', paymentData.serviceName!),
              ],
              if (paymentData.structureName != null) ...[
                const SizedBox(height: 16),
                _buildInfoRow('Structure', paymentData.structureName!),
              ],
              const Spacer(),
              CustomButton(
                onPressed: () {
                  // Retour à l'écran d'accueil
                  Navigator.of(context).popUntil((route) => route.isFirst);
                },
                text: 'Retour à l\'accueil',
                backgroundColor: AppColors.primary,
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () {
                  // Télécharger le reçu
                  _downloadReceipt(context);
                },
                child: const Text(
                  'Télécharger le reçu',
                  style: TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(fontSize: 16, color: Colors.grey)),
        Text(
          value,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  void _downloadReceipt(BuildContext context) {
    // Implémentez la logique de téléchargement du reçu ici
    // Par exemple, générer un PDF ou ouvrir une URL de téléchargement

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Téléchargement du reçu...'),
        duration: Duration(seconds: 2),
      ),
    );
  }
}

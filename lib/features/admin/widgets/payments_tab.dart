import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:structure_mobile/core/providers/auth_provider.dart';
import 'package:structure_mobile/features/admin/models/payment_model.dart';
import 'package:structure_mobile/features/admin/providers/dashboard_provider.dart';
import 'package:structure_mobile/themes/app_theme.dart';

class PaymentsTab extends StatefulWidget {
  const PaymentsTab({super.key});

  @override
  State<PaymentsTab> createState() => _PaymentsTabState();
}

class _PaymentsTabState extends State<PaymentsTab> {
  final TextEditingController _searchController = TextEditingController();
  DateTimeRange? _selectedDateRange;
  final DateFormat _dateFormat = DateFormat('dd/MM/yyyy HH:mm');
  final NumberFormat _currencyFormat = NumberFormat.currency(
    symbol: 'XAF',
    decimalDigits: 0,
  );

  @override
  void initState() {
    super.initState();
    _loadPayments();
  }

  void _loadPayments() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final auth = context.read<AuthProvider>();
      final structureId = auth.user?.structureId;
      context.read<DashboardProvider>().loadPayments(structureId);
    });
  }

  // Sélectionner une plage de dates
  Future<void> _selectDateRange(BuildContext context) async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2023),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      initialDateRange: _selectedDateRange,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppTheme.primaryColor,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );
    
    if (picked != null) {
      setState(() {
        _selectedDateRange = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<DashboardProvider>(
      builder: (context, provider, _) {
        // Filtrage local pour la recherche et les dates
        final query = _searchController.text.toLowerCase();
        final filteredPayments = provider.payments.where((payment) {
          final matchesSearch = query.isEmpty ||
              payment.clientName.toLowerCase().contains(query) ||
              payment.serviceName.toLowerCase().contains(query) ||
              payment.id.toLowerCase().contains(query) ||
              payment.reference.toLowerCase().contains(query);
          
          final matchesDateRange = _selectedDateRange == null ||
              (payment.date.isAfter(_selectedDateRange!.start) &&
                  payment.date.isBefore(_selectedDateRange!.end.add(const Duration(days: 1))));
          
          return matchesSearch && matchesDateRange;
        }).toList();

        return Scaffold(
          body: Column(
            children: [
              // En-tête avec filtres
              Card(
                margin: const EdgeInsets.all(16.0),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      // Barre de recherche
                      TextField(
                        controller: _searchController,
                        decoration: InputDecoration(
                          hintText: 'Rechercher un paiement...',
                          prefixIcon: const Icon(Icons.search),
                          suffixIcon: IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              _searchController.clear();
                              setState(() {});
                            },
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                        ),
                        onChanged: (_) => setState(() {}),
                      ),
                      const SizedBox(height: 16.0),
                      // Filtres
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              icon: const Icon(Icons.date_range),
                              label: Text(
                                _selectedDateRange == null
                                    ? 'Toutes les dates'
                                    : '${DateFormat('dd/MM/yyyy').format(_selectedDateRange!.start)} - ${DateFormat('dd/MM/yyyy').format(_selectedDateRange!.end)}',
                                overflow: TextOverflow.ellipsis,
                              ),
                              onPressed: () => _selectDateRange(context),
                            ),
                          ),
                          const SizedBox(width: 8.0),
                          if (_selectedDateRange != null)
                            IconButton(
                              icon: const Icon(Icons.clear, color: Colors.red),
                              onPressed: () {
                                setState(() {
                                  _selectedDateRange = null;
                                });
                              },
                            ),
                          IconButton(
                            icon: const Icon(Icons.refresh),
                            onPressed: _loadPayments,
                            tooltip: 'Actualiser',
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              // Liste des paiements
              Expanded(
                child: provider.isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : filteredPayments.isEmpty
                        ? const Center(child: Text('Aucun paiement trouvé'))
                        : ListView.builder(
                            itemCount: filteredPayments.length,
                            itemBuilder: (context, index) {
                              final payment = filteredPayments[index];
                              return _buildPaymentItem(payment);
                            },
                          ),
              ),
            ],
          ),
          // Résumé des paiements
          bottomNavigationBar: _buildSummaryFooter(filteredPayments),
        );
      },
    );
  }

  Widget _buildPaymentItem(Payment payment) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
      child: InkWell(
        onTap: () => _showPaymentDetails(payment),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            children: [
              Expanded(
                flex: 2,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      payment.clientName,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      payment.serviceName,
                      style: TextStyle(color: Colors.grey[600], fontSize: 12),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      _currencyFormat.format(payment.amount),
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primaryColor,
                      ),
                    ),
                    Text(
                      _dateFormat.format(payment.date),
                      style: const TextStyle(fontSize: 10.0, color: Colors.grey),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryFooter(List<Payment> filteredPayments) {
    final totalAmount = filteredPayments.fold<double>(
      0,
      (sum, payment) => sum + payment.amount,
    );

    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        border: Border(top: BorderSide(color: Colors.grey[200]!)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            '${filteredPayments.length} paiement${filteredPayments.length > 1 ? 's' : ''}',
            style: const TextStyle(color: Colors.grey),
          ),
          Text(
            _currencyFormat.format(totalAmount),
            style: const TextStyle(
              fontSize: 18.0,
              fontWeight: FontWeight.bold,
              color: AppTheme.primaryColor,
            ),
          ),
        ],
      ),
    );
  }

  void _showPaymentDetails(Payment payment) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Détails du paiement',
              style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24.0),
            _buildDetailRow('ID Transaction', payment.id),
            _buildDetailRow('Référence', payment.reference),
            _buildDetailRow('Client', payment.clientName),
            _buildDetailRow('Service', payment.serviceName),
            _buildDetailRow('Méthode', payment.paymentMethod),
            _buildDetailRow('Statut', payment.status, 
                valueStyle: TextStyle(
                  color: payment.status == 'SUCCESS' ? Colors.green : Colors.orange,
                  fontWeight: FontWeight.bold,
                )),
            _buildDetailRow(
              'Montant',
              _currencyFormat.format(payment.amount),
              valueStyle: const TextStyle(
                fontWeight: FontWeight.bold,
                color: AppTheme.primaryColor,
                fontSize: 18.0,
              ),
            ),
            _buildDetailRow('Date', _dateFormat.format(payment.date)),
            const SizedBox(height: 24.0),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryColor),
                child: const Text('Fermer', style: TextStyle(color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, {TextStyle? valueStyle}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120.0,
            child: Text(label, style: const TextStyle(color: Colors.grey)),
          ),
          Expanded(child: Text(value, style: valueStyle)),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}

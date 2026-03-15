import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:structure_mobile/features/admin/models/payment_model.dart';
import 'package:structure_mobile/themes/app_theme.dart';

class PaymentsTab extends StatefulWidget {
  const PaymentsTab({super.key});

  @override
  State<PaymentsTab> createState() => _PaymentsTabState();
}

class _PaymentsTabState extends State<PaymentsTab> {
  final TextEditingController _searchController = TextEditingController();
  bool _isLoading = false;
  List<Payment> _payments = [];
  List<Payment> _filteredPayments = [];
  DateTimeRange? _selectedDateRange;
  final DateFormat _dateFormat = DateFormat('dd/MM/yyyy');
  final NumberFormat _currencyFormat = NumberFormat.currency(
    symbol: 'XAF',
    decimalDigits: 0,
  );

  @override
  void initState() {
    super.initState();
    _loadPayments();
  }

  // Charger les paiements (simulé)
  Future<void> _loadPayments() async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
    });

    try {
      // Simuler un chargement de données
      await Future.delayed(const Duration(seconds: 1));
      
      // Données de démonstration
      _payments = _getDemoPayments();
      _filteredPayments = List.from(_payments);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur lors du chargement des paiements: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  // Données de démonstration
  List<Payment> _getDemoPayments() {
    final now = DateTime.now();
    return [
      Payment(
        id: 'PAY001',
        clientName: 'Jean Dupont',
        serviceName: 'Consultation Générale',
        amount: 5000,
        date: now.subtract(const Duration(days: 2)),
        paymentMethod: 'Mobile Money',
        receiptUrl: 'https://example.com/receipts/PAY001',
      ),
      Payment(
        id: 'PAY002',
        clientName: 'Marie Martin',
        serviceName: 'Analyse Sanguine',
        amount: 15000,
        date: now.subtract(const Duration(days: 5)),
        paymentMethod: 'Carte Bancaire',
        receiptUrl: 'https://example.com/receipts/PAY002',
      ),
      Payment(
        id: 'PAY003',
        clientName: 'Pierre Durand',
        serviceName: 'Frais de Scolarité',
        amount: 75000,
        date: now.subtract(const Duration(days: 1)),
        paymentMethod: 'Espèces',
        receiptUrl: 'https://example.com/receipts/PAY003',
      ),
      Payment(
        id: 'PAY004',
        clientName: 'Sophie Lambert',
        serviceName: 'Consultation Spécialisée',
        amount: 10000,
        date: now.subtract(const Duration(days: 3)),
        paymentMethod: 'Mobile Money',
        receiptUrl: 'https://example.com/receipts/PAY004',
      ),
    ];
  }

  // Appliquer les filtres (recherche et plage de dates)
  void _applyFilters() {
    setState(() {
      _filteredPayments = _payments.where((payment) {
        final matchesSearch = _searchController.text.isEmpty ||
            payment.clientName.toLowerCase().contains(_searchController.text.toLowerCase()) ||
            payment.serviceName.toLowerCase().contains(_searchController.text.toLowerCase()) ||
            payment.id.toLowerCase().contains(_searchController.text.toLowerCase());
        
        final matchesDateRange = _selectedDateRange == null ||
            (payment.date.isAfter(_selectedDateRange!.start) &&
                payment.date.isBefore(_selectedDateRange!.end.add(const Duration(days: 1))));
        
        return matchesSearch && matchesDateRange;
      }).toList();
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
            colorScheme: ColorScheme.light(
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
        _applyFilters();
      });
    }
  }

  // Afficher les détails d'un paiement
  void _showPaymentDetails(Payment payment) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => _buildPaymentDetailsSheet(payment),
    );
  }

  @override
  Widget build(BuildContext context) {
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
                          _applyFilters();
                        },
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                    ),
                    onChanged: (_) => _applyFilters(),
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
                                : '${_dateFormat.format(_selectedDateRange!.start)} - ${_dateFormat.format(_selectedDateRange!.end)}',
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
                              _applyFilters();
                            });
                          },
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          // En-tête des colonnes
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            color: Colors.grey[100],
            child: const Row(
              children: [
                Expanded(
                  flex: 2,
                  child: Text('Client', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
                Expanded(
                  flex: 2,
                  child: Text('Service', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
                Expanded(
                  child: Text('Montant', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
                Expanded(
                  child: Text('Date', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
                SizedBox(width: 40), // Pour les boutons d'action
              ],
            ),
          ),
          // Liste des paiements
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filteredPayments.isEmpty
                    ? const Center(child: Text('Aucun paiement trouvé'))
                    : ListView.builder(
                        itemCount: _filteredPayments.length,
                        itemBuilder: (context, index) {
                          final payment = _filteredPayments[index];
                          return _buildPaymentItem(payment);
                        },
                      ),
          ),
        ],
      ),
      // Résumé des paiements
      bottomNavigationBar: _buildSummaryFooter(),
    );
  }

  // Construire un élément de la liste des paiements
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
                child: Text(
                  payment.clientName,
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
              ),
              Expanded(
                flex: 2,
                child: Text(
                  payment.serviceName,
                  style: const TextStyle(color: Colors.grey),
                ),
              ),
              Expanded(
                child: Text(
                  _currencyFormat.format(payment.amount),
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryColor,
                  ),
                ),
              ),
              Expanded(
                child: Text(
                  _dateFormat.format(payment.date),
                  style: const TextStyle(fontSize: 12.0),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.visibility, size: 20.0),
                onPressed: () => _showPaymentDetails(payment),
                tooltip: 'Voir les détails',
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Construire le pied de page avec le résumé
  Widget _buildSummaryFooter() {
    final totalAmount = _filteredPayments.fold<double>(
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
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${_filteredPayments.length} paiement${_filteredPayments.length > 1 ? 's' : ''}',
                style: const TextStyle(
                  fontWeight: FontWeight.w500,
                  color: Colors.grey,
                ),
              ),
              const Text(
                'Montant total',
                style: TextStyle(
                  fontSize: 12.0,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
          Text(
            _currencyFormat.format(totalAmount),
            style: const TextStyle(
              fontSize: 20.0,
              fontWeight: FontWeight.bold,
              color: AppTheme.primaryColor,
            ),
          ),
        ],
      ),
    );
  }

  // Construire la feuille de détails d'un paiement
  Widget _buildPaymentDetailsSheet(Payment payment) {
    return Container(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Détails du paiement',
            style: TextStyle(
              fontSize: 20.0,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 24.0),
          _buildDetailRow('ID Transaction', payment.id),
          _buildDetailRow('Client', payment.clientName),
          _buildDetailRow('Service', payment.serviceName),
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
          _buildDetailRow('Moyen de paiement', payment.paymentMethod),
          const SizedBox(height: 24.0),
          if (payment.receiptUrl.isNotEmpty) ...[
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.receipt_long),
                label: const Text('Voir le reçu'),
                onPressed: () {
                  // TODO: Implémenter la visualisation du reçu
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Ouverture du reçu...'),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                ),
              ),
            ),
            const SizedBox(height: 8.0),
          ],
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Fermer'),
            ),
          ),
        ],
      ),
    );
  }

  // Construire une ligne de détail
  Widget _buildDetailRow(String label, String value, {TextStyle? valueStyle}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140.0,
            child: Text(
              label,
              style: const TextStyle(
                color: Colors.grey,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const Text(':  '),
          Expanded(
            child: Text(
              value,
              style: valueStyle,
            ),
          ),
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

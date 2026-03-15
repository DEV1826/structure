import 'package:flutter/material.dart';
import 'package:structure_mobile/core/constants/app_constants.dart';
import 'package:structure_mobile/features/user/models/service_model.dart';

// Énumération des méthodes de paiement disponibles
enum PaymentMethod {
  mtnMoney('MTN Money', Icons.phone_android, 'MTN'),
  orangeMoney('Orange Money', Icons.phone_iphone, 'Orange'),
  moovMoney('Moov Money', Icons.phone_android, 'Moov'),
  campost('CAMPOST', Icons.account_balance, 'CAMPOST');

  final String name;
  final IconData icon;
  final String prefix;

  const PaymentMethod(this.name, this.icon, this.prefix);
}

class PaymentForm extends StatefulWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController phoneController;
  final TextEditingController nameController;
  final TextEditingController secretCodeController;
  final List<Map<String, dynamic>> selectedServices;
  final double totalAmount;
  final bool isEnabled;
  final ValueChanged<PaymentMethod>? onPaymentMethodSelected;
  final ValueChanged<String>? onSecretCodeChanged;
  final bool isProcessing;
  final PaymentMethod selectedPaymentMethod;
  final Future<void> Function() onPaymentSubmitted;

  const PaymentForm({
    Key? key,
    required this.formKey,
    required this.phoneController,
    required this.nameController,
    required this.secretCodeController,
    required this.selectedServices,
    required this.totalAmount,
    this.isEnabled = true,
    this.onPaymentMethodSelected,
    this.onSecretCodeChanged,
    this.isProcessing = false,
    required this.selectedPaymentMethod,
    required this.onPaymentSubmitted,
  }) : super(key: key);

  @override
  State<PaymentForm> createState() => _PaymentFormState();
}

class _PaymentFormState extends State<PaymentForm> {
  late PaymentMethod _selectedMethod;
  bool _showSecretCodeField = false;
  final _secretCodeFormKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _selectedMethod = widget.selectedPaymentMethod;
    // Si le numéro commence par un préfixe connu, sélectionner automatiquement la méthode
    _detectPaymentMethodFromPhoneNumber();
  }

  @override
  void didUpdateWidget(PaymentForm oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.phoneController.text != widget.phoneController.text) {
      _detectPaymentMethodFromPhoneNumber();
    }
  }

  void _detectPaymentMethodFromPhoneNumber() {
    final phone = widget.phoneController.text.trim();
    if (phone.isEmpty) return;

    // Détection basée sur les préfixes des opérateurs camerounais
    if (phone.startsWith('6') ||
        phone.startsWith('65') ||
        phone.startsWith('67') ||
        phone.startsWith('68') ||
        phone.startsWith('69')) {
      setState(() => _selectedMethod = PaymentMethod.mtnMoney);
    } else if (phone.startsWith('65') || phone.startsWith('69')) {
      setState(() => _selectedMethod = PaymentMethod.orangeMoney);
    } else if (phone.startsWith('65') || phone.startsWith('69')) {
      setState(() => _selectedMethod = PaymentMethod.moovMoney);
    }

    // Notifier le parent du changement de méthode
    widget.onPaymentMethodSelected?.call(_selectedMethod);
  }

  void _onPaymentMethodSelected(PaymentMethod? method) {
    if (method == null) return;

    setState(() {
      _selectedMethod = method;
      _showSecretCodeField = false; // Réinitialiser l'affichage du code secret
    });

    // Mettre à jour le préfixe du numéro si nécessaire
    if (!widget.phoneController.text.startsWith(method.prefix)) {
      widget.phoneController.text = method.prefix;
    }

    // Notifier le parent du changement de méthode
    widget.onPaymentMethodSelected?.call(method);
  }

  void _onProceedToPayment() {
    if (!_showSecretCodeField) {
      setState(() => _showSecretCodeField = true);
    } else if (_secretCodeFormKey.currentState?.validate() ?? false) {
      // Le code secret est valide, le parent peut procéder au paiement
      widget.onSecretCodeChanged?.call(widget.secretCodeController.text);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Form(
      key: widget.formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Récapitulatif des services
          Card(
            elevation: 1,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppConstants.mediumRadius),
              side: BorderSide(color: theme.dividerColor.withOpacity(0.1)),
            ),
            child: Padding(
              padding: const EdgeInsets.all(AppConstants.mediumPadding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Récapitulatif de la commande',
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: AppConstants.mediumPadding),

                  // Liste des services sélectionnés
                  ...widget.selectedServices.map((item) {
                    final service = item['service'] as ServiceModel;
                    final quantity = item['quantity'] as int;
                    final total = (service.price ?? 0) * quantity;

                    return Padding(
                      padding: const EdgeInsets.only(
                        bottom: AppConstants.smallPadding,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  '${service.name} (x$quantity)',
                                  style: theme.textTheme.bodyMedium,
                                ),
                              ),
                              Text(
                                '${total.toStringAsFixed(0)} FCFA',
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          if (widget.selectedServices.last != item) ...{
                            const Divider(height: AppConstants.mediumPadding),
                          },
                        ],
                      ),
                    );
                  }).toList(),

                  const Divider(height: AppConstants.largePadding),

                  // Total
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Total à payer',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '${widget.totalAmount.toStringAsFixed(0)} FCFA',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: AppConstants.mediumPadding),

          // Champ du nom complet
          TextFormField(
            controller: widget.nameController,
            enabled: widget.isEnabled,
            decoration: InputDecoration(
              labelText: 'Votre nom complet',
              prefixIcon: const Icon(Icons.person_outline),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppConstants.mediumRadius),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: AppConstants.mediumPadding,
                vertical: AppConstants.smallPadding,
              ),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Veuillez entrer votre nom complet';
              }
              if (value.length < 3) {
                return 'Le nom doit contenir au moins 3 caractères';
              }
              return null;
            },
            textInputAction: TextInputAction.next,
          ),

          const SizedBox(height: AppConstants.mediumPadding),

          // Champ du numéro de téléphone avec préfixe
          TextFormField(
            controller: widget.phoneController,
            enabled: widget.isEnabled,
            decoration: InputDecoration(
              labelText: 'Numéro de téléphone',
              hintText: 'Ex: 0123456789',
              prefixIcon: const Icon(Icons.phone_android_outlined),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppConstants.mediumRadius),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: AppConstants.mediumPadding,
                vertical: AppConstants.smallPadding,
              ),
            ),
            keyboardType: TextInputType.phone,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Veuillez entrer votre numéro de téléphone';
              }

              // Vérification basique du format du numéro de téléphone
              final phoneRegex = RegExp(r'^[0-9]{8,15}$');
              if (!phoneRegex.hasMatch(value)) {
                return 'Numéro de téléphone invalide';
              }

              return null;
            },
            textInputAction: TextInputAction.done,
          ),

          const SizedBox(height: AppConstants.mediumPadding),

          // Méthodes de paiement
          Text(
            'Méthode de paiement',
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: AppConstants.smallPadding),

          // Sélecteur de méthode de paiement
          DropdownButtonFormField<PaymentMethod>(
            value: _selectedMethod,
            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppConstants.mediumRadius),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: AppConstants.mediumPadding,
                vertical: AppConstants.smallPadding,
              ),
            ),
            items: PaymentMethod.values.map((method) {
              return DropdownMenuItem(
                value: method,
                child: Row(
                  children: [
                    Icon(
                      method.icon,
                      size: 20,
                      color: theme.colorScheme.primary,
                    ),
                    const SizedBox(width: 12),
                    Text(method.name),
                  ],
                ),
              );
            }).toList(),
            onChanged: widget.isEnabled ? _onPaymentMethodSelected : null,
            isExpanded: true,
          ),

          // Champ du code secret (affiché uniquement après sélection de la méthode)
          if (_showSecretCodeField) ...[
            const SizedBox(height: AppConstants.mediumPadding),
            Form(
              key: _secretCodeFormKey,
              child: TextFormField(
                controller: widget.secretCodeController,
                enabled: widget.isEnabled && !widget.isProcessing,
                obscureText: true,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Code secret',
                  hintText: 'Entrez votre code secret',
                  prefixIcon: const Icon(Icons.lock_outline),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(
                      AppConstants.mediumRadius,
                    ),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: AppConstants.mediumPadding,
                    vertical: AppConstants.smallPadding,
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez entrer votre code secret';
                  }
                  if (value.length < 4) {
                    return 'Le code secret doit contenir au moins 4 chiffres';
                  }
                  return null;
                },
              ),
            ),
          ],

          const SizedBox(height: AppConstants.largePadding),

          // Bouton de paiement
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: widget.isEnabled && !widget.isProcessing
                  ? _onProceedToPayment
                  : null,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(
                    AppConstants.mediumRadius,
                  ),
                ),
              ),
              child: widget.isProcessing
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : Text(
                      _showSecretCodeField
                          ? 'Payer maintenant'
                          : 'Continuer vers le paiement',
                      style: const TextStyle(fontSize: 16),
                    ),
            ),
          ),

          const SizedBox(height: AppConstants.mediumPadding),

          // Informations de sécurité
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.lock_outline, size: 16, color: Colors.grey),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Vos informations de paiement sont sécurisées et cryptées. Nous ne stockons jamais les détails de votre carte.',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

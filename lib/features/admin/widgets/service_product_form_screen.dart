import 'package:flutter/material.dart';
import 'package:structure_mobile/features/admin/models/service_product_model.dart';
import 'package:structure_mobile/themes/app_theme.dart';

class ServiceProductFormScreen extends StatefulWidget {
  final ServiceProduct? serviceProduct;
  final Function(ServiceProduct) onSave;
  final String structureId;
  final String structureName;

  const ServiceProductFormScreen({
    super.key,
    this.serviceProduct,
    required this.onSave,
    required this.structureId,
    required this.structureName,
  });

  @override
  State<ServiceProductFormScreen> createState() => _ServiceProductFormScreenState();
}

class _ServiceProductFormScreenState extends State<ServiceProductFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  late TextEditingController _priceController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.serviceProduct?.name ?? '');
    _descriptionController = TextEditingController(text: widget.serviceProduct?.description ?? '');
    _priceController = TextEditingController(
      text: widget.serviceProduct?.price.toString() ?? '',
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      final serviceProduct = ServiceProduct(
        id: widget.serviceProduct?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
        name: _nameController.text,
        description: _descriptionController.text,
        price: double.tryParse(_priceController.text) ?? 0.0,
        structureId: widget.structureId,
      );
      widget.onSave(serviceProduct);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.serviceProduct == null
              ? 'Nouveau service/produit'
              : 'Modifier le service/produit',
        ),
        backgroundColor: AppTheme.primaryColor,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Informations sur la structure
              Card(
                margin: const EdgeInsets.only(bottom: 20.0),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Structure',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 8.0),
                      Text(
                        widget.structureName,
                        style: const TextStyle(fontSize: 18),
                      ),
                    ],
                  ),
                ),
              ),

              // Champ Nom
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Nom du service/produit',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.medical_services),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez entrer un nom';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16.0),

              // Champ Description
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  border: OutlineInputBorder(),
                  alignLabelWithHint: true,
                ),
                maxLines: 3,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez entrer une description';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16.0),

              // Champ Prix
              TextFormField(
                controller: _priceController,
                decoration: const InputDecoration(
                  labelText: 'Prix (XAF)',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.attach_money),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez entrer un prix';
                  }
                  final price = double.tryParse(value);
                  if (price == null || price <= 0) {
                    return 'Veuillez entrer un prix valide';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 32.0),

              // Bouton de soumission
              SizedBox(
                width: double.infinity,
                height: 50.0,
                child: ElevatedButton(
                  onPressed: _submitForm,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                  ),
                  child: const Text(
                    'Enregistrer',
                    style: TextStyle(
                      fontSize: 16.0,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

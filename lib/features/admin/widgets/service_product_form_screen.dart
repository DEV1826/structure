import 'package:flutter/material.dart';
import 'package:structure_mobile/features/admin/models/service_product_model.dart';
import 'package:structure_mobile/themes/app_theme.dart';

class ServiceProductFormScreen extends StatefulWidget {
  final ServiceProduct? serviceProduct;
  final Future<void> Function(ServiceProduct) onSave;
  final String? initialStructureId;
  final String? initialStructureName;
  final List<Map<String, dynamic>> structures;
  final bool isSuperAdmin;

  const ServiceProductFormScreen({
    super.key,
    this.serviceProduct,
    required this.onSave,
    this.initialStructureId,
    this.initialStructureName,
    this.structures = const [],
    this.isSuperAdmin = false,
  });

  @override
  State<ServiceProductFormScreen> createState() =>
      _ServiceProductFormScreenState();
}

class _ServiceProductFormScreenState extends State<ServiceProductFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  late TextEditingController _priceController;
  String? _selectedStructureId;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _nameController =
        TextEditingController(text: widget.serviceProduct?.name ?? '');
    _descriptionController =
        TextEditingController(text: widget.serviceProduct?.description ?? '');
    _priceController = TextEditingController(
      text: widget.serviceProduct?.price != null
          ? widget.serviceProduct!.price.toStringAsFixed(0)
          : '',
    );
    _selectedStructureId = widget.serviceProduct?.structureId ?? widget.initialStructureId;
    
    // Si on a des structures et aucune sélectionnée (ou sélection non valide), on prend la première
    if (widget.isSuperAdmin && widget.structures.isNotEmpty) {
      bool isValid = widget.structures.any((s) => s['id'].toString() == _selectedStructureId);
      if (!isValid) {
        _selectedStructureId = widget.structures.first['id'].toString();
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedStructureId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Veuillez sélectionner une structure')),
      );
      return;
    }

    setState(() => _isSaving = true);

    final serviceProduct = ServiceProduct(
      id: widget.serviceProduct?.id ??
          DateTime.now().millisecondsSinceEpoch.toString(),
      name: _nameController.text.trim(),
      description: _descriptionController.text.trim(),
      price: double.tryParse(_priceController.text) ?? 0.0,
      structureId: _selectedStructureId!,
    );

    try {
      await widget.onSave(serviceProduct);
      if (mounted) Navigator.pop(context, serviceProduct);
    } catch (_) {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.serviceProduct == null
            ? 'Nouveau service/produit'
            : 'Modifier le service/produit'),
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
              // Sélection de structure
              if (widget.isSuperAdmin && widget.structures.isNotEmpty)
                Container(
                  margin: const EdgeInsets.only(bottom: 20.0),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.blue[50],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.blue[100]!),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Sélectionner la structure *',
                          style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Colors.blueGrey)),
                      const SizedBox(height: 8),
                      DropdownButtonFormField<String>(
                        value: _selectedStructureId,
                        isExpanded: true,
                        decoration: const InputDecoration(
                          contentPadding: EdgeInsets.symmetric(horizontal: 10),
                          border: OutlineInputBorder(),
                          fillColor: Colors.white,
                          filled: true,
                        ),
                        items: widget.structures.map((s) {
                          return DropdownMenuItem<String>(
                            value: s['id'].toString(),
                            child: Text(s['name'] ?? 'Inconnu'),
                          );
                        }).toList(),
                        onChanged: (val) {
                          setState(() {
                            _selectedStructureId = val;
                          });
                        },
                      ),
                    ],
                  ),
                )
              else if (widget.initialStructureName != null)
                Card(
                  margin: const EdgeInsets.only(bottom: 20.0),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Structure',
                            style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey)),
                        const SizedBox(height: 4),
                        Text(widget.initialStructureName!,
                            style: const TextStyle(
                                fontSize: 16, fontWeight: FontWeight.w500)),
                      ],
                    ),
                  ),
                ),

              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Nom du service/produit',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.medical_services),
                ),
                validator: (v) =>
                (v == null || v.trim().isEmpty) ? 'Champ requis' : null,
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  border: OutlineInputBorder(),
                  alignLabelWithHint: true,
                ),
                maxLines: 3,
                validator: (v) =>
                (v == null || v.trim().isEmpty) ? 'Champ requis' : null,
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _priceController,
                decoration: const InputDecoration(
                  labelText: 'Prix (XAF)',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.attach_money),
                ),
                keyboardType:
                const TextInputType.numberWithOptions(decimal: true),
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Champ requis';
                  final p = double.tryParse(v);
                  if (p == null || p <= 0) return 'Prix invalide';
                  return null;
                },
              ),
              const SizedBox(height: 32),

              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isSaving ? null : _submitForm,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryColor,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                  ),
                  child: _isSaving
                      ? const SizedBox(
                      height: 22,
                      width: 22,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white))
                      : const Text('Enregistrer',
                      style:
                      TextStyle(fontSize: 16, color: Colors.white)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
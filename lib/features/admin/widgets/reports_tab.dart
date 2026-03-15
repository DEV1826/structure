import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:structure_mobile/themes/app_theme.dart';
import 'package:csv/csv.dart';
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';

class ReportsTab extends StatefulWidget {
  const ReportsTab({super.key});

  @override
  State<ReportsTab> createState() => _ReportsTabState();
}

class _ReportsTabState extends State<ReportsTab> {
  String _selectedReportType = 'revenue';
  String _selectedPeriod = 'monthly';
  DateTime _selectedDate = DateTime.now();
  
  final List<Map<String, dynamic>> _reportTypes = [
    {'id': 'revenue', 'label': 'Revenus', 'icon': Icons.attach_money},
    {'id': 'users', 'label': 'Utilisateurs', 'icon': Icons.people},
    {'id': 'structures', 'label': 'Structures', 'icon': Icons.business},
  ];
  
  final List<Map<String, dynamic>> _periods = [
    {'id': 'daily', 'label': 'Journalier'},
    {'id': 'weekly', 'label': 'Hebdomadaire'},
    {'id': 'monthly', 'label': 'Mensuel'},
  ];
  
  // Données de démonstration
  final Map<String, List<Map<String, dynamic>>> _chartData = {
    'revenue': [
      {'month': 'Jan', 'value': 12000, 'target': 15000},
      {'month': 'Fév', 'value': 15000, 'target': 15000},
      {'month': 'Mar', 'value': 18000, 'target': 16000},
      {'month': 'Avr', 'value': 14000, 'target': 17000},
      {'month': 'Mai', 'value': 22000, 'target': 18000},
      {'month': 'Juin', 'value': 25000, 'target': 20000},
      {'month': 'Juil', 'value': 28000, 'target': 22000},
    ],
    'users': [
      {'month': 'Jan', 'new': 120, 'total': 1200},
      {'month': 'Fév', 'new': 150, 'total': 1350},
      {'month': 'Mar', 'new': 180, 'total': 1530},
      {'month': 'Avr', 'new': 140, 'total': 1670},
      {'month': 'Mai', 'new': 220, 'total': 1890},
      {'month': 'Juin', 'new': 250, 'total': 2140},
      {'month': 'Juil', 'new': 280, 'total': 2420},
    ],
    'structures': [
      {'month': 'Jan', 'total': 120, 'active': 100, 'pending': 20},
      {'month': 'Fév', 'total': 135, 'active': 110, 'pending': 25},
      {'month': 'Mar', 'total': 153, 'active': 125, 'pending': 28},
      {'month': 'Avr', 'total': 167, 'active': 140, 'pending': 27},
      {'month': 'Mai', 'total': 189, 'active': 160, 'pending': 29},
      {'month': 'Juin', 'total': 214, 'active': 180, 'pending': 34},
      {'month': 'Juil', 'total': 242, 'active': 200, 'pending': 42},
    ],
  };

  @override
  Widget build(BuildContext context) {
    final chartData = _chartData[_selectedReportType]!;
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // En-tête avec sélecteurs
          _buildHeader(),
          
          const SizedBox(height: 16),
          
          // Graphique principal
          _buildMainChart(chartData),
          
          const SizedBox(height: 24),
          
          // Tableau de données
          _buildDataTable(chartData),
          
          const SizedBox(height: 24),
          
          // Bouton d'export
          Center(
            child: ElevatedButton.icon(
              onPressed: _exportReport,
              icon: const Icon(Icons.download, size: 20),
              label: const Text('Exporter le rapport'),
              style: ButtonStyle(
                backgroundColor: WidgetStateProperty.all<Color>(AppTheme.primaryColor),
                foregroundColor: WidgetStateProperty.all<Color>(Colors.white),
                padding: WidgetStateProperty.all<EdgeInsetsGeometry>(
                  const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
                shape: WidgetStateProperty.all<RoundedRectangleBorder>(
                  RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildHeader() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Rapports et analyses',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppTheme.primaryColor,
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Sélecteur de type de rapport
            const Text(
              'Type de rapport',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
            const SizedBox(height: 8),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: _reportTypes.map((type) {
                  final isSelected = _selectedReportType == type['id'];
                  return Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: FilterChip(
                      label: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(type['icon'], size: 16, color: isSelected ? Colors.white : null),
                          const SizedBox(width: 4),
                          Text(type['label']),
                        ],
                      ),
                      selected: isSelected,
                      onSelected: (selected) {
                        setState(() {
                          _selectedReportType = selected ? type['id'] : _selectedReportType;
                        });
                      },
                      backgroundColor: isSelected 
                          ? AppTheme.primaryColor 
                          : Colors.grey[200],
                      labelStyle: TextStyle(
                        color: isSelected ? Colors.white : Colors.black87,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Sélecteur de période et date
            Row(
              children: [
                // Sélecteur de période
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Période',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.grey[300]!),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: _selectedPeriod,
                            isExpanded: true,
                            icon: const Icon(Icons.arrow_drop_down, size: 20),
                            style: const TextStyle(fontSize: 14, color: Colors.black87),
                            onChanged: (String? newValue) {
                              if (newValue != null) {
                                setState(() {
                                  _selectedPeriod = newValue;
                                });
                              }
                            },
                            items: _periods.map<DropdownMenuItem<String>>((period) {
                              return DropdownMenuItem<String>(
                                value: period['id'],
                                child: Text(period['label']),
                              );
                            }).toList(),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(width: 16),
                
                // Sélecteur de date
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Date',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                      ),
                      const SizedBox(height: 8),
                      InkWell(
                        onTap: _selectDate,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.grey[300]!),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.calendar_today, size: 16, color: Colors.grey),
                              const SizedBox(width: 8),
                              Text(
                                DateFormat('dd/MM/yyyy').format(_selectedDate),
                                style: const TextStyle(fontSize: 14),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildMainChart(List<Map<String, dynamic>> data) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _getChartTitle(),
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            
            const SizedBox(height: 16),
            
            SizedBox(
              height: 300,
              child: SfCartesianChart(
                primaryXAxis: CategoryAxis(
                  labelRotation: 0,
                  labelStyle: const TextStyle(fontSize: 10),
                ),
                primaryYAxis: NumericAxis(
                  numberFormat: _selectedReportType == 'revenue' 
                      ? NumberFormat.currency(symbol: 'FCFA ', decimalDigits: 0)
                      : null,
                  labelStyle: const TextStyle(fontSize: 10),
                ),
                tooltipBehavior: TooltipBehavior(
                  enable: true,
                  header: '',
                  format: _getTooltipFormat(),
                ),
                legend: Legend(
                  isVisible: true,
                  position: LegendPosition.bottom,
                  overflowMode: LegendItemOverflowMode.wrap,
                  textStyle: const TextStyle(fontSize: 10),
                ),
                series: _getChartSeries(data),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  String _getChartTitle() {
    switch (_selectedReportType) {
      case 'revenue':
        return 'Évolution des revenus';
      case 'users':
        return 'Croissance des utilisateurs';
      case 'structures':
        return 'Évolution des structures';
      default:
        return 'Graphique';
    }
  }
  
  String _getTooltipFormat() {
    switch (_selectedReportType) {
      case 'revenue':
        return 'point.x : point.y FCFA';
      case 'users':
      case 'structures':
        return 'point.x : point.y';
      default:
        return 'point.x : point.y';
    }
  }
  
  List<CartesianSeries<Map<String, dynamic>, String>> _getChartSeries(List<Map<String, dynamic>> data) {
    switch (_selectedReportType) {
      case 'revenue':
        return [
          ColumnSeries<Map<String, dynamic>, String>(
            dataSource: data,
            xValueMapper: (data, _) => data['month'],
            yValueMapper: (data, _) => data['value'],
            name: 'Revenus',
            color: AppTheme.primaryColor,
            width: 0.6,
            spacing: 0.2,
          ),
          LineSeries<Map<String, dynamic>, String>(
            dataSource: data,
            xValueMapper: (data, _) => data['month'],
            yValueMapper: (data, _) => data['target'],
            name: 'Objectif',
            color: Colors.green,
            width: 2,
            markerSettings: const MarkerSettings(
              isVisible: true,
              height: 4,
              width: 4,
              borderWidth: 2,
              borderColor: Colors.green,
            ),
            dashArray: const [5, 5],
          ),
        ];
      case 'users':
        return [
          LineSeries<Map<String, dynamic>, String>(
            dataSource: data,
            xValueMapper: (data, _) => data['month'],
            yValueMapper: (data, _) => data['total'],
            name: 'Total utilisateurs',
            color: Colors.blue,
            width: 3,
            markerSettings: const MarkerSettings(isVisible: true),
          ),
          LineSeries<Map<String, dynamic>, String>(
            dataSource: data,
            xValueMapper: (data, _) => data['month'],
            yValueMapper: (data, _) => data['new'],
            name: 'Nouveaux',
            color: Colors.green,
            width: 2,
            markerSettings: const MarkerSettings(isVisible: true),
          ),
        ];
      case 'structures':
        return [
          LineSeries<Map<String, dynamic>, String>(
            dataSource: data,
            xValueMapper: (data, _) => data['month'],
            yValueMapper: (data, _) => data['total'],
            name: 'Total structures',
            color: Colors.blue,
            width: 3,
            markerSettings: const MarkerSettings(isVisible: true),
          ),
          LineSeries<Map<String, dynamic>, String>(
            dataSource: data,
            xValueMapper: (data, _) => data['month'],
            yValueMapper: (data, _) => data['active'],
            name: 'Actives',
            color: Colors.green,
            width: 2,
            markerSettings: const MarkerSettings(isVisible: true),
          ),
          LineSeries<Map<String, dynamic>, String>(
            dataSource: data,
            xValueMapper: (data, _) => data['month'],
            yValueMapper: (data, _) => data['pending'],
            name: 'En attente',
            color: Colors.orange,
            width: 2,
            markerSettings: const MarkerSettings(isVisible: true),
          ),
        ];
      default:
        return [];
    }
  }
  
  Widget _buildDataTable(List<Map<String, dynamic>> data) {
    List<DataColumn> columns = [];
    List<DataRow> rows = [];
    
    // Définir les colonnes en fonction du type de rapport
    switch (_selectedReportType) {
      case 'revenue':
        columns = const [
          DataColumn(label: Text('Mois')),
          DataColumn(label: Text('Revenus'), numeric: true),
          DataColumn(label: Text('Objectif'), numeric: true),
          DataColumn(label: Text('Écart'), numeric: true),
        ];
        
        rows = data.map<DataRow>((item) {
          final diff = (item['value'] as int) - (item['target'] as int);
          final isPositive = diff >= 0;
          
          return DataRow(
            cells: [
              DataCell(Text(item['month'])),
              DataCell(Text('${item['value']} FCFA')),
              DataCell(Text('${item['target']} FCFA')),
              DataCell(
                Text(
                  '${isPositive ? '+' : ''}${diff.toStringAsFixed(0)} FCFA',
                  style: TextStyle(
                    color: isPositive ? Colors.green : Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          );
        }).toList();
        break;
        
      case 'users':
        columns = const [
          DataColumn(label: Text('Mois')),
          DataColumn(label: Text('Nouveaux'), numeric: true),
          DataColumn(label: Text('Total'), numeric: true),
          DataColumn(label: Text('Croissance'), numeric: true),
        ];
        
        rows = data.asMap().entries.map<DataRow>((entry) {
          final index = entry.key;
          final item = entry.value;
          final growth = index > 0 
              ? ((item['new'] as int) / (data[index-1]['total'] as int) * 100).toStringAsFixed(1) + '%'
              : '-';
          
          return DataRow(
            cells: [
              DataCell(Text(item['month'])),
              DataCell(Text(item['new'].toString())),
              DataCell(Text(item['total'].toString())),
              DataCell(Text(growth)),
            ],
          );
        }).toList();
        break;
        
      case 'structures':
        columns = const [
          DataColumn(label: Text('Mois')),
          DataColumn(label: Text('Actives'), numeric: true),
          DataColumn(label: Text('En attente'), numeric: true),
          DataColumn(label: Text('Total'), numeric: true),
        ];
        
        rows = data.map<DataRow>((item) {
          return DataRow(
            cells: [
              DataCell(Text(item['month'])),
              DataCell(Text(item['active'].toString())),
              DataCell(Text(item['pending'].toString())),
              DataCell(Text(item['total'].toString())),
            ],
          );
        }).toList();
        break;
    }
    
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          columns: columns,
          rows: rows,
          headingRowColor: MaterialStateProperty.all(Colors.grey[100]),
          dataRowMinHeight: 40,
          dataRowMaxHeight: 40,
          headingRowHeight: 44,
          horizontalMargin: 16,
          columnSpacing: 24,
        ),
      ),
    );
  }
  
  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: ThemeData.light().copyWith(
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
    
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }
  
  Future<void> _exportReport() async {
    // Afficher un indicateur de chargement
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Génération du rapport en cours...'),
        backgroundColor: Colors.blue,
        duration: Duration(seconds: 2),
      ),
    );

    try {
      // Obtenir le répertoire de stockage
      final directory = await getApplicationDocumentsDirectory();
      final dateStr = DateFormat('yyyyMMdd').format(DateTime.now());
      final reportType = _reportTypes.firstWhere(
        (type) => type['id'] == _selectedReportType,
        orElse: () => {'label': 'rapport'},
      )['label'] as String;
      
      final fileName = '${reportType}_${_selectedPeriod}_$dateStr.csv';
      final file = File('${directory.path}/$fileName');

      // Préparer les données CSV
      final data = _chartData[_selectedReportType] ?? [];
      
      if (data.isEmpty) {
        throw Exception('Aucune donnée à exporter');
      }

      // Créer l'en-tête CSV en fonction du type de rapport
      List<dynamic> header;
      List<List<dynamic>> rows = [];

      switch (_selectedReportType) {
        case 'revenue':
          header = ['Mois', 'Revenus (FCFA)', 'Objectif (FCFA)', 'Écart (FCFA)'];
          rows = List<List<dynamic>>.from(data.map<dynamic>((row) => [
                row['month'],
                row['value'],
                row['target'],
                (row['value'] as num) - (row['target'] as num),
              ]));
          break;
          
        case 'users':
          header = ['Mois', 'Nouveaux utilisateurs', 'Total utilisateurs'];
          rows = List<List<dynamic>>.from(data.map<dynamic>((row) => [
                row['month'],
                row['new'],
                row['total'],
              ]));
          break;
          
        case 'structures':
          header = ['Mois', 'Nouvelles structures', 'Total structures'];
          rows = List<List<dynamic>>.from(data.map<dynamic>((row) => [
                row['month'],
                row['new'],
                row['total'],
              ]));
          break;
          
        default:
          throw Exception('Type de rapport non supporté');
      }

      // Convertir en CSV
      final csvData = [header, ...rows];
      final csv = const ListToCsvConverter().convert(csvData);
      
      // Écrire dans le fichier
      await file.writeAsString(csv);

      // Afficher un message de succès avec option d'ouverture
      if (!mounted) return;
      
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      
      final result = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Rapport exporté avec succès'),
          content: Text('Le rapport a été enregistré sous :\n${file.path}'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('OK'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Ouvrir'),
            ),
          ],
        ),
      );

      // Ouvrir le fichier si demandé
      if (result == true) {
        await OpenFile.open(file.path);
      }
      
    } catch (e) {
      if (!mounted) return;
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur lors de l\'exportation : $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}



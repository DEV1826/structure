import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:structure_mobile/features/admin/models/dashboard_stats.dart';
import 'package:structure_mobile/features/admin/providers/dashboard_provider.dart';
import 'package:structure_mobile/themes/app_theme.dart';
import 'package:intl/intl.dart';

class OverviewTab extends StatelessWidget {
  const OverviewTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<DashboardProvider>(
      builder: (context, provider, _) {
        final stats = provider.stats;

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Graphique de revenus
              _buildSectionTitle('Revenus mensuels'),
              const SizedBox(height: 16),
              _buildRevenueChart(stats),
              const SizedBox(height: 24),

              // Graphique des catégories
              _buildSectionTitle('Répartition par catégorie'),
              const SizedBox(height: 16),
              _buildCategoryChart(stats),
              const SizedBox(height: 24),

              // Activités récentes
              _buildSectionTitle('Activités récentes'),
              const SizedBox(height: 16),
              _buildRecentActivities(stats),
              const SizedBox(height: 24),

              // Meilleures structures
              _buildSectionTitle('Meilleures structures'),
              const SizedBox(height: 16),
              _buildTopStructures(stats, context), // Correction ici
            ],
          ),
        );
      },
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: AppTheme.primaryColor,
      ),
    );
  }

  Widget _buildRevenueChart(DashboardStats stats) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: const Color.fromARGB(
              13,
              0,
              0,
              0,
            ), // Correction: Remplacement de `withValues`
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Évolution des revenus',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 250,
            child: SfCartesianChart(
              primaryXAxis: CategoryAxis(
                labelRotation: -45,
                labelStyle: const TextStyle(fontSize: 10),
              ),
              primaryYAxis: NumericAxis(
                numberFormat: NumberFormat.compact(
                  locale: 'fr_FR',
                  explicitSign: false,
                ),
                labelStyle: const TextStyle(fontSize: 10),
              ),
              tooltipBehavior: TooltipBehavior(
                enable: true,
                header: '',
                format: 'point.x : point.y FCFA',
              ),
              series: <CartesianSeries>[
                ColumnSeries<Map<String, dynamic>, String>(
                  dataSource: stats.chartData,
                  xValueMapper: (data, _) => data['month'],
                  yValueMapper: (data, _) => data['revenue'],
                  name: 'Revenus',
                  color: AppTheme.primaryColor,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(4),
                  ),
                  width: 0.6,
                  spacing: 0.2,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryChart(DashboardStats stats) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: const Color.fromARGB(
              13,
              0,
              0,
              0,
            ), // Correction: Remplacement de `withValues`
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          SizedBox(
            height: 300,
            child: SfCircularChart(
              legend: Legend(
                isVisible: true,
                position: LegendPosition.bottom,
                overflowMode: LegendItemOverflowMode.wrap,
                textStyle: const TextStyle(fontSize: 10),
              ),
              series: <CircularSeries>[
                DoughnutSeries<Map<String, dynamic>, String>(
                  dataSource: stats.categoryData,
                  xValueMapper: (data, _) => data['category'],
                  yValueMapper: (data, _) => data['count'],
                  pointColorMapper: (data, _) {
                    final colors = [
                      Colors.blue,
                      Colors.green,
                      Colors.orange,
                      Colors.purple,
                      Colors.teal,
                      Colors.amber,
                      Colors.red,
                      Colors.indigo,
                      Colors.pink,
                      Colors.cyan,
                    ];
                    final index =
                        stats.categoryData.indexOf(data) % colors.length;
                    return colors[index];
                  },
                  dataLabelSettings: DataLabelSettings(
                    isVisible: true,
                    labelPosition: ChartDataLabelPosition.outside,
                    textStyle: TextStyle(fontSize: 10),
                    builder:
                        (
                          dynamic data,
                          dynamic point,
                          dynamic series,
                          int pointIndex,
                          int seriesIndex,
                        ) {
                          return Text('${point.y}');
                        },
                  ),
                  radius: '70%',
                  innerRadius: '40%',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentActivities(DashboardStats stats) {
    if (stats.recentActivities.isEmpty) {
      return const Center(child: Text('Aucune activité récente'));
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: const Color.fromARGB(
              13,
              0,
              0,
              0,
            ), // Correction: Remplacement de `withValues`
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: stats.recentActivities.length,
        separatorBuilder: (context, index) =>
            const Divider(height: 1, indent: 16, endIndent: 16),
        itemBuilder: (context, index) {
          final activity = stats.recentActivities[index];
          return ListTile(
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withAlpha(
                  (255 * 0.1).round(),
                ), // Correction: Remplacement de `withOpacity`
                shape: BoxShape.circle,
              ),
              child: Icon(
                activity['icon'] ?? Icons.notifications_none,
                color: AppTheme.primaryColor,
                size: 20,
              ),
            ),
            title: Text(
              activity['title'] ?? '',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text(activity['description'] ?? ''),
            trailing: Text(
              activity['time'] ?? '',
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 8,
            ),
            onTap: () {
              // TODO: Gérer le clic sur une activité
            },
          );
        },
      ),
    );
  }

  Widget _buildTopStructures(DashboardStats stats, BuildContext context) {
    // Correction: Ajout de 'context'
    if (stats.topStructures.isEmpty) {
      return const Center(child: Text('Aucune donnée disponible'));
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: const Color.fromARGB(
              13,
              0,
              0,
              0,
            ), // Correction: Remplacement de `withValues`
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          ...stats.topStructures.map((structure) {
            final revenue = structure['revenue'] as int;
            final revenueFormatted =
                '${(revenue / 1000).toStringAsFixed(0)}K FCFA';

            return ListTile(
              leading: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withAlpha(
                    (255 * 0.1).round(),
                  ), // Correction: Remplacement de `withOpacity`
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.business, color: AppTheme.primaryColor),
              ),
              title: Text(
                structure['name'] ?? '',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text(
                structure['category'] ?? '',
                style: const TextStyle(fontSize: 12),
              ),
              trailing: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    revenueFormatted,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primaryColor,
                    ),
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.star, color: Colors.amber, size: 16),
                      const SizedBox(width: 4),
                      Text(
                        structure['rating']?.toStringAsFixed(1) ?? '0.0',
                        style: const TextStyle(fontSize: 12),
                      ),
                    ],
                  ),
                ],
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 8,
              ),
              onTap: () {
                // TODO: Naviguer vers les détails de la structure
              },
            );
          }), // Correction: Suppression de `toList()`
          // Bouton pour voir toutes les structures
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () {
                  // TODO: Naviguer vers la liste complète des structures
                  final provider = Provider.of<DashboardProvider>(
                    context,
                    listen: false,
                  );
                  provider.setActiveTab('structures');
                },
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppTheme.primaryColor,
                  side: const BorderSide(color: AppTheme.primaryColor),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                child: const Text('Voir toutes les structures'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

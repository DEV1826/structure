import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:structure_mobile/features/admin/providers/dashboard_provider.dart';
import 'package:structure_mobile/themes/app_theme.dart';

class DashboardHeader extends StatelessWidget {
  const DashboardHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<DashboardProvider>(context, listen: false);
    final stats = provider.stats;
    
    return Container(
      color: AppTheme.primaryColor,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Ligne supérieure avec le titre et les actions
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Titre et filtre de date
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Tableau de bord',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    // Sélecteur de plage de dates
                    Consumer<DashboardProvider>(
                      builder: (context, provider, _) {
                        final startDate = provider.selectedDateRange.start;
                        final endDate = provider.selectedDateRange.end;
                        final dateFormat = 'd MMM yyyy';
                        
                        return GestureDetector(
                          onTap: () => _selectDateRange(context, provider),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  '${_formatDate(startDate, dateFormat)} - ${_formatDate(endDate, dateFormat)}',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                const Icon(
                                  Icons.calendar_today,
                                  size: 14,
                                  color: Colors.white,
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
                
                // Bouton de rafraîchissement
                IconButton(
                  icon: const Icon(Icons.refresh, color: Colors.white),
                  onPressed: provider.loadDashboardData,
                  tooltip: 'Rafraîchir',
                ),
              ],
            ),
            
            const SizedBox(height: 24),
            
            // Cartes de statistiques
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildStatCard(
                    context,
                    title: 'Structures',
                    value: '${stats.activeStructures}/${stats.totalStructures}',
                    subtitle: 'Actives',
                    icon: Icons.business,
                    color: Colors.blue[100]!,
                    textColor: Colors.blue[800]!,
                  ),
                  const SizedBox(width: 12),
                  _buildStatCard(
                    context,
                    title: 'Utilisateurs',
                    value: '${stats.activeUsers}/${stats.totalUsers}',
                    subtitle: 'Actifs',
                    icon: Icons.people,
                    color: Colors.green[100]!,
                    textColor: Colors.green[800]!,
                  ),
                  const SizedBox(width: 12),
                  _buildStatCard(
                    context,
                    title: 'Revenu total',
                    value: stats.formattedTotalRevenue,
                    subtitle: 'Ce mois-ci',
                    icon: Icons.attach_money,
                    color: Colors.orange[100]!,
                    textColor: Colors.orange[800]!,
                  ),
                  const SizedBox(width: 12),
                  _buildStatCard(
                    context,
                    title: 'Nouveaux utilisateurs',
                    value: '${stats.newUsersThisMonth}+',
                    subtitle: 'Ce mois-ci',
                    icon: Icons.person_add,
                    color: Colors.purple[100]!,
                    textColor: Colors.purple[800]!,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  // Méthode pour formater une date
  String _formatDate(DateTime date, String format) {
    return '${date.day} ${_getMonthName(date.month)} ${date.year}';
  }
  
  // Obtenir le nom du mois
  String _getMonthName(int month) {
    const months = [
      'Jan', 'Fév', 'Mar', 'Avr', 'Mai', 'Juin',
      'Juil', 'Août', 'Sep', 'Oct', 'Nov', 'Déc'
    ];
    return months[month - 1];
  }
  
  // Afficher le sélecteur de plage de dates
  Future<void> _selectDateRange(
    BuildContext context, 
    DashboardProvider provider,
  ) async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020, 1),
      lastDate: DateTime(2100),
      initialDateRange: provider.selectedDateRange,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppTheme.primaryColor,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black,
            ),
            dialogBackgroundColor: Colors.white,
          ),
          child: child!,
        );
      },
    );
    
    if (picked != null) {
      await provider.updateDateRange(picked);
    }
  }
  
  // Construire une carte de statistique
  Widget _buildStatCard(
    BuildContext context, {
    required String title,
    required String value,
    required String subtitle,
    required IconData icon,
    required Color color,
    required Color textColor,
  }) {
    return Container(
      width: 180,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // Icône
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: textColor, size: 20),
          ),
          const SizedBox(width: 12),
          // Texte
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  title,
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 12,
                  ),
                ),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: Colors.grey[500],
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

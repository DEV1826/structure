import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:structure_mobile/features/admin/providers/dashboard_provider.dart';
import 'package:structure_mobile/themes/app_theme.dart';

class UsersTab extends StatefulWidget {
  const UsersTab({super.key});

  @override
  State<UsersTab> createState() => _UsersTabState();
}

class _UsersTabState extends State<UsersTab> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedFilter = 'all';
  String _selectedRole = 'all';
  String _selectedSort = 'newest';
  bool _isLoading = false;

  // Méthode pour charger les utilisateurs avec filtres et tri
  Future<void> _loadFilteredAndSortedUsers() async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final provider = Provider.of<DashboardProvider>(context, listen: false);
      await provider.loadUsers(
        status: _selectedFilter == 'all' ? null : _selectedFilter,
        role: _selectedRole == 'all' ? null : _selectedRole,
        searchQuery: _searchController.text.isEmpty
            ? null
            : _searchController.text,
        sortBy: _selectedSort,
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur lors du chargement des utilisateurs: $e'),
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

  final List<Map<String, dynamic>> _filters = [
    {'id': 'all', 'label': 'Tous'},
    {'id': 'active', 'label': 'Actifs'},
    {'id': 'inactive', 'label': 'Inactifs'},
    {'id': 'suspended', 'label': 'Suspendus'},
  ];

  final List<Map<String, dynamic>> _roles = [
    {'id': 'all', 'label': 'Tous les rôles'},
    {'id': 'admin', 'label': 'Administrateurs'},
    {'id': 'structure_owner', 'label': 'Propriétaires'},
    {'id': 'user', 'label': 'Utilisateurs'},
  ];

  final List<Map<String, dynamic>> _sortOptions = [
    {'id': 'newest', 'label': 'Plus récents'},
    {'id': 'oldest', 'label': 'Plus anciens'},
    {'id': 'name_asc', 'label': 'Nom (A-Z)'},
    {'id': 'name_desc', 'label': 'Nom (Z-A)'},
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Barre de recherche et filtres
        Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // Barre de recherche
              TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Rechercher un utilisateur...',
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            _searchController.clear();
                            if (mounted) {
                              setState(() {
                                // La recherche sera effectuée lors de la soumission
                              });
                            }
                          },
                        )
                      : null,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: Theme.of(
                    context,
                  ).colorScheme.surfaceVariant.withOpacity(0.5),
                  contentPadding: const EdgeInsets.symmetric(
                    vertical: 0,
                    horizontal: 20,
                  ),
                ),
                onSubmitted: (value) {
                  // Recharger les utilisateurs avec le terme de recherche
                  _loadFilteredAndSortedUsers();
                },
              ),

              const SizedBox(height: 12),

              // Filtres
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Filtres de statut
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        const Text(
                          'Statut: ',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(width: 4),
                        ..._filters.map((filter) {
                          final isSelected = _selectedFilter == filter['id'];
                          return Padding(
                            padding: const EdgeInsets.only(right: 8.0),
                            child: FilterChip(
                              label: Text(filter['label']),
                              selected: isSelected,
                              onSelected: (selected) {
                                setState(() {
                                  _selectedFilter = selected
                                      ? filter['id']
                                      : 'all';
                                  if (mounted) {
                                    setState(() {
                                      // Le filtre sera appliqué lors du chargement des données
                                    });
                                  }
                                  _loadFilteredAndSortedUsers();
                                });
                              },
                              backgroundColor: isSelected
                                  ? AppTheme.primaryColor.withValues(
                                      red: AppTheme.primaryColor.red.toDouble(),
                                      green: AppTheme.primaryColor.green
                                          .toDouble(),
                                      blue: AppTheme.primaryColor.blue
                                          .toDouble(),
                                      alpha: 0.1,
                                    )
                                  : Theme.of(context).colorScheme.surfaceVariant
                                        .withOpacity(0.5),
                              labelStyle: TextStyle(
                                color: isSelected
                                    ? AppTheme.primaryColor
                                    : Colors.black87,
                                fontWeight: isSelected
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                              ),
                              side: BorderSide(
                                color: isSelected
                                    ? AppTheme.primaryColor
                                    : Colors.grey[300]!,
                              ),
                            ),
                          );
                        }).toList(),
                      ],
                    ),
                  ),

                  const SizedBox(height: 8),

                  // Filtres de rôle et tri
                  Row(
                    children: [
                      // Filtre de rôle
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: Colors.grey[300]!),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              value: _selectedRole,
                              isExpanded: true,
                              icon: const Icon(Icons.arrow_drop_down, size: 20),
                              style: const TextStyle(
                                fontSize: 14,
                                color: Colors.black87,
                              ),
                              onChanged: (String? newValue) {
                                if (newValue != null) {
                                  setState(() {
                                    _selectedRole = newValue;
                                    if (mounted) {
                                      setState(() {
                                        // Le filtre sera appliqué lors du chargement des données
                                      });
                                      _loadFilteredAndSortedUsers();
                                    }
                                  });
                                }
                              },
                              items: _roles.map<DropdownMenuItem<String>>((
                                role,
                              ) {
                                return DropdownMenuItem<String>(
                                  value: role['id'],
                                  child: Text(
                                    role['label'],
                                    style: const TextStyle(fontSize: 13),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                );
                              }).toList(),
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(width: 8),

                      // Menu de tri
                      PopupMenuButton<String>(
                        onSelected: (value) {
                          setState(() {
                            _selectedSort = value;
                            // TODO: Appliquer le tri
                          });
                        },
                        itemBuilder: (context) =>
                            _sortOptions.map<PopupMenuItem<String>>((option) {
                              return PopupMenuItem<String>(
                                value: option['id'] as String,
                                child: Text(option['label'] as String),
                              );
                            }).toList(),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: Colors.grey[300]!),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.sort, size: 16),
                              SizedBox(width: 4),
                              Text('Trier', style: TextStyle(fontSize: 13)),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),

        // Liste des utilisateurs
        Expanded(
          child: Consumer<DashboardProvider>(
            builder: (context, provider, _) {
              if (provider.isLoading) {
                return const Center(child: CircularProgressIndicator());
              }

              if (provider.error != null) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.error_outline,
                        size: 48,
                        color: Colors.red,
                      ),
                      const SizedBox(height: 16),
                      Text(provider.error!),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () {
                          // TODO: Recharger les données
                        },
                        child: const Text('Réessayer'),
                      ),
                    ],
                  ),
                );
              }

              // Données de démo - dans une vraie application, cela viendrait de l'API
              final users = [
                {
                  'id': '1',
                  'name': 'Admin User',
                  'email': 'admin@example.com',
                  'role': 'admin',
                  'status': 'active',
                  'lastLogin': 'Il y a 2 heures',
                  'createdAt': '15 Juin 2023',
                },
                {
                  'id': '2',
                  'name': 'Propriétaire Hôtel',
                  'email': 'hotel@example.com',
                  'role': 'structure_owner',
                  'status': 'active',
                  'lastLogin': 'Aujourd\'hui',
                  'createdAt': '1 Juil. 2023',
                  'structure': 'Hôtel du Plateau',
                },
                {
                  'id': '3',
                  'name': 'Utilisateur Test',
                  'email': 'user@example.com',
                  'role': 'user',
                  'status': 'active',
                  'lastLogin': 'Hier',
                  'createdAt': '10 Juil. 2023',
                },
                {
                  'id': '4',
                  'name': 'Restaurant Le Délicieux',
                  'email': 'resto@example.com',
                  'role': 'structure_owner',
                  'status': 'pending',
                  'lastLogin': 'Jamais',
                  'createdAt': 'Hier',
                  'structure': 'Restaurant Le Délicieux',
                },
                {
                  'id': '5',
                  'name': 'Utilisateur Suspendu',
                  'email': 'suspended@example.com',
                  'role': 'user',
                  'status': 'suspended',
                  'lastLogin': 'Il y a 2 semaines',
                  'createdAt': '1 Jan. 2023',
                  'suspendedReason': 'Violation des conditions d\'utilisation',
                },
              ];

              // Filtrer les utilisateurs en fonction des sélections
              final filteredUsers = users.where((user) {
                // Filtre par statut
                if (_selectedFilter != 'all' &&
                    user['status'] != _selectedFilter) {
                  return false;
                }

                // Filtre par rôle
                if (_selectedRole != 'all' && user['role'] != _selectedRole) {
                  return false;
                }

                // Filtre par recherche
                if (_searchController.text.isNotEmpty) {
                  final query = _searchController.text.toLowerCase();
                  if (!user['name'].toLowerCase().contains(query) &&
                      !user['email'].toLowerCase().contains(query)) {
                    return false;
                  }
                }

                return true;
              }).toList();

              // Trier les utilisateurs
              filteredUsers.sort((a, b) {
                switch (_selectedSort) {
                  case 'newest':
                    return 0; // Dans une vraie app, comparer les dates de création
                  case 'oldest':
                    return 0; // Dans une vraie app, comparer les dates de création
                  case 'name_asc':
                    return a['name'].compareTo(b['name']);
                  case 'name_desc':
                    return b['name'].compareTo(a['name']);
                  default:
                    return 0;
                }
              });

              if (filteredUsers.isEmpty) {
                return const Center(child: Text('Aucun utilisateur trouvé'));
              }

              return ListView.builder(
                padding: const EdgeInsets.only(bottom: 16),
                itemCount: filteredUsers.length,
                itemBuilder: (context, index) {
                  final user = filteredUsers[index];
                  return _buildUserCard(user);
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildUserCard(Map<String, dynamic> user) {
    final status = user['status'] ?? 'inactive';
    Color statusColor;
    String statusText;

    switch (status) {
      case 'active':
        statusColor = Colors.green;
        statusText = 'Actif';
        break;
      case 'inactive':
        statusColor = Colors.grey;
        statusText = 'Inactif';
        break;
      case 'pending':
        statusColor = Colors.orange;
        statusText = 'En attente';
        break;
      case 'suspended':
        statusColor = Colors.red;
        statusText = 'Suspendu';
        break;
      default:
        statusColor = Colors.grey;
        statusText = 'Inconnu';
    }

    // Déterminer le rôle de l'utilisateur
    String roleText;
    IconData roleIcon;
    Color roleColor;

    switch (user['role']) {
      case 'admin':
        roleText = 'Administrateur';
        roleIcon = Icons.admin_panel_settings;
        roleColor = Colors.purple;
        break;
      case 'structure_owner':
        roleText = 'Propriétaire';
        roleIcon = Icons.business;
        roleColor = Colors.blue;
        break;
      case 'user':
      default:
        roleText = 'Utilisateur';
        roleIcon = Icons.person;
        roleColor = Colors.green;
    }

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 2,
      child: InkWell(
        onTap: () {
          // TODO: Naviguer vers les détails de l'utilisateur
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Avatar de l'utilisateur
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      roleIcon,
                      color: AppTheme.primaryColor,
                      size: 24,
                    ),
                  ),

                  const SizedBox(width: 16),

                  // Détails de l'utilisateur
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                user['name'],
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: statusColor.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                statusText,
                                style: TextStyle(
                                  color: statusColor,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 4),

                        Text(
                          user['email'],
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey[600],
                          ),
                        ),

                        const SizedBox(height: 4),

                        Row(
                          children: [
                            Icon(roleIcon, size: 14, color: roleColor),
                            const SizedBox(width: 4),
                            Text(
                              roleText,
                              style: TextStyle(
                                fontSize: 12,
                                color: roleColor,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(width: 12),
                            const Icon(
                              Icons.calendar_today,
                              size: 12,
                              color: Colors.grey,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'Inscrit le ${user['createdAt']}',
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),

                        if (user['structure'] != null) ...[
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              const Icon(
                                Icons.business,
                                size: 12,
                                color: Colors.grey,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                user['structure'],
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        ],

                        if (user['suspendedReason'] != null) ...[
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              const Icon(
                                Icons.warning_amber,
                                size: 12,
                                color: Colors.orange,
                              ),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  user['suspendedReason'],
                                  style: const TextStyle(
                                    fontSize: 11,
                                    color: Colors.orange,
                                    fontStyle: FontStyle.italic,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // Actions
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  if (status == 'pending') ...[
                    TextButton(
                      onPressed: () {
                        _rejectUser(user['id']);
                      },
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.red,
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                      ),
                      child: const Text('Refuser'),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: () {
                        _approveUser(user['id']);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryColor,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                      ),
                      child: const Text('Approuver'),
                    ),
                  ] else ...[
                    TextButton(
                      onPressed: () {
                        // TODO: Voir les détails
                      },
                      style: TextButton.styleFrom(
                        foregroundColor: AppTheme.primaryColor,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                      ),
                      child: const Text('Détails'),
                    ),
                    if (status == 'suspended') ...[
                      const SizedBox(width: 8),
                      OutlinedButton(
                        onPressed: () {
                          _unsuspendUser(user['id']);
                        },
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.green,
                          side: const BorderSide(color: Colors.green),
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                        ),
                        child: const Text('Lever la suspension'),
                      ),
                    ] else ...[
                      const SizedBox(width: 8),
                      PopupMenuButton<String>(
                        onSelected: (value) {
                          if (value == 'suspend') {
                            _showSuspendDialog(user['id']);
                          } else if (value == 'edit') {
                            _editUser(user['id']);
                          } else if (value == 'delete') {
                            _deleteUser(user['id']);
                          }
                        },
                        itemBuilder: (context) => [
                          const PopupMenuItem(
                            value: 'edit',
                            child: Text('Modifier'),
                          ),
                          const PopupMenuItem(
                            value: 'suspend',
                            child: Text('Suspendre'),
                          ),
                          const PopupMenuItem(
                            value: 'delete',
                            child: Text(
                              'Supprimer',
                              style: TextStyle(color: Colors.red),
                            ),
                          ),
                        ],
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.grey[100],
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Icons.more_vert,
                            size: 20,
                            color: Colors.grey,
                          ),
                        ),
                      ),
                    ],
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Méthodes pour les actions sur les utilisateurs
  Future<void> _approveUser(String userId) async {
    if (!mounted) return;

    try {
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Confirmer l\'approbation'),
          content: const Text(
            'Voulez-vous vraiment approuver cet utilisateur ?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Annuler'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              style: TextButton.styleFrom(foregroundColor: Colors.green),
              child: const Text('Approuver'),
            ),
          ],
        ),
      );

      if (confirmed != true || !mounted) return;

      // Afficher un indicateur de chargement
      final scaffold = ScaffoldMessenger.of(context);
      scaffold.showSnackBar(
        const SnackBar(
          content: Text('Traitement en cours...'),
          duration: Duration(seconds: 2),
        ),
      );

      // Simuler un appel API
      await Future.delayed(const Duration(seconds: 1));

      if (!mounted) return;

      // Mettre à jour l'interface
      scaffold.hideCurrentSnackBar();
      scaffold.showSnackBar(
        const SnackBar(
          content: Text('Utilisateur approuvé avec succès'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
        ),
      );

      // TODO: Mettre à jour la liste des utilisateurs
      if (mounted) {
        // Recharger les données
        await _loadFilteredAndSortedUsers();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  void _rejectUser(String userId) async {
    final reasonController = TextEditingController();

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Refuser l\'utilisateur'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Veuillez indiquer la raison du refus :'),
            const SizedBox(height: 12),
            TextField(
              controller: reasonController,
              maxLines: 3,
              decoration: const InputDecoration(
                hintText: 'Raison du refus...',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () {
              final reason = reasonController.text.trim();
              if (reason.isNotEmpty) {
                Navigator.pop(context, true);
              }
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Confirmer le refus'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        final reason = reasonController.text.trim();

        // Afficher un indicateur de chargement
        final scaffold = ScaffoldMessenger.of(context);
        scaffold.showSnackBar(
          const SnackBar(
            content: Text('Traitement en cours...'),
            duration: Duration(seconds: 2),
          ),
        );

        // Simuler un appel API
        await Future.delayed(const Duration(seconds: 1));

        // Mettre à jour l'interface
        scaffold.hideCurrentSnackBar();
        scaffold.showSnackBar(
          const SnackBar(
            content: Text('Utilisateur refusé avec succès'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );

        // TODO: Mettre à jour la liste des utilisateurs
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Erreur: $e'), backgroundColor: Colors.red),
          );
        }
      }
    }
  }

  void _showSuspendDialog(String userId) {
    final reasonController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Suspendre l\'utilisateur'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Veuillez indiquer la raison de la suspension :'),
            const SizedBox(height: 12),
            TextField(
              controller: reasonController,
              maxLines: 3,
              decoration: const InputDecoration(
                hintText: 'Raison de la suspension...',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'L\'utilisateur ne pourra plus se connecter à son compte.',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () {
              final reason = reasonController.text.trim();
              if (reason.isNotEmpty) {
                Navigator.pop(context);
                _suspendUser(userId, reason);
              }
            },
            style: TextButton.styleFrom(foregroundColor: Colors.orange),
            child: const Text('Suspendre'),
          ),
        ],
      ),
    );
  }

  /// Suspend un utilisateur avec une raison donnée
  /// Affiche des retours visuels à l'utilisateur pendant et après l'opération
  Future<void> _suspendUser(String userId, String reason) async {
    if (!mounted) return;
    try {
      // Afficher un indicateur de chargement
      final scaffold = ScaffoldMessenger.of(context);
      scaffold.showSnackBar(
        const SnackBar(
          content: Text('Traitement en cours...'),
          duration: Duration(seconds: 2),
        ),
      );

      // Simuler un appel API
      await Future.delayed(const Duration(seconds: 1));

      // Mettre à jour l'interface
      scaffold.hideCurrentSnackBar();
      scaffold.showSnackBar(
        const SnackBar(
          content: Text('Utilisateur suspendu avec succès'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
        ),
      );

      // TODO: Mettre à jour la liste des utilisateurs
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  /// Lève la suspension d'un utilisateur
  /// Demande une confirmation avant de procéder
  Future<void> _unsuspendUser(String userId) async {
    if (!mounted) return;
    try {
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Lever la suspension'),
          content: const Text(
            'Voulez-vous vraiment lever la suspension de cet utilisateur ?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Annuler'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              style: TextButton.styleFrom(foregroundColor: Colors.green),
              child: const Text('Lever la suspension'),
            ),
          ],
        ),
      );

      if (confirmed == true) {
        // Afficher un indicateur de chargement
        final scaffold = ScaffoldMessenger.of(context);
        scaffold.showSnackBar(
          const SnackBar(
            content: Text('Traitement en cours...'),
            duration: Duration(seconds: 2),
          ),
        );

        // Simuler un appel API
        await Future.delayed(const Duration(seconds: 1));

        // Mettre à jour l'interface
        scaffold.hideCurrentSnackBar();
        scaffold.showSnackBar(
          const SnackBar(
            content: Text('Suspension levée avec succès'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );

        // TODO: Mettre à jour la liste des utilisateurs
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  /// Affiche l'interface d'édition d'un utilisateur
  /// TODO: Implémenter la logique complète d'édition
  Future<void> _editUser(String userId) async {
    if (!mounted) return;
    // TODO: Implémenter l'édition de l'utilisateur
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Fonctionnalité d\'édition à implémenter'),
        backgroundColor: Colors.blue,
      ),
    );
  }

  /// Supprime définitivement un utilisateur après confirmation
  /// Affiche des retours visuels pendant et après l'opération
  Future<void> _deleteUser(String userId) async {
    if (!mounted) return;
    try {
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Supprimer l\'utilisateur'),
          content: const Text(
            'Êtes-vous sûr de vouloir supprimer définitivement cet utilisateur ? '
            'Cette action est irréversible.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Annuler'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Supprimer'),
            ),
          ],
        ),
      );

      if (confirmed == true) {
        // Afficher un indicateur de chargement
        final scaffold = ScaffoldMessenger.of(context);
        scaffold.showSnackBar(
          const SnackBar(
            content: Text('Suppression en cours...'),
            duration: Duration(seconds: 2),
          ),
        );

        // Simuler un appel API
        await Future.delayed(const Duration(seconds: 1));

        // Mettre à jour l'interface
        scaffold.hideCurrentSnackBar();
        scaffold.showSnackBar(
          const SnackBar(
            content: Text('Utilisateur supprimé avec succès'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );

        // TODO: Mettre à jour la liste des utilisateurs
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }
}

extension on String? {
  toLowerCase() {}

  int compareTo(String? b) {
    return 0;
  }
}

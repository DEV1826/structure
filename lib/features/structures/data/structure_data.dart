import 'package:structure_mobile/features/structures/models/structure_model.dart';
import 'package:structure_mobile/features/structures/models/service_model.dart';

class StructureData {
  // Identifiants des administrateurs (doivent correspondre à ceux dans auth_provider.dart)
  static const String superAdminId = 'superadmin@example.com';
  static const String adminAnticId = 'admin@antic.cm';
  static const String adminMinaderId = 'admin@minader.cm';
  static const String adminMinepiaId = 'admin@minepia.cm';
  static const String adminObcId = 'admin@obc.cm';
  static const String adminDouaneId = 'admin@douane.cm';

  // Liste des structures avec leurs services et administrateurs
  static final List<Structure> structures = [
    // 1. ANTIC
    Structure(
      id: 'struct_antic_001',
      name: 'ANTIC',
      description: 'Agence Nationale des Technologies de l\'Information et de la Communication',
      address: 'Bastos, Yaoundé, Cameroun',
      imageUrl: 'assets/images/antic_logo.png',
      category: 'Administration',
      phoneNumber: '+237 222 22 22 22',
      email: 'contact@antic.cm',
      website: 'https://www.antic.cm',
      adminId: adminAnticId,
      services: [
        Service(
          id: 'serv_antic_001',
          name: 'Certificat électronique',
          description: 'Certificat électronique pour signature numérique',
          price: 50000.0,
          priceUnit: 'FCFA',
          duration: const Duration(days: 5),
        ),
        Service(
          id: 'serv_antic_002',
          name: 'Hébergement .cm',
          description: 'Hébergement de site web avec extension .cm',
          price: 150000.0,
          priceUnit: 'FCFA/an',
          duration: const Duration(days: 2),
        ),
      ],
    ),

    // 2. MINADER
    Structure(
      id: 'struct_minader_001',
      name: 'MINADER',
      description: 'Ministère de l\'Agriculture et du Développement Rural',
      address: 'Bastos, Yaoundé, Cameroun',
      imageUrl: 'assets/images/minader_logo.png',
      category: 'Ministère',
      phoneNumber: '+237 222 23 23 23',
      email: 'contact@minader.cm',
      website: 'https://www.minader.cm',
      adminId: adminMinaderId,
      services: [
        Service(
          id: 'serv_minader_001',
          name: 'Certificat phytosanitaire',
          description: 'Certificat pour l\'exportation des produits agricoles',
          price: 35000.0,
          priceUnit: 'FCFA',
          duration: const Duration(days: 3),
        ),
      ],
    ),

    // 3. MINEPIA
    Structure(
      id: 'struct_minepia_001',
      name: 'MINEPIA',
      description: 'Ministère de l\'Élevage, des Pêches et des Industries Animales',
      address: 'Nlongkak, Yaoundé, Cameroun',
      imageUrl: 'assets/images/minepia_logo.png',
      category: 'Ministère',
      phoneNumber: '+237 222 23 45 67',
      email: 'contact@minepia.cm',
      website: 'https://www.minepia.gov.cm',
      adminId: adminMinepiaId,
      services: [
        Service(
          id: 'serv_minepia_001',
          name: 'Certificat sanitaire',
          description: 'Certificat pour l\'exportation des produits animaux',
          price: 40000.0,
          priceUnit: 'FCFA',
          duration: const Duration(days: 2),
        ),
      ],
    ),

    // 4. OBC
    Structure(
      id: 'struct_obc_001',
      name: 'OBC',
      description: 'Office de Biocarburants du Cameroun',
      address: 'Bonanjo, Douala, Cameroun',
      imageUrl: 'assets/images/obc_logo.png',
      category: 'Énergie',
      phoneNumber: '+237 233 44 55 66',
      email: 'contact@obc.cm',
      website: 'https://www.obc-cm.org',
      adminId: adminObcId,
      services: [
        Service(
          id: 'serv_obc_001',
          name: 'Licence biocarburant',
          description: 'Licence pour la production et la commercialisation de biocarburants',
          price: 250000.0,
          priceUnit: 'FCFA/an',
          duration: const Duration(days: 7),
        ),
      ],
    ),

    // 5. DOUANE
    Structure(
      id: 'struct_douane_001',
      name: 'DOUANE',
      description: 'Direction Générale des Douanes',
      address: 'Bonanjo, Douala, Cameroun',
      imageUrl: 'assets/images/douane_logo.png',
      category: 'Administration',
      phoneNumber: '+237 233 50 50 50',
      email: 'contact@douane.cm',
      website: 'https://www.douane.cm',
      adminId: adminDouaneId,
      services: [
        Service(
          id: 'serv_douane_001',
          name: 'Dédouanement',
          description: 'Procédure de dédouanement des marchandises',
          price: 10000.0,
          priceUnit: 'FCFA',
          duration: const Duration(days: 1),
        ),
        Service(
          id: 'serv_douane_002',
          name: 'Carte d\'importateur',
          description: 'Carte d\'importateur valable 2 ans',
          price: 100000.0,
          priceUnit: 'FCFA',
          duration: const Duration(days: 14),
        ),
      ],
    ),
  ];

  // Récupérer une structure par son ID
  static Structure? getStructureById(String id) {
    try {
      return structures.firstWhere((structure) => structure.id == id);
    } catch (e) {
      return null;
    }
  }

  // Récupérer tous les services d'une structure
  static List<Service> getServicesForStructure(String structureId) {
    final structure = getStructureById(structureId);
    return structure?.services ?? [];
  }

  // Récupérer l'ID de l'administrateur d'une structure
  static String? getAdminIdForStructure(String structureId) {
    switch (structureId) {
      case 'struct_antic_001':
        return adminAnticId;
      case 'struct_minader_001':
        return adminMinaderId;
      case 'struct_minepia_001':
        return adminMinepiaId;
      case 'struct_obc_001':
        return adminObcId;
      case 'struct_douane_001':
        return adminDouaneId;
      default:
        return null;
    }
  }
}

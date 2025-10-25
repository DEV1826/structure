import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:structure_mobile/core/constants/app_images.dart';
import 'package:structure_mobile/core/routes/app_router.dart';

// Couleurs personnalisées pour l'écran de bienvenue
class AppColors {
  static const Color primaryBlue = Color(0xFF1E88E5);
  static const Color lightBlue = Color(0xFF90CAF9);
  static const Color white = Colors.white;
  static const Color lightGrey = Color(0xFFF5F5F5);
  static const Color darkGrey = Color(0xFF424242);
}

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  final PageController _pageController = PageController(initialPage: 0);
  int _currentPage = 0;
  Timer? _timer;

  final List<Map<String, String>> _welcomePages = [
    {
      'title': 'Bienvenue sur Mon Projet Cameroun',
      'description': 'Découvrez et réservez des services dans les meilleures structures du Cameroun, facilement et rapidement.',
      'image': AppImages.welcome1,
    },
    {
      'title': 'Explorez une multitude de structures',
      'description': 'Hôpitaux, universités, agences de voyage, centres sportifs... Trouvez ce dont vous avez besoin.',
      'image': AppImages.welcome2,
    },
    {
      'title': 'Réservez et payez en toute simplicité',
      'description': 'Sélectionnez vos services, remplissez vos informations et payez en toute sécurité via MTN/Orange Money ou CAM-POST.',
      'image': AppImages.welcome3,
    },
    {
      'title': 'Obtenez votre reçu instantanément',
      'description': 'Après chaque transaction réussie, téléchargez un reçu détaillé directement sur votre téléphone.',
      'image': AppImages.welcome4,
    },
  ];

  @override
  void initState() {
    super.initState();
    _startAutoScroll();
    _pageController.addListener(() {
      if (_pageController.hasClients && _pageController.page != null) {
        int next = _pageController.page!.round();
        if (_currentPage != next) {
          setState(() {
            _currentPage = next;
          });
        }
      }
    });
  }

  void _startAutoScroll() {
    _timer = Timer.periodic(const Duration(seconds: 5), (Timer timer) {
      if (_pageController.hasClients) {
        if (_currentPage < _welcomePages.length - 1) {
          _currentPage++;
        } else {
          _currentPage = 0;
        }
        _pageController.animateToPage(
          _currentPage,
          duration: const Duration(milliseconds: 700),
          curve: Curves.easeIn,
        );
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    if (_pageController.hasClients) {
      _pageController.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Bouton pour passer l'introduction
            Align(
              alignment: Alignment.topRight,
              child: TextButton(
                onPressed: () {
                  context.go(AppRouter.home);
                },
                child: const Text('Passer'),
              ),
            ),
            
            // Carrousel des pages d'introduction
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: _welcomePages.length,
                itemBuilder: (context, index) {
                  final page = _welcomePages[index];
                  return WelcomeCard(
                    title: page['title']!,
                    description: page['description']!,
                    imagePath: page['image']!,
                  );
                },
              ),
            ),
            // Indicateurs de pagination (dots)
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(_welcomePages.length, (index) {
                return GestureDetector(
                  onTap: () {
                    _pageController.animateToPage(
                      index,
                      duration: const Duration(milliseconds: 500),
                      curve: Curves.easeInOut,
                    );
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    margin: const EdgeInsets.symmetric(horizontal: 4.0),
                    height: 8.0,
                    width: _currentPage == index ? 24.0 : 8.0,
                    decoration: BoxDecoration(
                      color: _currentPage == index ? AppColors.primaryBlue : AppColors.lightBlue,
                      borderRadius: BorderRadius.circular(4.0),
                    ),
                  ),
                );
              }),
            ),
            const SizedBox(height: 24),
            // Bouton principal de démarrage
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 16.0),
              child: ElevatedButton(
                onPressed: () {
                  context.go(AppRouter.home);
                },
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 56),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                  elevation: 2,
                  backgroundColor: AppColors.primaryBlue,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: Text(
                  _currentPage == _welcomePages.length - 1 
                      ? 'Commencer' 
                      : 'Suivant',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: AppColors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                ),
              ),
            ),
            
            // Bouton secondaire pour passer directement à l'application
            TextButton(
              onPressed: () {
                context.go(AppRouter.home);
              },
              child: Text(
                'Passer l\'introduction',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.darkGrey,
                    ),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}

class WelcomeCard extends StatelessWidget {
  final String title;
  final String description;
  final String imagePath;

  const WelcomeCard({
    super.key,
    required this.title,
    required this.description,
    required this.imagePath,
  });
  
  // Vérifie si le chemin de l'image est valide
  bool get _isValidImage {
    if (imagePath.isEmpty) return false;
    final p = imagePath.toLowerCase();
    return p.endsWith('.png') || p.endsWith('.jpg') || p.endsWith('.jpeg') || p.endsWith('.jfif');
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final imageSize = size.width * 0.7;
    
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Conteneur de l'image avec hauteur fixe
            SizedBox(
              height: imageSize * 0.8,
              width: imageSize,
              child: _isValidImage 
                  ? Image.asset(
                      imagePath,
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) => _buildDefaultImage(context, size: imageSize),
                    )
                  : _buildDefaultImage(context, size: imageSize),
            ),
            
            const SizedBox(height: 40),
            // Titre de la page
            Text(
              title,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryBlue,
                    fontSize: 24,
                  ),
            ),
            
            const SizedBox(height: 16),
            
            // Description de la page
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                description,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: AppColors.darkGrey,
                      height: 1.6,
                      fontSize: 16,
                    ),
              ),
            ),
            
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
  
  // Construit une image par défaut avec une icône
  Widget _buildDefaultImage(BuildContext context, {required double size}) {
    return Container(
      width: size,
      height: size * 0.8,
      decoration: BoxDecoration(
        color: AppColors.lightGrey.withOpacity(0.5),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.photo_library,
            size: size * 0.3,
            color: AppColors.primaryBlue.withOpacity(0.7),
          ),
          const SizedBox(height: 16),
          Text(
            'Image d\'illustration',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.darkGrey.withOpacity(0.7),
                ),
          ),
        ],
      ),
    );
  }
}

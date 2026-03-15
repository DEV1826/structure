import 'package:flutter/material.dart';
import 'package:structure_mobile/features/user/theme/app_theme.dart';

/// Un indicateur de chargement personnalisé avec une animation fluide
class LoadingIndicator extends StatelessWidget {
  final double size;
  final Color? color;
  final double strokeWidth;
  final bool withBackground;
  final String? message;

  const LoadingIndicator({
    Key? key,
    this.size = 24.0,
    this.color,
    this.strokeWidth = 2.0,
    this.withBackground = false,
    this.message,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final indicator = Center(
      child: SizedBox(
        width: size,
        height: size,
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(
            color ?? AppTheme.primaryColor,
          ),
          strokeWidth: strokeWidth,
        ),
      ),
    );

    if (message != null) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (withBackground)
            _buildWithBackground(context, indicator)
          else
            indicator,
          const SizedBox(height: 16),
          Text(
            message!,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppTheme.textSecondary,
                ),
            textAlign: TextAlign.center,
          ),
        ],
      );
    }

    return withBackground ? _buildWithBackground(context, indicator) : indicator;
  }

  Widget _buildWithBackground(BuildContext context, Widget child) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }

  /// Affiche un indicateur de chargement en plein écran avec un fond semi-transparent
  static Widget fullScreen({
    String? message,
    bool barrierDismissible = false,
  }) {
    return Stack(
      children: [
        // Fond semi-transparent
        ModalBarrier(
          dismissible: barrierDismissible,
          color: Colors.black54,
        ),
        // Contenu centré
        Center(
          child: LoadingIndicator(
            size: 48.0,
            strokeWidth: 3.0,
            withBackground: true,
            message: message,
          ),
        ),
      ],
    );
  }

  /// Affiche un indicateur de chargement en bas d'une liste
  static Widget listBottom() {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 16.0),
      child: Center(
        child: SizedBox(
          width: 24.0,
          height: 24.0,
          child: CircularProgressIndicator(strokeWidth: 2.0),
        ),
      ),
    );
  }

  /// Affiche un indicateur de chargement dans un bouton
  static Widget button() {
    return const SizedBox(
      width: 20.0,
      height: 20.0,
      child: CircularProgressIndicator(
        color: Colors.white,
        strokeWidth: 2.0,
      ),
    );
  }

  /// Affiche un indicateur de chargement dans une carte
  static Widget card() {
    return Container(
      padding: const EdgeInsets.all(24.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: const Center(
        child: SizedBox(
          width: 32.0,
          height: 32.0,
          child: CircularProgressIndicator(strokeWidth: 2.5),
        ),
      ),
    );
  }
}

/// Un widget qui affiche un indicateur de chargement avec un message
class LoadingWithMessage extends StatelessWidget {
  final String message;
  final bool showLoading;
  final Widget? child;

  const LoadingWithMessage({
    Key? key,
    required this.message,
    this.showLoading = true,
    this.child,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (showLoading) ...[
          const LoadingIndicator(),
          const SizedBox(height: 16.0),
        ],
        Text(
          message,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppTheme.textSecondary,
              ),
          textAlign: TextAlign.center,
        ),
        if (child != null) ...[
          const SizedBox(height: 16.0),
          child!,
        ],
      ],
    );
  }
}

/// Un widget qui affiche un indicateur de chargement avec un message d'erreur et un bouton de réessai
class ErrorWithRetry extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  final String? retryText;

  const ErrorWithRetry({
    Key? key,
    required this.message,
    required this.onRetry,
    this.retryText,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 48.0,
              color: AppTheme.errorColor,
            ),
            const SizedBox(height: 16.0),
            Text(
              message,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppTheme.textSecondary,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16.0),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh, size: 18.0),
              label: Text(retryText ?? 'Réessayer'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.errorColor,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

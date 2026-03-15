import 'package:flutter/material.dart';
import 'package:structure_mobile/core/constants/app_constants.dart';

class LoadingWidget extends StatelessWidget {
  final String? message;
  final bool withScaffold;
  final Color? backgroundColor;
  final Color? color;
  final double size;

  const LoadingWidget({
    Key? key,
    this.message,
    this.withScaffold = false,
    this.backgroundColor,
    this.color,
    this.size = 40.0,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    final content = Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: size,
            height: size,
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(
                color ?? theme.colorScheme.primary,
              ),
              strokeWidth: 3.0,
            ),
          ),
          if (message != null) ...[
            const SizedBox(height: AppConstants.mediumPadding),
            Text(
              message!,
              style: theme.textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );

    if (withScaffold) {
      return Scaffold(
        backgroundColor: backgroundColor,
        body: content,
      );
    }
    
    return content;
  }
}

class ButtonLoadingWidget extends StatelessWidget {
  final double size;
  final Color? color;
  final double strokeWidth;

  const ButtonLoadingWidget({
    Key? key,
    this.size = 24.0,
    this.color,
    this.strokeWidth = 2.0,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CircularProgressIndicator(
        valueColor: AlwaysStoppedAnimation<Color>(
          color ?? Theme.of(context).colorScheme.onPrimary,
        ),
        strokeWidth: strokeWidth,
      ),
    );
  }
}

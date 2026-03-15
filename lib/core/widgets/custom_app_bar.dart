import 'package:flutter/material.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final bool showBackButton;
  final List<Widget>? actions;
  final Color? backgroundColor;
  final Color? textColor;
  final double? elevation;

  const CustomAppBar({
    Key? key,
    required this.title,
    this.showBackButton = true,
    this.actions,
    this.backgroundColor,
    this.textColor,
    this.elevation,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(
        title,
        style: TextStyle(
          color:
              textColor ?? Theme.of(context).appBarTheme.titleTextStyle?.color,
        ),
      ),
      backgroundColor:
          backgroundColor ?? Theme.of(context).appBarTheme.backgroundColor,
      elevation: elevation ?? 0,
      automaticallyImplyLeading: showBackButton,
      leading: showBackButton && Navigator.canPop(context)
          ? IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => Navigator.of(context).pop(),
            )
          : null,
      actions: [
        ...?actions,
        if (showBackButton && !Navigator.canPop(context))
          const SizedBox(width: 48), // Pour maintenir l'alignement
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

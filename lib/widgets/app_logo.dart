import 'package:flutter/material.dart';
import '../core/constants.dart';
import '../core/theme_colors.dart';

class AppLogo extends StatelessWidget {
  final double size;
  final bool showText;

  const AppLogo({
    Key? key,
    this.size = 80,
    this.showText = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Logo - remplacer par Image.asset('assets/images/logo.png') quand le logo sera ajouté
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: ThemeColors.surfaceColor(context),
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.asset(
              'assets/images/Xtensus2.png',
              width: size,
              height: size,
              fit: BoxFit.contain,
            ),
          ),
        ),
        if (showText) ...[
          const SizedBox(height: 16),
          Text(
            AppConstants.appName,
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: ThemeColors.textColor(context),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            AppConstants.appSubtitle,
            style: TextStyle(
              fontSize: 14,
              color: ThemeColors.secondaryTextColor(context),
            ),
          ),
        ],
      ],
    );
  }
}
import 'package:flutter/material.dart';
import 'constants.dart';

/// Helper class pour obtenir les couleurs adaptées au thème actuel
class ThemeColors {
  
  /// Couleur de fond principale
  static Color backgroundColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? AppConstants.darkBackgroundColor
        : AppConstants.backgroundColor;
  }
  
  /// Couleur de surface (cartes, conteneurs)
  static Color surfaceColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? AppConstants.darkCardColor
        : AppConstants.whiteColor;
  }
  
  /// Couleur de texte principal
  static Color textColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? AppConstants.darkTextColor
        : AppConstants.darkGreyColor;
  }
  
  /// Couleur de texte secondaire
  static Color secondaryTextColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? AppConstants.darkSecondaryTextColor
        : AppConstants.greyColor;
  }
  
  /// Couleur de bordure
  static Color borderColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? AppConstants.darkBorderColor
        : AppConstants.textFieldBorderColor;
  }
  
  /// Couleur de fond des champs de saisie
  static Color inputFillColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? AppConstants.darkInputFillColor
        : AppConstants.whiteColor;
  }
  
  /// Couleur de surface avec opacité
  static Color surfaceWithOpacity(BuildContext context, double opacity) {
    return surfaceColor(context).withValues(alpha: opacity);
  }
  
  /// Couleur pour les dividers
  static Color dividerColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? AppConstants.darkBorderColor
        : AppConstants.lightGreyColor;
  }
  
  /// Couleur pour les icônes
  static Color iconColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? AppConstants.darkSecondaryTextColor
        : AppConstants.greyColor;
  }
  
  /// Couleur pour l'AppBar
  static Color appBarColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? AppConstants.darkSurfaceColor
        : AppConstants.whiteColor;
  }
  
  /// Couleur pour les cartes (alias de surfaceColor)
  static Color cardColor(BuildContext context) {
    return surfaceColor(context);
  }
  
  /// Couleur pour les ombres
  static Color shadowColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? Colors.black.withValues(alpha: 0.3)
        : Colors.grey.withValues(alpha: 0.2);
  }
}
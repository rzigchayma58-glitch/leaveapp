// 🎨 SYSTÈME DE DESIGN SAAS PROFESSIONNEL
import 'package:flutter/material.dart';
import 'animations.dart';

class SaaSDesign {
  // 🎨 PALETTE DE COULEURS ORANGE PROFESSIONNEL (LOGO SOCIÉTÉ)
  static const Color primaryOrange = Color(0xFFFF6B35);
  static const Color lightOrange = Color(0xFFFF8B5A);
  static const Color darkOrange = Color(0xFFE55A2B);
  static const Color success = Color(0xFF10B981);
  static const Color warning = Color(0xFFF59E0B);
  static const Color error = Color(0xFFEF4444);
  static const Color info = Color(0xFF3B82F6);
  
  // Dégradés modernes orange
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primaryOrange, lightOrange],
  );
  
  static const LinearGradient successGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [success, Color(0xFF34D399)],
  );

  // 📐 ESPACEMENTS COHÉRENTS
  static const double spacing4 = 4.0;
  static const double spacing8 = 8.0;
  static const double spacing12 = 12.0;
  static const double spacing16 = 16.0;
  static const double spacing20 = 20.0;
  static const double spacing24 = 24.0;
  static const double spacing32 = 32.0;
  static const double spacing48 = 48.0;

  // 🎯 RAYONS DE BORDURE MODERNES
  static const double radiusSmall = 8.0;
  static const double radiusMedium = 12.0;
  static const double radiusLarge = 16.0;
  static const double radiusXLarge = 20.0;

  static const Color fieldFill = Color(0xFF0A0A0A);
  static const Color fieldText = Colors.white;
  static const Color fieldHint = Color(0xFFC8C8C8);

  static const TextStyle fieldTextStyle = TextStyle(
    color: fieldText,
    fontSize: 17,
    fontWeight: FontWeight.w500,
    height: 1.35,
  );

  static InputDecoration fieldDecoration({
    required String hintText,
    IconData? prefixIcon,
    Widget? suffixIcon,
  }) {
    OutlineInputBorder border(Color color, {double width = 1}) {
      return OutlineInputBorder(
        borderRadius: BorderRadius.circular(radiusMedium),
        borderSide: BorderSide(color: color, width: width),
      );
    }

    return InputDecoration(
      hintText: hintText,
      hintStyle: const TextStyle(
        color: fieldHint,
        fontSize: 16,
        fontWeight: FontWeight.w400,
      ),
      prefixIcon: prefixIcon != null
          ? Icon(prefixIcon, color: primaryOrange, size: 22)
          : null,
      suffixIcon: suffixIcon,
      filled: true,
      fillColor: fieldFill,
      isDense: false,
      contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 20),
      border: border(const Color(0xFF3A3A3A)),
      enabledBorder: border(const Color(0xFF3A3A3A)),
      focusedBorder: border(primaryOrange, width: 2),
      errorBorder: border(error, width: 2),
      focusedErrorBorder: border(error, width: 2),
    );
  }

  // 🌟 OMBRES ÉLÉGANTES
  static List<BoxShadow> get elevationLow => [
    BoxShadow(
      color: Colors.black.withOpacity(0.05),
      blurRadius: 8,
      offset: const Offset(0, 2),
    ),
  ];

  static List<BoxShadow> get elevationMedium => [
    BoxShadow(
      color: Colors.black.withOpacity(0.1),
      blurRadius: 16,
      offset: const Offset(0, 4),
    ),
  ];

  static List<BoxShadow> get elevationHigh => [
    BoxShadow(
      color: Colors.black.withOpacity(0.15),
      blurRadius: 24,
      offset: const Offset(0, 8),
    ),
  ];
}

// 📱 CARTE MODERNE STYLE SAAS
class SaaSCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets? padding;
  final Color? backgroundColor;
  final List<BoxShadow>? boxShadow;
  final double? borderRadius;
  final VoidCallback? onTap;
  final bool animateOnTap;

  const SaaSCard({
    Key? key,
    required this.child,
    this.padding,
    this.backgroundColor,
    this.boxShadow,
    this.borderRadius,
    this.onTap,
    this.animateOnTap = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Widget card = Container(
      padding: padding ?? const EdgeInsets.all(SaaSDesign.spacing20),
      decoration: BoxDecoration(
        color: backgroundColor ?? Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(borderRadius ?? SaaSDesign.radiusMedium),
        boxShadow: boxShadow ?? SaaSDesign.elevationLow,
        border: Border.all(
          color: Theme.of(context).dividerColor.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: child,
    );

    if (onTap != null) {
      return GestureDetector(
        onTap: onTap,
        child: animateOnTap 
          ? ScaleAnimation(
              duration: AppAnimations.fast,
              begin: 1.0,
              end: 0.98,
              curve: AppAnimations.smooth,
              child: card,
            )
          : card,
      );
    }

    return card;
  }
}

// 🔥 HEADER MODERNE AVEC DÉGRADÉ
class SaaSHeader extends StatelessWidget {
  final String title;
  final String? subtitle;
  final List<Widget>? actions;
  final bool showBackButton;
  final VoidCallback? onBack;

  const SaaSHeader({
    Key? key,
    required this.title,
    this.subtitle,
    this.actions,
    this.showBackButton = false,
    this.onBack,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: SaaSDesign.primaryGradient,
      ),
      child: SafeArea(
        left: false,
        right: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            SaaSDesign.spacing20,
            SaaSDesign.spacing16,
            SaaSDesign.spacing20,
            SaaSDesign.spacing24,
          ),
          child: SlideAndFadeAnimation(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (showBackButton || actions != null)
                  Row(
                    children: [
                      if (showBackButton)
                        IconButton(
                          onPressed: onBack ?? () => Navigator.of(context).pop(),
                          icon: const Icon(Icons.arrow_back, color: Colors.white),
                        ),
                      const Spacer(),
                      if (actions != null) ...actions!,
                    ],
                  ),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: SaaSDesign.spacing8),
                  Text(
                    subtitle!,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white.withOpacity(0.9),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// 📊 CARTE STATISTIQUE MODERNE
class SaaSStatsCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;
  final String? trend;
  final int animationIndex;

  const SaaSStatsCard({
    Key? key,
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
    this.trend,
    this.animationIndex = 0,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SlideAndFadeAnimation(
      index: animationIndex,
      child: SaaSCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.all(SaaSDesign.spacing8),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(SaaSDesign.radiusSmall),
                  ),
                  child: Icon(icon, color: color, size: 20),
                ),
                if (trend != null)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: SaaSDesign.spacing4,
                      vertical: SaaSDesign.spacing4,
                    ),
                    decoration: BoxDecoration(
                      color: SaaSDesign.success.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(SaaSDesign.radiusSmall),
                    ),
                    child: Text(
                      trend!,
                      style: const TextStyle(
                        color: SaaSDesign.success,
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: SaaSDesign.spacing12),
            Text(
              value,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: SaaSDesign.spacing4),
            Text(
              title,
              style: TextStyle(
                fontSize: 12,
                color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.7),
              ),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
          ],
        ),
      ),
    );
  }
}

// 🎪 LISTE MODERNE AVEC ANIMATIONS
class SaaSListItem extends StatelessWidget {
  final Widget leading;
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;
  final Color? backgroundColor;
  final int animationIndex;

  const SaaSListItem({
    Key? key,
    required this.leading,
    required this.title,
    this.subtitle,
    this.trailing,
    this.onTap,
    this.backgroundColor,
    this.animationIndex = 0,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SlideAndFadeAnimation(
      index: animationIndex,
      child: Container(
        margin: const EdgeInsets.only(bottom: SaaSDesign.spacing8),
        child: SaaSCard(
          backgroundColor: backgroundColor,
          onTap: onTap,
          child: Row(
            children: [
              leading,
              const SizedBox(width: SaaSDesign.spacing16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (subtitle != null) ...[
                      const SizedBox(height: SaaSDesign.spacing4),
                      Text(
                        subtitle!,
                        style: TextStyle(
                          fontSize: 14,
                          color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.7),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              if (trailing != null) ...[
                const SizedBox(width: SaaSDesign.spacing16),
                trailing!,
              ],
            ],
          ),
        ),
      ),
    );
  }
}

// 🏷️ BADGE MODERNE
class SaaSBadge extends StatelessWidget {
  final String text;
  final Color backgroundColor;
  final Color textColor;
  final IconData? icon;

  const SaaSBadge({
    Key? key,
    required this.text,
    required this.backgroundColor,
    required this.textColor,
    this.icon,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: SaaSDesign.spacing12,
        vertical: SaaSDesign.spacing4,
      ),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(SaaSDesign.radiusSmall),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 14, color: textColor),
            const SizedBox(width: SaaSDesign.spacing4),
          ],
          Text(
            text,
            style: TextStyle(
              color: textColor,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

// 🎭 MODAL MODERNE SAAS
class SaaSModal extends StatelessWidget {
  final String title;
  final Widget content;
  final List<Widget>? actions;

  const SaaSModal({
    Key? key,
    required this.title,
    required this.content,
    this.actions,
  }) : super(key: key);

  static void show(BuildContext context, SaaSModal modal) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => ScaleAnimation(
        duration: AppAnimations.medium,
        child: modal,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(SaaSDesign.spacing16),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: BorderRadius.circular(SaaSDesign.radiusLarge),
        boxShadow: SaaSDesign.elevationHigh,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(SaaSDesign.spacing20),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: Theme.of(context).dividerColor.withOpacity(0.1),
                ),
              ),
            ),
            child: Row(
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
          ),
          // Content
          Padding(
            padding: const EdgeInsets.all(SaaSDesign.spacing20),
            child: content,
          ),
          // Actions
          if (actions != null)
            Padding(
              padding: const EdgeInsets.all(SaaSDesign.spacing20),
              child: Row(
                children: actions!,
              ),
            ),
        ],
      ),
    );
  }
}
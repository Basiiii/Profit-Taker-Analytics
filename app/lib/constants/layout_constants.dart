class LayoutConstants {
  // Screen sizes
  static const double startingWidth = 1700;
  static const double startingHeight = 750;
  static const double minimumWidth = 995;
  static const double minimumHeight = 400;

  // Navigation widget sizes
  static const double navigationBarWidth = 80;

  // Home page padding sizes
  static const double leftPaddingHome = 60;
  static const double totalSpacingBetweenCards = 60;
  static const double totalLeftPaddingHome =
      navigationBarWidth + leftPaddingHome + totalSpacingBetweenCards;

  // Responsive breakpoints
  static const double minimumResponsiveWidth =
      startingWidth - totalLeftPaddingHome - 200;
  static const double minimumResponsiveHeight = startingHeight;

  // Home cards default sizes
  static const double overviewCardWidth = 245;
  static const double phaseCardWidth = 760;

  // Analytics cards default sizes
  static const double graphCardWidth = 760;
}

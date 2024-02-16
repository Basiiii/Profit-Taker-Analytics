/// App details
const String version = 'BETA 0.7.0';

/// Starting screen sizes
const double startingWidth = 1700; // Initial width of the app at launch
const double startingHeight = 750; // Initial height of the app at launch
const double minimumWidth = 970; // Minimum width required for the app
const double minimumHeight = 400; // Minimum height required for the app

/// Responsive breakpoints for width and height
const double minimumResponsiveWidth =
    startingWidth - totalLeftPaddingHome - 200;
const double minimumResponsiveHeight = startingHeight;

/// Navigation widget sizes
const double navigationBarWidth = 80; // Width of the navigation bar

/// Home page padding sizes
const double leftPaddingHome = 60; // Left padding for the home page
const double totalSpacingBetweenCards = 60; // Total spacing between cards
const double totalLeftPaddingHome = navigationBarWidth +
    leftPaddingHome +
    totalSpacingBetweenCards; // Total left padding for the home page

/// Home cards default sizes
const double overviewCardWidth = 245; // Width of the overview card
const double phaseCardWidth = 760; // Width of the phase card

/// Analytics cards default sizes
const double graphCardWidth = 760; // Width of the graph card

/// Connection constants
const noNewDataAvailable = 0;
const newDataAvailable = 1;
const connectionError = 2;

/// Error codes setting port number
const successSettingPort = 0;
const errorSettingPort = 1;

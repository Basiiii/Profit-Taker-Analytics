/// App details
const String version = 'ALPHA 0.2.1';

/// Starting screen sizes
const double startingWidth = 1500; // Initial width of the app at launch
const double startingHeight = 750; // Initial height of the app at launch
const double minimumWidth = 870; // Minimum width required for the app
const double minimumHeight = 400; // Minimum height required for the app

/// Responsive breakpoints for width and height
const double minimumResponsiveWidth = startingWidth - totalLeftPaddingHome;
const double minimumResponsiveHeight = startingHeight;

/// Navigation widget sizes
const double navigationBarWidth = 80; // Width of the navigation bar

/// Home page padding sizes
const double leftPaddingHome = 60; // Left padding for the home page
const double leftPaddingCards = 10; // Left padding for cards
const double totalSpacingBetweenCards = 60; // Total spacing between cards
const double totalLeftPaddingHome = navigationBarWidth +
    leftPaddingHome +
    leftPaddingCards +
    totalSpacingBetweenCards; // Total left padding for the home page

/// Home cards default sizes
const double overviewCardWidth = 200; // Width of the overview card
const double phaseCardWidth = 625; // Width of the phase card

/// Connection constants
const noNewDataAvailable = 0;
const newDataAvailable = 1;
const connectionError = 2;

/// Error codes setting port number
const successSettingPort = 0;
const errorSettingPort = 1;

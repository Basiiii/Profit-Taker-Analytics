import 'package:flutter/material.dart';

// Define a map of index to a map of time thresholds to colors
Map<int, Map<double, Color>> indexToThresholdColorsMap = {
  0: {
    55.000: const Color(0xFFb33dc6),
    60.000: const Color(0xFF27aeef),
    70.000: const Color(0xFFbdcf32),
    90.000: const Color(0xFFef9b20),
  },
  1: {
    3.500: const Color(0xFFb33dc6),
    4.000: const Color(0xFF27aeef),
    6.000: const Color(0xFFbdcf32),
    8.000: const Color(0xFFef9b20),
  },
  2: {
    7.000: const Color(0xFFb33dc6),
    8.000: const Color(0xFF27aeef),
    10.000: const Color(0xFFbdcf32),
    15.000: const Color(0xFFef9b20),
  },
  3: {
    8.000: const Color(0xFFb33dc6),
    10.000: const Color(0xFF27aeef),
    15.000: const Color(0xFFbdcf32),
    20.000: const Color(0xFFef9b20),
  },
  4: {
    1.300: const Color(0xFFb33dc6),
    1.500: const Color(0xFF27aeef),
    1.800: const Color(0xFFbdcf32),
    2.200: const Color(0xFFef9b20),
  },
  5: {
    16.000: const Color(0xFFb33dc6),
    18.000: const Color(0xFF27aeef),
    23.000: const Color(0xFFbdcf32),
    28.000: const Color(0xFFef9b20),
  },
};

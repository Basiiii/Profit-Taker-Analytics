/// Rounds the given [value] to three decimal places.
///
/// This function multiplies the input [value] by 1000, rounds the result to the nearest integer,
/// and then divides the rounded value by 1000 to obtain the rounded result with three decimal places.
///
/// Example:
/// ```dart
/// double originalValue = 3.14159265359;
/// double roundedValue = roundToThreeDecimalPlaces(originalValue);
/// print(roundedValue); // Output: 3.142
/// ```
double roundToThreeDecimalPlaces(double value) {
  return ((value * 1000).round() / 1000);
}

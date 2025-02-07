/// Replaces all newline characters (`\n`) in the input string with spaces.
///
/// This function is useful for sanitizing text that contains newline characters,
/// ensuring the resulting string is displayed in a single line.
///
/// Example:
/// ```dart
/// String input = "Hello\nWorld";
/// String result = replaceNewLines(input);
/// print(result); // Outputs: "Hello World"
/// ```
///
/// - [input]: The input string containing potential newline characters.
///
/// Returns:
/// A new string where all `\n` characters have been replaced by spaces.
String replaceNewLines(String input) {
  return input.replaceAll('\n', ' '); // Replace all '\n' with spaces
}

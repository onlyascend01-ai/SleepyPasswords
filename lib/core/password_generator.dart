import 'dart:math';

class PasswordGenerator {
  String generate({
    required int length,
    bool useDigits = true,
    bool useSymbols = true,
    bool excludeSimilar = false,
  }) {
    if (length < 4) length = 4; // Min length safety

    // Base Character Sets
    String lowerCase = 'abcdefghijklmnopqrstuvwxyz';
    String upperCase = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
    String digits = '0123456789';
    String symbols = '!@#\$%^&*()-_=+[]{}|;:,.<>?';

    // Remove ambiguous characters if requested
    if (excludeSimilar) {
      lowerCase = lowerCase.replaceAll(RegExp(r'[l]'), '');
      upperCase = upperCase.replaceAll(RegExp(r'[IO]'), '');
      digits = digits.replaceAll(RegExp(r'[01]'), '');
      symbols = symbols.replaceAll(RegExp(r'[|]'), '');
    }

    String allChars = lowerCase + upperCase;
    if (useDigits) allChars += digits;
    if (useSymbols) allChars += symbols;

    // Ensure at least one of each required type is included
    final List<String> passwordChars = [];
    final Random random = Random.secure();

    // Helper
    String getRandomChar(String set) => set.isNotEmpty 
        ? set[random.nextInt(set.length)] 
        : (allChars.isNotEmpty ? allChars[random.nextInt(allChars.length)] : 'x');

    // Add required characters (unless sets are empty due to exclusion)
    if (lowerCase.isNotEmpty) passwordChars.add(getRandomChar(lowerCase));
    if (upperCase.isNotEmpty) passwordChars.add(getRandomChar(upperCase));
    if (useDigits && digits.isNotEmpty) passwordChars.add(getRandomChar(digits));
    if (useSymbols && symbols.isNotEmpty) passwordChars.add(getRandomChar(symbols));

    // Fill the rest
    while (passwordChars.length < length) {
      passwordChars.add(getRandomChar(allChars));
    }

    // Shuffle
    passwordChars.shuffle(random);

    return passwordChars.join('');
  }
}

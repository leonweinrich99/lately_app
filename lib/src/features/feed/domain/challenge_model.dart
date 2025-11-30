class Challenge {
  final String id;
  final String title; // z.B. "Daily 10"
  final String subtitle; // z.B. "Die 10 Fragen des Tages"
  final String logo; // z.B. "D10" (Text-Logo)
  final List<String> questions; // Die Liste der Fragen

  // Design-Eigenschaften (Optional, könnten auch separat gemappt werden)
  // Wir speichern sie hier als Hex-Strings oder einfache Werte, um UI-Code sauber zu halten
  final int bgColorHex;
  final int textColorHex;

  const Challenge({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.logo,
    required this.questions,
    required this.bgColorHex,
    required this.textColorHex,
  });
}
class UserGroup {
  final String id;
  final String name;
  final int colorHex; // Für individuelle Farben der Chips

  const UserGroup({
    required this.id,
    required this.name,
    this.colorHex = 0xFF68C9C3, // Standard Türkis
  });
}
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/user_group_model.dart';

abstract class GroupRepository {
  Future<List<UserGroup>> getUserGroups(String userId);
}

class MockGroupRepository implements GroupRepository {
  @override
  Future<List<UserGroup>> getUserGroups(String userId) async {
    // Simuliere Datenbank-Zugriff
    await Future.delayed(const Duration(milliseconds: 200));

    return [
      const UserGroup(id: 'besties', name: 'Engste Freunde', colorHex: 0xFF68C9C3),
      const UserGroup(id: 'family', name: 'Familie', colorHex: 0xFFE6C6BB),
      const UserGroup(id: 'all', name: 'Alle Bekannten', colorHex: 0xFFD8F1EF),
      // Stell dir vor, der User hat diese selbst erstellt:
      const UserGroup(id: 'work', name: 'Arbeitskollegen', colorHex: 0xFF912D2D),
    ];
  }
}

// --- PROVIDERS ---

final groupRepositoryProvider = Provider<GroupRepository>((ref) {
  return MockGroupRepository();
});

// Dieser Provider liefert die Gruppen für den aktuellen User
final userGroupsProvider = FutureProvider<List<UserGroup>>((ref) async {
  final repository = ref.watch(groupRepositoryProvider);
  return repository.getUserGroups('current_user_id');
});
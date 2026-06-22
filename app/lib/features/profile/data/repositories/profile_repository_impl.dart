import '../../domain/entities/personal_data.dart';
import '../../domain/entities/profile.dart';
import '../../domain/repositories/profile_repository.dart';
import '../datasources/profile_supabase_datasource.dart';

/// Implementación del contrato de perfil: lee y escribe directo en Supabase.
class ProfileRepositoryImpl implements ProfileRepository {
  const ProfileRepositoryImpl(this._datasource);

  final ProfileSupabaseDataSource _datasource;

  @override
  Future<Profile> fetchProfile() => _datasource.fetchProfile();

  @override
  Future<void> updateCalorieGoal(int goal) =>
      _datasource.updateCalorieGoal(goal);

  @override
  Future<void> updatePersonalData(PersonalData data) =>
      _datasource.updatePersonalData(data);
}

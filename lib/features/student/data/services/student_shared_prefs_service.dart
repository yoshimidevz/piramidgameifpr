import 'dart:convert';
import '../../../../core/result/result.dart';
import '../../../../core/storage/local_storage_helper.dart';
import '../models/student_model.dart';
import 'student_local_service.dart';

class StudentSharedPrefsService implements StudentLocalService {
  static const _storageKey = 'students';

  final LocalStorageHelper _storage;

  StudentSharedPrefsService(this._storage);

  @override
  Future<Result<List<StudentModel>>> getAll() async {
    final result = await _storage.getString(_storageKey);

    return result.when(
      onSuccess: (jsonString) {
        if (jsonString == null) {
          return const Result.success([]);
        }

        try {
          final jsonList = jsonDecode(jsonString) as List<dynamic>;
          final students = jsonList
              .map((item) =>
                  StudentModel.fromJson(item as Map<String, dynamic>))
              .toList();
          return Result.success(students);
        } catch (e) {
          return Result.failure(
            Failure('Não foi possível interpretar os alunos salvos',
                exception: e),
          );
        }
      },
      onFailure: (failure) => Result.failure(failure),
    );
  }

  @override
  Future<Result<void>> saveAll(List<StudentModel> students) async {
    final jsonList = students.map((student) => student.toJson()).toList();
    final jsonString = jsonEncode(jsonList);

    return _storage.setString(_storageKey, jsonString);
  }
}
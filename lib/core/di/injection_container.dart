import 'package:shared_preferences/shared_preferences.dart';
import '../storage/local_storage_helper.dart';
import '../../features/student/data/services/student_local_service.dart';
import '../../features/student/data/services/student_shared_prefs_service.dart';
import '../../features/student/data/repositories/student_repository_impl.dart';
import '../../features/student/domain/repositories/student_repository.dart';
import '../../features/student/domain/usecases/create_student_usecase.dart';
import '../../features/student/domain/usecases/update_student_usecase.dart';
import '../../features/student/domain/usecases/delete_student_usecase.dart';
import '../../features/student/domain/usecases/get_all_students_usecase.dart';
import '../../features/student/domain/usecases/get_student_by_id_usecase.dart';
import '../../features/student/domain/usecases/calculate_ranking_usecase.dart';
import '../../features/student/facade/student_usecases_facade.dart';
import '../../features/student/presentation/viewmodels/student_form_viewmodel.dart';
import '../../features/theme_settings/data/services/theme_local_service.dart';
import '../../features/theme_settings/data/services/theme_shared_prefs_service.dart';
import '../../features/theme_settings/data/repositories/theme_repository_impl.dart';
import '../../features/theme_settings/domain/repositories/theme_repository.dart';
import '../../features/theme_settings/domain/usecases/get_theme_mode_usecase.dart';
import '../../features/theme_settings/domain/usecases/toggle_theme_usecase.dart';
import '../../features/theme_settings/facade/theme_usecases_facade.dart';
import '../../features/student/presentation/viewmodels/ranking_viewmodel.dart';

class InjectionContainer {
  InjectionContainer._();

  static final InjectionContainer instance = InjectionContainer._();

  late final LocalStorageHelper _storageHelper;

  late final StudentLocalService _studentLocalService;
  late final StudentRepository _studentRepository;
  late final StudentUseCasesFacade studentFacade;

  late final ThemeLocalService _themeLocalService;
  late final ThemeRepository _themeRepository;
  late final ThemeUseCasesFacade themeFacade;

  bool _initialized = false;

  Future<void> init() async {
    if (_initialized) return;

    await SharedPreferences.getInstance();

    _storageHelper = LocalStorageHelper();

    _studentLocalService = StudentSharedPrefsService(_storageHelper);
    _studentRepository = StudentRepositoryImpl(_studentLocalService);
    studentFacade = StudentUseCasesFacade(
      createStudent: CreateStudentUseCase(_studentRepository),
      updateStudent: UpdateStudentUseCase(_studentRepository),
      deleteStudent: DeleteStudentUseCase(_studentRepository),
      getAllStudents: GetAllStudentsUseCase(_studentRepository),
      getStudentById: GetStudentByIdUseCase(_studentRepository),
      calculateRanking: CalculateRankingUseCase(_studentRepository),
    );

    _themeLocalService = ThemeSharedPrefsService(_storageHelper);
    _themeRepository = ThemeRepositoryImpl(_themeLocalService);
    themeFacade = ThemeUseCasesFacade(
      getThemeMode: GetThemeModeUseCase(_themeRepository),
      toggleTheme: ToggleThemeUseCase(_themeRepository),
    );

    studentFormViewModel = StudentFormViewModel(studentFacade);
    rankingViewModel = RankingViewModel(studentFacade);

    _initialized = true;
  }

  late final StudentFormViewModel studentFormViewModel;
  late final RankingViewModel rankingViewModel;
}
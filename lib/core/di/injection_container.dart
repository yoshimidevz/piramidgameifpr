  import 'package:shared_preferences/shared_preferences.dart';
  import '../storage/local_storage_helper.dart';
  import '../../features/student/data/services/firestore_student_service.dart';
  import '../../features/student/data/repositories/student_repository_firestore_impl.dart';
  import '../../features/student/domain/repositories/student_repository.dart';
  import '../../features/student/domain/usecases/create_student_usecase.dart';
  import '../../features/student/domain/usecases/update_student_usecase.dart';
  import '../../features/student/domain/usecases/delete_student_usecase.dart';
  import '../../features/student/domain/usecases/get_all_students_usecase.dart';
  import '../../features/student/domain/usecases/get_student_by_id_usecase.dart';
  import '../../features/student/domain/usecases/calculate_ranking_usecase.dart';
  import '../../features/student/facade/student_usecases_facade.dart';
  import '../../features/student/presentation/viewmodels/student_form_viewmodel.dart';
  import '../../features/student/presentation/viewmodels/ranking_viewmodel.dart';
  import '../../features/student/presentation/viewmodels/student_detail_viewmodel.dart';
  import '../../features/theme_settings/data/services/theme_local_service.dart';
  import '../../features/theme_settings/data/services/theme_shared_prefs_service.dart';
  import '../../features/theme_settings/data/repositories/theme_repository_impl.dart';
  import '../../features/theme_settings/domain/repositories/theme_repository.dart';
  import '../../features/theme_settings/domain/usecases/get_theme_mode_usecase.dart';
  import '../../features/theme_settings/domain/usecases/toggle_theme_usecase.dart';
  import '../../features/theme_settings/facade/theme_usecases_facade.dart';
  import '../../features/theme_settings/presentation/viewmodels/theme_viewmodel.dart';
  import '../../features/auth/data/services/auth_service.dart';
  import '../../features/auth/data/repositories/auth_repository_impl.dart';
  import '../../features/auth/facade/auth_facade.dart';
  import '../../features/auth/presentation/viewmodels/auth_viewmodel.dart';
  import '../../features/auth/data/services/firestore_usuario_service.dart';
  import '../../features/avaliacao/data/services/firestore_avaliacao_service.dart';
  import '../../features/avaliacao/data/repositories/avaliacao_repository_impl.dart';
  import '../../features/avaliacao/domain/usecases/salvar_avaliacao_usecase.dart';
  import '../../features/avaliacao/domain/usecases/buscar_avaliacao_usecase.dart';
  import '../../features/avaliacao/domain/usecases/calcular_ranking_pessoal_usecase.dart';
  import '../../features/avaliacao/domain/usecases/calcular_ranking_global_usecase.dart';
  import '../../features/avaliacao/facade/avaliacao_facade.dart';
  import '../../features/avaliacao/presentation/viewmodels/avaliacao_viewmodel.dart';
  import '../../features/avaliacao/presentation/viewmodels/ranking_pessoal_viewmodel.dart';

  class InjectionContainer {
    InjectionContainer._();

    static final InjectionContainer instance = InjectionContainer._();

    late final LocalStorageHelper _storageHelper;

    late final StudentRepository _studentRepository;
    late final StudentUseCasesFacade studentFacade;

    late final ThemeLocalService _themeLocalService;
    late final ThemeRepository _themeRepository;
    late final ThemeUseCasesFacade themeFacade;

    late final StudentFormViewModel studentFormViewModel;
    late final RankingViewModel rankingViewModel;
    late final StudentDetailViewModel studentDetailViewModel;
    late final ThemeViewModel themeViewModel;
    late final AuthViewModel authViewModel;

    late final AvaliacaoFacade avaliacaoFacade;
    late final AvaliacaoViewModel avaliacaoViewModel;
    late final RankingPessoalViewModel rankingPessoalViewModel;
    late final FirestoreUsuarioService firestoreUsuarioService;

    bool _initialized = false;

    Future<void> init() async {
      if (_initialized) return;

      await SharedPreferences.getInstance();

      _storageHelper = LocalStorageHelper();
      firestoreUsuarioService = FirestoreUsuarioService();

      // Student — Firestore
      final firestoreStudentService = FirestoreStudentService();
      _studentRepository = StudentRepositoryFirestoreImpl(firestoreStudentService);
      studentFacade = StudentUseCasesFacade(
        createStudent: CreateStudentUseCase(_studentRepository),
        updateStudent: UpdateStudentUseCase(_studentRepository),
        deleteStudent: DeleteStudentUseCase(_studentRepository),
        getAllStudents: GetAllStudentsUseCase(_studentRepository),
        getStudentById: GetStudentByIdUseCase(_studentRepository),
        calculateRanking: CalculateRankingUseCase(_studentRepository),
      );

      final firestoreAvaliacaoService = FirestoreAvaliacaoService();
      final avaliacaoRepository =
          AvaliacaoRepositoryImpl(firestoreAvaliacaoService);
      avaliacaoFacade = AvaliacaoFacade(
        salvar: SalvarAvaliacaoUseCase(avaliacaoRepository),
        buscar: BuscarAvaliacaoUseCase(avaliacaoRepository),
        rankingPessoal: CalcularRankingPessoalUseCase(
            avaliacaoRepository, _studentRepository),
        rankingGlobal: CalcularRankingGlobalUseCase(
            avaliacaoRepository, _studentRepository),
      );
      avaliacaoViewModel = AvaliacaoViewModel(avaliacaoFacade);
      rankingPessoalViewModel = RankingPessoalViewModel(avaliacaoFacade);

      // Theme — SharedPreferences (permanece local)
      _themeLocalService = ThemeSharedPrefsService(_storageHelper);
      _themeRepository = ThemeRepositoryImpl(_themeLocalService);
      themeFacade = ThemeUseCasesFacade(
        getThemeMode: GetThemeModeUseCase(_themeRepository),
        toggleTheme: ToggleThemeUseCase(_themeRepository),
      );

      // Auth — Firebase Authentication
      final authService = AuthService();
      final authRepository = AuthRepositoryImpl(authService);
      final authFacade = AuthFacade(authRepository);
      authViewModel = AuthViewModel(authFacade);

      // ViewModels
      studentFormViewModel = StudentFormViewModel(studentFacade);
      rankingViewModel = RankingViewModel(avaliacaoFacade);
      studentDetailViewModel = StudentDetailViewModel(studentFacade, avaliacaoFacade);      
      themeViewModel = ThemeViewModel(themeFacade);

      _initialized = true;
    }
  }
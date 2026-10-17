import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../../core/di/injection_container.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_text_styles.dart';
import '../../../student/domain/entities/popularity_criteria.dart';
import '../../../student/domain/entities/student.dart';
import '../../domain/entities/usuario.dart';
import '../../data/services/firestore_usuario_service.dart';


class CompletarPerfilScreen extends StatefulWidget {
  const CompletarPerfilScreen({super.key});

  @override
  State<CompletarPerfilScreen> createState() => _CompletarPerfilScreenState();
}

class _CompletarPerfilScreenState extends State<CompletarPerfilScreen> {
  final _nomeController = TextEditingController();
  final _apelidoController = TextEditingController();
  Course _curso = Course.tads;
  int _turma = 2024;
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    // Pre-preenche o nome com o nome do Google/Auth se disponivel
    final user = InjectionContainer.instance.authViewModel.currentUser.value;
    if (user != null && user.name.isNotEmpty) {
      _nomeController.text = user.name;
    }
  }

  @override
  void dispose() {
    _nomeController.dispose();
    _apelidoController.dispose();
    super.dispose();
  }

  Future<void> _salvar() async {
    final nome = _nomeController.text.trim();
    final apelido = _apelidoController.text.trim();

    if (nome.isEmpty) {
      setState(() => _errorMessage = 'Informe seu nome completo');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final uid = InjectionContainer.instance.authViewModel.currentUser.value?.uid;
    final email = InjectionContainer.instance.authViewModel.currentUser.value?.email;
    final fotoUrl = InjectionContainer.instance.authViewModel.currentUser.value?.photoUrl;
    late final FirestoreUsuarioService firestoreUsuarioService;

    if (uid == null) return;

    // Cria a pessoa no ranking
    final pessoaId = '${uid}_pessoa';
    final student = Student(
      id: pessoaId,
      name: nome,
      nickname: apelido,
      course: _curso,
      classYear: _turma,
      birthDate: DateTime(2000), // data generica, pode ser editada depois
      criteriaScores: {
        for (final c in CriteriaType.values) c: 1.0
      },
      criadoPor: uid,
    );

    final studentResult = await InjectionContainer.instance.studentFacade.createStudent(student);

    if (studentResult.isFailure) {
      studentResult.when(
        onSuccess: (_) {},
        onFailure: (failure) => print('DEBUG: erro = ${failure.message}'),
      );
      setState(() {
        _isLoading = false;
        _errorMessage = 'Erro ao criar perfil no ranking';
      });
      return;
    }

    if (!mounted) return;

    if (studentResult.isFailure) {
      print('DEBUG: erro = ${studentResult}');  
      setState(() {
        _isLoading = false;
        _errorMessage = 'Erro ao criar perfil no ranking';
      });
      return;
    }

    // Salva o usuario no Firestore com vinculo a pessoa
    final usuario = Usuario(
      uid: uid,
      nome: nome,
      email: email ?? '',
      fotoUrl: fotoUrl,
      curso: _curso.name,
      turma: _turma,
      pessoaId: pessoaId,
    );

    firestoreUsuarioService = FirestoreUsuarioService();    
    await firestoreUsuarioService.salvar(usuario);

    if (!mounted) return;

    await InjectionContainer.instance.rankingViewModel.refresh();
    context.go('/inicio');
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 24),
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppColors.green, AppColors.greenDeep],
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Icon(Icons.person_rounded, color: Colors.white, size: 34),
              ),
              const SizedBox(height: 20),
              Text(
                'Complete seu perfil',
                style: AppTextStyles.sora(fontSize: 26, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 6),
              Text(
                'Seus dados serão seu perfil no ranking do campus.',
                style: AppTextStyles.jakarta(
                  fontSize: 13.5, fontWeight: FontWeight.w500,
                  color: theme.colorScheme.onSurface.withOpacity(.6),
                ),
              ),
              const SizedBox(height: 28),

              // Nome
              Text('Nome completo', style: AppTextStyles.jakarta(fontSize: 13, fontWeight: FontWeight.w700)),
              const SizedBox(height: 6),
              TextField(
                controller: _nomeController,
                style: AppTextStyles.jakarta(fontSize: 15, fontWeight: FontWeight.w600),
                decoration: InputDecoration(
                  hintText: 'Seu nome completo',
                  filled: true,
                  fillColor: theme.colorScheme.surface,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                ),
              ),
              const SizedBox(height: 16),

              // Apelido
              Text('Apelido (opcional)', style: AppTextStyles.jakarta(fontSize: 13, fontWeight: FontWeight.w700)),
              const SizedBox(height: 6),
              TextField(
                controller: _apelidoController,
                style: AppTextStyles.jakarta(fontSize: 15, fontWeight: FontWeight.w600),
                decoration: InputDecoration(
                  hintText: 'Como te chamam',
                  filled: true,
                  fillColor: theme.colorScheme.surface,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                ),
              ),
              const SizedBox(height: 16),

              // Curso
              Text('Curso', style: AppTextStyles.jakarta(fontSize: 13, fontWeight: FontWeight.w700)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: Course.values.map((c) {
                  final selected = _curso == c;
                  return GestureDetector(
                    onTap: () => setState(() => _curso = c),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: selected ? AppColors.green : theme.colorScheme.surface,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: selected ? AppColors.green : theme.dividerColor,
                        ),
                      ),
                      child: Text(
                        c.label,
                        style: AppTextStyles.jakarta(
                          fontSize: 13, fontWeight: FontWeight.w700,
                          color: selected ? Colors.white : theme.colorScheme.onSurface,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),

              // Turma/Ano
              Text('Turma (ano de entrada)', style: AppTextStyles.jakarta(fontSize: 13, fontWeight: FontWeight.w700)),
              const SizedBox(height: 8),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: List.generate(
                    2026 - 1998 + 1,
                    (i) {
                      final ano = 1998 + i;
                      final selected = _turma == ano;
                      return GestureDetector(
                        onTap: () => setState(() => _turma = ano),
                        child: Container(
                          margin: const EdgeInsets.only(right: 8),
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                          decoration: BoxDecoration(
                            color: selected ? AppColors.green : theme.colorScheme.surface,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: selected ? AppColors.green : theme.dividerColor,
                            ),
                          ),
                          child: Text(
                            '$ano',
                            style: AppTextStyles.jakarta(
                              fontSize: 13, fontWeight: FontWeight.w700,
                              color: selected ? Colors.white : theme.colorScheme.onSurface,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
              const SizedBox(height: 16),

              if (_errorMessage != null)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.red.withOpacity(.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    _errorMessage!,
                    style: AppTextStyles.jakarta(
                      fontSize: 13, fontWeight: FontWeight.w600,
                      color: AppColors.red,
                    ),
                  ),
                ),

              const SizedBox(height: 24),

              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _salvar,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.green,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          width: 22, height: 22,
                          child: CircularProgressIndicator(strokeWidth: 2.4, color: Colors.white),
                        )
                      : Text(
                          'Entrar no Ranking',
                          style: AppTextStyles.jakarta(fontSize: 15.5, fontWeight: FontWeight.w700),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
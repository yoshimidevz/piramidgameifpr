import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../../core/di/injection_container.dart';
import '../../../../../core/extensions/string_extensions.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_text_styles.dart';
import '../../../student/domain/entities/popularity_criteria.dart';
import '../../../student/domain/entities/student.dart';
import '../../domain/entities/usuario.dart';

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

  // Estado do vinculo com perfil existente
  Student? _perfilExistente;
  bool _mostrandoConfirmacaoVinculo = false;

  @override
  void initState() {
    super.initState();
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
      _mostrandoConfirmacaoVinculo = false;
      _perfilExistente = null;
    });

    final uid = InjectionContainer.instance.authViewModel.currentUser.value?.uid;
    final email = InjectionContainer.instance.authViewModel.currentUser.value?.email;
    final fotoUrl = InjectionContainer.instance.authViewModel.currentUser.value?.photoUrl;

    if (uid == null) return;

    // Gera o @ automaticamente
    final arroba = gerarArroba(nome, _curso.label, _turma);

    // Verifica se ja existe um perfil com esse @
    final existenteResult = await InjectionContainer.instance.studentFacade.buscarPorArroba(arroba);

    if (!mounted) return;

    final existente = existenteResult.when(
      onSuccess: (s) => s,
      onFailure: (_) => null,
    );

    if (existente != null) {
      // Perfil ja existe — pergunta se é a mesma pessoa
      setState(() {
        _isLoading = false;
        _perfilExistente = existente;
        _mostrandoConfirmacaoVinculo = true;
      });
      return;
    }

    await _criarPerfil(uid, email, fotoUrl, nome, apelido, arroba);
  }

  Future<void> _vincularPerfilExistente() async {
    final uid = InjectionContainer.instance.authViewModel.currentUser.value?.uid;
    final email = InjectionContainer.instance.authViewModel.currentUser.value?.email;
    final fotoUrl = InjectionContainer.instance.authViewModel.currentUser.value?.photoUrl;

    if (uid == null || _perfilExistente == null) return;

    setState(() {
      _isLoading = true;
      _mostrandoConfirmacaoVinculo = false;
    });

    // Vincula o uid ao perfil existente
    final usuario = Usuario(
      uid: uid,
      nome: _perfilExistente!.name,
      email: email ?? '',
      fotoUrl: fotoUrl,
      curso: _perfilExistente!.course.name,
      turma: _perfilExistente!.classYear,
      pessoaId: _perfilExistente!.id,
    );

    await InjectionContainer.instance.firestoreUsuarioService.salvar(usuario);

    if (!mounted) return;

    await InjectionContainer.instance.rankingViewModel.refresh();
    context.go('/inicio');
  }

  Future<void> _criarPerfil(
    String uid, String? email, String? fotoUrl,
    String nome, String apelido, String arroba,
  ) async {
    final pessoaId = '${uid}_pessoa';
    final student = Student(
      id: pessoaId,
      name: nome,
      nickname: apelido,
      course: _curso,
      classYear: _turma,
      birthDate: DateTime(2000),
      criteriaScores: {for (final c in CriteriaType.values) c: 1.0},
      criadoPor: uid,
      arroba: arroba,
    );

    final studentResult =
        await InjectionContainer.instance.studentFacade.createStudent(student);

    if (!mounted) return;

    if (studentResult.isFailure) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Erro ao criar perfil no ranking';
      });
      return;
    }

    final usuario = Usuario(
      uid: uid,
      nome: nome,
      email: email ?? '',
      fotoUrl: fotoUrl,
      curso: _curso.name,
      turma: _turma,
      pessoaId: pessoaId,
    );

    await InjectionContainer.instance.firestoreUsuarioService.salvar(usuario);

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

              // Card de confirmacao de vinculo (aparece se @ ja existe)
              if (_mostrandoConfirmacaoVinculo && _perfilExistente != null) ...[
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.gold.withOpacity(.1),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppColors.gold.withOpacity(.4)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.person_search_rounded, color: AppColors.gold),
                          const SizedBox(width: 8),
                          Text(
                            'Perfil encontrado!',
                            style: AppTextStyles.jakarta(
                              fontSize: 14, fontWeight: FontWeight.w800,
                              color: AppColors.gold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Já existe um perfil com o nome "${_perfilExistente!.name}" '
                        '(${_perfilExistente!.course.label} ${_perfilExistente!.classYear}) '
                        'no ranking. Esse perfil é você?',
                        style: AppTextStyles.jakarta(
                          fontSize: 13.5, fontWeight: FontWeight.w500,
                          color: theme.colorScheme.onSurface.withOpacity(.8),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () => setState(() {
                                _mostrandoConfirmacaoVinculo = false;
                                _perfilExistente = null;
                                _errorMessage = 'Não é possível criar um perfil com os mesmos dados. Verifique suas informações.';
                              }),
                              style: OutlinedButton.styleFrom(
                                side: BorderSide(color: theme.dividerColor),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              ),
                              child: const Text('Não sou eu'),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: _vincularPerfilExistente,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.green,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              ),
                              child: const Text('Sou eu!'),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
              ],

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
                        border: Border.all(color: selected ? AppColors.green : theme.dividerColor),
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

              Text('Turma (ano de entrada)', style: AppTextStyles.jakarta(fontSize: 13, fontWeight: FontWeight.w700)),
              const SizedBox(height: 8),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: List.generate(2026 - 1998 + 1, (i) {
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
                          border: Border.all(color: selected ? AppColors.green : theme.dividerColor),
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
                  }),
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
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
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
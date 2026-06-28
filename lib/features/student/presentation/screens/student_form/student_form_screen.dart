import 'package:flutter/material.dart';
import 'package:signals/signals_flutter.dart';
import '../../../../../core/di/injection_container.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_text_styles.dart';
import '../../../domain/entities/popularity_criteria.dart';
import '../../../domain/entities/student.dart';
import '../../viewmodels/student_form_viewmodel.dart';
import '../../../domain/entities/student_tier.dart';
import 'package:go_router/go_router.dart';

class StudentFormScreen extends StatefulWidget {
  final String? studentId;

  const StudentFormScreen({super.key, required this.studentId});

  @override
  State<StudentFormScreen> createState() => _StudentFormScreenState();
}

class _StudentFormScreenState extends State<StudentFormScreen> {
  static const int minClassYear = 2008;
  static const int maxClassYear = 2026;

  StudentFormViewModel get _viewModel =>
      InjectionContainer.instance.studentFormViewModel;

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _pickBirthDate(BuildContext context) async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _viewModel.birthDate.value ?? DateTime(2008, 1, 1),
      firstDate: DateTime(1990),
      lastDate: now,
      helpText: 'Data de nascimento',
    );

    if (picked != null) {
      _viewModel.birthDate.value = picked;
    }
  }

  Future<void> _handleSave(BuildContext context) async {
    await _viewModel.save();

    if (!context.mounted) return;

    final state = _viewModel.saveCommand.state.value;

    if (state.isSuccess) {
      context.go('/ranking');
    } else if (state.isError) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${state.error}'),
          backgroundColor: AppColors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.studentId != null;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(22, 14, 22, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isEditing ? 'Editar Aluno' : 'Novo Aluno',
                      style: AppTextStyles.sora(
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Monte o perfil e avalie a aura',
                      style: AppTextStyles.jakarta(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: Theme.of(context)
                            .colorScheme
                            .onSurface
                            .withOpacity(.6),
                      ),
                    ),

                    const _SectionLabel(text: 'PERFIL', highlighted: true),
                    const SizedBox(height: 10),

                    _FormTextField(
                      signal: _viewModel.name,
                      placeholder: 'Nome completo',
                    ),
                    const SizedBox(height: 11),
                    _FormTextField(
                      signal: _viewModel.nickname,
                      placeholder: 'Apelido',
                    ),

                    const _SectionLabel(text: 'Curso'),
                    const SizedBox(height: 10),
                    _CourseSelector(signal: _viewModel.course),

                    const _SectionLabel(text: 'Ano da turma'),
                    const SizedBox(height: 10),
                    _YearSelector(
                      signal: _viewModel.classYear,
                      minYear: minClassYear,
                      maxYear: maxClassYear,
                    ),

                    const _SectionLabel(text: 'Data de nascimento'),
                    const SizedBox(height: 10),
                    _BirthDateField(
                      signal: _viewModel.birthDate,
                      onTap: () => _pickBirthDate(context),
                    ),

                    const _SectionLabel(text: 'CRITÉRIOS DE POPULARIDADE', highlighted: true),
                    const SizedBox(height: 6),
                    Watch((context) => Text(
                          '${_viewModel.evaluatedCount.value}/15 avaliados',
                          style: AppTextStyles.jakarta(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w600,
                            color: Theme.of(context)
                                .colorScheme
                                .onSurface
                                .withOpacity(.55),
                          ),
                        )),
                    const SizedBox(height: 8),

                    ...CriteriaType.values.map((criteria) {
                      return _StarRatingRow(
                        criteria: criteria,
                        signal: _viewModel.criteriaScores[criteria]!,
                        onChanged: (value) =>
                            _viewModel.setCriteriaScore(criteria, value),
                      );
                    }),

                    const SizedBox(height: 12),
                  ],
                ),
              ),
            ),

            // Painel fixo no rodape com total e botao de salvar.
            _BottomSavePanel(
              viewModel: _viewModel,
              onSave: () => _handleSave(context),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String text;
  final bool highlighted;

  const _SectionLabel({required this.text, this.highlighted = false});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 22, bottom: 0),
      child: Text(
        text,
        style: AppTextStyles.jakarta(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.2,
          color: highlighted
              ? Theme.of(context).colorScheme.primary
              : Theme.of(context).colorScheme.onSurface,
        ),
      ),
    );
  }
}

class _FormTextField extends StatelessWidget {
  final Signal<String> signal;
  final String placeholder;

  const _FormTextField({required this.signal, required this.placeholder});

  @override
  Widget build(BuildContext context) {
    return Watch((context) {
      return TextFormField(
        initialValue: signal.value,
        onChanged: (value) => signal.value = value,
        decoration: InputDecoration(
          hintText: placeholder,
          filled: true,
          fillColor: Theme.of(context).colorScheme.surface,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide:
                BorderSide(color: Theme.of(context).dividerColor, width: 1.5),
          ),
        ),
        style: AppTextStyles.jakarta(fontSize: 15, fontWeight: FontWeight.w600),
      );
    });
  }
}

class _CourseSelector extends StatelessWidget {
  final Signal<Course> signal;

  const _CourseSelector({required this.signal});

  @override
  Widget build(BuildContext context) {
    return Watch((context) {
      return Wrap(
        spacing: 8,
        runSpacing: 8,
        children: Course.values.map((course) {
          final isSelected = signal.value == course;
          return _Chip(
            label: course.label,
            isSelected: isSelected,
            onTap: () => signal.value = course,
          );
        }).toList(),
      );
    });
  }
}

class _YearSelector extends StatelessWidget {
  final Signal<int> signal;
  final int minYear;
  final int maxYear;

  const _YearSelector({
    required this.signal,
    required this.minYear,
    required this.maxYear,
  });

  @override
  Widget build(BuildContext context) {
    final years = List.generate(maxYear - minYear + 1, (i) => maxYear - i);

    return Watch((context) {
      return SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: years.map((year) {
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: _Chip(
                label: '$year',
                isSelected: signal.value == year,
                onTap: () => signal.value = year,
              ),
            );
          }).toList(),
        ),
      );
    });
  }
}

class _Chip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _Chip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(13),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
          decoration: BoxDecoration(
            color: isSelected ? theme.colorScheme.primary : theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(13),
            border: Border.all(
              color: isSelected ? theme.colorScheme.primary : theme.dividerColor,
              width: 1.4,
            ),
          ),
          child: Text(
            label,
            style: AppTextStyles.jakarta(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: isSelected ? Colors.white : theme.colorScheme.onSurface,
            ),
          ),
        ),
      ),
    );
  }
}

class _BirthDateField extends StatelessWidget {
  final Signal<DateTime?> signal;
  final VoidCallback onTap;

  const _BirthDateField({required this.signal, required this.onTap});

  String _format(DateTime date) {
    const months = [
      'jan', 'fev', 'mar', 'abr', 'mai', 'jun',
      'jul', 'ago', 'set', 'out', 'nov', 'dez',
    ];
    return '${date.day.toString().padLeft(2, '0')} '
        '${months[date.month - 1]} '
        '${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Watch((context) {
      final date = signal.value;

      return GestureDetector(
        onTap: onTap,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(15),
            border: Border.all(color: theme.dividerColor, width: 1.5),
          ),
          child: Row(
            children: [
              Icon(Icons.calendar_today_rounded,
                  size: 18, color: theme.colorScheme.primary),
              const SizedBox(width: 10),
              Text(
                date == null ? 'Selecionar data' : _format(date),
                style: AppTextStyles.jakarta(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: date == null
                      ? theme.colorScheme.onSurface.withOpacity(.5)
                      : theme.colorScheme.onSurface,
                ),
              ),
            ],
          ),
        ),
      );
    });
  }
}

// Uma linha de criterio: nome + 5 estrelas tocaveis + nota numerica.
class _StarRatingRow extends StatelessWidget {
  final CriteriaType criteria;
  final Signal<double> signal;
  final ValueChanged<double> onChanged;

  const _StarRatingRow({
    required this.criteria,
    required this.signal,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Watch((context) {
      final currentValue = signal.value;

      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 9),
        child: Row(
          children: [
            Expanded(
              child: Text(
                criteria.label,
                style: AppTextStyles.jakarta(
                  fontSize: 14.5,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            Row(
              children: List.generate(5, (index) {
                final starValue = index + 1.0;
                final isFilled = starValue <= currentValue;

                return GestureDetector(
                  onTap: () => onChanged(starValue),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 1.5),
                    child: Icon(
                      isFilled ? Icons.star_rounded : Icons.star_outline_rounded,
                      size: 22,
                      color: isFilled
                          ? AppColors.gold
                          : theme.colorScheme.onSurface.withOpacity(.3),
                    ),
                  ),
                );
              }),
            ),
            const SizedBox(width: 8),
            SizedBox(
              width: 16,
              child: Text(
                currentValue == 0 ? '-' : currentValue.toInt().toString(),
                textAlign: TextAlign.right,
                style: AppTextStyles.jakarta(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w700,
                  color: theme.colorScheme.onSurface.withOpacity(.6),
                ),
              ),
            ),
          ],
        ),
      );
    });
  }
}

// Painel fixo no rodape: pontuacao total / botao de salvar.
class _BottomSavePanel extends StatelessWidget {
  final StudentFormViewModel viewModel;
  final VoidCallback onSave;

  const _BottomSavePanel({required this.viewModel, required this.onSave});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Watch((context) {
      final total = viewModel.totalScore.value;
      final isComplete = viewModel.isComplete.value;
      final isSaving = viewModel.saveCommand.state.value.isRunning;
      final tier = StudentTierInfo.fromScore(total);

      return Container(
        padding: const EdgeInsets.fromLTRB(20, 14, 20, 16),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          border: Border(top: BorderSide(color: theme.dividerColor)),
        ),
        child: SafeArea(
          top: false,
          child: Row(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${total.toInt()} / 75',
                    style: AppTextStyles.sora(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: AppColors.green,
                    ),
                  ),
                  Text(
                    'NÍVEL ${tier.label.toUpperCase()}',
                    style: AppTextStyles.jakarta(
                      fontSize: 10.5,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.6,
                      color: AppColors.gold,
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 16),
              Expanded(
                child: SizedBox(
                  height: 50,
                  child: ElevatedButton(
                    onPressed: (isComplete && !isSaving) ? onSave : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.red,
                      disabledBackgroundColor:
                          theme.colorScheme.onSurface.withOpacity(.15),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                    child: isSaving
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.4,
                              color: Colors.white,
                            ),
                          )
                        : Text(
                            isComplete
                                ? 'Salvar Cadastro'
                                : '${viewModel.evaluatedCount.value}/15 avaliados',
                            style: AppTextStyles.jakarta(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    });
  }
}
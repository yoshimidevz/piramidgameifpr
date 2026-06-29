import 'dart:math';
import 'package:flutter/material.dart';
import '../../domain/entities/popularity_criteria.dart';
import '../../../../core/theme/app_colors.dart';

class AuraRadarChart extends StatelessWidget {
  final Map<CriteriaType, double> scores;

  const AuraRadarChart({super.key, required this.scores});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return CustomPaint(
      size: const Size(double.infinity, 260),
      painter: _RadarPainter(
        scores: scores,
        gridColor: theme.dividerColor,
        fillColor: AppColors.green.withOpacity(.25),
        strokeColor: AppColors.green,
        dotColor: AppColors.gold,
      ),
    );
  }
}

class _RadarPainter extends CustomPainter {
  final Map<CriteriaType, double> scores;
  final Color gridColor;
  final Color fillColor;
  final Color strokeColor;
  final Color dotColor;

  _RadarPainter({
    required this.scores,
    required this.gridColor,
    required this.fillColor,
    required this.strokeColor,
    required this.dotColor,
  });

  static const int _sides = 15; // 15 criterios = 15 eixos
  static const double _maxScore = 5.0;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = min(size.width, size.height) / 2 - 24;

    final criteriaList = CriteriaType.values;

    // Angulo entre cada eixo, comecando no topo (-90 graus = -pi/2).
    final angleStep = (2 * pi) / _sides;
    double angleFor(int index) => -pi / 2 + (angleStep * index);

    // Desenha as linhas de grade (teias de aranha) - 3 niveis (1.67, 3.33, 5).
    final gridPaint = Paint()
      ..color = gridColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    for (final fraction in [1 / 3, 2 / 3, 1.0]) {
      final path = Path();
      for (int i = 0; i <= _sides; i++) {
        final angle = angleFor(i % _sides);
        final point = Offset(
          center.dx + radius * fraction * cos(angle),
          center.dy + radius * fraction * sin(angle),
        );
        if (i == 0) {
          path.moveTo(point.dx, point.dy);
        } else {
          path.lineTo(point.dx, point.dy);
        }
      }
      canvas.drawPath(path, gridPaint);
    }

    // Desenha os eixos (linhas do centro até a borda).
    for (int i = 0; i < _sides; i++) {
      final angle = angleFor(i);
      final point = Offset(
        center.dx + radius * cos(angle),
        center.dy + radius * sin(angle),
      );
      canvas.drawLine(center, point, gridPaint);
    }

    // Calcula os pontos do polígono de dados (baseado nas notas).
    final dataPoints = <Offset>[];
    for (int i = 0; i < _sides; i++) {
      final criteria = criteriaList[i];
      final score = scores[criteria] ?? 0.0;
      final normalizedScore = (score / _maxScore).clamp(0.0, 1.0);
      final angle = angleFor(i);

      dataPoints.add(Offset(
        center.dx + radius * normalizedScore * cos(angle),
        center.dy + radius * normalizedScore * sin(angle),
      ));
    }

    // Desenha o poligono preenchido (a "aura" do aluno).
    final fillPath = Path();
    for (int i = 0; i < dataPoints.length; i++) {
      if (i == 0) {
        fillPath.moveTo(dataPoints[i].dx, dataPoints[i].dy);
      } else {
        fillPath.lineTo(dataPoints[i].dx, dataPoints[i].dy);
      }
    }
    fillPath.close();

    canvas.drawPath(fillPath, Paint()..color = fillColor);
    canvas.drawPath(
      fillPath,
      Paint()
        ..color = strokeColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );

    // Desenha um ponto dourado em cada vertice de dado.
    final dotPaint = Paint()..color = dotColor;
    for (final point in dataPoints) {
      canvas.drawCircle(point, 3.5, dotPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _RadarPainter oldDelegate) {
    return oldDelegate.scores != scores;
  }
}
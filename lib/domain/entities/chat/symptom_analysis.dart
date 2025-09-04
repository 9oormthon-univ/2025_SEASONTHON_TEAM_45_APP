import 'package:equatable/equatable.dart';

class SymptomAnalysis extends Equatable {
  final int? analysisId;
  final String extractedSymptoms;
  final String recommendedDepartment;
  final double confidenceScore;
  final String analysisSummary;
  final String? additionalQuestions;

  const SymptomAnalysis({
    this.analysisId,
    required this.extractedSymptoms,
    required this.recommendedDepartment,
    required this.confidenceScore,
    required this.analysisSummary,
    this.additionalQuestions,
  });

  @override
  List<Object?> get props => [
        analysisId,
        extractedSymptoms,
        recommendedDepartment,
        confidenceScore,
        analysisSummary,
        additionalQuestions,
      ];
}
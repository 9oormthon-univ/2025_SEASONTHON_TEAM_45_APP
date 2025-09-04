import '../../../domain/entities/chat/symptom_analysis.dart';

class SymptomAnalysisModel extends SymptomAnalysis {
  const SymptomAnalysisModel({
    int? analysisId,
    required String extractedSymptoms,
    required String recommendedDepartment,
    required double confidenceScore,
    required String analysisSummary,
    String? additionalQuestions,
  }) : super(
          analysisId: analysisId,
          extractedSymptoms: extractedSymptoms,
          recommendedDepartment: recommendedDepartment,
          confidenceScore: confidenceScore,
          analysisSummary: analysisSummary,
          additionalQuestions: additionalQuestions,
        );

  factory SymptomAnalysisModel.fromJson(Map<String, dynamic> json) {
    return SymptomAnalysisModel(
      analysisId: json['analysisId'] as int?,
      extractedSymptoms: json['extractedSymptoms'] as String? ?? '',
      recommendedDepartment: json['recommendedDepartment'] as String? ?? '내과',
      confidenceScore: (json['confidenceScore'] as num? ?? 0.0).toDouble(),
      analysisSummary: json['analysisSummary'] as String? ?? '',
      additionalQuestions: json['additionalQuestions'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'analysisId': analysisId,
      'extractedSymptoms': extractedSymptoms,
      'recommendedDepartment': recommendedDepartment,
      'confidenceScore': confidenceScore,
      'analysisSummary': analysisSummary,
      'additionalQuestions': additionalQuestions,
    };
  }
}
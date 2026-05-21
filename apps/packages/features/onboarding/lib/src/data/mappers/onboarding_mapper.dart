import '../../domain/entities/onboarding_draft.dart';
import '../../domain/entities/onboarding_profile.dart';

mixin OnboardingMapper {
  Map<String, dynamic> draftToJson(OnboardingDraft draft) {
    return {
      'learningTarget': draft.learningTarget.trim(),
      'studyLevel': draft.studyLevel?.wireName,
      'goalType': draft.goalType?.wireName,
      'targetDate': _dateOnly(draft.targetDate),
      'dailyMinutes': draft.dailyMinutes,
      'preferredLearningMethods': draft.preferredLearningMethods
          .map((method) => method.wireName)
          .toList(),
      'notificationsEnabled': draft.notificationsEnabled,
      'quietHoursStart': draft.quietHoursStart,
      'quietHoursEnd': draft.quietHoursEnd,
    }..removeWhere((_, value) => value == null);
  }

  OnboardingProfile profileFromJson(Map<String, dynamic> json) {
    return OnboardingProfile(
      onboardingCompleted: json['onboardingCompleted'] as bool? ?? false,
      onboardingCompletedAt: _dateTime(json['onboardingCompletedAt']),
      learningTarget: json['learningTarget'] as String? ?? '',
      studyLevel: StudyLevelWire.fromWire(json['studyLevel'] as String?),
      goalType: GoalTypeWire.fromWire(json['goalType'] as String?),
      targetDate:
          DateTime.tryParse(json['targetDate'] as String? ?? '') ??
          DateTime.fromMillisecondsSinceEpoch(0),
      dailyMinutes: json['dailyMinutes'] as int? ?? 0,
      preferredLearningMethods:
          (json['preferredLearningMethods'] as List<dynamic>? ?? const [])
              .whereType<String>()
              .map(LearningMethodWire.fromWire)
              .toSet(),
      notificationsEnabled: json['notificationsEnabled'] as bool? ?? false,
      quietHoursStart: json['quietHoursStart'] as String?,
      quietHoursEnd: json['quietHoursEnd'] as String?,
    );
  }

  String? _dateOnly(DateTime? date) {
    if (date == null) {
      return null;
    }
    return '${date.year.toString().padLeft(4, '0')}-'
        '${date.month.toString().padLeft(2, '0')}-'
        '${date.day.toString().padLeft(2, '0')}';
  }

  DateTime? _dateTime(Object? raw) {
    return switch (raw) {
      final String value => DateTime.tryParse(value),
      final int value => DateTime.fromMillisecondsSinceEpoch(value),
      _ => null,
    };
  }
}

extension StudyLevelWire on StudyLevel {
  String get wireName => switch (this) {
    StudyLevel.school => 'school',
    StudyLevel.undergraduate => 'undergraduate',
    StudyLevel.postgraduate => 'postgraduate',
    StudyLevel.competitiveExam => 'competitive_exam',
    StudyLevel.professional => 'professional',
  };

  static StudyLevel fromWire(String? value) => switch (value) {
    'school' => StudyLevel.school,
    'undergraduate' => StudyLevel.undergraduate,
    'postgraduate' => StudyLevel.postgraduate,
    'competitive_exam' => StudyLevel.competitiveExam,
    'professional' => StudyLevel.professional,
    _ => StudyLevel.school,
  };
}

extension GoalTypeWire on GoalType {
  String get wireName => switch (this) {
    GoalType.subject => 'subject',
    GoalType.course => 'course',
    GoalType.competitiveExam => 'competitive_exam',
    GoalType.professionalCert => 'professional_cert',
  };

  static GoalType fromWire(String? value) => switch (value) {
    'subject' => GoalType.subject,
    'course' => GoalType.course,
    'competitive_exam' => GoalType.competitiveExam,
    'professional_cert' => GoalType.professionalCert,
    _ => GoalType.subject,
  };
}

extension LearningMethodWire on LearningMethod {
  String get wireName => switch (this) {
    LearningMethod.reading => 'reading',
    LearningMethod.visual => 'visual',
    LearningMethod.mcq => 'mcq',
    LearningMethod.flashcards => 'flashcards',
    LearningMethod.videos => 'videos',
    LearningMethod.writing => 'writing',
  };

  static LearningMethod fromWire(String value) => switch (value) {
    'reading' => LearningMethod.reading,
    'visual' => LearningMethod.visual,
    'mcq' => LearningMethod.mcq,
    'flashcards' => LearningMethod.flashcards,
    'videos' => LearningMethod.videos,
    'writing' => LearningMethod.writing,
    _ => LearningMethod.reading,
  };
}

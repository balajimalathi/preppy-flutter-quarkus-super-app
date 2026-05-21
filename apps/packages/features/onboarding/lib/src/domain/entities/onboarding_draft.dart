enum StudyLevel {
  school,
  undergraduate,
  postgraduate,
  competitiveExam,
  professional,
}

enum GoalType { subject, course, competitiveExam, professionalCert }

enum LearningMethod { reading, visual, mcq, flashcards, videos, writing }

class OnboardingDraft {
  const OnboardingDraft({
    this.learningTarget = '',
    this.studyLevel,
    this.goalType,
    this.targetDate,
    this.dailyMinutes = 30,
    this.preferredLearningMethods = const {},
    this.notificationsEnabled = false,
    this.quietHoursStart,
    this.quietHoursEnd,
  });

  final String learningTarget;
  final StudyLevel? studyLevel;
  final GoalType? goalType;
  final DateTime? targetDate;
  final int dailyMinutes;
  final Set<LearningMethod> preferredLearningMethods;
  final bool notificationsEnabled;
  final String? quietHoursStart;
  final String? quietHoursEnd;

  OnboardingDraft copyWith({
    String? learningTarget,
    StudyLevel? studyLevel,
    bool clearStudyLevel = false,
    GoalType? goalType,
    bool clearGoalType = false,
    DateTime? targetDate,
    bool clearTargetDate = false,
    int? dailyMinutes,
    Set<LearningMethod>? preferredLearningMethods,
    bool? notificationsEnabled,
    String? quietHoursStart,
    bool clearQuietHoursStart = false,
    String? quietHoursEnd,
    bool clearQuietHoursEnd = false,
  }) {
    return OnboardingDraft(
      learningTarget: learningTarget ?? this.learningTarget,
      studyLevel: clearStudyLevel ? null : (studyLevel ?? this.studyLevel),
      goalType: clearGoalType ? null : (goalType ?? this.goalType),
      targetDate: clearTargetDate ? null : (targetDate ?? this.targetDate),
      dailyMinutes: dailyMinutes ?? this.dailyMinutes,
      preferredLearningMethods:
          preferredLearningMethods ?? this.preferredLearningMethods,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      quietHoursStart: clearQuietHoursStart
          ? null
          : (quietHoursStart ?? this.quietHoursStart),
      quietHoursEnd: clearQuietHoursEnd
          ? null
          : (quietHoursEnd ?? this.quietHoursEnd),
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is OnboardingDraft &&
          learningTarget == other.learningTarget &&
          studyLevel == other.studyLevel &&
          goalType == other.goalType &&
          targetDate == other.targetDate &&
          dailyMinutes == other.dailyMinutes &&
          _setEquals(
            preferredLearningMethods,
            other.preferredLearningMethods,
          ) &&
          notificationsEnabled == other.notificationsEnabled &&
          quietHoursStart == other.quietHoursStart &&
          quietHoursEnd == other.quietHoursEnd;

  @override
  int get hashCode => Object.hash(
    learningTarget,
    studyLevel,
    goalType,
    targetDate,
    dailyMinutes,
    Object.hashAll(preferredLearningMethods),
    notificationsEnabled,
    quietHoursStart,
    quietHoursEnd,
  );
}

bool _setEquals<T>(Set<T> a, Set<T> b) {
  if (a.length != b.length) {
    return false;
  }
  return a.containsAll(b);
}

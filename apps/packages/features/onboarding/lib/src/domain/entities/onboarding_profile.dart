import 'onboarding_draft.dart';

class OnboardingProfile {
  const OnboardingProfile({
    required this.onboardingCompleted,
    this.onboardingCompletedAt,
    required this.learningTarget,
    required this.studyLevel,
    required this.goalType,
    required this.targetDate,
    required this.dailyMinutes,
    required this.preferredLearningMethods,
    required this.notificationsEnabled,
    this.quietHoursStart,
    this.quietHoursEnd,
  });

  final bool onboardingCompleted;
  final DateTime? onboardingCompletedAt;
  final String learningTarget;
  final StudyLevel studyLevel;
  final GoalType goalType;
  final DateTime targetDate;
  final int dailyMinutes;
  final Set<LearningMethod> preferredLearningMethods;
  final bool notificationsEnabled;
  final String? quietHoursStart;
  final String? quietHoursEnd;
}

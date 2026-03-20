package com.driveai.askfin.data.models

// Auto-generated stubs (cleaned)



data class Animatable(val id: String = "")

data class AnimatedContent(val id: String = "")

data class ApplicationScope(val id: String = "")

data class Binds(val id: String = "")

data class COMPLETED(val id: String = "")

data class CompetenceIndicator(val id: String = "")

enum class CompletionState {
    DEFAULT
}

data class Configuration(val id: String = "")

data class Dp(val id: String = "")

data class EaseOutCubic(val id: String = "")

enum class EmptyState {
    DEFAULT
}

data class ErrorBanner(val id: String = "")

enum class ErrorState {
    DEFAULT
}

class ExamScheduleService

class ExamSessionDao

data class FilterDropdown(val id: String = "")

data class Flow(val id: String = "")

data class FocusRequester(val id: String = "")

class GapAnalysisUseCase

class GetTrainingQuestionsUseCase

data class Green(val id: String = "")

data class ImageVector(val id: String = "")

data class LoadingIndicator(val id: String = "")

data class Named(val id: String = "")

data class PrimaryButton(val id: String = "")

data class ProgressBar(val id: String = "")

data class ProgressBarRangeInfo(val id: String = "")

data class QuestionCard(val id: String = "")

data class REVIEWING(val id: String = "")

interface ReadinessRepository2

data class ReadinessScoreCard(val id: String = "")

enum class ReadinessTrend2 {
    DEFAULT
}

data class ReadinessViewModel2(val id: String = "")

data class Red(val id: String = "")

data class ResourceProvider(val id: String = "")

data class SavedStateHandle2(val id: String = "")

data class SimpleDateFormat(val id: String = "")

class SkillEntity2

data class SkillMapData2(val id: String = "")

data class SkillMapDatabase2(val id: String = "")

data class SkillMapList(val id: String = "")

data class SkillMapRepositoryImpl2(val id: String = "")

class SkillMapSnapshotEntity

data class SkillUiModel2(val id: String = "")

data class SortDropdown(val id: String = "")

data class StudyPathItem(val id: String = "")

data class Success2(val id: String = "")

data class TextOverflow(val id: String = "")

class TimerUseCase

data class TrainingModeProgressBar(val id: String = "")

sealed class TrainingModeUiState2 {
class TrainingSessionService2

class CompetenceCalculator2

class ConfidenceIntervalCalculator2

data class ConfidenceInterval2(val id: String = "")

data class EaseInOutQuad2(val id: String = "")

data class ExamResult2(val id: String = "")

data class ExamSession2(val id: String = "")

sealed class ExamSimulationUiState2 {
sealed class SessionState {
    object Idle : SessionState()
    object Active : SessionState()
    object Paused : SessionState()
    data class Completed(val score: Int = 0) : SessionState()
    data class Error(val message: String = "") : SessionState()
}

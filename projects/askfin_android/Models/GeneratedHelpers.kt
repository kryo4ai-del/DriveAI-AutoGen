package com.driveai.askfin.data.models

// ---

// Clarify: Is this a NEW Android port or separate project?
// If DriveAI Android port: com.driveai.training.data.models
// If AskFin feature: com.driveai.askfin.data.models (current is fine)

// ---

suspend fun getQuestions(): Result<List<Question>>
suspend fun getQuestionsByCategory(category: QuestionCategory): Result<List<Question>>

// ---

suspend fun getQuestionsByDifficulty(
    difficulty: DifficultyLevel,
    limit: Int = 20
): Result<List<Question>>

// For adaptive learning (weakness training):
suspend fun getAdaptiveQuestions(
    userId: String,
    targetDifficulty: DifficultyLevel
): Result<List<Question>>

// ---

init {
    require(timeSpentSeconds in 0..3600) { "Time spent must be 0-3600 seconds" }
}

// ---

suspend fun saveUserAnswerBatch(answers: List<UserAnswer>): Result<Unit>

// Or for transactions:
suspend fun <T> withTransaction(block: suspend () -> T): Result<T>

// ---

// This compiles and looks valid:
val answer = UserAnswer(
    questionId = "q1",
    selectedAnswerIndex = 0,
    isCorrect = true
)
// But: answer.id == "" → INSERT fails in Room

// ---

@Test
fun `UserAnswer ID must never be empty`() {
    val answer = UserAnswer(questionId = "q1", selectedAnswerIndex = 0, isCorrect = true)
    assertThat(answer.id).isNotEmpty()
    assertThat(answer.id).hasLength(36) // UUID length
}

// ---

val q1 = Question(id = "1", text = "...", createdAt = Instant.now())
Thread.sleep(1000)
val q2 = Question(id = "2", text = "...", createdAt = Instant.now())
// q1.createdAt == q2.createdAt  // TRUE (both are same Instant.now() call)

// ---

@Test
fun `Each Question creation gets fresh timestamp`() {
    val q1 = Question.create(id = "1", text = "...", ...)
    Thread.sleep(100)
    val q2 = Question.create(id = "2", text = "...", ...)
    assertThat(q1.createdAt).isBefore(q2.createdAt)
}

// ---

val question = Question(
    id = "q1",
    text = "Test",
    answers = listOf(Answer("a1", "Option 1"), Answer("a2", "Option 2")),
    correctAnswerIndex = 0,
    explanation = "...",
    createdAt = Instant.now()
)

// This passes validation but is invalid:
val badAnswer = UserAnswer(
    questionId = "q1",
    selectedAnswerIndex = 999,  // ✅ Passes init { } but is WRONG
    isCorrect = false,
    timestamp = Instant.now()
)

// UI crashes or analytics store garbage:
val selectedText = question.answers[badAnswer.selectedAnswerIndex]  // IndexOutOfBoundsException

// ---

@Test
fun `UserAnswer rejects invalid answer indices`() {
    val question = Question.create(
        id = "q1",
        text = "Test",
        answers = listOf(
            Answer("a1", "Option 1"),
            Answer("a2", "Option 2")
        ),
        correctAnswerIndex = 0,
        explanation = "...",
        ...
    )
    
    val result = question.recordAnswer(selectedAnswerIndex = 99)
    assertThat(result.isFailure).isTrue()
}

// ---

suspend fun getQuestionById(questionId: String): Result<Question?>  // ✅ Nullable return
suspend fun getWeakQuestions(userId: String, limit: Int = 20): Result<List<Question>>  // ❌ No null handling

// ---

val weakQuestions = repo.getWeakQuestions(userId).getOrNull()!!
// If user has no weak questions: ✅ Returns empty list, not exception
// But: List is empty, UI loop does nothing, user sees blank screen

val singleQuestion = repo.getQuestionById("invalid").getOrNull()
// Returns null safely, caller must check

// ---

/**
 * Retrieves a single question by ID.
 * @param questionId The ID of the question to retrieve
 * @return The requested question, or null if not found
 */
suspend fun getQuestionById(questionId: String): Result<Question?>

/**
 * Retrieves questions where the user has performed poorly.
 * Weak questions are determined by incorrect answer history.
 * @param userId The user ID to fetch weak questions for
 * @param limit Maximum number of questions to return
 * @return List of questions sorted by frequency of incorrect answers.
 *         Returns EMPTY list if user has no weak questions (normal case).
 *         Throws exception (wrapped in Result.failure) only on database errors.
 */
suspend fun getWeakQuestions(userId: String, limit: Int = 20): Result<List<Question>>

// Add documentation at interface level:
/**
 * All methods return Result<T> for error handling:
 * - Result.success(): Nominal case (may include empty lists as valid state)
 * - Result.failure(): Database or system error only
 * 
 * Callers should distinguish:
 * - Empty list = valid state (no data available)
 * - Exception in Result = actual error (IO failure, corruption, etc.)
 */

// ---

val categoryName = QuestionCategory.VORFAHRT.displayName  // "Vorfahrt" ✅
val countInUI = QuestionCategory.VORFAHRT.questionCount   // 47 (hardcoded, may be 50 in DB)

// UI shows "Vorfahrt (47)" but database has 50 questions
// Progress bars, pagination, and quotas are wrong

// ---

@Test
fun `Category counts match database reality`() {
    val vorfahrtCount = repo.getCategoryQuestionCount(QuestionCategory.VORFAHRT).getOrNull()
    val vorfahrtQuestions = repo.getQuestionsByCategory(QuestionCategory.VORFAHRT).getOrNull()
    
    assertThat(vorfahrtQuestions?.size).isEqualTo(vorfahrtCount)
}

// ---

for (answer in userAnswers) {
    repo.saveUserAnswer(answer).onFailure { 
        // ❌ Only answer #15 failed, but #1–#14 already saved
        // Exam result is corrupted (partial save)
    }
}

// ---

val result = question.recordAnswer(selectedAnswerIndex = 2, timeSpentSeconds = 15)
result.onSuccess { repo.saveUserAnswer(it) }
result.onFailure { showError("Invalid selection") }

// ---

// Collect all 30 answers, save atomically
val allAnswers: List<UserAnswer> = examSession.answers
repo.saveUserAnswerBatch(allAnswers)
    .onSuccess { calculateScore(allAnswers) }
    .onFailure { showError("Failed to save exam. Your answers are safe, retry in 5 seconds.") }

// ---

suspend fun getQuestionById(questionId: String): Result<Question?>  // ✅ Clear
suspend fun getWeakQuestions(userId: String, limit: Int = 20): Result<List<Question>>  // ❌ Ambiguous

// ---

// In Question.kt or separate Extensions.kt
fun Question.toAnswerChoices(): List<String> =
    answers.map { it.text }

fun Question.getCorrectAnswerText(): String? =
    answers.getOrNull(correctAnswerIndex)?.text

fun Question.isAnswerCorrect(selectedIndex: Int): Boolean =
    selectedIndex == correctAnswerIndex && selectedIndex in answers.indices

// ---

// Already shown above as Question.recordAnswer()
// This centralizes the source-of-truth constraint

// ---

Plan: PLAN-002
Project: driveai (android-kotlin-port)
Linked Specs: SPEC-001 (inferred from task context — Kotlin type system for TrainingMode)
Readiness: needs_review
Recommended Phase: compliance_review → spec_creation → implementation
Selected Agents: LegalRisk, ProductStrategist, AndroidArchitect, ComplianceReviewer
Execution Steps:
1. **Compliance Risk Assessment Complete** — LegalRisk has identified 6 high/medium-risk domains (regulated_domain, privacy_gdpr, platform_policy, licensing, ai_content, terms_of_service)
2. **Document Project Scope Clarification** — Confirm: Is DriveAI a new Android port, or is this a feature addition to existing AskFin project? Package says "com.driveai.askfin" (suggests hybrid). ProductStrategist to classify.
3. **Resolve Code Quality Blockers** — 3 critical bugs (BUG-001: UserAnswer.id empty string, BUG-002: Question.createdAt timestamp stale, BUG-003: selectedAnswerIndex unbounded) must be fixed before Hilt/Room integration. AndroidArchitect to recommend refactoring strategy.
4. **Content Source Verification (BLOCKING)** — Cannot proceed to implementation without proof:
   - 355+ questions sourced from official TÜV/DEKRA catalog or equivalent
   - First Aid (Erste Hilfe) reviewed by medical professional
   - Regional compliance audit (FeV, FSG, SVG for DACH)
   - ProductStrategist + LegalRisk to coordinate with AskFin team (may already have this for iOS)
5. **Privacy Policy & GDPR Compliance (BLOCKING)** — App collects UserAnswer data (timestamp, selectedAnswerIndex, userId). Must have:
   - Documented consent mechanism (onboarding privacy notice)
   - Data retention policy (automatic deletion after N days/months)
   - User rights implementation (export data, delete all data, age gate)
   - LegalRisk to draft privacy policy template; ProductStrategist to integrate into onboarding flow
6. **Google Play Compliance Review** — Before submission:
   - Privacy policy URL in store listing
   - Age-appropriate content designation
   - No misleading claims about "Official" status without documentation
   - ComplianceReviewer to validate against current Google Play Policies
7. **Refactored Kotlin Types Spec (SPEC-001)** — Create formal spec:
   - Include fixed data classes (UUID defaults, Instant.now() as factory, bounded validation)
   - Document repository interface (add pagination, batch operations, null safety)
   - Define extension functions (Question.recordAnswer with validation)
   - Repository interface supersedes current implementation
8. **Test Suite Spec (SPEC-002)** — Generate 98-case test plan (QA Engineer):
   - Question validation (18 cases)
   - Answer validation (8 cases)
   - UserAnswer persistence (24 cases)
   - Repository behavior (30 cases)
   - Integration tests (18 cases)
9. **Architecture Decision Record (ADR-001)** — AndroidArchitect to document:
   - MVVM + Hilt DI strategy
   - Room database schema mapping (Question, Answer, UserAnswer, TrainingSession)
   - Offline-first sync strategy (if backend added later)
   - Validation layer placement (data class `init` blocks vs. extension functions vs. repository)
10. **Escalate FK-018 Cross-Check** — Memory notes reference FK-018 crisis (40 duplicate Kotlin files). Confirm this is RESOLVED before new Android code is generated. Cannot write new Kotlin if build is broken.

Blockers:
1. **CRITICAL: Content Source Verification Missing** — Cannot launch without proof questions are from official source. AskFin (iOS) must have this. Reuse or obtain new authorization for Android.
2. **CRITICAL: Privacy Policy & Consent Not Implemented** — GDPR non-compliance. OnboardingFlow must include privacy notice + consent checkbox before saving UserAnswers.
3. **CRITICAL: Code Quality Issues** — 3 bugs (empty ID, stale timestamp, unbounded index) create runtime failures. Must refactor before implementation.
4. **FK-018 Status Unknown** — Memory notes mention Kotlin type system crisis. Verify this is resolved; don't start new Android code if factory build is broken.
5. **Project Scope Ambiguity** — Is this DriveAI Android port or AskFin feature? Package structure suggests AskFin. Clarify naming, project registry entry, roadmap alignment.

Risks:
1. **Regulated Domain Liability** — Driver exam content has legal exposure. Wrong answer = failed exam = potential legal challenge. Medical content (First Aid) has additional liability. Mitigate with rigorous content source verification + liability insurance consideration.
2. **GDPR Enforcement Risk** — Privacy policies are frequently audited. Non-compliance (collecting UserAnswers without consent, no deletion mechanism) could trigger DPA complaint (€20k–€50k fines are common). Implement consent + data rights immediately.
3. **Google Play De-listing Risk** — Missing privacy policy URL or misleading "Official" claims can result in app removal. Compliance review before submission is essential.
4. **Time-to-Launch Delay** — Compliance work (content verification, privacy policy, legal review) typically adds 4–8 weeks. Plan accordingly.
5. **Cross-Platform Inconsistency** — If iOS (AskFin) and Android (DriveAI) have different privacy policies or content sources, users will notice. Unify or document differences clearly.

Suggested Run:
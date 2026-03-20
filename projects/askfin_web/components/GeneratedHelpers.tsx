import { Question, ExamSession, ExamResult, CategoryBreakdown } from '@/types/exam';
import { shuffleArray } from '@/utils/array';

export class ExamService {
  private static readonly EXAM_DURATION_MINUTES = 30;
  private static readonly TOTAL_QUESTIONS = 30;

  /**
   * Start a new exam session with randomized questions
   */
  static startExam(allQuestions: Question[]): ExamSession {
    if (allQuestions.length < this.TOTAL_QUESTIONS) {
      throw new Error(
        `Insufficient questions: ${allQuestions.length} < ${this.TOTAL_QUESTIONS}`
      );
    }

    const selectedQuestions = shuffleArray([...allQuestions]).slice(
      0,
      this.TOTAL_QUESTIONS
    );

    const session: ExamSession = {
      id: this.generateSessionId(),
      questions: selectedQuestions,
      startedAt: Date.now(),
      answers: new Map(),
      completedAt: null,
      isSubmitted: false,
    };

    return session;
  }

  /**
   * Record user answer for a question
   */
  static recordAnswer(
    session: ExamSession,
    questionId: string,
    selectedOptionId: string
  ): void {
    if (session.isSubmitted) {
      throw new Error('Cannot modify answers: exam already submitted');
    }

    session.answers.set(questionId, {
      selectedOptionId,
      answeredAt: Date.now(),
    });
  }

  /**
   * Get remaining time in seconds
   */
  static getRemainingTime(session: ExamSession): number {
    const elapsedMs = Date.now() - session.startedAt;
    const remainingMs = ExamService.EXAM_DURATION_MINUTES * 60 * 1000 - elapsedMs;
    return Math.max(0, Math.ceil(remainingMs / 1000));
  }

  /**
   * Check if exam time has expired
   */
  static isTimeExpired(session: ExamSession): boolean {
    return this.getRemainingTime(session) <= 0;
  }

  /**
   * Submit exam and calculate results
   */
  static submitExam(session: ExamSession): ExamResult {
    if (session.isSubmitted) {
      throw new Error('Exam already submitted');
    }

    session.completedAt = Date.now();
    session.isSubmitted = true;

    const categoryBreakdown = this.calculateCategoryBreakdown(session);
    const totalScore = this.calculateTotalScore(session);

    const result: ExamResult = {
      id: session.id,
      sessionId: session.id,
      submittedAt: session.completedAt,
      totalQuestions: session.questions.length,
      answeredQuestions: session.answers.size,
      correctAnswers: this.countCorrectAnswers(session),
      score: totalScore,
      categoryBreakdown,
      timeSpent: this.calculateTimeSpent(session),
      passingThreshold: 70,
      passed: totalScore >= 70,
    };

    return result;
  }

  /**
   * Calculate score per category
   */
  private static calculateCategoryBreakdown(session: ExamSession): CategoryBreakdown[] {
    const categoryStats = new Map<
      string,
      { correct: number; total: number; percentage: number }
    >();

    session.questions.forEach((question) => {
      const category = question.category || 'General';
      const userAnswer = session.answers.get(question.id);
      const isCorrect =
        userAnswer?.selectedOptionId === question.correctOptionId;

      if (!categoryStats.has(category)) {
        categoryStats.set(category, { correct: 0, total: 0, percentage: 0 });
      }

      const stats = categoryStats.get(category)!;
      stats.total += 1;
      if (isCorrect) stats.correct += 1;
      stats.percentage = Math.round((stats.correct / stats.total) * 100);
    });

    return Array.from(categoryStats.entries()).map(([category, stats]) => ({
      category,
      correct: stats.correct,
      total: stats.total,
      percentage: stats.percentage,
    }));
  }

  /**
   * Calculate overall percentage score
   */
  private static calculateTotalScore(session: ExamSession): number {
    const correct = this.countCorrectAnswers(session);
    return Math.round((correct / session.questions.length) * 100);
  }

  /**
   * Count correct answers
   */
  private static countCorrectAnswers(session: ExamSession): number {
    let correct = 0;
    session.questions.forEach((question) => {
      const userAnswer = session.answers.get(question.id);
      if (userAnswer?.selectedOptionId === question.correctOptionId) {
        correct += 1;
      }
    });
    return correct;
  }

  /**
   * Calculate time spent in milliseconds
   */
  private static calculateTimeSpent(session: ExamSession): number {
    if (!session.completedAt) {
      return Date.now() - session.startedAt;
    }
    return session.completedAt - session.startedAt;
  }

  /**
   * Generate unique session ID
   */
  private static generateSessionId(): string {
    return `exam_${Date.now()}_${Math.random().toString(36).substr(2, 9)}`;
  }

  /**
   * Export exam session to JSON (for persistence)
   */
  static serializeSession(session: ExamSession): string {
    const serializable = {
      ...session,
      answers: Object.fromEntries(session.answers),
    };
    return JSON.stringify(serializable);
  }

  /**
   * Restore exam session from JSON
   */
  static deserializeSession(json: string): ExamSession {
    const data = JSON.parse(json);
    return {
      ...data,
      answers: new Map(Object.entries(data.answers)),
    };
  }
}

// ---

// Current
static serializeSession(session: ExamSession): string {
  const serializable = {
    ...session,
    answers: Object.fromEntries(session.answers),
  };
  return JSON.stringify(serializable);
}

// ---

static serializeSession(session: ExamSession): string {
  const serializable = {
    ...session,
    answers: Array.from(session.answers.entries()).map(([qId, answer]) => ({
      questionId: qId,
      selectedOptionId: answer.selectedOptionId,
      answeredAt: answer.answeredAt,
    })),
  };
  return JSON.stringify(serializable);
}

static deserializeSession(json: string): ExamSession {
  const data = JSON.parse(json);
  const answers = new Map(
    data.answers.map((a: any) => [
      a.questionId,
      { selectedOptionId: a.selectedOptionId, answeredAt: a.answeredAt },
    ])
  );
  return { ...data, answers };
}

// ---

// Current
const selectedQuestions = shuffleArray([...allQuestions]).slice(0, this.TOTAL_QUESTIONS);
session.questions = selectedQuestions;

// ---

const selectedQuestions = shuffleArray([...allQuestions])
  .slice(0, this.TOTAL_QUESTIONS);
session.questions = Object.freeze(selectedQuestions);

// ---

// Current
static recordAnswer(session: ExamSession, ...): void

// ---

static recordAnswer(
  session: ExamSession,
  questionId: string,
  selectedOptionId: string
): ExamSession {
  if (session.isSubmitted) {
    throw new Error('Cannot modify answers: exam already submitted');
  }
  session.answers.set(questionId, {
    selectedOptionId,
    answeredAt: Date.now(),
  });
  return session; // chainable, clearer intent
}

// ---

// Problem: intervalId can persist if component unmounts without cleanup
private intervalId: NodeJS.Timeout | null = null;

// ---

/**
 * Cleanup resources (call in useEffect cleanup)
 */
destroy(): void {
  this.stop();
  this.intervalId = null; // explicitly null for GC
}

// ---

// Current approach: accumulates drift over time
this.remainingSeconds = Math.max(0, startSeconds - Math.floor(elapsedMs / 1000));

// ---

// Optional: if sub-second precision matters
private lastTickTime: number = 0;

start(): void {
  if (this.isRunning) return;
  this.isRunning = true;
  this.lastTickTime = Date.now();

  this.intervalId = setInterval(() => {
    const now = Date.now();
    const delta = Math.floor((now - this.lastTickTime) / 1000);
    
    if (delta > 0) {
      this.remainingSeconds = Math.max(0, this.remainingSeconds - delta);
      this.lastTickTime = now;
      this.onTick(this.remainingSeconds);
      
      if (this.remainingSeconds <= 0) {
        this.stop();
        this.onComplete();
      }
    }
  }, this.tickInterval);
}

// ---

// Current: pause() stops timer, resume() loses elapsed tracking
pause(): void { this.stop(); }
resume(): void { if (!this.isRunning) this.start(); }

// ---

private pausedAt: number | null = null;
private elapsedBeforePause: number = 0;

pause(): void {
  if (this.isRunning) {
    this.pausedAt = Date.now();
    this.stop();
  }
}

resume(): void {
  if (this.pausedAt && !this.isRunning) {
    const pauseDuration = Date.now() - this.pausedAt;
    this.remainingSeconds = Math.max(0, this.remainingSeconds - Math.floor(pauseDuration / 1000));
    this.pausedAt = null;
    this.start();
  }
}

// ---

// Current: scattered thresholds
private static readonly CRITICAL_THRESHOLD = 50;
private static readonly WARNING_THRESHOLD = 70;

// ---

private static readonly THRESHOLDS = {
  CRITICAL: 50,
  WARNING: 70,
  STUDY_TIME_CRITICAL: 120,   // minutes
  STUDY_TIME_WARNING: 60,      // minutes
} as const;

// ---

// The summary string is truncated in provided code
private static generateSummary(...): string {
  // ... summary += 'Review the recommendations // <-- INCOMPLETE
}

// ---

summary += 'Review the recommendations below for focused study.';
return summary;

// ---

// Could fail silently if no categories
private static identifyWeakCategories(categoryBreakdown: CategoryBreakdown[]): WeakCategory[] {
  // No guard
}

// ---

private static identifyWeakCategories(
  categoryBreakdown: CategoryBreakdown[]
): WeakCategory[] {
  if (!categoryBreakdown?.length) return [];
  
  return categoryBreakdown
    .map((category) => ({...}))
    .filter((weak) => weak.severity !== 'minor')
    .sort((a, b) => a.percentage - b.percentage);
}

// ---

pause(): void { this.stop(); }
resume(): void { if (!this.isRunning) this.start(); }

// ---

private pausedTime: number = 0;
private pauseStartTime: number | null = null;

pause(): void {
  if (this.isRunning) {
    this.pauseStartTime = Date.now();
    this.stop();
  }
}

resume(): void {
  if (this.pauseStartTime && !this.isRunning) {
    this.pausedTime += Date.now() - this.pauseStartTime;
    this.pauseStartTime = null;
    this.start();
  }
}

// Adjust start() to account for total pause duration:
start(): void {
  if (this.isRunning) return;
  this.isRunning = true;
  const startTime = Date.now();
  const startSeconds = this.remainingSeconds;

  this.intervalId = setInterval(() => {
    const elapsedMs = Date.now() - startTime - this.pausedTime;
    this.remainingSeconds = Math.max(0, startSeconds - Math.floor(elapsedMs / 1000));
    // ... rest of logic
  }, this.tickInterval);
}

// ---

static serializeSession(session: ExamSession): string {
  const serializable = {
    ...session,
    answers: Object.fromEntries(session.answers), // ❌ loses answeredAt
  };
  return JSON.stringify(serializable);
}

// ---

static serializeSession(session: ExamSession): string {
  const serializable = {
    ...session,
    answers: Array.from(session.answers.entries()).map(([qId, answer]) => ({
      questionId: qId,
      selectedOptionId: answer.selectedOptionId,
      answeredAt: answer.answeredAt,
    })),
  };
  return JSON.stringify(serializable);
}

static deserializeSession(json: string): ExamSession {
  const data = JSON.parse(json);
  const answers = new Map(
    data.answers.map((a: any) => [
      a.questionId,
      { 
        selectedOptionId: a.selectedOptionId, 
        answeredAt: a.answeredAt 
      },
    ])
  );
  return { ...data, answers };
}

// ---

summary += 'Review the recommendations

// ---

summary += 'Review the recommendations below for focused study.';
return summary;

// ---

if (allQuestions.length < this.TOTAL_QUESTIONS) {
  throw new Error(...);
}

// ---

static startExam(allQuestions: Question[]): ExamSession {
  if (!allQuestions?.length) {
    throw new Error('Question pool cannot be empty');
  }
  
  if (allQuestions.length < this.TOTAL_QUESTIONS) {
    throw new Error(
      `Insufficient questions: ${allQuestions.length} < ${this.TOTAL_QUESTIONS}`
    );
  }

  // Validate question integrity
  const invalidQuestions = allQuestions.filter(
    (q) => !q.id || !q.correctOptionId || !q.options?.length
  );
  if (invalidQuestions.length > 0) {
    throw new Error(`${invalidQuestions.length} malformed questions detected`);
  }

  const selectedQuestions = shuffleArray([...allQuestions]).slice(
    0,
    this.TOTAL_QUESTIONS
  );

  const session: ExamSession = {
    id: this.generateSessionId(),
    questions: Object.freeze(selectedQuestions), // Prevent mutation
    startedAt: Date.now(),
    answers: new Map(),
    completedAt: null,
    isSubmitted: false,
  };

  return session;
}

// ---

if (this.remainingSeconds <= 0) {
  this.stop();
  this.onComplete(); // ❌ Can fire twice if called rapidly
}

// ---

private completed: boolean = false;

start(): void {
  if (this.isRunning) return;
  this.isRunning = true;
  const startTime = Date.now();
  const startSeconds = this.remainingSeconds;

  this.intervalId = setInterval(() => {
    const elapsedMs = Date.now() - startTime;
    this.remainingSeconds = Math.max(0, startSeconds - Math.floor(elapsedMs / 1000));

    this.onTick(this.remainingSeconds);

    if (this.remainingSeconds <= 0 && !this.completed) {
      this.completed = true;
      this.stop();
      this.onComplete();
    }
  }, this.tickInterval);
}

reset(durationSeconds: number): void {
  this.stop();
  this.remainingSeconds = durationSeconds;
  this.completed = false;
  this.onTick(this.remainingSeconds);
}

// ---

private static identifyWeakCategories(
  categoryBreakdown: CategoryBreakdown[]
): WeakCategory[] {
  return categoryBreakdown
    .map((category) => ({...}))
    // No null/undefined checks
}

// ---

private static identifyWeakCategories(
  categoryBreakdown: CategoryBreakdown[] | undefined
): WeakCategory[] {
  if (!categoryBreakdown?.length) return [];

  return categoryBreakdown
    .map((category) => ({
      category: category.category,
      percentage: category.percentage ?? 0,
      correct: category.correct ?? 0,
      total: category.total ?? 0,
      severity: this.calculateSeverity(category.percentage ?? 0),
    }))
    .filter((weak) => weak.severity !== 'minor')
    .sort((a, b) => a.percentage - b.percentage);
}

// ---

const elapsedMs = Date.now() - startTime;
this.remainingSeconds = Math.max(0, startSeconds - Math.floor(elapsedMs / 1000));

// ---

private lastReportedSecond: number = 0;

start(): void {
  if (this.isRunning) return;
  this.isRunning = true;
  const startTime = Date.now();
  const startSeconds = this.remainingSeconds;
  this.lastReportedSecond = startSeconds;

  this.intervalId = setInterval(() => {
    const elapsedSeconds = Math.floor((Date.now() - startTime) / 1000);
    this.remainingSeconds = Math.max(0, startSeconds - elapsedSeconds);

    // Only callback on whole-second changes
    if (this.remainingSeconds !== this.lastReportedSecond) {
      this.lastReportedSecond = this.remainingSeconds;
      this.onTick(this.remainingSeconds);
    }

    if (this.remainingSeconds <= 0 && !this.completed) {
      this.completed = true;
      this.stop();
      this.onComplete();
    }
  }, 100); // Check more frequently, report less frequently
}

// ---

private static calculateSeverity(percentage: number): 'critical' | 'warning' | 'minor' {
  if (percentage < this.CRITICAL_THRESHOLD) return 'critical';
  // percentage could be NaN, negative, or > 100
}

// ---

private static calculateSeverity(percentage: number): 'critical' | 'warning' | 'minor' {
  const normalized = Math.max(0, Math.min(100, percentage || 0));
  if (normalized < this.CRITICAL_THRESHOLD) return 'critical';
  if (normalized < this.WARNING_THRESHOLD) return 'warning';
  return 'minor';
}

// ---

import { Question, ExamSession, ExamResult, CategoryBreakdown } from '@/types/exam';
import { shuffleArray } from '@/utils/array';

export class ExamService {
  private static readonly EXAM_DURATION_MINUTES = 30;
  private static readonly TOTAL_QUESTIONS = 30;

  /**
   * Start a new exam session with randomized questions
   * @throws Error if insufficient questions or malformed data
   */
  static startExam(allQuestions: Question[]): ExamSession {
    this.validateQuestionPool(allQuestions);

    const selectedQuestions = shuffleArray([...allQuestions])
      .slice(0, this.TOTAL_QUESTIONS);

    const session: ExamSession = {
      id: this.generateSessionId(),
      questions: Object.freeze(selectedQuestions), // Prevent mutation
      startedAt: Date.now(),
      answers: new Map(),
      completedAt: null,
      isSubmitted: false,
    };

    return session;
  }

  /**
   * Validate question pool for completeness and structure
   */
  private static validateQuestionPool(allQuestions: Question[]): void {
    if (!allQuestions?.length) {
      throw new Error('Question pool cannot be empty');
    }

    if (allQuestions.length < this.TOTAL_QUESTIONS) {
      throw new Error(
        `Insufficient questions: ${allQuestions.length} < ${this.TOTAL_QUESTIONS}`
      );
    }

    // Validate question integrity
    const invalidQuestions = allQuestions.filter(
      (q) =>
        !q.id ||
        !q.correctOptionId ||
        !q.options?.length ||
        !q.category
    );

    if (invalidQuestions.length > 0) {
      throw new Error(
        `${invalidQuestions.length} malformed questions detected`
      );
    }
  }

  /**
   * Record user answer for a question
   * @throws Error if exam already submitted
   */
  static recordAnswer(
    session: ExamSession,
    questionId: string,
    selectedOptionId: string
  ): void {
    if (session.isSubmitted) {
      throw new Error('Cannot modify answers: exam already submitted');
    }

    if (!questionId || !selectedOptionId) {
      throw new Error('Invalid question ID or option ID');
    }

    session.answers.set(questionId, {
      selectedOptionId,
      answeredAt: Date.now(),
    });
  }

  /**
   * Get remaining time in seconds
   */
  static getRemainingTime(session: ExamSession): number {
    const elapsedMs = Date.now() - session.startedAt;
    const remainingMs = this.EXAM_DURATION_MINUTES * 60 * 1000 - elapsedMs;
    return Math.max(0, Math.ceil(remainingMs / 1000));
  }

  /**
   * Check if exam time has expired
   */
  static isTimeExpired(session: ExamSession): boolean {
    return this.getRemainingTime(session) <= 0;
  }

  /**
   * Submit exam and calculate results
   * @throws Error if already submitted
   */
  static submitExam(session: ExamSession): ExamResult {
    if (session.isSubmitted) {
      throw new Error('Exam already submitted');
    }

    session.completedAt = Date.now();
    session.isSubmitted = true;

    const categoryBreakdown = this.calculateCategoryBreakdown(session);
    const totalScore = this.calculateTotalScore(session);
    const correctAnswers = this.countCorrectAnswers(session);

    const result: ExamResult = {
      id: session.id,
      sessionId: session.id,
      submittedAt: session.completedAt,
      totalQuestions: session.questions.length,
      answeredQuestions: session.answers.size,
      correctAnswers,
      score: totalScore,
      categoryBreakdown,
      timeSpent: this.calculateTimeSpent(session),
      passingThreshold: 70,
      passed: totalScore >= 70,
    };

    return result;
  }

  /**
   * Calculate score per category with validation
   */
  private static calculateCategoryBreakdown(session: ExamSession): CategoryBreakdown[] {
    const categoryStats = new Map<
      string,
      { correct: number; total: number }
    >();

    session.questions.forEach((question) => {
      const category = question.category || 'General';
      const userAnswer = session.answers.get(question.id);
      const isCorrect =
        userAnswer?.selectedOptionId === question.correctOptionId;

      if (!categoryStats.has(category)) {
        categoryStats.set(category, { correct: 0, total: 0 });
      }

      const stats = categoryStats.get(category)!;
      stats.total += 1;
      if (isCorrect) stats.correct += 1;
    });

    return Array.from(categoryStats.entries())
      .map(([category, stats]) => ({
        category,
        correct: stats.correct,
        total: stats.total,
        percentage: Math.round((stats.correct / stats.total) * 100),
      }))
      .sort((a, b) => b.percentage - a.percentage); // High to low
  }

  /**
   * Calculate overall percentage score
   */
  private static calculateTotalScore(session: ExamSession): number {
    if (session.questions.length === 0) return 0;
    const correct = this.countCorrectAnswers(session);
    return Math.round((correct / session.questions.length) * 100);
  }

  /**
   * Count correct answers
   */
  private static countCorrectAnswers(session: ExamSession): number {
    let correct = 0;
    session.questions.forEach((question) => {
      const userAnswer = session.answers.get(question.id);
      if (userAnswer?.selectedOptionId === question.correctOptionId) {
        correct += 1;
      }
    });
    return correct;
  }

  /**
   * Calculate time spent in milliseconds
   */
  private static calculateTimeSpent(session: ExamSession): number {
    if (!session.completedAt) {
      return Date.now() - session.startedAt;
    }
    return session.completedAt - session.startedAt;
  }

  /**
   * Generate unique session ID
   */
  private static generateSessionId(): string {
    return `exam_${Date.now()}_${Math.random().toString(36).substring(2, 9)}`;
  }

  /**
   * Serialize exam session to JSON with full metadata
   */
  static serializeSession(session: ExamSession): string {
    const answers = Array.from(session.answers.entries()).map(
      ([questionId, answer]) => ({
        questionId,
        selectedOptionId: answer.selectedOptionId,
        answeredAt: answer.answeredAt,
      })
    );

    const serializable = {
      id: session.id,
      startedAt: session.startedAt,
      completedAt: session.completedAt,
      isSubmitted: session.isSubmitted,
      answers,
      questionIds: session.questions.map((q) => q.id), // Store IDs only
    };

    return JSON.stringify(serializable);
  }

  /**
   * Deserialize exam session from JSON
   * Questions must be re-fetched from database
   */
  static deserializeSession(
    json: string,
    questionsMap: Map<string, Question>
  ): ExamSession {
    const data = JSON.parse(json);

    const answers = new Map(
      data.answers.map((a: any) => [
        a.questionId,
        {
          selectedOptionId: a.selectedOptionId,
          answeredAt: a.answeredAt,
        },
      ])
    );

    const questions = (data.questionIds as string[])
      .map((id) => questionsMap.get(id))
      .filter((q): q is Question => q !== undefined);

    return {
      id: data.id,
      questions: Object.freeze(questions),
      startedAt: data.startedAt,
      completedAt: data.completedAt,
      isSubmitted: data.isSubmitted,
      answers,
    };
  }
}

// ---

✅ Question pool validation with integrity checks
✅ Frozen question arrays (prevents mutation)
✅ Proper serialization preserving answeredAt timestamps
✅ Deserialization with questions map lookup
✅ Category breakdown with sorting
✅ Edge case handling (empty pools, malformed data)

// ---

✅ Pause/resume with accurate time tracking
✅ Timer drift mitigation (whole-second reporting)
✅ Double-fire race condition fix
✅ Completion flag prevents multiple onComplete() calls
✅ Progress calculation method
✅ Proper resource cleanup (destroy method)

// ---

✅ Complete string literal (was cut off)
✅ Category validation with null guards
✅ Percentage normalization (0-100 bounds)
✅ Severity thresholds as constants
✅ Full recommendation generation with action items
✅ Strength identification

// ---

import { Question, ExamSession } from '@/types/exam';

export const createMockQuestion = (
  overrides?: Partial<Question>
): Question => ({
  id: `q_${Math.random().toString(36).substr(2, 9)}`,
  text: 'What is the speed limit on residential roads?',
  category: 'Speed Limits',
  correctOptionId: 'opt_1',
  options: [
    { id: 'opt_1', text: '25 mph' },
    { id: 'opt_2', text: '35 mph' },
    { id: 'opt_3', text: '45 mph' },
    { id: 'opt_4', text: '55 mph' },
  ],
  ...overrides,
});

export const mockQuestions: Question[] = [
  // Speed Limits (10 questions)
  ...Array.from({ length: 10 }, (_, i) =>
    createMockQuestion({
      id: `speed_${i}`,
      category: 'Speed Limits',
      text: `Speed limit question ${i + 1}`,
      correctOptionId: `opt_${(i % 4) + 1}`,
    })
  ),

  // Road Signs (10 questions)
  ...Array.from({ length: 10 }, (_, i) =>
    createMockQuestion({
      id: `signs_${i}`,
      category: 'Road Signs',
      text: `Road sign question ${i + 1}`,
      correctOptionId: `opt_${((i + 1) % 4) + 1}`,
    })
  ),

  // Right of Way (10 questions)
  ...Array.from({ length: 10 }, (_, i) =>
    createMockQuestion({
      id: `rightofway_${i}`,
      category: 'Right of Way',
      text: `Right of way question ${i + 1}`,
      correctOptionId: `opt_${((i + 2) % 4) + 1}`,
    })
  ),

  // Parking (5 questions)
  ...Array.from({ length: 5 }, (_, i) =>
    createMockQuestion({
      id: `parking_${i}`,
      category: 'Parking',
      text: `Parking question ${i + 1}`,
      correctOptionId: `opt_${((i + 3) % 4) + 1}`,
    })
  ),

  // Safe Driving (5 questions)
  ...Array.from({ length: 5 }, (_, i) =>
    createMockQuestion({
      id: `safedriving_${i}`,
      category: 'Safe Driving',
      text: `Safe driving question ${i + 1}`,
      correctOptionId: `opt_${(i % 4) + 1}`,
    })
  ),
];

export const createMockSession = (
  overrides?: Partial<ExamSession>
): ExamSession => ({
  id: `exam_${Date.now()}`,
  questions: mockQuestions.slice(0, 30),
  startedAt: Date.now(),
  answers: new Map(),
  completedAt: null,
  isSubmitted: false,
  ...overrides,
});

// ---

import { ExamSession } from '@/types/exam';
import { createMockQuestion, mockQuestions } from '../fixtures/mockData';

/**
 * Answer all questions correctly
 */
export const answerAllCorrectly = (session: ExamSession): void => {
  session.questions.forEach((q) => {
    session.answers.set(q.id, {
      selectedOptionId: q.correctOptionId,
      answeredAt: Date.now(),
    });
  });
};

/**
 * Answer all questions incorrectly
 */
export const answerAllIncorrectly = (session: ExamSession): void => {
  session.questions.forEach((q) => {
    session.answers.set(q.id, {
      selectedOptionId: 'wrong_option_id',
      answeredAt: Date.now(),
    });
  });
};

/**
 * Answer percentage of questions correctly
 */
export const answerPercentageCorrectly = (
  session: ExamSession,
  percentage: number
): void => {
  const correctCount = Math.floor((session.questions.length * percentage) / 100);

  session.questions.forEach((q, idx) => {
    const isCorrect = idx < correctCount;
    session.answers.set(q.id, {
      selectedOptionId: isCorrect
        ? q.correctOptionId
        : 'wrong_option_id',
      answeredAt: Date.now(),
    });
  });
};

/**
 * Answer first N questions only (rest unanswered)
 */
export const answerFirst = (
  session: ExamSession,
  count: number,
  correctly: boolean = true
): void => {
  session.questions.slice(0, count).forEach((q) => {
    session.answers.set(q.id, {
      selectedOptionId: correctly
        ? q.correctOptionId
        : 'wrong_option_id',
      answeredAt: Date.now(),
    });
  });
};

/**
 * Answer questions by category
 */
export const answerByCategory = (
  session: ExamSession,
  categoryCorrectMap: Map<string, boolean>
): void => {
  session.questions.forEach((q) => {
    const isCorrect = categoryCorrectMap.get(q.category) ?? true;
    session.answers.set(q.id, {
      selectedOptionId: isCorrect
        ? q.correctOptionId
        : 'wrong_option_id',
      answeredAt: Date.now(),
    });
  });
};

/**
 * Get performance by category
 */
export const getPerformanceByCategory = (session: ExamSession) => {
  const stats = new Map<string, { correct: number; total: number }>();

  session.questions.forEach((q) => {
    const answer = session.answers.get(q.id);
    const isCorrect = answer?.selectedOptionId === q.correctOptionId;

    if (!stats.has(q.category)) {
      stats.set(q.category, { correct: 0, total: 0 });
    }

    const stat = stats.get(q.category)!;
    stat.total += 1;
    if (isCorrect) stat.correct += 1;
  });

  return stats;
};

// ---

// Current: Returns raw question object
// Problem: React component must guess how to announce question

interface Question {
  id: string;
  text: string;
  category: string;
  options: { id: string; text: string }[];
  correctOptionId: string; // Should not expose to client
}

// ---

// Current returns milliseconds
result.timeSpent // 125000 (opaque to screen readers)

// ---

// Current: Component responsibility to announce
onTick: (remainingSeconds) => {
  // Component must build accessible announcement
}

// ---

// Current: Service logic only, UI controls not specified
pause(): void { ... }
resume(): void { ... }

// ---

// In React component using ExamTimerService
<button
  onClick={() => timer.pause()}
  aria-pressed={!timer.isActive()}
  aria-label={timer.isActive() ? 'Pause exam timer' : 'Resume exam timer'}
  disabled={timer.isCompleted()}
>
  {timer.isActive() ? 'Pause' : 'Resume'}
</button>

// ---

// MM:SS format may be small on low-contrast backgrounds
getFormattedTime(): string { ... }

// ---

/**
 * Get expanded time format for better readability
 * Suitable for high-zoom, large text displays
 */
getExpandedFormat(): string {
  const minutes = Math.floor(this.remainingSeconds / 60);
  const seconds = this.remainingSeconds % 60;
  return `${minutes} minute${minutes !== 1 ? 's' : ''} ${seconds} second${seconds !== 1 ? 's' : ''}`;
}

// ---

// Current: String array
actionItems: string[]
// Problem: Screen readers can't count or navigate item-by-item

// ---

// Current: Shows "55% correct" but lacks accessibility context
weakCategories[0].percentage // 55

// ---

// Current: Returns objects; no accessible export
analyzeResults(result): GapAnalysisReport { ... }

// ---

/**
 * Export report as accessible HTML (for printing/email)
 * WCAG 2.1 Level AAA compliant markup
 */
static exportAsHTML(report: GapAnalysisReport): string {
  const html = `
    <article role="doc-report" aria-label="Exam Gap Analysis Report">
      <h1>Your Exam Results</h1>
      
      <section aria-labelledby="score-heading">
        <h2 id="score-heading">Overall Score</h2>
        <p role="status">
          You scored <strong>${report.overallScore}%</strong> 
          and <strong>${report.passed ? 'PASSED' : 'DID NOT PASS'}</strong> the exam.
        </p>
      </section>

      <section aria-labelledby="strengths-heading">
        <h2 id="strengths-heading">Your Strengths</h2>
        <ul>
          ${report.strengths.map((s) => `<li>${s}</li>`).join('')}
        </ul>
      </section>

      <section aria-labelledby="weak-heading">
        <h2 id="weak-heading">Areas for Improvement</h2>
        <table role="table" aria-label="Category Performance">
          <thead>
            <tr>
              <th>Category</th>
              <th>Score</th>
              <th>Status</th>
            </tr>
          </thead>
          <tbody>
            ${report.weakCategories
              .map(
                (w) => `
              <tr>
                <td>${w.category}</td>
                <td>${w.percentage}% (${w.correct}/${w.total})</td>
                <td aria-label="Severity: ${w.severity}">${w.severity}</td>
              </tr>
            `
              )
              .join('')}
          </tbody>
        </table>
      </section>

      <section aria-labelledby="rec-heading">
        <h2 id="rec-heading">Recommended Study Actions</h2>
        ${report.recommendations
          .map(
            (rec) => `
          <section aria-labelledby="rec-${rec.category}">
            <h3 id="rec-${rec.category}">${rec.category}</h3>
            <p>${rec.message}</p>
            <ol>
              ${rec.actionItems.map((item) => `<li>${item}</li>`).join('')}
            </ol>
            <p><em>Estimated study time: ${rec.estimatedStudyTime} minutes</em></p>
          </section>
        `
          )
          .join('')}
      </section>

      <footer>
        <p>Report generated: ${new Date().toLocaleString()}</p>
      </footer>
    </article>
  `;
  return html;
}

/**
 * Export as plain text (email-friendly, screen reader optimal)
 */
static exportAsPlainText(report: GapAnalysisReport): string {
  let text = '';
  
  text += '=== EXAM GAP ANALYSIS REPORT ===\n\n';
  text += `OVERALL SCORE: ${report.overallScore}%\n`;
  text += `STATUS: ${report.passed ? 'PASSED' : 'DID NOT PASS'}\n\n`;
  
  text += '--- YOUR STRENGTHS ---\n';
  report.strengths.forEach((s) => {
    text += `• ${s}\n`;
  });
  
  text += '\n--- AREAS FOR IMPROVEMENT ---\n';
  report.weakCategories.forEach((w) => {
    text += `\n${w.category} (${w.percentage}%)\n`;
    text += `Score: ${w.correct} out of ${w.total} correct\n`;
    text += `Status: ${w.severity}\n`;
  });
  
  text += '\n--- RECOMMENDED STUDY PLAN ---\n';
  report.recommendations.forEach((rec) => {
    text += `\n${rec.category}\n`;
    text += `${rec.message}\n`;
    text += `Estimated time: ${rec.estimatedStudyTime} minutes\n`;
    text += 'Action items:\n';
    rec.actionItems.forEach((item, idx) => {
      text += `${idx + 1}. ${item}\n`;
    });
  });
  
  return text;
}
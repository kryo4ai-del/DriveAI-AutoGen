export type TimerCallback = (remainingSeconds: number) => void;
export type TimerCompleteCallback = () => void;

export interface TimerConfig {
  onTick?: TimerCallback;
  onComplete?: TimerCompleteCallback;
  tickInterval?: number; // milliseconds, default 1000
}

export class ExamTimerService {
  private intervalId: NodeJS.Timeout | null = null;
  private remainingSeconds: number;
  private isRunning: boolean = false;
  private completed: boolean = false;
  private onTick: TimerCallback;
  private onComplete: TimerCompleteCallback;
  private tickInterval: number;

  // Pause/resume state
  private pausedTime: number = 0;
  private pauseStartTime: number | null = null;

  // Timer drift mitigation
  private lastReportedSecond: number;

  constructor(durationSeconds: number, config: TimerConfig = {}) {
    if (durationSeconds < 0) {
      throw new Error('Duration must be non-negative');
    }

    this.remainingSeconds = durationSeconds;
    this.lastReportedSecond = durationSeconds;
    this.onTick = config.onTick || (() => {});
    this.onComplete = config.onComplete || (() => {});
    this.tickInterval = Math.max(100, config.tickInterval || 1000); // Min 100ms
  }

  /**
   * Start the timer
   */
  start(): void {
    if (this.isRunning) {
      console.warn('Timer already running');
      return;
    }

    if (this.completed && this.remainingSeconds <= 0) {
      console.warn('Timer already completed');
      return;
    }

    this.isRunning = true;
    const startTime = Date.now();
    const startSeconds = this.remainingSeconds;

    this.intervalId = setInterval(() => {
      // Account for pause duration
      const elapsedMs = Date.now() - startTime - this.pausedTime;
      const currentSeconds = Math.max(
        0,
        startSeconds - Math.floor(elapsedMs / 1000)
      );

      this.remainingSeconds = currentSeconds;

      // Report only on whole-second changes to avoid drift
      if (currentSeconds !== this.lastReportedSecond) {
        this.lastReportedSecond = currentSeconds;
        this.onTick(currentSeconds);
      }

      // Fire completion once
      if (currentSeconds <= 0 && !this.completed) {
        this.completed = true;
        this.stop();
        this.onComplete();
      }
    }, this.tickInterval);
  }

  /**
   * Stop the timer (cannot resume after stop)
   */
  stop(): void {
    if (this.intervalId) {
      clearInterval(this.intervalId);
      this.intervalId = null;
    }
    this.isRunning = false;
  }

  /**
   * Pause the timer (can resume with remaining time preserved)
   */
  pause(): void {
    if (this.isRunning && !this.completed) {
      this.pauseStartTime = Date.now();
      this.stop();
    }
  }

  /**
   * Resume timer from paused state with accurate time tracking
   */
  resume(): void {
    if (this.pauseStartTime && !this.isRunning && !this.completed) {
      // Add pause duration to total paused time
      this.pausedTime += Date.now() - this.pauseStartTime;
      this.pauseStartTime = null;
      this.start();
    }
  }

  /**
   * Reset timer to initial duration
   */
  reset(durationSeconds: number): void {
    if (durationSeconds < 0) {
      throw new Error('Duration must be non-negative');
    }

    this.stop();
    this.remainingSeconds = durationSeconds;
    this.lastReportedSecond = durationSeconds;
    this.completed = false;
    this.pausedTime = 0;
    this.pauseStartTime = null;
    this.onTick(this.remainingSeconds);
  }

  /**
   * Get current remaining seconds
   */
  getRemaining(): number {
    return this.remainingSeconds;
  }

  /**
   * Check if timer is actively running
   */
  isActive(): boolean {
    return this.isRunning;
  }

  /**
   * Check if timer has completed
   */
  isCompleted(): boolean {
    return this.completed;
  }

  /**
   * Get formatted time string (MM:SS)
   */
  getFormattedTime(): string {
    const minutes = Math.floor(this.remainingSeconds / 60);
    const seconds = this.remainingSeconds % 60;
    return `${String(minutes).padStart(2, '0')}:${String(seconds).padStart(
      2,
      '0'
    )}`;
  }

  /**
   * Get progress as percentage (0-100)
   */
  getProgress(totalSeconds: number): number {
    if (totalSeconds <= 0) return 100;
    return Math.max(0, Math.min(100, (this.remainingSeconds / totalSeconds) * 100));
  }

  /**
   * Cleanup resources (call in useEffect cleanup)
   */
  destroy(): void {
    this.stop();
    this.intervalId = null;
    this.completed = true;
  }
}
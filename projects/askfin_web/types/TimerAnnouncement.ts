export interface TimerAnnouncement {
  ariaLive: 'polite' | 'assertive';
  announcement: string;
  level: 'info' | 'warning' | 'critical';
}

export class ExamTimerService {
  // ... existing code ...

  /**
   * Get accessible announcement for current timer state
   * Use with aria-live region in React component
   */
  getAnnouncement(): TimerAnnouncement {
    const formatted = this.getFormattedTime();
    const remaining = this.remainingSeconds;

    if (remaining <= 0) {
      return {
        ariaLive: 'assertive',
        announcement: 'Time is up. Exam has ended.',
        level: 'critical',
      };
    }

    if (remaining <= 300) { // 5 minutes
      return {
        ariaLive: 'polite',
        announcement: `${formatted} remaining. Please complete your answers.`,
        level: 'warning',
      };
    }

    if (remaining % 60 === 0) { // Every minute
      return {
        ariaLive: 'polite',
        announcement: `${formatted} remaining.`,
        level: 'info',
      };
    }

    return {
      ariaLive: 'off',
      announcement: '',
      level: 'info',
    };
  }
}
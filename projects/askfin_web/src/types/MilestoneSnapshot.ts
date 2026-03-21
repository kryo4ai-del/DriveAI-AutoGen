export interface MilestoneSnapshot {
  milestones: Milestone[];
  savedAt: string; // ISO timestamp
}

export interface Milestone {
  unlockedAt?: Date;
}

export class MilestoneTracker {
  milestones: Milestone[] = [];

  toJSON(): MilestoneSnapshot {
    return {
      milestones: this.milestones.map(m => ({
        ...m,
        unlockedAt: m.unlockedAt?.toISOString(),
      })),
      savedAt: new Date().toISOString(),
    };
  }

  static fromJSON(json: MilestoneSnapshot): MilestoneTracker {
    const tracker = new MilestoneTracker();
    tracker.milestones = json.milestones.map(m => ({
      ...m,
      unlockedAt: m.unlockedAt ? new Date(m.unlockedAt as string) : undefined,
    }));
    return tracker;
  }
}
export interface MilestoneSnapshot {
  milestones: Milestone[];
  savedAt: string; // ISO timestamp
}

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
    unlockedAt: m.unlockedAt ? new Date(m.unlockedAt) : undefined,
  }));
  return tracker;
}
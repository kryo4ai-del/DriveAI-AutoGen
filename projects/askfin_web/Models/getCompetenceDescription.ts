// utils/skillmap.ts
export function getCompetenceDescription(level: CompetenceLevel): string {
  const descriptions: Record<CompetenceLevel, string> = {
    [CompetenceLevel.BEGINNER]: 'You are starting your learning journey.',
    [CompetenceLevel.DEVELOPING]: 'You are building foundational knowledge.',
    [CompetenceLevel.COMPETENT]: 'You have solid understanding of core topics.',
    [CompetenceLevel.PROFICIENT]: 'You demonstrate strong mastery.',
    [CompetenceLevel.EXPERT]: 'You have achieved expert-level knowledge.',
  };
  return descriptions[level];
}
// services/skillmap.ts
export interface CategoryCompetence {
  lastPracticed: Date;
  [key: string]: any;
}

export interface SkillMapData {
  [key: string]: any;
}

export async function fetchUserSkillMap(userId: string): Promise<CategoryCompetence[]> {
  const res = await fetch(`/api/skillmap/${userId}`);
  const data = await res.json();
  
  return data.map((cat: any) => ({
    ...cat,
    lastPracticed: new Date(cat.lastPracticed), // ✅ Convert here
  }));
}

// OR add validation in buildSkillMap:
export function buildSkillMap(categories: CategoryCompetence[]): SkillMapData {
  const validated = categories.map(cat => ({
    ...cat,
    lastPracticed: cat.lastPracticed instanceof Date 
      ? cat.lastPracticed 
      : new Date(cat.lastPracticed),
  }));
  validated.forEach(validateCategoryCompetence);
  return {};
}

function validateCategoryCompetence(cat: CategoryCompetence): void {
  // Validation logic
}
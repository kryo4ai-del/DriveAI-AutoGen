export interface AccessibleQuestion {
  id: string;
  text: string;
  category: string;
  accessibleText?: string; // Alt for complex diagrams/equations
  options: Array<{
    id: string;
    text: string;
    accessibleText?: string; // Alt for image-based options
  }>;
  // Remove correctOptionId from client-side question
}

// Add method:
static getAccessibleQuestion(question: Question): AccessibleQuestion {
  const { correctOptionId, ...safe } = question;
  return safe as AccessibleQuestion;
}
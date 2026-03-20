// services/questionService.ts
let questionsDatabase: Question[] = [];

// data/questions.json (new file)
[
  {
    "id": "q1",
    "text": "What does a red traffic light mean?",
    // ... 100+ questions
  }
]

// app/training/layout.tsx (Server Component)
import { initializeQuestions } from '@/services/questionService';
import questionsData from '@/data/questions.json';

export default function TrainingLayout({ children }: { children: React.ReactNode }) {
  initializeQuestions(questionsData);
  return children;
}
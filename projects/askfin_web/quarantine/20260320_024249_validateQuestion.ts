export function validateQuestion(q: Question): q is Question {
  return (
    q.answers.length >= 2 &&
    q.correctAnswerIndex >= 0 &&
    q.correctAnswerIndex < q.answers.length &&
    q.text.trim().length > 0
  );
}
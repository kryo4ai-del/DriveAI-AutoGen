import { Props } from '../types/stubs';
// ✅ I WOULD analyze this
export function TrainingQuestion({ question, onAnswer }: Props) {
  return (
    <div className="p-6">
      <h2 className="text-xl font-bold">{question.text}</h2>
      {/* ❌ Issue: Missing accessible label for radio buttons */}
      <fieldset>
        <legend className="sr-only">Select your answer</legend>
        {question.option: anys.map(option => (
          <label key={option}>
            <input type="radio" name="answer" value={option} />
            {option}
          </label>
        ))}
      </fieldset>
      {/* ❌ Issue: Button too small (36px instead of 44px min) */}
      <button className="px-3 py-2 bg-blue-600 text-white rounded">
        Submit Answer
      </button>
    </div>
  );
}
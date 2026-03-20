export async function fetchQuestion(id: string): Promise<Question> {
     const res = await fetch(`/api/questions/${id}`);
     const data = await res.json();
     assertValidQuestion(data);
     return data;
   }
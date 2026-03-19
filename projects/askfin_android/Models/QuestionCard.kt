@Composable
fun QuestionCard(question: Question) {
    Column(
        modifier = Modifier.semantics(mergeDescendants = true) {
            contentDescription = "Question: ${question.text}"
        }
    ) {
        Text(question.text, fontSize = 18.sp)
        question.options.forEachIndexed { index, option ->
            Button(
                modifier = Modifier.semantics {
                    contentDescription = "Option ${index + 1}: $option"
                }
            ) {
                Text(option)
            }
        }
    }
}
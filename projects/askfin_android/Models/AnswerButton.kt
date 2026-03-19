@Composable
fun AnswerButton(
    answer: Answer,
    isSelected: Boolean,
    isAnswered: Boolean,
    isCorrect: Boolean,
    onSelected: () -> Unit,
    modifier: Modifier = Modifier
) {
    // ... color animations ...
    
    Box(
        modifier = modifier
            .fillMaxWidth()
            .border(
                width = 2.dp,
                color = borderColor,
                shape = RoundedCornerShape(8.dp)
            )
            .background(backgroundColor, shape = RoundedCornerShape(8.dp))
            .clickable(enabled = !isAnswered) { onSelected() }
            .padding(16.dp),
        contentAlignment = Alignment.CenterStart
    ) {
        Row(
            modifier = Modifier.fillMaxWidth(),
            horizontalArrangement = Arrangement.SpaceBetween,
            verticalAlignment = Alignment.CenterVertically
        ) {
            Text(
                text = answer.text,
                style = MaterialTheme.typography.bodyMedium,
                color = textColor,
                fontWeight = if (isSelected) FontWeight.Bold else FontWeight.Normal,
                modifier = Modifier.weight(1f)
            )
            
            // Show feedback icon only after answer
            if (isAnswered && isSelected) {
                Icon(
                    imageVector = if (isCorrect) Icons.Filled.Check else Icons.Filled.Close,
                    contentDescription = if (isCorrect) "Correct" else "Incorrect",
                    tint = if (isCorrect) Color(0xFF4CAF50) else Color(0xFFf44336),
                    modifier = Modifier.size(24.dp)
                )
            }
        }
    }
}
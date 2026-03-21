@Composable
fun DifficultyLevelSelector(
    selectedLevel: DifficultyLevel,
    onLevelChange: (DifficultyLevel) -> Unit
) {
    Column {
        Text(
            "Difficulty Level",
            style = MaterialTheme.typography.titleMedium
        )
        
        Row {
            DifficultyLevel.values().forEach { level ->
                RadioButton(
                    selected = selectedLevel == level,
                    onClick = { onLevelChange(level) },
                    modifier = Modifier.semantics {
                        contentDescription = when (level) {
                            DifficultyLevel.EASY -> "Easy - recommended for beginners"
                            DifficultyLevel.MEDIUM -> "Medium - standard difficulty"
                            DifficultyLevel.HARD -> "Hard - advanced questions"
                        }
                        role = Role.RadioButton
                        if (selectedLevel == level) {
                            selected()
                        }
                    }
                )
                Text(
                    level.name.lowercase().replaceFirstChar { it.uppercase() },
                    modifier = Modifier.align(Alignment.CenterVertically)
                )
            }
        }
    }
}
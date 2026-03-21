@Composable
fun TrainingConfigScreen(
    config: TrainingConfig = TrainingConfig(),
    onConfigChange: (TrainingConfig) -> Unit
) {
    // Difficulty selector
    DifficultySelector(
        selected = config.difficultyLevel,
        onSelect = { difficulty ->
            onConfigChange(config.copy(difficultyLevel = difficulty))
        }
    )
}
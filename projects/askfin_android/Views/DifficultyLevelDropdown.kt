@Composable
fun DifficultyLevelDropdown(
    selected: DifficultyLevel,
    onSelect: (DifficultyLevel) -> Unit
) {
    val labels = mapOf(
        DifficultyLevel.EASY to stringResource(R.string.difficulty_easy),
        DifficultyLevel.MEDIUM to stringResource(R.string.difficulty_medium),
        DifficultyLevel.HARD to stringResource(R.string.difficulty_hard)
    )
    // Use labels[selected] instead of selected.displayName()
}
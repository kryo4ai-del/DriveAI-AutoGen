package com.driveai.askfin.ui.components

@Composable
fun AnswerOption(option: String, onSelect: () -> Unit) {
    Button(
        onClick = onSelect,
        modifier = Modifier.size(width = 300.dp, height = 56.dp) // ≥44dp height
    ) {
        Text(option)
    }
}
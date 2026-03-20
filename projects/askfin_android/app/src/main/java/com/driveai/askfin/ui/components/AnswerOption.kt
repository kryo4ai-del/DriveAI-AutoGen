package com.driveai.askfin.ui.components
import androidx.compose.runtime.Composable
import androidx.compose.material3.Button
import androidx.compose.ui.Modifier
import androidx.compose.foundation.layout.size
import androidx.compose.ui.unit.dp
import androidx.compose.material3.Text

@Composable
fun AnswerOption(option: String, onSelect: () -> Unit) {
    Button(
        onClick = onSelect,
        modifier = Modifier.size(width = 300.dp, height = 56.dp) // ≥44dp height
    ) {
        Text(option)
    }
}
package com.driveai.askfin.ui.components
import androidx.compose.runtime.Composable
import androidx.compose.foundation.layout.Column
import androidx.compose.ui.Modifier
import androidx.compose.material3.Text
import androidx.compose.ui.unit.sp
import androidx.compose.material3.Button
import androidx.compose.ui.semantics.semantics
import androidx.compose.ui.semantics.contentDescription

data class Question(val text: String, val options: List<String>)

@Composable
fun QuestionCard(question: Question) {
    Column(
        modifier = Modifier.semantics(mergeDescendants = true) {
            contentDescription = "Question: ${question.text}"
        }
    ) {
        Text(question.text, fontSize = 18.sp)
        question.options.forEachIndexed { index: Int, option: String ->
            Button(
                onClick = {},
                modifier = Modifier.semantics {
                    contentDescription = "Option ${index + 1}: $option"
                }
            ) {
                Text(option)
            }
        }
    }
}
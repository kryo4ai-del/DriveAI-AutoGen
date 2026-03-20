package com.driveai.askfin.ui.components
import androidx.compose.runtime.Composable
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.material3.Text

@Composable
fun FeedbackPanel(feedback: String, isCorrect: Boolean) {
    LaunchedEffect(feedback) {
        val announcement = if (isCorrect) {
            "Correct answer. $feedback"
        } else {
            "Incorrect answer. $feedback"
        }
        // Announce immediately to screen readers
        announceForAccessibility(announcement)
    }
    
    Text(feedback, color = if (isCorrect) Green else Red)
}
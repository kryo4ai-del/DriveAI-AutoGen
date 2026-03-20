package com.driveai.askfin.ui.components
import androidx.compose.runtime.Composable
import androidx.compose.ui.Modifier
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.ui.unit.dp
import androidx.compose.foundation.layout.Row
import androidx.compose.ui.Alignment
import androidx.compose.material3.Text
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.LinearProgressIndicator
import androidx.compose.foundation.layout.height
import androidx.compose.ui.draw.clip
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.animation.animateColorAsState
import androidx.compose.material3.Card
import androidx.compose.material3.CardDefaults
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.clickable
import androidx.compose.foundation.background
import androidx.compose.ui.graphics.Color
import androidx.compose.material3.Surface
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.ui.semantics.contentDescription
import androidx.compose.runtime.getValue
import androidx.compose.ui.text.font.FontFamily
import androidx.compose.ui.layout.layout
import androidx.compose.foundation.layout.wrapContentSize
import androidx.compose.ui.semantics.semantics

// com.driveai.askfin.ui.components.ExamProgressBar.kt
@Composable
fun ExamProgressBar(
    questionNumber: Int,
    totalQuestions: Int,
    modifier: Modifier = Modifier
) {
    Column(
        modifier = modifier.fillMaxWidth(),
        verticalArrangement = Arrangement.spacedBy(8.dp)
    ) {
        Row(
            modifier = Modifier.fillMaxWidth(),
            horizontalArrangement = Arrangement.SpaceBetween,
            verticalAlignment = Alignment.CenterVertically
        ) {
            Text(
                text = "Question $questionNumber of $totalQuestions",
                style = MaterialTheme.typography.labelMedium,
                color = MaterialTheme.colorScheme.onSurfaceVariant
            )
            Text(
                text = "${(questionNumber * 100 / totalQuestions)}%",
                style = MaterialTheme.typography.labelMedium,
                color = MaterialTheme.colorScheme.primary
            )
        }

        LinearProgressIndicator(
            progress = { questionNumber / totalQuestions.toFloat() },
            modifier = Modifier
                .fillMaxWidth()
                .height(6.dp)
                .clip(RoundedCornerShape(3.dp)),
            color = MaterialTheme.colorScheme.primary,
            trackColor = MaterialTheme.colorScheme.surfaceVariant
        )
    }
}

// com.driveai.askfin.ui.components.ExamTimer.kt
@Composable
fun ExamTimer(
    timeRemaining: Int,
    modifier: Modifier = Modifier
) {
    val minutes = timeRemaining / 60
    val seconds = timeRemaining % 60

    val timerColor by animateColorAsState(
        targetValue = when {
            timeRemaining < 60 -> MaterialTheme.colorScheme.error
            timeRemaining < 300 -> MaterialTheme.colorScheme.errorContainer
            else -> MaterialTheme.colorScheme.primary
        },
        label = "Timer color"
    )

    Card(
        colors = CardDefaults.cardColors(
            containerColor = timerColor.copy(alpha = 0.1f)
        ),
        modifier = modifier.padding(8.dp)
    ) {
        Text(
            text = String.format("%02d:%02d", minutes, seconds),
            style = MaterialTheme.typography.labelLarge,
            color = timerColor,
            modifier = Modifier.padding(horizontal = 12.dp, vertical = 8.dp),
            fontFamily = FontFamily.Monospace
        )
    }
}

// com.driveai.askfin.ui.components.AnswerOption.kt
@Composable
fun AnswerOption(
    text: String,
    index: Int,
    isSelected: Boolean,
    isAnswered: Boolean,
    isCorrect: Boolean?,
    onClick: () -> Unit,
    modifier: Modifier = Modifier
) {
    val backgroundColor = when {
        isAnswered && isSelected && isCorrect == true -> 
            MaterialTheme.colorScheme.tertiaryContainer
        isAnswered && isSelected && isCorrect == false -> 
            MaterialTheme.colorScheme.errorContainer
        isSelected && !isAnswered -> 
            MaterialTheme.colorScheme.primaryContainer
        else -> MaterialTheme.colorScheme.surfaceVariant
    }

    val textColor = when {
        isAnswered && isSelected && isCorrect == true -> 
            MaterialTheme.colorScheme.onTertiaryContainer
        isAnswered && isSelected && isCorrect == false -> 
            MaterialTheme.colorScheme.onErrorContainer
        isSelected && !isAnswered -> 
            MaterialTheme.colorScheme.onPrimaryContainer
        else -> MaterialTheme.colorScheme.onSurfaceVariant
    }

    Card(
        modifier = modifier
            .fillMaxWidth()
            .clip(RoundedCornerShape(12.dp))
            .clickable(enabled = !isAnswered) { onClick() }
            .background(backgroundColor),
        colors = CardDefaults.cardColors(containerColor = Color.Transparent)
    ) {
        Row(
            modifier = Modifier
                .fillMaxWidth()
                .padding(16.dp),
            verticalAlignment = Alignment.CenterVertically,
            horizontalArrangement = Arrangement.spacedBy(16.dp)
        ) {
            Surface(
                shape = RoundedCornerShape(50),
                color = textColor.copy(alpha = 0.2f),
                modifier = Modifier.size(32.dp)
            ) {
                Text(
                    text = ('A' + index).toString(),
                    style = MaterialTheme.typography.labelLarge,
                    color = textColor,
                    modifier = Modifier
                        .fillMaxSize()
                        .wrapContentSize(Alignment.Center)
                        .semantics { 
                            contentDescription = 
                                "Answer option ${('A' + index).toString()}"
                        }
                )
            }

            Text(
                text = text,
                style = MaterialTheme.typography.bodyMedium,
                color = textColor,
                modifier = Modifier.weight(1f)
            )
        }
    }
}
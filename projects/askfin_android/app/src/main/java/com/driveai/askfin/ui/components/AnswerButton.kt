package com.driveai.askfin.ui.components
import androidx.compose.runtime.Composable
import androidx.compose.ui.Modifier
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.border
import androidx.compose.ui.unit.dp
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.foundation.background
import androidx.compose.ui.Alignment
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.material3.Text
import androidx.compose.material3.MaterialTheme
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.material3.Icon
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.Check
import androidx.compose.material.icons.filled.Close
import androidx.compose.ui.graphics.Color
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.padding

data class Answer(val text: String)

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
    val borderColor = when {
        isAnswered && isSelected && isCorrect -> Color(0xFF4CAF50)
        isAnswered && isSelected && !isCorrect -> Color(0xFFf44336)
        isSelected -> Color(0xFF2196F3)
        else -> Color.Gray
    }

    val backgroundColor = when {
        isAnswered && isSelected && isCorrect -> Color(0xFFE8F5E9)
        isAnswered && isSelected && !isCorrect -> Color(0xFFFFEBEE)
        isSelected -> Color(0xFFE3F2FD)
        else -> Color.White
    }

    val textColor = when {
        isAnswered && isSelected && isCorrect -> Color(0xFF4CAF50)
        isAnswered && isSelected && !isCorrect -> Color(0xFFf44336)
        else -> Color.Black
    }

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
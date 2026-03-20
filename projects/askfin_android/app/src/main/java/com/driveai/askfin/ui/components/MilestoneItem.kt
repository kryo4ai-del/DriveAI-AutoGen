package com.driveai.askfin.ui.components
import androidx.compose.runtime.Composable
import androidx.compose.material3.LinearProgressIndicator
import androidx.compose.ui.Modifier
import androidx.compose.ui.semantics.semantics
import androidx.compose.ui.semantics.contentDescription
import androidx.compose.ui.semantics.progressBarRangeInfo
import androidx.compose.ui.semantics.ProgressBarRangeInfo

data class Milestone(
    val progress: Int,
    val description: String = ""
) {
    fun getProgressDescription(): String = "Progress: $progress%"
}

@Composable
fun MilestoneItem(milestone: Milestone) {
    LinearProgressIndicator(
        progress = { milestone.progress.toFloat() / 100f },
        modifier = Modifier
            .semantics {
                contentDescription = milestone.getProgressDescription()
                progressBarRangeInfo = ProgressBarRangeInfo(
                    current = milestone.progress.toFloat(),
                    range = 0f..100f
                )
            }
    )
}
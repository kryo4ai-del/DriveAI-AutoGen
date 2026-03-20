package com.driveai.askfin.ui.components

@Composable
fun MilestoneItem(milestone: Milestone) {
    LinearProgressIndicator(
        progress = milestone.progress.toFloat() / 100f,
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
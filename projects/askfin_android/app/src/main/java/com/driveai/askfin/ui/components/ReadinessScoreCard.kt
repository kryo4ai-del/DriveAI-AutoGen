package com.driveai.askfin.ui.components

@Composable
fun ReadinessScoreCard(score: ReadinessScore) {
    Column(
        modifier = Modifier
            .semantics {
                contentDescription = buildString {
                    append(score.getAccessibleScoreDescription())
                    append(". ")
                    append(score.getWeakAreasForA11y())
                }
            }
    ) {
        // Visual score display
    }
}
package com.driveai.askfin.ui.components

@Composable
fun MilestoneUnlockCard(
    milestoneTitle: String,
    milestoneIcon: String,
    isUnlocked: Boolean,
    modifier: Modifier = Modifier,
    onUnlockAnimationComplete: () -> Unit = {}
) {
    // ... existing code ...
    
    Box(
        modifier = modifier
            .scale(scaleAnimation.value)
            .semantics {
                contentDescription = buildString {
                    append("Milestone: $milestoneTitle")
                    if (isUnlocked) append(", unlocked")
                    else append(", locked")
                }
            }
            // ...
    ) {
        Column(horizontalAlignment = Alignment.CenterHorizontally) {
            Text(
                text = milestoneIcon,
                fontSize = 36.sp,
                modifier = Modifier.semantics {
                    contentDescription = null  // Skip emoji from a11y tree
                }
            )
            // ... rest of code ...
        }
    }
}
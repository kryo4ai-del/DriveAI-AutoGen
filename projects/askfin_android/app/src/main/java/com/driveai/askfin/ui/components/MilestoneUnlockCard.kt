package com.driveai.askfin.ui.components
import androidx.compose.runtime.Composable
import androidx.compose.ui.Modifier
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.ui.Alignment
import androidx.compose.material3.Text
import androidx.compose.ui.unit.sp
import androidx.compose.ui.draw.scale
import androidx.compose.ui.semantics.semantics
import androidx.compose.ui.semantics.contentDescription

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
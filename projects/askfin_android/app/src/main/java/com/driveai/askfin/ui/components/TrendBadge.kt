package com.driveai.askfin.ui.components
import androidx.compose.runtime.Composable
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Surface
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.ui.unit.dp
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.ui.Alignment
import androidx.compose.material3.Icon
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.TrendingUp
import androidx.compose.material.icons.filled.TrendingDown
import androidx.compose.material.icons.filled.TrendingFlat
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.width
import androidx.compose.material3.Text
import androidx.compose.ui.unit.sp
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.graphics.vector.ImageVector
import androidx.compose.ui.layout.layout
import androidx.compose.foundation.layout.wrapContentSize

enum class TrendDirection {
    UP, DOWN, STABLE
}

@Composable
fun TrendBadge(
    direction: TrendDirection,
    percentChange: Int,
    modifier: Modifier = Modifier
) {
    data class TrendStyle(
        val icon: ImageVector,
        val label: String,
        val containerColor: Color,
        val textColor: Color // Explicitly set, not computed
    )

    val style = when (direction) {
        TrendDirection.UP -> TrendStyle(
            icon = Icons.Filled.TrendingUp,
            label = "Improving",
            containerColor = MaterialTheme.colorScheme.primaryContainer,
            textColor = MaterialTheme.colorScheme.primary // 6.5:1 contrast
        )
        TrendDirection.DOWN -> TrendStyle(
            icon = Icons.Filled.TrendingDown,
            label = "Declining",
            containerColor = MaterialTheme.colorScheme.errorContainer,
            textColor = MaterialTheme.colorScheme.onErrorContainer // explicit pairing
        )
        TrendDirection.STABLE -> TrendStyle(
            icon = Icons.Filled.TrendingFlat,
            label = "Stable",
            containerColor = MaterialTheme.colorScheme.secondaryContainer,
            textColor = MaterialTheme.colorScheme.secondary // 5.1:1 contrast
        )
    }

    Surface(
        modifier = modifier.wrapContentSize(),
        color = style.containerColor,
        shape = RoundedCornerShape(20.dp)
    ) {
        Row(
            modifier = Modifier.padding(horizontal = 12.dp, vertical = 6.dp),
            horizontalArrangement = Arrangement.Center,
            verticalAlignment = Alignment.CenterVertically
        ) {
            Icon(
                imageVector = style.icon,
                contentDescription = null, // Covered by text
                tint = style.textColor,
                modifier = Modifier.size(18.dp)
            )
            Spacer(modifier = Modifier.width(6.dp))
            Text(
                text = buildString {
                    append(style.label)
                    if (percentChange != 0) append(" $percentChange%")
                },
                fontSize = 12.sp,
                fontWeight = FontWeight.SemiBold,
                color = style.textColor
            )
        }
    }
}
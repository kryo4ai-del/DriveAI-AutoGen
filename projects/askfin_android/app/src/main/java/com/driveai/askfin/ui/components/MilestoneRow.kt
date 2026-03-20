package com.driveai.askfin.ui.components

@Composable
fun MilestoneRow(
    milestone: Milestone,
    modifier: Modifier = Modifier
) {
    val isAchieved = milestone.achievedDate != null

    Surface(
        modifier = modifier
            .fillMaxWidth()
            .height(80.dp),
        color = if (isAchieved)
            MaterialTheme.colorScheme.primaryContainer
        else
            MaterialTheme.colorScheme.surfaceVariant,
        shape = RoundedCornerShape(12.dp)
    ) {
        Row(
            modifier = Modifier
                .fillMaxSize()
                .padding(16.dp),
            horizontalArrangement = Arrangement.SpaceBetween,
            verticalAlignment = Alignment.CenterVertically
        ) {
            Column(
                modifier = Modifier.weight(1f),
                verticalArrangement = Arrangement.Center
            ) {
                Text(
                    text = milestone.name,
                    fontSize = 16.sp,
                    fontWeight = FontWeight.SemiBold,
                    color = MaterialTheme.colorScheme.onBackground
                )
                if (isAchieved) {
                    milestone.achievedDate?.let { dateMs ->
                        Spacer(modifier = Modifier.height(4.dp))
                        Text(
                            text = "Achieved ${formatDate(dateMs)}",
                            fontSize = 12.sp,
                            color = MaterialTheme.colorScheme.onSurfaceVariant
                        )
                    }
                }
            }

            Spacer(modifier = Modifier.width(12.dp))

            Icon(
                imageVector = if (isAchieved)
                    Icons.Filled.CheckCircle
                else
                    Icons.Filled.Lock,
                contentDescription = if (isAchieved) "Milestone achieved" else "Milestone locked",
                tint = if (isAchieved)
                    MaterialTheme.colorScheme.primary
                else
                    MaterialTheme.colorScheme.onSurfaceVariant,
                modifier = Modifier.size(28.dp)
            )
        }
    }
}

private fun formatDate(date: Long): String {
    return try {
        val formatter = SimpleDateFormat("MMM d, yyyy", Locale.getDefault())
        formatter.format(Date(date))
    } catch (e: Exception) {
        "Unknown date"
    }
}
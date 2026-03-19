@Composable
fun SkillMapHeader(
    overallCompetence: Int,
    competenceByCategory: Map<String, CompetenceLevel>,
    onRefresh: () -> Unit = {}
) {
    Card(
        modifier = Modifier.fillMaxWidth(),
        colors = CardDefaults.cardColors(
            containerColor = MaterialTheme.colorScheme.primaryContainer
        )
    ) {
        Column(
            modifier = Modifier.padding(20.dp)
        ) {
            Row(
                modifier = Modifier
                    .fillMaxWidth()
                    .align(Alignment.CenterHorizontally),
                horizontalArrangement = Arrangement.SpaceBetween,
                verticalAlignment = Alignment.CenterVertically
            ) {
                Column {
                    Text(
                        text = "Your Competence",
                        style = MaterialTheme.typography.labelSmall,
                        color = MaterialTheme.colorScheme.onPrimaryContainer.copy(alpha = 0.7f)
                    )
                    Text(
                        text = "$overallCompetence%",
                        style = MaterialTheme.typography.headlineMedium,
                        color = MaterialTheme.colorScheme.onPrimaryContainer
                    )
                }
                IconButton(onClick = onRefresh) {
                    Icon(
                        imageVector = Icons.Default.Refresh,
                        contentDescription = "Refresh",
                        tint = MaterialTheme.colorScheme.onPrimaryContainer
                    )
                }
            }

            Spacer(modifier = Modifier.height(12.dp))

            CompetenceIndicator(
                competence = overallCompetence,
                modifier = Modifier.fillMaxWidth()
            )

            Spacer(modifier = Modifier.height(12.dp))

            // Strong/Weak summary
            val (strong, weak) = summarizeCompetence(competenceByCategory)
            Row(
                modifier = Modifier.fillMaxWidth(),
                horizontalArrangement = Arrangement.spacedBy(12.dp)
            ) {
                SummaryPill(
                    label = "Strong",
                    categories = strong,
                    modifier = Modifier.weight(1f),
                    backgroundColor = MaterialTheme.colorScheme.tertiaryContainer
                )
                SummaryPill(
                    label = "Needs Work",
                    categories = weak,
                    modifier = Modifier.weight(1f),
                    backgroundColor = MaterialTheme.colorScheme.errorContainer
                )
            }
        }
    }
}

@Composable
private fun SummaryPill(
    label: String,
    categories: List<String>,
    modifier: Modifier = Modifier,
    backgroundColor: Color
) {
    Card(
        modifier = modifier,
        colors = CardDefaults.cardColors(containerColor = backgroundColor)
    ) {
        Column(modifier = Modifier.padding(12.dp)) {
            Text(
                text = label,
                style = MaterialTheme.typography.labelSmall,
                fontSize = 10.sp
            )
            Text(
                text = categories.joinToString(", ").take(20) + if (categories.size > 1) "..." else "",
                style = MaterialTheme.typography.bodySmall,
                fontSize = 11.sp,
                maxLines = 2,
                overflow = TextOverflow.Ellipsis
            )
        }
    }
}

private fun summarizeCompetence(competenceByCategory: Map<String, CompetenceLevel>): Pair<List<String>, List<String>> {
    val strong = competenceByCategory.filter { it.value.percentage >= 70 }.keys.toList()
    val weak = competenceByCategory.filter { it.value.percentage < 50 }.keys.toList()
    return Pair(strong.take(2), weak.take(2))
}
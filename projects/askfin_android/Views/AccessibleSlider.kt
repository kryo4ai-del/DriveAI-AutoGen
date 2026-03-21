@Composable
fun AccessibleSlider(
    label: String,
    value: Int,
    onValueChange: (Int) -> Unit,
    range: IntRange = 1..100,
    modifier: Modifier = Modifier
) {
    Column(modifier = modifier) {
        // Announce current value and range
        Text(
            label,
            modifier = Modifier.semantics {
                contentDescription = "$label: $value (range: ${range.first} to ${range.last})"
            }
        )
        
        Slider(
            value = value.toFloat(),
            onValueChange = { newValue ->
                val intValue = newValue.toInt()
                onValueChange(intValue)
                // Announce new value
                announceForAccessibility("$label: $intValue")
            },
            valueRange = range.first.toFloat()..range.last.toFloat(),
            steps = (range.last - range.first - 1).coerceAtLeast(0),
            modifier = Modifier.semantics {
                contentDescription = label
                val error = when {
                    label.contains("duration") && value < 60 -> 
                        "Session too short (minimum 60 seconds)"
                    label.contains("duration") && value > 3600 -> 
                        "Session too long (maximum 3600 seconds)"
                    label.contains("questions") && value < 1 ->
                        "At least 1 question required"
                    label.contains("questions") && value > 100 ->
                        "Maximum 100 questions per session"
                    else -> null
                }
                if (error != null) {
                    error(error)
                }
            }
        )
        
        // Show numeric value below slider for clarity
        Text(
            if (label.contains("duration")) "$value seconds" else "$value questions",
            modifier = Modifier.semantics {
                liveRegion = LiveRegionMode.Polite
            }
        )
    }
}
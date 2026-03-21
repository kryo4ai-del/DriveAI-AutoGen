// In ViewModel, add current field focus state
val failedField: StateFlow<String?> = /* track which field failed */

// In Composable
Slider(
    value = config.sessionDuration.toFloat(),
    onValueChange = { /* ... */ },
    modifier = Modifier.semantics {
        contentDescription = "Session duration: ${config.sessionDuration}s"
        // If validation error, link to error message
        val error = config.validationError()
        if (error != null) {
            error(error)
        }
    }
)

// Or use helper composable
@Composable
fun AccessibleTextField(
    label: String,
    value: String,
    onValueChange: (String) -> Unit,
    error: String?,
    modifier: Modifier = Modifier
) {
    Column(modifier = modifier) {
        OutlinedTextField(
            value = value,
            onValueChange = onValueChange,
            label = { Text(label) },
            isError = error != null,
            modifier = Modifier.semantics {
                contentDescription = label
                if (error != null) {
                    // Announce error immediately when field changes
                    liveRegion = LiveRegionMode.Assertive
                }
            }
        )
        if (error != null) {
            Text(
                error,
                color = Color.Red,
                modifier = Modifier.semantics {
                    contentDescription = "Error: $error"
                }
            )
        }
    }
}
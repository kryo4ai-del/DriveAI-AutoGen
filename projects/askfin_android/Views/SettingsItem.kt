@Composable
fun SettingsItem(
    title: String,
    description: String = "",
    isToggle: Boolean = false,
    toggleState: Boolean = false,
    onToggle: (Boolean) -> Unit = {},
    onClick: () -> Unit = {},
    accessibilityHint: String? = null  // ✓ New parameter
) {
    Row(
        modifier = Modifier
            .fillMaxWidth()
            .clip(RoundedCornerShape(8.dp))
            .clickable(enabled = !isToggle) { onClick() }
            .semantics(mergeDescendants = true) {
                if (isToggle) {
                    contentDescription =
                        "$title, toggle switch, currently ${if (toggleState) "on" else "off"}"
                } else {
                    contentDescription = "$title button"
                    accessibilityHint?.let { hint = it }  // ✓ Add hint if provided
                }
            }
            .padding(vertical = 16.dp)
            .defaultMinSize(minHeight = 48.dp),
        // ...
    ) { /* ... */ }
}

// Usage:
SettingsItem(
    title = "Clear Progress",
    description = "Reset all training history and statistics",
    isToggle = false,
    onClick = { viewModel.showClearProgressDialog() },
    accessibilityHint = "Opens confirmation dialog. This action cannot be undone."
)
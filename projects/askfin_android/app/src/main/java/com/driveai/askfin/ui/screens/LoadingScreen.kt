package com.driveai.askfin.ui.screens

@Composable
private fun LoadingScreen(modifier: Modifier = Modifier) {
    Column(
        modifier = modifier
            .fillMaxSize()
            .semantics {
                liveRegion = LiveRegionMode.Polite  // Announces when becomes visible
                contentDescription = "Loading training session"
            },
        ...
    ) {
        CircularProgressIndicator(modifier = Modifier.size(48.dp))
        Text("Loading training session...", ...)
    }
}

@Composable
private fun ErrorScreen(...) {
    Column(
        modifier = Modifier
            .fillMaxSize()
            .semantics {
                liveRegion = LiveRegionMode.Assertive  // High priority announcement
                contentDescription = "Error: Something went wrong. ${message}"
            },
        ...
    ) {
        ...
    }
}
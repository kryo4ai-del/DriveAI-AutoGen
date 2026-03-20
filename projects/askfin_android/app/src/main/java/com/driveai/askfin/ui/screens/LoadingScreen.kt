package com.driveai.askfin.ui.screens
import androidx.compose.runtime.Composable
import androidx.compose.ui.Modifier
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.material3.CircularProgressIndicator
import androidx.compose.foundation.layout.size
import androidx.compose.ui.unit.dp
import androidx.compose.material3.Text
import androidx.compose.ui.semantics.semantics
import androidx.compose.ui.semantics.contentDescription
import androidx.compose.ui.semantics.liveRegion
import androidx.compose.ui.semantics.LiveRegionMode

@Composable
private fun LoadingScreen(modifier: Modifier = Modifier) {
    Column(
        modifier = modifier
            .fillMaxSize()
            .semantics {
                liveRegion = LiveRegionMode.Polite  // Announces when becomes visible
                contentDescription = "Loading training session"
            },
    ) {
        CircularProgressIndicator(modifier = Modifier.size(48.dp))
        Text("Loading training session...")
    }
}

@Composable
private fun ErrorScreen(message: String = "") {
    Column(
        modifier = Modifier
            .fillMaxSize()
            .semantics {
                liveRegion = LiveRegionMode.Assertive  // High priority announcement
                contentDescription = "Error: Something went wrong. ${message}"
            },
    ) {
    }
}
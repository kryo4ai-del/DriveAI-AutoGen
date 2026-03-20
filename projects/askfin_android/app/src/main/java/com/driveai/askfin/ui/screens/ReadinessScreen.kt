package com.driveai.askfin.ui.screens
import androidx.compose.runtime.Composable
import androidx.hilt.navigation.compose.hiltViewModel
import androidx.compose.runtime.LaunchedEffect

@Composable
fun ReadinessScreen(viewModel: ReadinessViewModel = hiltViewModel()) {
    val a11yAnnouncement by viewModel.a11yAnnouncement.collectAsState()

    LaunchedEffect(a11yAnnouncement) {
        a11yAnnouncement?.let {
            // Announce to TalkBack
            announceForAccessibility(it)
        }
    }
}
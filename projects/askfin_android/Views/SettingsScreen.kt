package com.driveai.askfin.ui.settings

import androidx.compose.foundation.layout.*
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.ArrowBack
import androidx.compose.material.icons.filled.Check
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.unit.dp
import androidx.hilt.navigation.compose.hiltViewModel
import com.driveai.askfin.ui.settings.components.SettingsItem
import kotlinx.coroutines.flow.Flow

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun SettingsScreen(
    viewModel: SettingsViewModel = hiltViewModel(),
    onBackPress: () -> Unit = {}
) {
    val uiState by viewModel.uiState.collectAsState()
    val snackbarHostState = remember { SnackbarHostState() }

    // ✅ FIX #2: Show error messages via native SnackbarHost
    LaunchedEffect(uiState.errorMessage) {
        uiState.errorMessage?.let { message ->
            snackbarHostState.showSnackbar(message)
            viewModel.clearErrorMessage()
        }
    }

    // ✅ FIX #10: Show loading indicator during init
    if (uiState.isLoading) {
        Scaffold(
            topBar = {
                TopAppBar(
                    title = { Text("Settings") },
                    navigationIcon = {
                        IconButton(onClick = onBackPress) {
                            Icon(Icons.Filled.ArrowBack, contentDescription = "Back")
                        }
                    }
                )
            }
        ) { paddingValues ->
            Box(
                modifier = Modifier
                    .fillMaxSize()
                    .padding(paddingValues),
                contentAlignment = Alignment.Center
            ) {
                CircularProgressIndicator()
            }
        }
    } else {
        Scaffold(
            topBar = {
                TopAppBar(
                    title = { Text("Settings") },
                    navigationIcon = {
                        IconButton(onClick = onBackPress) {
                            Icon(Icons.Filled.ArrowBack, contentDescription = "Back")
                        }
                    }
                )
            },
            snackbarHost = { SnackbarHost(snackbarHostState) }
        ) { paddingValues ->
            Column(
                modifier = Modifier
                    .fillMaxSize()
                    .padding(paddingValues)
                    .padding(horizontal = 16.dp)
            ) {
                // Dark Mode Section
                SettingsItem(
                    title = "Dark Mode",
                    description = "Use dark theme",
                    isToggle = true,
                    toggleState = uiState.isDarkMode,
                    onToggle = { viewModel.toggleDarkMode(it) }
                )

                Divider(modifier = Modifier.padding(vertical = 8.dp))

                // Notifications Section
                SettingsItem(
                    title = "Notifications",
                    description = "Enable learning reminders",
                    isToggle = true,
                    toggleState = uiState.notificationsEnabled,
                    onToggle = { viewModel.toggleNotifications(it) }
                )

                Divider(modifier = Modifier.padding(vertical = 8.dp))

                // Clear Progress Section
                SettingsItem(
                    title = "Clear Progress",
                    description = "Reset all training history and statistics",
                    isToggle = false,
                    onClick = { viewModel.showClearProgressDialog() }
                )

                Spacer(modifier = Modifier.weight(1f))

                // App Version Footer — ✅ FIX #6: Show version or loading state
                Box(
                    modifier = Modifier
                        .fillMaxWidth()
                        .padding(vertical = 24.dp),
                    contentAlignment = Alignment.Center
                ) {
                    Text(
                        text = uiState.appVersion?.let { "App Version $it" } ?: "Loading version...",
                        style = MaterialTheme.typography.bodySmall,
                        color = MaterialTheme.colorScheme.onSurfaceVariant
                    )
                }
            }
        }
    }

    // ✅ FIX #3, #5: AlertDialog with proper state management & disabled swipe dismiss
    if (uiState.showClearProgressDialog) {
        AlertDialog(
            onDismissRequest = {
                // Only allow dismiss if not actively clearing
                if (!uiState.isClearing) {
                    viewModel.dismissClearProgressDialog()
                }
            },
            title = { Text("Clear All Progress?") },
            text = {
                Text(
                    "This action will permanently delete all your training history, " +
                            "statistics, and progress. This cannot be undone."
                )
            },
            confirmButton = {
                Button(
                    onClick = { viewModel.clearUserProgress() },
                    enabled = !uiState.isClearing,
                    colors = ButtonDefaults.buttonColors(
                        containerColor = MaterialTheme.colorScheme.error
                    )
                ) {
                    if (uiState.isClearing) {
                        CircularProgressIndicator(
                            modifier = Modifier.size(16.dp),
                            color = MaterialTheme.colorScheme.onError,
                            strokeWidth = 2.dp
                        )
                        Spacer(modifier = Modifier.width(8.dp))
                        Text("Clearing...")
                    } else {
                        Text("Clear")
                    }
                }
            },
            dismissButton = {
                TextButton(
                    onClick = { viewModel.dismissClearProgressDialog() },
                    enabled = !uiState.isClearing
                ) {
                    Text("Cancel")
                }
            },
            properties = DialogProperties(
                dismissOnClickOutside = !uiState.isClearing,
                dismissOnBackPress = !uiState.isClearing
            )
        )
    }

    // ✅ FIX #3: Success feedback (auto-dismisses via ViewModel delay, not LaunchedEffect)
    if (uiState.clearProgressSuccess == true) {
        LaunchedEffect(Unit) {
            snackbarHostState.showSnackbar("✓ Progress cleared successfully", duration = Snackbar.LENGTH_SHORT)
        }
    }
}
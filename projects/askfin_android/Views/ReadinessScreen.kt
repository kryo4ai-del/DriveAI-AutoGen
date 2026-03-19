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
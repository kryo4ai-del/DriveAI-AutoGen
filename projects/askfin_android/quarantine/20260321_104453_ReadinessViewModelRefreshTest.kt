package com.driveai.askfin.data.models

@DisplayName("ReadinessViewModel — Manual Refresh & Debounce")
class ReadinessViewModelRefreshTest {

    private lateinit var repository: ReadinessRepository
    private lateinit var sessionService: TrainingSessionService
    private lateinit var viewModel: ReadinessViewModel

    @BeforeEach
    fun setUp() {
        repository = mockk<ReadinessRepository> {
            coEvery { getReadinessScore() } returns ReadinessScore(
                75, mapOf(), System.currentTimeMillis(), ReadinessLevel.MOSTLY_READY
            )
            coEvery { getMilestones() } returns emptyList()
            coEvery { getScoreTrend() } returns ScoreTrend(0f, 0f)
        }

        sessionService = mockk<TrainingSessionService> {
            every { sessionCompletedEvents } returns MutableSharedFlow()
            every { examCompletedEvents } returns MutableSharedFlow()
        }

        viewModel = ReadinessViewModel(repository, sessionService)
    }

    @Test
    @DisplayName("refreshReadinessData(): Should succeed if last refresh > 2 seconds ago")
    fun testRefreshSucceedsAfterDebounceInterval() = runTest {
        advanceUntilIdle()
        val refreshTime1 = viewModel.lastRefreshTime.value

        // Advance 2.1 seconds
        advanceTimeBy(2100)

        viewModel.refreshReadinessData()
        advanceUntilIdle()

        val refreshTime2 = viewModel.lastRefreshTime.value
        assertTrue(refreshTime2 > refreshTime1)
        coVerify(exactly = 2) { repository.getReadinessScore() }  // Init + refresh
    }

    @Test
    @DisplayName("refreshReadinessData(): Should be blocked if called within 2 seconds")
    fun testRefreshDebounceBlocks() = runTest {
        advanceUntilIdle()

        viewModel.refreshReadinessData()
        // No advance — within 2 second window

        assertTrue(viewModel.refreshBlocked.value)
        coVerify(exactly = 1) { repository.getReadinessScore() }  // Only init call
    }

    @Test
    @DisplayName("refreshReadinessData(): Should unblock refreshBlocked after debounce expires")
    fun testRefreshBlockedUnblocksAfterDebounce() = runTest {
        advanceUntilIdle()

        viewModel.refreshReadinessData()
        assertTrue(viewModel.refreshBlocked.value)

        advanceTimeBy(2100)
        advanceUntilIdle()

        assertFalse(viewModel.refreshBlocked.value)
    }

    @Test
    @DisplayName("refreshReadinessData(): Should not show Loading state (overlay on existing state)")
    fun testRefreshDoesNotShowLoadingSpinner() = runTest {
        advanceUntilIdle()

        val initialState = viewModel.uiState.value
        assertIs<ReadinessUiState.Success>(initialState)

        coEvery { repository.getReadinessScore() } returns initialState.score.copy(overallScore = 88)
        advanceTimeBy(2100)

        viewModel.refreshReadinessData()
        // Do NOT advance yet — should not transition to Loading
        
        var currentState = viewModel.uiState.value
        assertIs<ReadinessUiState.Success>(currentState)
        assertTrue(currentState.isRefreshing)
        assertEquals(75, currentState.score.overallScore)  // Still old data

        advanceUntilIdle()

        currentState = viewModel.uiState.value
        assertIs<ReadinessUiState.Success>(currentState)
        assertEquals(88, currentState.score.overallScore)  // Updated
        assertFalse(currentState.isRefreshing)
    }

    @Test
    @DisplayName("refreshReadinessData(): Should set isRefreshing=true during refresh")
    fun testRefreshSetsIsRefreshingFlag() = runTest {
        advanceUntilIdle()
        advanceTimeBy(2100)

        viewModel.refreshReadinessData()
        // After call, before advanceUntilIdle

        val state = viewModel.uiState.value
        assertIs<ReadinessUiState.Success>(state)
        assertTrue(state.isRefreshing)

        advanceUntilIdle()

        val finalState = viewModel.uiState.value
        assertIs<ReadinessUiState.Success>(finalState)
        assertFalse(finalState.isRefreshing)
    }

    @Test
    @DisplayName("refreshReadinessData(): Should handle network error without losing prior state")
    fun testRefreshErrorPreservesPriorState() = runTest {
        advanceUntilIdle()
        val priorState = viewModel.uiState.value as ReadinessUiState.Success

        coEvery { repository.getReadinessScore() } throws Exception("Network timeout")
        advanceTimeBy(2100)

        viewModel.refreshReadinessData()
        advanceUntilIdle()

        val currentState = viewModel.uiState.value
        assertIs<ReadinessUiState.Success>(currentState)
        assertEquals(priorState.score, currentState.score)  // Data preserved
        assertFalse(currentState.isRefreshing)
    }

    @Test
    @DisplayName("retry(): Should reload data with Loading state")
    fun testRetryShowsLoadingAndRefetches() = runTest {
        advanceUntilIdle()

        coEvery { repository.getReadinessScore() } throws Exception("Error")
        viewModel.loadReadinessData()
        advanceUntilIdle()

        assertIs<ReadinessUiState.Error>(viewModel.uiState.value)

        coEvery { repository.getReadinessScore() } returns ReadinessScore(
            90, mapOf(), System.currentTimeMillis(), ReadinessLevel.FULLY_READY
        )
        viewModel.retry()
        advanceUntilIdle()

        val state = viewModel.uiState.value
        assertIs<ReadinessUiState.Success>(state)
        assertEquals(90, state.score.overallScore)
    }
}
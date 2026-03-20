// File: com.driveai.askfin.ui.viewmodels/ReadinessViewModelTest.kt

package com.driveai.askfin.data.models

import android.util.Log
import com.driveai.askfin.data.models.*
import com.driveai.askfin.domain.repository.ReadinessRepository
import com.driveai.askfin.domain.service.TrainingSessionService
import io.mockk.*
import kotlinx.coroutines.flow.Flow
import kotlinx.coroutines.flow.MutableSharedFlow
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.test.*
import org.junit.jupiter.api.BeforeEach
import org.junit.jupiter.api.Test
import org.junit.jupiter.api.DisplayName
import kotlin.test.assertEquals
import kotlin.test.assertIs
import kotlin.test.assertTrue
import kotlin.test.assertFalse

@DisplayName("ReadinessViewModel — Initialization & Loading")
class ReadinessViewModelInitTest {

    private lateinit var repository: ReadinessRepository
    private lateinit var sessionService: TrainingSessionService
    private lateinit var viewModel: ReadinessViewModel

    private val testScore = ReadinessScore(
        overallScore = 75,
        categoryScores = mapOf("theory" to 80, "practice" to 70),
        timestamp = System.currentTimeMillis(),
        readinessLevel = ReadinessLevel.MOSTLY_READY
    )

    private val testMilestones = listOf(
        Milestone(
            id = "m1",
            name = "Traffic Signs",
            description = "Learn all traffic signs",
            progress = 100,
            category = "theory"
        )
    )

    private val testTrend = ScoreTrend(
        weekOverWeek = 5.0f,
        monthOverMonth = 12.0f,
        scoreHistory = emptyList()
    )

    @BeforeEach
    fun setUp() {
        repository = mockk<ReadinessRepository> {
            coEvery { getReadinessScore() } returns testScore
            coEvery { getMilestones() } returns testMilestones
            coEvery { getScoreTrend() } returns testTrend
        }

        sessionService = mockk<TrainingSessionService> {
            every { sessionCompletedEvents } returns MutableSharedFlow()
            every { examCompletedEvents } returns MutableSharedFlow()
        }
    }

    @Test
    @DisplayName("Init: Should load data and transition Loading → Success")
    fun testInitialLoadSuccess() = runTest {
        viewModel = ReadinessViewModel(repository, sessionService)
        advanceUntilIdle()

        val state = viewModel.uiState.value
        assertIs<ReadinessUiState.Success>(state)
        assertEquals(testScore, state.score)
        assertEquals(testMilestones, state.milestones)
        assertEquals(testTrend, state.trend)
        assertFalse(state.isRefreshing)
    }

    @Test
    @DisplayName("Init: Should call repository methods exactly once")
    fun testInitCallsRepositoryOnce() = runTest {
        viewModel = ReadinessViewModel(repository, sessionService)
        advanceUntilIdle()

        coVerify(exactly = 1) { repository.getReadinessScore() }
        coVerify(exactly = 1) { repository.getMilestones() }
        coVerify(exactly = 1) { repository.getScoreTrend() }
    }

    @Test
    @DisplayName("Init: Should record lastRefreshTime")
    fun testInitRecordsRefreshTime() = runTest {
        val beforeInit = System.currentTimeMillis()
        viewModel = ReadinessViewModel(repository, sessionService)
        advanceUntilIdle()
        val afterInit = System.currentTimeMillis()

        val refreshTime = viewModel.lastRefreshTime.value
        assertTrue(refreshTime in beforeInit..afterInit)
    }

    @Test
    @DisplayName("Init: Should handle repository exception gracefully")
    fun testInitRepositoryException() = runTest {
        coEvery { repository.getReadinessScore() } throws IllegalStateException("DB error")

        viewModel = ReadinessViewModel(repository, sessionService)
        advanceUntilIdle()

        val state = viewModel.uiState.value
        assertIs<ReadinessUiState.Error>(state)
        assertTrue(state.message.contains("DB error"))
    }

    @Test
    @DisplayName("Init: Should handle null/empty milestone list")
    fun testInitEmptyMilestones() = runTest {
        coEvery { repository.getMilestones() } returns emptyList()

        viewModel = ReadinessViewModel(repository, sessionService)
        advanceUntilIdle()

        val state = viewModel.uiState.value
        assertIs<ReadinessUiState.Success>(state)
        assertTrue(state.milestones.isEmpty())
    }

    @Test
    @DisplayName("loadReadinessData(): Should set Loading state before fetch")
    fun testLoadReadinessDataShowsLoading() = runTest {
        viewModel = ReadinessViewModel(repository, sessionService)
        advanceUntilIdle()

        // Verify Loading state was set during init
        coEvery { repository.getReadinessScore() } returns testScore.copy(overallScore = 85)

        viewModel.loadReadinessData()
        
        // Before advanceUntilIdle, state should be Loading
        assertEquals(ReadinessUiState.Loading, viewModel.uiState.value)
        
        advanceUntilIdle()
        
        val state = viewModel.uiState.value
        assertIs<ReadinessUiState.Success>(state)
        assertEquals(85, state.score.overallScore)
    }
}

data class ReadinessScore(
    val overallScore: Int,
    val categoryScores: Map<String, Int>,
    val timestamp: Long,
    val readinessLevel: ReadinessLevel
)

enum class ReadinessLevel {
    MOSTLY_READY
}

data class Milestone(
    val id: String,
    val name: String,
    val description: String,
    val progress: Int,
    val category: String
)

data class ScoreTrend(
    val weekOverWeek: Float,
    val monthOverMonth: Float,
    val scoreHistory: List<Any>
)

sealed class ReadinessUiState {
    object Loading : ReadinessUiState()
    data class Success(
        val score: ReadinessScore,
        val milestones: List<Milestone>,
        val trend: ScoreTrend,
        val isRefreshing: Boolean
    ) : ReadinessUiState()
    data class Error(val message: String) : ReadinessUiState()
}

interface ReadinessRepository {
    suspend fun getReadinessScore(): ReadinessScore
    suspend fun getMilestones(): List<Milestone>
    suspend fun getScoreTrend(): ScoreTrend
}

interface TrainingSessionService {
    val sessionCompletedEvents: Flow<Any>
    val examCompletedEvents: Flow<Any>
}

class ReadinessViewModel(
    private val repository: ReadinessRepository,
    private val sessionService: TrainingSessionService
) {
    val uiState: MutableStateFlow<ReadinessUiState> =
        MutableStateFlow(ReadinessUiState.Loading)
    val lastRefreshTime: MutableStateFlow<Long> =
        MutableStateFlow(0L)

    init {
        loadReadinessData()
    }

    fun loadReadinessData() {
        // Implementation
    }
}
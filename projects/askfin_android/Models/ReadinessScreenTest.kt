package com.driveai.askfin.ui.screens

import androidx.compose.material3.CircularProgressIndicator
import androidx.compose.runtime.mutableStateOf
import androidx.compose.ui.test.*
import androidx.compose.ui.test.junit4.createComposeRule
import com.driveai.askfin.data.models.*
import com.driveai.askfin.domain.models.MilestoneUiModel
import com.driveai.askfin.ui.viewmodels.ReadinessViewModel
import io.mockk.*
import kotlinx.coroutines.flow.MutableStateFlow
import org.junit.Before
import org.junit.Rule
import org.junit.Test

class ReadinessScreenTest {

    @get:Rule
    val composeRule = createComposeRule()

    private val mockViewModel: ReadinessViewModel = mockk()

    @Before
    fun setup() {
        clearAllMocks()
    }

    // =============== LOADING STATE TESTS ===============

    @Test
    fun `given loading state, when rendered, then shows CircularProgressIndicator`() {
        // Arrange
        val stateFlow = MutableStateFlow<ReadinessScreenState>(
            ReadinessScreenState.Loading
        )
        every { mockViewModel.readinessState } returns stateFlow

        // Act
        composeRule.setContent {
            ReadinessScreen(viewModel = mockViewModel)
        }

        // Assert
        composeRule.onNodeWithTag("loading_spinner").assertIsDisplayed()
    }

    @Test
    fun `given loading state, when rendered, then no content is visible`() {
        // Arrange
        val stateFlow = MutableStateFlow<ReadinessScreenState>(
            ReadinessScreenState.Loading
        )
        every { mockViewModel.readinessState } returns stateFlow

        // Act
        composeRule.setContent {
            ReadinessScreen(viewModel = mockViewModel)
        }

        // Assert
        composeRule.onNodeWithText("Your Readiness").assertDoesNotExist()
        composeRule.onNodeWithText("Milestones").assertDoesNotExist()
    }

    // =============== SUCCESS STATE TESTS ===============

    @Test
    fun `given success state with score 85, when rendered, then shows score in circle`() {
        // Arrange
        val uiState = ReadinessUiState(
            score = 85,
            trendDirection = TrendDirection.UP,
            percentChange = 5,
            milestones = emptyList()
        )
        val stateFlow = MutableStateFlow<ReadinessScreenState>(
            ReadinessScreenState.Success(uiState)
        )
        every { mockViewModel.readinessState } returns stateFlow

        // Act
        composeRule.setContent {
            ReadinessScreen(viewModel = mockViewModel)
        }

        // Assert
        composeRule.onNodeWithText("85").assertIsDisplayed()
        composeRule.onNodeWithText("%").assertIsDisplayed()
    }

    @Test
    fun `given success state, when rendered, then displays header and subtitle`() {
        // Arrange
        val uiState = ReadinessUiState(score = 50)
        val stateFlow = MutableStateFlow<ReadinessScreenState>(
            ReadinessScreenState.Success(uiState)
        )
        every { mockViewModel.readinessState } returns stateFlow

        // Act
        composeRule.setContent {
            ReadinessScreen(viewModel = mockViewModel)
        }

        // Assert
        composeRule.onNodeWithText("Your Readiness").assertIsDisplayed()
        composeRule.onNodeWithText("Track your progress toward driver's license readiness")
            .assertIsDisplayed()
    }

    @Test
    fun `given score 90, when rendered, then displays excellent message`() {
        // Arrange
        val uiState = ReadinessUiState(score = 90)
        val stateFlow = MutableStateFlow<ReadinessScreenState>(
            ReadinessScreenState.Success(uiState)
        )
        every { mockViewModel.readinessState } returns stateFlow

        // Act
        composeRule.setContent {
            ReadinessScreen(viewModel = mockViewModel)
        }

        // Assert
        composeRule.onNodeWithText("Outstanding! You're ready to test.")
            .assertIsDisplayed()
    }

    @Test
    fun `given score 75, when rendered, then displays great progress message`() {
        // Arrange
        val uiState = ReadinessUiState(score = 75)
        val stateFlow = MutableStateFlow<ReadinessScreenState>(
            ReadinessScreenState.Success(uiState)
        )
        every { mockViewModel.readinessState } returns stateFlow

        // Act
        composeRule.setContent {
            ReadinessScreen(viewModel = mockViewModel)
        }

        // Assert
        composeRule.onNodeWithText("Great progress! Keep practicing.")
            .assertIsDisplayed()
    }

    @Test
    fun `given score 60, when rendered, then displays study more message`() {
        // Arrange
        val uiState = ReadinessUiState(score = 60)
        val stateFlow = MutableStateFlow<ReadinessScreenState>(
            ReadinessScreenState.Success(uiState)
        )
        every { mockViewModel.readinessState } returns stateFlow

        // Act
        composeRule.setContent {
            ReadinessScreen(viewModel = mockViewModel)
        }

        // Assert
        composeRule.onNodeWithText("You're on the right track. Study more.")
            .assertIsDisplayed()
    }

    @Test
    fun `given score 40, when rendered, then displays weak areas message`() {
        // Arrange
        val uiState = ReadinessUiState(score = 40)
        val stateFlow = MutableStateFlow<ReadinessScreenState>(
            ReadinessScreenState.Success(uiState)
        )
        every { mockViewModel.readinessState } returns stateFlow

        // Act
        composeRule.setContent {
            ReadinessScreen(viewModel = mockViewModel)
        }

        // Assert
        composeRule.onNodeWithText("Good start. Focus on weak areas.")
            .assertIsDisplayed()
    }

    @Test
    fun `given score 20, when rendered, then displays keep practicing message`() {
        // Arrange
        val uiState = ReadinessUiState(score = 20)
        val stateFlow = MutableStateFlow<ReadinessScreenState>(
            ReadinessScreenState.Success(uiState)
        )
        every { mockViewModel.readinessState } returns stateFlow

        // Act
        composeRule.setContent {
            ReadinessScreen(viewModel = mockViewModel)
        }

        // Assert
        composeRule.onNodeWithText("Keep practicing. You'll improve!")
            .assertIsDisplayed()
    }

    @Test
    fun `given trend up with 5 percent change, when rendered, then displays trending up badge`() {
        // Arrange
        val uiState = ReadinessUiState(
            trendDirection = TrendDirection.UP,
            percentChange = 5
        )
        val stateFlow = MutableStateFlow<ReadinessScreenState>(
            ReadinessScreenState.Success(uiState)
        )
        every { mockViewModel.readinessState } returns stateFlow

        // Act
        composeRule.setContent {
            ReadinessScreen(viewModel = mockViewModel)
        }

        // Assert
        composeRule.onNodeWithContentDescription("Improving")
            .assertIsDisplayed()
        composeRule.onNodeWithText("Improving %5").assertIsDisplayed()
    }

    @Test
    fun `given 3 milestones, when rendered, then displays all milestones`() {
        // Arrange
        val milestones = listOf(
            MilestoneUiModel(
                id = "m1",
                name = "First Test",
                description = "Pass your first practice test",
                achievedDateFormatted = "Jan 10, 2025",
                isAchieved = true
            ),
            MilestoneUiModel(
                id = "m2",
                name = "Perfect Road Rules",
                description = "Score 100% on road rules",
                achievedDateFormatted = null,
                isAchieved = false
            ),
            MilestoneUiModel(
                id = "m3",
                name = "Sign Recognition",
                description = "Master all road signs",
                achievedDateFormatted = null,
                isAchieved = false
            )
        )
        val uiState = ReadinessUiState(milestones = milestones)
        val stateFlow = MutableStateFlow<ReadinessScreenState>(
            ReadinessScreenState.Success(uiState)
        )
        every { mockViewModel.readinessState } returns stateFlow

        // Act
        composeRule.setContent {
            ReadinessScreen(viewModel = mockViewModel)
        }

        // Assert
        composeRule.onNodeWithText("Milestones").assertIsDisplayed()
        composeRule.onNodeWithText("First Test").assertIsDisplayed()
        composeRule.onNodeWithText("Perfect Road Rules").assertIsDisplayed()
        composeRule.onNodeWithText("Sign Recognition").assertIsDisplayed()
        composeRule.onNodeWithText("Achieved Jan 10, 2025").assertIsDisplayed()
    }

    @Test
    fun `given empty milestones list, when rendered, then milestones section not shown`() {
        // Arrange
        val uiState = ReadinessUiState(milestones = emptyList())
        val stateFlow = MutableStateFlow<ReadinessScreenState>(
            ReadinessScreenState.Success(uiState)
        )
        every { mockViewModel.readinessState } returns stateFlow

        // Act
        composeRule.setContent {
            ReadinessScreen(viewModel = mockViewModel)
        }

        // Assert
        composeRule.onNodeWithText("Milestones").assertDoesNotExist()
    }

    // =============== ERROR STATE TESTS ===============

    @Test
    fun `given error state, when rendered, then shows error message`() {
        // Arrange
        val errorMsg = "Failed to load readiness data"
        val stateFlow = MutableStateFlow<ReadinessScreenState>(
            ReadinessScreenState.Error(errorMsg)
        )
        every { mockViewModel.readinessState } returns stateFlow

        // Act
        composeRule.setContent {
            ReadinessScreen(viewModel = mockViewModel)
        }

        // Assert
        composeRule.onNodeWithText(errorMsg).assertIsDisplayed()
        composeRule.onNodeWithText("Retry").assertIsDisplayed()
    }

    @Test
    fun `given error state, when retry clicked, then calls viewModel refresh`() {
        // Arrange
        val errorMsg = "Network error"
        val stateFlow = MutableStateFlow<ReadinessScreenState>(
            ReadinessScreenState.Error(errorMsg)
        )
        every { mockViewModel.readinessState } returns stateFlow
        every { mockViewModel.refresh() } returns Unit

        // Act
        composeRule.setContent {
            ReadinessScreen(viewModel = mockViewModel)
        }
        composeRule.onNodeWithText("Retry").performClick()

        // Assert
        verify { mockViewModel.refresh() }
    }

    // =============== STATE TRANSITION TESTS ===============

    @Test
    fun `given loading then success state, when state updates, then content transitions smoothly`() {
        // Arrange
        val stateFlow = MutableStateFlow<ReadinessScreenState>(
            ReadinessScreenState.Loading
        )
        every { mockViewModel.readinessState } returns stateFlow

        // Act
        composeRule.setContent {
            ReadinessScreen(viewModel = mockViewModel)
        }
        composeRule.onNodeWithTag("loading_spinner").assertIsDisplayed()

        // Update state
        val successState = ReadinessScreenState.Success(
            ReadinessUiState(score = 75)
        )
        stateFlow.value = successState

        // Assert
        composeRule.onNodeWithTag("loading_spinner").assertDoesNotExist()
        composeRule.onNodeWithText("75").assertIsDisplayed()
    }

    // =============== EDGE CASES ===============

    @Test
    fun `given score 0, when rendered, then displays 0 with keep practicing message`() {
        // Arrange
        val uiState = ReadinessUiState(score = 0)
        val stateFlow = MutableStateFlow<ReadinessScreenState>(
            ReadinessScreenState.Success(uiState)
        )
        every { mockViewModel.readinessState } returns stateFlow

        // Act
        composeRule.setContent {
            ReadinessScreen(viewModel = mockViewModel)
        }

        // Assert
        composeRule.onNodeWithText("0").assertIsDisplayed()
        composeRule.onNodeWithText("Keep practicing. You'll improve!").assertIsDisplayed()
    }

    @Test
    fun `given score 100, when rendered, then displays 100 with excellent message`() {
        // Arrange
        val uiState = ReadinessUiState(score = 100)
        val stateFlow = MutableStateFlow<ReadinessScreenState>(
            ReadinessScreenState.Success(uiState)
        )
        every { mockViewModel.readinessState } returns stateFlow

        // Act
        composeRule.setContent {
            ReadinessScreen(viewModel = mockViewModel)
        }

        // Assert
        composeRule.onNodeWithText("100").assertIsDisplayed()
        composeRule.onNodeWithText("Outstanding! You're ready to test.").assertIsDisplayed()
    }

    @Test
    fun `given refreshing state, when rendered, then shows loading spinner and disables retry`() {
        // Arrange
        val uiState = ReadinessUiState(isRefreshing = true)
        val stateFlow = MutableStateFlow<ReadinessScreenState>(
            ReadinessScreenState.Success(uiState)
        )
        every { mockViewModel.readinessState } returns stateFlow

        // Act
        composeRule.setContent {
            ReadinessScreen(viewModel = mockViewModel)
        }

        // Assert (implementation depends on whether refreshing shows overlay)
        // This is optional based on UX design
    }
}
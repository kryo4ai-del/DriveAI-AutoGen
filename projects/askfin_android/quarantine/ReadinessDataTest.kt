// test/data/models/ReadinessDataTest.kt
package com.driveai.askfin.data.models

import org.junit.jupiter.api.Test
import org.junit.jupiter.api.assertThrows
import org.junit.jupiter.api.assertEquals
import java.time.LocalDateTime

data class ReadinessMilestoneModel(
    val name: String,
    val threshold: Float,
    val achieved: Boolean,
    val achievedAt: LocalDateTime? = null
)

enum class ReadinessTrendModel {
    STABLE, IMPROVING, DECLINING
}

data class ReadinessDataModel(
    val overallScore: Float,
    val milestones: List<ReadinessMilestoneModel>,
    val trend: ReadinessTrendModel,
    val lastUpdated: LocalDateTime
) {
    init {
        require(overallScore in 0f..100f) { "Overall score must be between 0 and 100" }
    }
}

class ReadinessDataTest {

    private val now = LocalDateTime.now()
    private val baseMilestone = ReadinessMilestoneModel(
        name = "Basics",
        threshold = 25f,
        achieved = false
    )

    @Test
    fun `overall score in valid range 0-100 succeeds`() {
        val data = ReadinessDataModel(
            overallScore = 50f,
            milestones = listOf(baseMilestone),
            trend = ReadinessTrendModel.STABLE,
            lastUpdated = now
        )
        assertEquals(50f, data.overallScore)
    }

    @Test
    fun `overall score 0 at lower bound succeeds`() {
        val data = ReadinessDataModel(
            overallScore = 0f,
            milestones = listOf(baseMilestone),
            trend = ReadinessTrendModel.STABLE,
            lastUpdated = now
        )
        assertEquals(0f, data.overallScore)
    }

    @Test
    fun `overall score 100 at upper bound succeeds`() {
        val data = ReadinessDataModel(
            overallScore = 100f,
            milestones = listOf(baseMilestone),
            trend = ReadinessTrendModel.STABLE,
            lastUpdated = now
        )
        assertEquals(100f, data.overallScore)
    }

    @Test
    fun `overall score exceeds 100 throws IllegalArgumentException`() {
        assertThrows<IllegalArgumentException> {
            ReadinessDataModel(
                overallScore = 100.1f,
                milestones = listOf(baseMilestone),
                trend = ReadinessTrendModel.STABLE,
                lastUpdated = now
            )
        }
    }

    @Test
    fun `overall score below 0 throws IllegalArgumentException`() {
        assertThrows<IllegalArgumentException> {
            ReadinessDataModel(
                overallScore = -0.1f,
                milestones = listOf(baseMilestone),
                trend = ReadinessTrendModel.STABLE,
                lastUpdated = now
            )
        }
    }

    @Test
    fun `empty milestones list is allowed`() {
        val data = ReadinessDataModel(
            overallScore = 50f,
            milestones = emptyList(),
            trend = ReadinessTrendModel.STABLE,
            lastUpdated = now
        )
        assertEquals(0, data.milestones.size)
    }

    @Test
    fun `multiple milestones preserved in order`() {
        val m1 = ReadinessMilestoneModel("M1", 25f, false)
        val m2 = ReadinessMilestoneModel("M2", 50f, false)
        val m3 = ReadinessMilestoneModel("M3", 75f, false)
        
        val data = ReadinessDataModel(
            overallScore = 50f,
            milestones = listOf(m1, m2, m3),
            trend = ReadinessTrendModel.STABLE,
            lastUpdated = now
        )
        
        assertEquals(3, data.milestones.size)
        assertEquals("M1", data.milestones[0].name)
        assertEquals("M3", data.milestones[2].name)
    }
}
// test/data/models/ReadinessDataTest.kt
package com.driveai.askfin.data.models

import org.junit.jupiter.api.Test
import org.junit.jupiter.api.assertThrows
import java.time.LocalDateTime
import kotlin.test.assertEquals

class ReadinessDataTest {

    private val now = LocalDateTime.now()
    private val baseMilestone = ReadinessMilestone(
        name = "Basics",
        threshold = 25f,
        achieved = false
    )

    @Test
    fun `overall score in valid range 0-100 succeeds`() {
        val data = ReadinessData(
            overallScore = 50f,
            milestones = listOf(baseMilestone),
            trend = ReadinessTrend.STABLE,
            lastUpdated = now
        )
        assertEquals(50f, data.overallScore)
    }

    @Test
    fun `overall score 0 at lower bound succeeds`() {
        val data = ReadinessData(
            overallScore = 0f,
            milestones = listOf(baseMilestone),
            trend = ReadinessTrend.STABLE,
            lastUpdated = now
        )
        assertEquals(0f, data.overallScore)
    }

    @Test
    fun `overall score 100 at upper bound succeeds`() {
        val data = ReadinessData(
            overallScore = 100f,
            milestones = listOf(baseMilestone),
            trend = ReadinessTrend.STABLE,
            lastUpdated = now
        )
        assertEquals(100f, data.overallScore)
    }

    @Test
    fun `overall score exceeds 100 throws IllegalArgumentException`() {
        assertThrows<IllegalArgumentException> {
            ReadinessData(
                overallScore = 100.1f,
                milestones = listOf(baseMilestone),
                trend = ReadinessTrend.STABLE,
                lastUpdated = now
            )
        }
    }

    @Test
    fun `overall score below 0 throws IllegalArgumentException`() {
        assertThrows<IllegalArgumentException> {
            ReadinessData(
                overallScore = -0.1f,
                milestones = listOf(baseMilestone),
                trend = ReadinessTrend.STABLE,
                lastUpdated = now
            )
        }
    }

    @Test
    fun `empty milestones list is allowed`() {
        val data = ReadinessData(
            overallScore = 50f,
            milestones = emptyList(),
            trend = ReadinessTrend.STABLE,
            lastUpdated = now
        )
        assertEquals(0, data.milestones.size)
    }

    @Test
    fun `multiple milestones preserved in order`() {
        val m1 = ReadinessMilestone("M1", 25f, false)
        val m2 = ReadinessMilestone("M2", 50f, false)
        val m3 = ReadinessMilestone("M3", 75f, false)
        
        val data = ReadinessData(
            overallScore = 50f,
            milestones = listOf(m1, m2, m3),
            trend = ReadinessTrend.STABLE,
            lastUpdated = now
        )
        
        assertEquals(3, data.milestones.size)
        assertEquals("M1", data.milestones[0].name)
        assertEquals("M3", data.milestones[2].name)
    }
}
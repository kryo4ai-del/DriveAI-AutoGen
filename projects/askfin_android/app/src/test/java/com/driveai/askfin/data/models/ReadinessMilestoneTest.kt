// test/data/models/ReadinessMilestoneTest.kt
package com.driveai.askfin.data.models

import org.junit.jupiter.api.Test
import org.junit.jupiter.api.assertThrows
import java.time.LocalDateTime
import kotlin.test.assertEquals
import kotlin.test.assertNull

class ReadinessMilestoneTest {

    private val now = LocalDateTime.now()

    // ============ Happy Path ============

    @Test
    fun `unachieved milestone without timestamp succeeds`() {
        val m = ReadinessMilestone(
            name = "Basics",
            threshold = 25f,
            achieved = false,
            achievedAt = null
        )
        assertEquals("Basics", m.name)
        assertEquals(false, m.achieved)
        assertNull(m.achievedAt)
    }

    @Test
    fun `achieved milestone with timestamp succeeds`() {
        val m = ReadinessMilestone(
            name = "Basics",
            threshold = 25f,
            achieved = true,
            achievedAt = now
        )
        assertEquals(true, m.achieved)
        assertEquals(now, m.achievedAt)
    }

    @Test
    fun `default achievedAt null works`() {
        val m = ReadinessMilestone(
            name = "Test",
            threshold = 50f,
            achieved = false
        )
        assertNull(m.achievedAt)
    }

    // ============ Bidirectional Validation ============

    @Test
    fun `achieved=true without timestamp throws IllegalArgumentException`() {
        assertThrows<IllegalArgumentException> {
            ReadinessMilestone(
                name = "Basics",
                threshold = 25f,
                achieved = true,
                achievedAt = null  // ❌ Invalid: achieved but no timestamp
            )
        }
    }

    @Test
    fun `achieved=false with timestamp throws IllegalArgumentException`() {
        assertThrows<IllegalArgumentException> {
            ReadinessMilestone(
                name = "Basics",
                threshold = 25f,
                achieved = false,
                achievedAt = now  // ❌ Invalid: not achieved but has timestamp
            )
        }
    }

    // ============ Name Validation ============

    @Test
    fun `empty name throws IllegalArgumentException`() {
        assertThrows<IllegalArgumentException> {
            ReadinessMilestone(
                name = "",
                threshold = 25f,
                achieved = false
            )
        }
    }

    @Test
    fun `whitespace-only name throws IllegalArgumentException`() {
        assertThrows<IllegalArgumentException> {
            ReadinessMilestone(
                name = "   ",
                threshold = 25f,
                achieved = false
            )
        }
    }

    @Test
    fun `valid name with special characters succeeds`() {
        val m = ReadinessMilestone(
            name = "Road Signs & Signals",
            threshold = 50f,
            achieved = false
        )
        assertEquals("Road Signs & Signals", m.name)
    }

    // ============ Threshold Validation ============

    @Test
    fun `threshold 0 at lower bound succeeds`() {
        val m = ReadinessMilestone(
            name = "Test",
            threshold = 0f,
            achieved = false
        )
        assertEquals(0f, m.threshold)
    }

    @Test
    fun `threshold 100 at upper bound succeeds`() {
        val m = ReadinessMilestone(
            name = "Test",
            threshold = 100f,
            achieved = false
        )
        assertEquals(100f, m.threshold)
    }

    @Test
    fun `threshold exceeds 100 throws IllegalArgumentException`() {
        assertThrows<IllegalArgumentException> {
            ReadinessMilestone(
                name = "Test",
                threshold = 100.1f,
                achieved = false
            )
        }
    }

    @Test
    fun `threshold below 0 throws IllegalArgumentException`() {
        assertThrows<IllegalArgumentException> {
            ReadinessMilestone(
                name = "Test",
                threshold = -0.1f,
                achieved = false
            )
        }
    }

    // ============ Edge Cases ============

    @Test
    fun `very long name succeeds`() {
        val longName = "A".repeat(500)
        val m = ReadinessMilestone(
            name = longName,
            threshold = 50f,
            achieved = false
        )
        assertEquals(500, m.name.length)
    }

    @Test
    fun `timestamp far in future succeeds`() {
        val future = LocalDateTime.now().plusYears(10)
        val m = ReadinessMilestone(
            name = "Future",
            threshold = 50f,
            achieved = true,
            achievedAt = future
        )
        assertEquals(future, m.achievedAt)
    }

    @Test
    fun `timestamp far in past succeeds`() {
        val past = LocalDateTime.now().minusYears(10)
        val m = ReadinessMilestone(
            name = "Past",
            threshold = 50f,
            achieved = true,
            achievedAt = past
        )
        assertEquals(past, m.achievedAt)
    }
}
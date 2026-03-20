// File: src/test/kotlin/com/driveai/askfin/data/models/DifficultyTest.kt
package com.driveai.askfin.data.models

import org.junit.jupiter.api.DisplayName
import org.junit.jupiter.api.Test
import kotlin.test.assertEquals
import kotlin.test.assertFailsWith

@DisplayName("Difficulty Enum Tests")
class DifficultyTest {
    
    @Test
    @DisplayName("TC-DF-001: EASY difficulty exists")
    fun testEasyDifficultyExists() {
        assertEquals(Difficulty.EASY, Difficulty.valueOf("EASY"))
    }
    
    @Test
    @DisplayName("TC-DF-002: MEDIUM difficulty exists")
    fun testMediumDifficultyExists() {
        assertEquals(Difficulty.MEDIUM, Difficulty.valueOf("MEDIUM"))
    }
    
    @Test
    @DisplayName("TC-DF-003: HARD difficulty exists")
    fun testHardDifficultyExists() {
        assertEquals(Difficulty.HARD, Difficulty.valueOf("HARD"))
    }
    
    @Test
    @DisplayName("TC-DF-004: All three difficulties are present")
    fun testAllThreeDifficultiesPresent() {
        val difficulties = Difficulty.values()
        assertEquals(3, difficulties.size)
    }
    
    @Test
    @DisplayName("TC-DF-005: Difficulties are ordered (EASY to HARD)")
    fun testDifficultiesOrdered() {
        val difficulties = Difficulty.values()
        assertEquals(
            listOf("EASY", "MEDIUM", "HARD"),
            difficulties.map { it.name }
        )
    }
    
    @Test
    @DisplayName("TC-DF-006: Invalid difficulty name throws exception")
    fun testInvalidDifficultyThrowsException() {
        assertFailsWith<IllegalArgumentException> {
            Difficulty.valueOf("EXTREME")
        }
    }
}

enum class Difficulty {
    EASY,
    MEDIUM,
    HARD
}
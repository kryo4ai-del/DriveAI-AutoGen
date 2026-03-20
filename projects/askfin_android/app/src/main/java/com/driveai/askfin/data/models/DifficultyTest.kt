// File: src/test/kotlin/com/driveai/askfin/data/models/DifficultyTest.kt
package com.driveai.askfin.data.models

import org.junit.jupiter.api.DisplayName
import org.junit.jupiter.api.Test
import kotlin.test.assertEquals

@DisplayName("Difficulty Enum Tests")
class DifficultyTest {
    
    @Test
    fun `TC-DF-001: EASY difficulty exists`() {
        assertEquals(Difficulty.EASY, Difficulty.valueOf("EASY"))
    }
    
    @Test
    fun `TC-DF-002: MEDIUM difficulty exists`() {
        assertEquals(Difficulty.MEDIUM, Difficulty.valueOf("MEDIUM"))
    }
    
    @Test
    fun `TC-DF-003: HARD difficulty exists`() {
        assertEquals(Difficulty.HARD, Difficulty.valueOf("HARD"))
    }
    
    @Test
    fun `TC-DF-004: All three difficulties are present`() {
        val difficulties = Difficulty.values()
        assertEquals(3, difficulties.size)
    }
    
    @Test
    fun `TC-DF-005: Difficulties are ordered (EASY to HARD)`() {
        val difficulties = Difficulty.values()
        assertEquals(
            listOf("EASY", "MEDIUM", "HARD"),
            difficulties.map { it.name }
        )
    }
    
    @Test
    fun `TC-DF-006: Invalid difficulty name throws exception`() {
        kotlin.test.assertFailsWith<IllegalArgumentException> {
            Difficulty.valueOf("EXTREME")
        }
    }
}
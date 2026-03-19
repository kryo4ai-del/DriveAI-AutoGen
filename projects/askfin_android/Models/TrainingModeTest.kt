// File: src/test/kotlin/com/driveai/askfin/data/models/TrainingModeTest.kt
package com.driveai.askfin.data.models

import org.junit.jupiter.api.DisplayName
import org.junit.jupiter.api.Test
import org.junit.jupiter.api.Nested
import kotlin.test.assertEquals
import kotlin.test.assertNotNull

@DisplayName("TrainingMode Enum Tests")
class TrainingModeTest {
    
    @Nested
    @DisplayName("Enum Values")
    inner class EnumValues {
        @Test
        fun `TC-TM-001: All four modes are defined`() {
            val modes = TrainingMode.values()
            assertEquals(4, modes.size)
            assertEquals(setOf("LEARNER", "PRACTICE", "EXAM", "REVIEW"), 
                modes.map { it.name }.toSet())
        }
        
        @Test
        fun `TC-TM-002: LEARNER mode exists`() {
            assertNotNull(TrainingMode.LEARNER)
        }
        
        @Test
        fun `TC-TM-003: PRACTICE mode exists`() {
            assertNotNull(TrainingMode.PRACTICE)
        }
        
        @Test
        fun `TC-TM-004: EXAM mode exists`() {
            assertNotNull(TrainingMode.EXAM)
        }
        
        @Test
        fun `TC-TM-005: REVIEW mode exists`() {
            assertNotNull(TrainingMode.REVIEW)
        }
    }
    
    @Nested
    @DisplayName("Enum Conversion")
    inner class EnumConversion {
        @Test
        fun `TC-TM-006: valueOf() returns correct mode for LEARNER`() {
            val mode = TrainingMode.valueOf("LEARNER")
            assertEquals(TrainingMode.LEARNER, mode)
        }
        
        @Test
        fun `TC-TM-007: valueOf() returns correct mode for PRACTICE`() {
            val mode = TrainingMode.valueOf("PRACTICE")
            assertEquals(TrainingMode.PRACTICE, mode)
        }
        
        @Test
        fun `TC-TM-008: valueOf() returns correct mode for EXAM`() {
            val mode = TrainingMode.valueOf("EXAM")
            assertEquals(TrainingMode.EXAM, mode)
        }
        
        @Test
        fun `TC-TM-009: valueOf() returns correct mode for REVIEW`() {
            val mode = TrainingMode.valueOf("REVIEW")
            assertEquals(TrainingMode.REVIEW, mode)
        }
        
        @Test
        fun `TC-TM-010: valueOf() throws exception for invalid mode`() {
            kotlin.test.assertFailsWith<IllegalArgumentException> {
                TrainingMode.valueOf("INVALID_MODE")
            }
        }
    }
}
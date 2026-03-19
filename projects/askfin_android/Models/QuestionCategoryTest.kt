// File: src/test/kotlin/com/driveai/askfin/data/models/QuestionCategoryTest.kt
package com.driveai.askfin.data.models

import org.junit.jupiter.api.DisplayName
import org.junit.jupiter.api.Test
import org.junit.jupiter.api.Nested
import kotlin.test.assertEquals

@DisplayName("QuestionCategory Enum Tests")
class QuestionCategoryTest {
    
    @Nested
    @DisplayName("All Categories Defined")
    inner class AllCategoriesDefined {
        @Test
        fun `TC-QC-001: All 10 categories are present`() {
            val categories = QuestionCategory.values()
            assertEquals(10, categories.size)
        }
        
        @Test
        fun `TC-QC-002: ROAD_SIGNS category exists`() {
            assertEquals(QuestionCategory.ROAD_SIGNS, 
                QuestionCategory.valueOf("ROAD_SIGNS"))
        }
        
        @Test
        fun `TC-QC-003: TRAFFIC_RULES category exists`() {
            assertEquals(QuestionCategory.TRAFFIC_RULES, 
                QuestionCategory.valueOf("TRAFFIC_RULES"))
        }
        
        @Test
        fun `TC-QC-004: EMERGENCY_PROCEDURES category exists`() {
            assertEquals(QuestionCategory.EMERGENCY_PROCEDURES, 
                QuestionCategory.valueOf("EMERGENCY_PROCEDURES"))
        }
        
        @Test
        fun `TC-QC-005: PEDESTRIAN_INTERACTION category exists`() {
            assertEquals(QuestionCategory.PEDESTRIAN_INTERACTION, 
                QuestionCategory.valueOf("PEDESTRIAN_INTERACTION"))
        }
    }
    
    @Nested
    @DisplayName("Category Filtering")
    inner class CategoryFiltering {
        @Test
        fun `TC-QC-006: Can filter categories by name`() {
            val safetyCategories = listOf(
                QuestionCategory.ROAD_SAFETY,
                QuestionCategory.HAZARD_PERCEPTION,
                QuestionCategory.EMERGENCY_PROCEDURES
            )
            assertEquals(3, safetyCategories.size)
        }
        
        @Test
        fun `TC-QC-007: Categories are unique`() {
            val allCategories = QuestionCategory.values().toList()
            assertEquals(allCategories.size, allCategories.distinct().size)
        }
        
        @Test
        fun `TC-QC-008: Invalid category name throws exception`() {
            kotlin.test.assertFailsWith<IllegalArgumentException> {
                QuestionCategory.valueOf("INVALID_CATEGORY")
            }
        }
    }
}
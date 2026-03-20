package com.driveai.askfin.data.models

data class CategoriesSection(
    val title: String,  // "Strong Areas", "Areas to Improve", etc.
    val categories: List<Category>,
    val a11yDescription: String,  // "5 categories where you scored 70% or higher"
)

    val categoriesGrouped: List<CategoriesSection> = emptyList(),  // NEW: pre-grouped for a11y
    val categories: List<Category> = emptyList(),  // Keep for backward compat
    val error: ErrorState? = null,
    val sortBy: SortOption = SortOption.COMPETENCE_ASC,
    val filterBy: FilterOption = FilterOption.ALL,
    val lastRefresh: Long = 0L,
    val lastAction: UserAction? = null,
)
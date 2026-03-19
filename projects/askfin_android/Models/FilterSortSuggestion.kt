data class FilterSortSuggestion(
    val recommendedSort: SortOption,        // Primary: "Lowest Score First"
    val recommendedFilter: FilterOption,    // Primary: "Ready to Level Up" (WEAK)
    val reasoning: String,                  // "Focus on your weakest areas first"
    val alternativeSort: List<SortOption>,  // [NAME_ASC, COMPETENCE_DESC]
    val alternativeFilter: List<FilterOption>, // [ALL, STRONG]
)

    val filterSortSuggestion: FilterSortSuggestion? = null,  // NEW: reduce choice paralysis
)
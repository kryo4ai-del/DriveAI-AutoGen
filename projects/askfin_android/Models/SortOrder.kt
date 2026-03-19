enum class SortOrder { RECENT, OLDEST, HIGHEST_SCORE }

fun getExamHistory(
    limit: Int = 10,
    offset: Int = 0,
    sortOrder: SortOrder = SortOrder.RECENT
): Flow<Result<List<ExamResult>>> {
    require(limit in 1..100) { "Limit 1-100, got $limit" }
    require(offset >= 0) { "Offset non-negative, got $offset" }
}
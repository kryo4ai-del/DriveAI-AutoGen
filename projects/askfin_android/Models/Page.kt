
// Add model
data class Page<T>(
    val items: List<T>,
    val pageIndex: Int,
    val totalCount: Int,
    val hasMore: Boolean
)
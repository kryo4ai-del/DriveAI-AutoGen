package com.driveai.askfin.data.models

data class PaginationParams(
    val limit: Int = 20,
    val offset: Int = 0
) {
    init {
        require(limit > 0) { "Limit must be positive" }
        require(offset >= 0) { "Offset cannot be negative" }
    }
}
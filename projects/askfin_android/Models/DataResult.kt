// File: com.driveai.askfin/data/models/Result.kt
package com.driveai.askfin.data.models

sealed class DataResult<out T> {
    data class Success<T>(val data: T) : DataResult<T>()
    data class Failure(val exception: Exception) : DataResult<Nothing>()
    object Loading : DataResult<Nothing>()
    
    inline fun <R> fold(
        onSuccess: (T) -> R,
        onFailure: (Exception) -> R
    ): R = when (this) {
        is Success -> onSuccess(data)
        is Failure -> onFailure(exception)
        Loading -> throw IllegalStateException("Cannot fold Loading state")
    }
    
    inline fun <R> map(transform: (T) -> R): DataResult<R> = when (this) {
        is Success -> Success(transform(data))
        is Failure -> this
        Loading -> Loading
    }
}

// Helper extension for data model validation
inline fun <T> validateData(block: () -> T): DataResult<T> = try {
    DataResult.Success(block())
} catch (e: IllegalArgumentException) {
    DataResult.Failure(e)
} catch (e: Exception) {
    DataResult.Failure(e)
}
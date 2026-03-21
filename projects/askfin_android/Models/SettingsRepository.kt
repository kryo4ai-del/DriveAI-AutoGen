package com.driveai.askfin.domain.repository

import kotlinx.coroutines.flow.Flow

interface SettingsRepository {
    fun getDarkModeEnabled(): Flow<Boolean>
    suspend fun setDarkModeEnabled(enabled: Boolean)

    fun getNotificationsEnabled(): Flow<Boolean>
    suspend fun setNotificationsEnabled(enabled: Boolean)

    suspend fun getAppVersion(): String
    suspend fun clearUserProgress()
}
package com.driveai.breathflow.domain

import androidx.datastore.core.DataStore
import androidx.datastore.preferences.core.Preferences
import androidx.datastore.preferences.core.edit
import androidx.datastore.preferences.core.intPreferencesKey
import androidx.datastore.preferences.core.longPreferencesKey
import kotlinx.coroutines.flow.Flow
import kotlinx.coroutines.flow.map
import javax.inject.Inject
import javax.inject.Singleton

@Singleton
class StatsService @Inject constructor(
    private val dataStore: DataStore<Preferences>
) {
    companion object {
        private val WEEKLY_MINUTES_KEY = intPreferencesKey("weekly_minutes")
        private val SESSION_COUNT_KEY = intPreferencesKey("session_count")
        private val LAST_RESET_KEY = longPreferencesKey("last_reset_timestamp")
    }

    val weeklyMinutesFlow: Flow<Int> = dataStore.data.map { prefs ->
        prefs[WEEKLY_MINUTES_KEY] ?: 0
    }

    val sessionCountFlow: Flow<Int> = dataStore.data.map { prefs ->
        prefs[SESSION_COUNT_KEY] ?: 0
    }

    suspend fun addSessionMinutes(minutes: Int) {
        dataStore.edit { prefs ->
            val current = prefs[WEEKLY_MINUTES_KEY] ?: 0
            prefs[WEEKLY_MINUTES_KEY] = current + minutes

            val sessions = prefs[SESSION_COUNT_KEY] ?: 0
            prefs[SESSION_COUNT_KEY] = sessions + 1

            // Auto-reset weekly stats if 7 days have passed
            val lastReset = prefs[LAST_RESET_KEY] ?: System.currentTimeMillis()
            val weekAgoMs = System.currentTimeMillis() - (7 * 24 * 60 * 60 * 1000)
            if (lastReset < weekAgoMs) {
                prefs[WEEKLY_MINUTES_KEY] = minutes
                prefs[SESSION_COUNT_KEY] = 1
                prefs[LAST_RESET_KEY] = System.currentTimeMillis()
            }
        }
    }

    suspend fun resetWeeklyStats() {
        dataStore.edit { prefs ->
            prefs[WEEKLY_MINUTES_KEY] = 0
            prefs[SESSION_COUNT_KEY] = 0
            prefs[LAST_RESET_KEY] = System.currentTimeMillis()
        }
    }
}
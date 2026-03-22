package com.driveai.breathflow.data.local

import androidx.room.Dao
import androidx.room.Insert
import androidx.room.Query
import kotlinx.coroutines.flow.Flow

@Dao
interface SessionDao {
    @Insert
    suspend fun insertSession(session: SessionEntity)

    @Query("SELECT * FROM sessions ORDER BY timestamp DESC LIMIT 50")
    fun getAllSessions(): Flow<List<SessionEntity>>

    @Query("""
        SELECT COALESCE(SUM(durationSeconds), 0) as totalSeconds FROM sessions
        WHERE timestamp >= :weekAgoMs
    """)
    fun getWeeklySeconds(weekAgoMs: Long): Flow<Long>

    @Query("SELECT COUNT(*) FROM sessions WHERE timestamp >= :weekAgoMs")
    fun getSessionCountThisWeek(weekAgoMs: Long): Flow<Int>
}
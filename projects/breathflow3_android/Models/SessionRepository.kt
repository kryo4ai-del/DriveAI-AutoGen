package com.driveai.breathflow.data.repository

import com.driveai.breathflow.data.local.SessionDao
import com.driveai.breathflow.data.local.SessionEntity
import com.driveai.breathflow.data.models.SessionRecord
import kotlinx.coroutines.flow.Flow
import kotlinx.coroutines.flow.map
import javax.inject.Inject
import javax.inject.Singleton

interface ISessionRepository {
    suspend fun saveSession(record: SessionRecord)
    fun getWeeklyMinutes(): Flow<Int>
    fun getSessionCountThisWeek(): Flow<Int>
    fun getAllSessions(): Flow<List<SessionRecord>>
}

@Singleton
class SessionRepository @Inject constructor(
    private val sessionDao: SessionDao
) : ISessionRepository {

    override suspend fun saveSession(record: SessionRecord) {
        val entity = SessionEntity(
            technique = record.technique,
            durationSeconds = record.durationSeconds,
            cyclesCompleted = record.cyclesCompleted,
            timestamp = record.timestamp,
            notes = record.notes
        )
        sessionDao.insertSession(entity)
    }

    override fun getWeeklyMinutes(): Flow<Int> {
        val weekAgoMs = System.currentTimeMillis() - (7 * 24 * 60 * 60 * 1000)
        return sessionDao.getWeeklySeconds(weekAgoMs).map { seconds ->
            (seconds / 60).toInt()
        }
    }

    override fun getSessionCountThisWeek(): Flow<Int> {
        val weekAgoMs = System.currentTimeMillis() - (7 * 24 * 60 * 60 * 1000)
        return sessionDao.getSessionCountThisWeek(weekAgoMs)
    }

    override fun getAllSessions(): Flow<List<SessionRecord>> {
        return sessionDao.getAllSessions().map { entities ->
            entities.map { entity ->
                SessionRecord(
                    id = entity.id.toString(),
                    technique = entity.technique,
                    durationSeconds = entity.durationSeconds,
                    cyclesCompleted = entity.cyclesCompleted,
                    timestamp = entity.timestamp,
                    notes = entity.notes
                )
            }
        }
    }
}
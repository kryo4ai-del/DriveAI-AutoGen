package com.driveai.askfin.data.local
import androidx.room.Dao
import androidx.room.Query
import java.time.Instant

@Dao
   interface UserAnswerDao {
       @Query("DELETE FROM user_answers WHERE timestamp < :cutoffDate AND userId = :userId")
       suspend fun deleteOldAnswers(userId: String, cutoffDate: Instant): Int
       
       @Query("UPDATE user_answers SET userId = NULL WHERE timestamp < :anonymizeCutoff")
       suspend fun anonymizeOldAnswers(anonymizeCutoff: Instant): Int
   }
   
   // ViewModel triggers deletion on schedule (e.g., nightly)
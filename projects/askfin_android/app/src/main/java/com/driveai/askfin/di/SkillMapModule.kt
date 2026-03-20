package com.driveai.askfin.di

import android.content.Context
import androidx.room.Database
import androidx.room.Room
import androidx.room.RoomDatabase
import dagger.Module
import dagger.Provides
import dagger.hilt.InstallIn
import dagger.hilt.android.qualifiers.ApplicationContext
import dagger.hilt.components.SingletonComponent
import com.driveai.askfin.data.local.SkillMapDao
import com.driveai.askfin.data.repository.SkillMapRepository
import com.driveai.askfin.domain.GetSkillsUseCase
import javax.inject.Singleton

// Placeholder for SkillMapDatabase
abstract class SkillMapDatabase : RoomDatabase() {
    abstract fun skillMapDao(): SkillMapDao
}

// Placeholder for SkillMapRepositoryImpl
class SkillMapRepositoryImpl(private val dao: SkillMapDao) : SkillMapRepository

@Module
@InstallIn(SingletonComponent::class)
object SkillMapModule {

    @Provides
    @Singleton
    fun provideSkillMapDatabase(
        @ApplicationContext context: Context
    ): SkillMapDatabase {
        return Room.databaseBuilder(
            context,
            SkillMapDatabase::class.java,
            "skillmap_db"
        ).build()
    }

    @Provides
    @Singleton
    fun provideSkillMapDao(database: SkillMapDatabase): SkillMapDao {
        return database.skillMapDao()
    }

    @Provides
    @Singleton
    fun provideSkillMapRepository(dao: SkillMapDao): SkillMapRepository {
        return SkillMapRepositoryImpl(dao)
    }

    @Provides
    @Singleton
    fun provideGetSkillsUseCase(repository: SkillMapRepository): GetSkillsUseCase {
        return GetSkillsUseCase(repository)
    }
}
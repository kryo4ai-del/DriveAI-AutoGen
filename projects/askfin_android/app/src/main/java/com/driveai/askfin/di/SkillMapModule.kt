package com.driveai.askfin.di

import android.content.Context
import androidx.room.Room
import dagger.Module
import dagger.Provides
import dagger.hilt.InstallIn
import dagger.hilt.android.qualifiers.ApplicationContext
import dagger.hilt.components.SingletonComponent
import com.driveai.skillmap.data.local.SkillMapDatabase
import com.driveai.skillmap.data.local.SkillMapDao
import com.driveai.skillmap.data.repository.SkillMapRepository
import com.driveai.skillmap.data.repository.SkillMapRepositoryImpl
import com.driveai.skillmap.domain.GetSkillsUseCase
import javax.inject.Singleton

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
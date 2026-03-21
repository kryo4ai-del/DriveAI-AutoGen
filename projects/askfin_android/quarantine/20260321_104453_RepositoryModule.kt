package com.driveai.askfin.di

import com.driveai.askfin.data.local.ReadinessDao
import com.driveai.askfin.data.repository.ReadinessRepository
import com.driveai.askfin.data.repository.ReadinessRepositoryImpl
import dagger.Module
import dagger.Provides
import dagger.hilt.InstallIn
import dagger.hilt.components.SingletonComponent
import javax.inject.Singleton

@Module
@InstallIn(SingletonComponent::class)
object RepositoryModule {

    @Provides
    @Singleton
    fun provideReadinessRepository(
        readinessDao: ReadinessDao
    ): ReadinessRepository = ReadinessRepositoryImpl(readinessDao)
}
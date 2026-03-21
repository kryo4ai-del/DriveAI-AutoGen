package com.driveai.askfin.di
import dagger.Module
import dagger.hilt.InstallIn
import dagger.hilt.components.SingletonComponent
import javax.inject.Singleton

@Module
@InstallIn(SingletonComponent::class)
abstract class SkillMapRepositoryModule {
    @Binds
    @Singleton
    abstract fun bindRepository(
        impl: SkillMapRepositoryImpl
    ): SkillMapRepository
}
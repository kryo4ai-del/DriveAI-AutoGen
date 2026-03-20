package com.driveai.askfin.di

@Module
@InstallIn(SingletonComponent::class)
abstract class SkillMapRepositoryModule {
    @Binds
    @Singleton
    abstract fun bindRepository(
        impl: SkillMapRepositoryImpl
    ): SkillMapRepository
}
package com.driveai.askfin.di

import android.content.Context
import com.driveai.askfin.ui.utils.HapticFeedback
import dagger.Module
import dagger.Provides
import dagger.hilt.InstallIn
import dagger.hilt.android.qualifiers.ApplicationContext
import dagger.hilt.components.SingletonComponent
import javax.inject.Singleton

@Module
@InstallIn(SingletonComponent::class)
object HapticModule {
    @Singleton
    @Provides
    fun provideHapticFeedback(
        @ApplicationContext context: Context
    ): HapticFeedback = HapticFeedback(context)
}
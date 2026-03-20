package com.driveai.askfin.data.models

import android.content.Context
import android.os.Build
import android.os.VibrationEffect
import android.os.Vibrator
import android.os.VibratorManager
import androidx.core.content.ContextCompat
import dagger.hilt.android.qualifiers.ApplicationContext
import javax.inject.Inject
import javax.inject.Singleton

@Singleton
class HapticFeedback @Inject constructor(
    @ApplicationContext private val context: Context
) {
    private val vibrator: Vibrator? = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
        val vibratorManager = 
            context.getSystemService(Context.VIBRATOR_MANAGER_SERVICE) as VibratorManager
        vibratorManager.defaultVibrator
    } else {
        @Suppress("DEPRECATION")
        ContextCompat.getSystemService(context, Vibrator::class.java)
    }

    fun feedback(type: HapticType) {
        if (vibrator?.hasVibrator() != true) return
        
        val effect = when (type) {
            HapticType.CORRECT -> VibrationEffect.createPredefined(VibrationEffect.EFFECT_TICK)
            HapticType.INCORRECT -> VibrationEffect.createPredefined(VibrationEffect.EFFECT_DOUBLE_CLICK)
            HapticType.SELECTION -> VibrationEffect.createPredefined(VibrationEffect.EFFECT_CLICK)
        }
        
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
            vibrator?.vibrate(effect)
        }
    }

    enum class HapticType {
        CORRECT, INCORRECT, SELECTION
    }
}
package com.driveai.askfin.ui.viewmodels
import dagger.hilt.android.lifecycle.HiltViewModel
import javax.inject.Inject
import androidx.lifecycle.ViewModel

@HiltViewModel
class ReadinessScoreViewModel @Inject constructor(
    private val readinessRepository: ReadinessRepository
) : ViewModel() {
    // No retry logic, no error recovery
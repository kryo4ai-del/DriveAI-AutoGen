'use client';

import React from 'react';
import { BreathingTechniqueType, BREATHING_TECHNIQUES } from '@/types/BreathingTechnique';
import { ExerciseCard } from './ExerciseCard';
import { BreathingCircle } from './BreathingCircle';

interface ExerciseSelectionProps {
  selectedTechnique: BreathingTechniqueType | null;
  isActive: boolean;
  currentPhase: 'inhale' | 'hold' | 'exhale' | 'idle';
  progress: number;
  timeRemaining: number;
  elapsedTime: number;
  sessionDuration: number;
  onSelectTechnique: (techniqueId: BreathingTechniqueType) => void;
  onStartSession: () => void;
  onPauseSession: () => void;
  onResumeSession: () => void;
  onEndSession: () => void;
}

export function ExerciseSelection({
  selectedTechnique,
  isActive,
  currentPhase,
  progress,
  timeRemaining,
  elapsedTime,
  sessionDuration,
  onSelectTechnique,
  onStartSession,
  onPauseSession,
  onResumeSession,
  onEndSession,
}: ExerciseSelectionProps) {
  // Active breathing session view
  if (isActive && selectedTechnique) {
    return (
      <div className="flex flex-col items-center gap-12 py-8">
        <BreathingCircle
          phase={currentPhase}
          progress={progress}
          timeRemaining={timeRemaining}
        />

        <div className="flex gap-4">
          <button
            onClick={onPauseSession}
            className="px-6 py-3 bg-yellow-500 text-white font-semibold rounded-lg hover:bg-yellow-600 transition"
            aria-label="Pause breathing session"
          >
            Pause
          </button>
          <button
            onClick={onEndSession}
            className="px-6 py-3 bg-red-500 text-white font-semibold rounded-lg hover:bg-red-600 transition"
            aria-label="End breathing session"
          >
            End Session
          </button>
        </div>

        <div className="text-center text-sm text-gray-600">
          {elapsedTime}s / {sessionDuration}s
        </div>
      </div>
    );
  }

  // Technique selection grid
  return (
    <div className="space-y-8 py-8">
      <div>
        <h2 className="text-2xl font-bold text-gray-900 mb-6">Choose Your Exercise</h2>
        <div className="grid grid-cols-1 md:grid-cols-3 gap-4">
          {Object.values(BREATHING_TECHNIQUES).map((technique) => (
            <ExerciseCard
              key={technique.id}
              technique={technique}
              isSelected={selectedTechnique === technique.id}
              onClick={() => onSelectTechnique(technique.id)}
            />
          ))}
        </div>
      </div>

      {selectedTechnique && (
        <div className="flex justify-center">
          <button
            onClick={onStartSession}
            className="px-8 py-4 bg-gradient-to-r from-blue-500 to-blue-600 text-white font-bold text-lg rounded-lg hover:from-blue-600 hover:to-blue-700 shadow-lg transition transform hover:scale-105"
            aria-label={`Start ${BREATHING_TECHNIQUES[selectedTechnique].name} session`}
          >
            Begin Session
          </button>
        </div>
      )}
    </div>
  );
}
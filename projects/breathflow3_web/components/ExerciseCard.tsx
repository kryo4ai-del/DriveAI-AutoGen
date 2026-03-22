'use client';

import React from 'react';
import { BreathingTechnique } from '@/types/BreathingTechnique';

interface ExerciseCardProps {
  technique: BreathingTechnique;
  isSelected: boolean;
  onClick: () => void;
}

export function ExerciseCard({ technique, isSelected, onClick }: ExerciseCardProps) {
  const durationMinutes = Math.floor(technique.duration / 60);

  return (
    <button
      onClick={onClick}
      className={`
        relative p-6 rounded-lg border-2 transition-all duration-300
        ${
          isSelected
            ? 'border-blue-500 bg-blue-50 shadow-lg scale-105'
            : 'border-gray-200 bg-white hover:border-blue-300 hover:shadow-md'
        }
      `}
    >
      {/* Icon */}
      <div className="text-4xl mb-4">{technique.icon}</div>

      {/* Name */}
      <h3 className="text-lg font-semibold text-gray-900 mb-1">{technique.name}</h3>

      {/* Description */}
      <p className="text-sm text-gray-600 mb-3">{technique.description}</p>

      {/* Duration and Emotional Label */}
      <div className="flex items-center justify-between">
        <span className="text-xs font-medium text-gray-500">
          {durationMinutes} min
        </span>
        {technique.emotional && (
          <span className="text-xs px-2 py-1 bg-blue-100 text-blue-700 rounded-full">
            {technique.emotional}
          </span>
        )}
      </div>

      {/* Selection indicator */}
      {isSelected && (
        <div className="absolute top-3 right-3">
          <div className="w-4 h-4 bg-blue-500 rounded-full border-2 border-white shadow-md" />
        </div>
      )}
    </button>
  );
}
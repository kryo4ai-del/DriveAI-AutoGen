// components/ExamSimulation/ExamStartScreen.tsx
'use client';

import React from 'react';
import { DISPLAY_TIME_LIMIT } from './constants';

interface ExamStartScreenProps {
  onStart: () => void;
  isLoading?: boolean;
  totalQuestions?: number;
}

export function ExamStartScreen({
  onStart,
  isLoading = false,
  totalQuestions = 30,
}: ExamStartScreenProps) {
  return (
    <div className="min-h-screen flex items-center justify-center bg-gradient-to-br from-blue-50 to-indigo-100 p-6">
      <div className="bg-white rounded-2xl shadow-xl max-w-md w-full p-8">
        <div className="text-center mb-8">
          <h1 className="text-4xl font-bold text-gray-900 mb-2">
            License Exam
          </h1>
          <p className="text-gray-600">Simulation Mode</p>
        </div>

        <div className="space-y-4 mb-8 bg-gray-50 rounded-lg p-6">
          <div className="flex items-center justify-between">
            <span className="text-gray-700 font-medium">📋 Questions</span>
            <span className="text-2xl font-bold text-indigo-600">
              {totalQuestions}
            </span>
          </div>
          <div className="flex items-center justify-between">
            <span className="text-gray-700 font-medium">⏱️ Time Limit</span>
            <span className="text-2xl font-bold text-indigo-600">
              {DISPLAY_TIME_LIMIT} min
            </span>
          </div>
          <div className="flex items-center justify-between">
            <span className="text-gray-700 font-medium">✅ Passing Score</span>
            <span className="text-2xl font-bold text-green-600">70%</span>
          </div>
        </div>

        <div className="bg-blue-50 border border-blue-200 rounded-lg p-4 mb-8">
          <p className="text-sm text-blue-900">
            <strong>💡 Tip:</strong> Answer all questions carefully. Review
            before submitting.
          </p>
        </div>

        <button
          onClick={onStart}
          disabled={isLoading}
          className="w-full bg-indigo-600 hover:bg-indigo-700 disabled:bg-gray-400 text-white font-bold py-3 px-6 rounded-lg transition duration-200 ease-in-out transform hover:scale-105 disabled:scale-100 disabled:cursor-not-allowed"
          aria-label="Start the exam"
        >
          {isLoading ? 'Starting...' : 'Start Exam'}
        </button>
      </div>
    </div>
  );
}
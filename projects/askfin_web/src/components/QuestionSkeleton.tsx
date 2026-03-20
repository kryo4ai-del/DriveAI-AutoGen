// components/Skeletons/QuestionSkeleton.tsx
'use client';

import React from 'react';

export const QuestionSkeleton: React.FC = () => (
  <div className="space-y-4 p-4 sm:p-6">
    {/* Question text */}
    <div className="h-6 bg-gray-200 rounded-md w-3/4 animate-pulse" />
    
    {/* Options */}
    <div className="space-y-3">
      {Array.from({ length: 4 }).map((_, i) => (
        <div
          key={i}
          className="h-12 bg-gray-200 rounded-lg animate-pulse"
        />
      ))}
    </div>
  </div>
);
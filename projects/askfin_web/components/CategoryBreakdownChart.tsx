// components/ExamSimulation/CategoryBreakdownChart.tsx
'use client';

import React from 'react';
import { CategoryScore } from './types';

interface CategoryBreakdownChartProps {
  categories: CategoryScore[];
}

export function CategoryBreakdownChart({
  categories,
}: CategoryBreakdownChartProps) {
  const sortedCategories = [...categories].sort(
    (a, b) => b.percentage - a.percentage
  );

  const getBarColor = (percentage: number): string => {
    if (percentage >= 80) return 'bg-green-500';
    if (percentage >= 70) return 'bg-yellow-500';
    return 'bg-red-500';
  };

  return (
    <div className="space-y-6">
      {sortedCategories.map((category) => (
        <div key={category.category}>
          <div className="flex justify-between mb-2">
            <h4 className="font-semibold text-gray-800">{category.category}</h4>
            <span className="text-sm font-bold text-gray-700">
              {category.correct}/{category.total} ({category.percentage}%)
            </span>
          </div>
          <div className="w-full bg-gray-200 rounded-full h-4 overflow-hidden">
            <div
              className={`h-4 rounded-full transition-all duration-500 ${getBarColor(
                category.percentage
              )}`}
              style={{ width: `${category.percentage}%` }}
            />
          </div>
        </div>
      ))}
    </div>
  );
}
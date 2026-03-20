'use client';

import React from 'react';
import { TrendBadgeProps, TrendDirection } from './types';

// Arrow icons (SVG instead of Unicode for accessibility + reliability)
const ArrowUp = () => (
  <svg
    className="w-4 h-4"
    fill="none"
    stroke="currentColor"
    viewBox="0 0 24 24"
  >
    <path
      strokeLinecap="round"
      strokeLinejoin="round"
      strokeWidth={2.5}
      d="M7 16V4m0 0L3 8m0 0l4-4m10 0v12m0 0l4-4m0 0l-4 4"
    />
  </svg>
);

const ArrowDown = () => (
  <svg
    className="w-4 h-4"
    fill="none"
    stroke="currentColor"
    viewBox="0 0 24 24"
  >
    <path
      strokeLinecap="round"
      strokeLinejoin="round"
      strokeWidth={2.5}
      d="M17 8v12m0 0l4-4m0 0l-4 4M3 8v12m0 0l-4-4m0 0l4 4"
    />
  </svg>
);

const ArrowRight = () => (
  <svg
    className="w-4 h-4"
    fill="none"
    stroke="currentColor"
    viewBox="0 0 24 24"
  >
    <path
      strokeLinecap="round"
      strokeLinejoin="round"
      strokeWidth={2.5}
      d="M13 7l5 5m0 0l-5 5m5-5H6"
    />
  </svg>
);

interface TrendConfig {
  bg: string;
  border: string;
  text: string;
  icon: React.ReactNode;
  label: string;
}

const trendConfig: Record<TrendDirection, TrendConfig> = {
  up: {
    bg: 'bg-green-50',
    border: 'border-green-200',
    text: 'text-green-700',
    icon: <ArrowUp />,
    label: 'Increased',
  },
  down: {
    bg: 'bg-red-50',
    border: 'border-red-200',
    text: 'text-red-700',
    icon: <ArrowDown />,
    label: 'Decreased',
  },
  stable: {
    bg: 'bg-gray-50',
    border: 'border-gray-200',
    text: 'text-gray-700',
    icon: <ArrowRight />,
    label: 'No change',
  },
};

export function TrendBadge({
  trend,
  percentage,
  label = 'Progress',
}: TrendBadgeProps) {
  const config = trendConfig[trend];

  return (
    <div
      className={`inline-flex items-center gap-2 px-3 py-1.5 rounded-lg border ${config.bg} ${config.border}`}
      role="status"
      aria-label={`${config.label}: ${Math.abs(percentage)}%`}
    >
      <span className={`flex-shrink-0 ${config.text}`}>{config.icon}</span>
      <div className="flex flex-col">
        <span className="text-xs font-medium text-gray-600">{label}</span>
        <span className={`text-sm font-bold ${config.text}`}>
          {Math.abs(percentage)}%
        </span>
      </div>
    </div>
  );
}
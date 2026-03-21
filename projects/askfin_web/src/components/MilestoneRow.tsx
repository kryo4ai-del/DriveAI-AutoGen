'use client';

import React from 'react';
import { MilestoneRowProps, MilestoneState } from './types';

// Check icon
const CheckIcon = () => (
  <svg
    className="w-6 h-6 text-white"
    fill="currentColor"
    viewBox="0 0 20 20"
  >
    <path
      fillRule="evenodd"
      d="M16.707 5.293a1 1 0 010 1.414l-8 8a1 1 0 01-1.414 0l-4-4a1 1 0 011.414-1.414L8 12.586l7.293-7.293a1 1 0 011.414 0z"
      clipRule="evenodd"
    />
  </svg>
);

// Lock icon
const LockIcon = () => (
  <svg
    className="w-3.5 h-3.5 text-white"
    fill="currentColor"
    viewBox="0 0 20 20"
  >
    <path
      fillRule="evenodd"
      d="M5 9V7a5 5 0 0110 0v2a2 2 0 012 2v5a2 2 0 01-2 2H5a2 2 0 01-2-2v-5a2 2 0 012-2zm8-2v2H7V7a3 3 0 016 0z"
      clipRule="evenodd"
    />
  </svg>
);

// Pending icon (circle)
const PendingIcon = () => (
  <div className="w-6 h-6 rounded-full border-2 border-yellow-400" />
);

// Status badge config: each status has its own styling + icon
const statusConfig: Record<
  MilestoneState['status'],
  {
    bg: string;
    border: string;
    text: string;
    statusBg: string;
    icon: React.ReactNode;
    statusLabel: string;
  }
> = {
  achieved: {
    bg: 'bg-blue-50',
    border: 'border-blue-200',
    text: 'text-gray-900',
    statusBg: 'bg-green-500',
    icon: <CheckIcon />,
    statusLabel: 'Achieved',
  },
  locked: {
    bg: 'bg-gray-50',
    border: 'border-gray-200',
    text: 'text-gray-400',
    statusBg: 'bg-gray-300',
    icon: <LockIcon />,
    statusLabel: 'Locked',
  },
  pending: {
    bg: 'bg-yellow-50',
    border: 'border-yellow-200',
    text: 'text-gray-700',
    statusBg: '',
    icon: <PendingIcon />,
    statusLabel: 'Pending',
  },
};

export function MilestoneRow({
  name,
  state,
  icon = '🎯',
}: MilestoneRowProps) {
  const config = statusConfig[state.status];
  const date = 'date' in state ? state.date : undefined;

  return (
    <div
      className={`flex items-center gap-4 p-4 rounded-lg border transition-all ${config.bg} ${config.border}`}
      role="listitem"
      aria-label={`${name}: ${config.statusLabel}`}
    >
      {/* Icon */}
      <div className="flex-shrink-0 text-2xl">{icon}</div>

      {/* Content */}
      <div className="flex-1 min-w-0">
        <h3 className={`font-semibold text-sm ${config.text}`}>{name}</h3>
        {date && (
          <p className="text-xs text-gray-500 mt-1">
            {state.status === 'achieved' ? 'Achieved' : 'Target'}: {date}
          </p>
        )}
      </div>

      {/* Status indicator */}
      <div className="flex-shrink-0">
        {state.status === 'pending' && config.icon}
        {state.status !== 'pending' && (
          <div
            className={`flex items-center justify-center w-6 h-6 rounded-full ${config.statusBg}`}
          >
            {config.icon}
          </div>
        )}
      </div>
    </div>
  );
}
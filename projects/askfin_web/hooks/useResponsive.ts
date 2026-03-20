'use client';

import { useState, useLayoutEffect } from 'react';

type Breakpoint = 'mobile' | 'tablet' | 'desktop';

interface ResponsiveState {
  breakpoint: Breakpoint;
  isMobile: boolean;
  isTablet: boolean;
  isDesktop: boolean;
}

function getBreakpoint(width: number): Breakpoint {
  if (width < 768) return 'mobile';
  if (width < 1024) return 'tablet';
  return 'desktop';
}

export function useResponsive(): ResponsiveState {
  const [breakpoint, setBreakpoint] = useState<Breakpoint>(() => {
    // Initialize with correct value on server
    if (typeof window === 'undefined') return 'mobile';
    return getBreakpoint(window.innerWidth);
  });

  useLayoutEffect(() => {
    // Sync client breakpoint on mount
    setBreakpoint(getBreakpoint(window.innerWidth));

    const handleResize = () => {
      setBreakpoint(getBreakpoint(window.innerWidth));
    };

    window.addEventListener('resize', handleResize);
    return () => window.removeEventListener('resize', handleResize);
  }, []);

  return {
    breakpoint,
    isMobile: breakpoint === 'mobile',
    isTablet: breakpoint === 'tablet',
    isDesktop: breakpoint === 'desktop',
  };
}
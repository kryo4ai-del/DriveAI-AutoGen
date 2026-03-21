export function getProgressColor(progress: number): {
  bar: string;
  badge: string;
} {
  if (progress < 33) {
    return {
      bar: 'bg-red-500',
      badge: 'bg-red-100 text-red-800',
    };
  }
  if (progress < 66) {
    return {
      bar: 'bg-yellow-500',
      badge: 'bg-yellow-100 text-yellow-800',
    };
  }
  return {
    bar: 'bg-green-500',
    badge: 'bg-green-100 text-green-800',
  };
}
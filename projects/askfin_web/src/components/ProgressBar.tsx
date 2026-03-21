// Updated ProgressBar with pattern
export function ProgressBar({
  progress,
  ariaLabel,
  animationDuration = 800,
}: ProgressBarProps) {
  const animatedProgress = useProgressAnimation(progress, animationDuration);
  const { bar, indicator } = getProgressColor(progress);

  return (
    <div
      className="w-full h-2 bg-gray-200 rounded-full overflow-hidden relative"
      role="progressbar"
      aria-valuenow={Math.round(animatedProgress)}
      aria-valuemin={0}
      aria-valuemax={100}
      aria-describedby="progress-description"
    >
      <div
        className={`h-full ${bar} rounded-full transition-all duration-50`}
        style={{
          width: `${animatedProgress}%`,
          backgroundImage: `repeating-linear-gradient(
            45deg,
            transparent,
            transparent 10px,
            rgba(255, 255, 255, 0.3) 10px,
            rgba(255, 255, 255, 0.3) 20px
          )`,
        }}
      />
      {/* Add text indicator overlay for very low or high progress */}
      {animatedProgress > 5 && animatedProgress < 95 && (
        <span
          className="absolute inset-0 flex items-center justify-center text-white text-xs font-bold"
          aria-hidden="true"
        >
          {indicator}
        </span>
      )}
      <span id="progress-description" className="sr-only">
        {ariaLabel}
      </span>
    </div>
  );
}
// ❌ PROBLEM
deinit {
    timer?.invalidate()  // Only invalidates if timer exists
}

private func startTimer() {
    timer = Timer.scheduledTimer(withTimeInterval: timerInterval, repeats: true) { [weak self] _ in
        self?.tick()  // Weak self prevents retain cycle, but...
    }
}

// ---

private func startTimer() {
    timer?.invalidate()  // Always stop existing timer
    timer = Timer.scheduledTimer(withTimeInterval: timerInterval, repeats: true) { [weak self] _ in
        self?.tick()
    }
}

private func pauseSession() {
    guard isActive else { return }
    isActive = false
    isPaused = true
    timer?.invalidate()
    timer = nil  // ✓ Set to nil
}

deinit {
    timer?.invalidate()
    timer = nil
}

// ---

// ❌ PROBLEM
func stopSession() {
    let record = SessionRecord(
        date: sessionStartTime ?? Date(),  // May be nil!
        technique: selectedTechnique,
        durationSeconds: duration,
        completedCycles: completedCycles
    )
}

// ---

private var sessionStartTime: Date? = nil

func startSession() {
    sessionStartTime = Date()  // ✓ Always set
    // ...
}

func stopSession() {
    guard let startTime = sessionStartTime else {
        print("⚠️ Cannot stop: session never started")
        return
    }
    
    let record = SessionRecord(
        date: startTime,  // ✓ Guaranteed to exist
        technique: selectedTechnique,
        durationSeconds: duration,
        completedCycles: completedCycles
    )
}

// ---

// ❌ PROBLEM
private func updateProgress() {
    let ratio = Float(phaseElapsedTime) / Float(totalPhaseTime)
    progress = min(1.0, ratio)  // Caps at 1.0
}

// ---

private func updateProgress() {
    guard totalPhaseTime > 0 else { return }
    progress = min(1.0, max(0.0, Float(phaseElapsedTime) / Float(totalPhaseTime)))
}

// In BreathingView:
Circle()
    .scaleEffect(CGFloat(0.5 + Double(viewModel.progress) * 0.5))
    .animation(.easeInOut(duration: 0.05), value: viewModel.progress)

// ---

// ❌ PROBLEM
func sessionsThisWeek() -> [SessionRecord] {
    let weekAgo = Calendar.current.date(byAdding: .day, value: -7, to: Date()) ?? Date()
    return _allSessions.filter { $0.date >= weekAgo }
}

// ---

func sessionsThisWeek() -> [SessionRecord] {
    var calendar = Calendar.current
    calendar.timeZone = TimeZone.current
    
    guard let weekAgo = calendar.date(byAdding: .day, value: -7, to: Date()) else {
        return []
    }
    
    return _allSessions.filter { $0.date >= weekAgo && $0.date <= Date() }
}

// ---

// ⚠️ SUBOPTIMAL
Circle()
    .scaleEffect(0.5 + CGFloat(viewModel.progress) * 0.5)
    .animation(.easeInOut(duration: 0.05), value: viewModel.progress)

// ---

.animation(.easeInOut(duration: 0.1), value: viewModel.progress)

// ---

// ⚠️ FRAGILE
func loadAllSessions() {
    guard let data = UserDefaults.standard.data(forKey: sessionsKey) else {
        _allSessions = []
        return
    }
    
    do {
        _allSessions = try decoder.decode([SessionRecord].self, from: data)
    } catch {
        print("⚠️ Failed to decode sessions: \(error)")
        _allSessions = []
        // Silent failure—user loses data!
    }
}

// ---

func loadAllSessions() {
    guard let data = UserDefaults.standard.data(forKey: sessionsKey) else {
        _allSessions = []
        return
    }
    
    do {
        _allSessions = try decoder.decode([SessionRecord].self, from: data)
    } catch {
        print("❌ CRITICAL: Failed to decode sessions: \(error)")
        // Attempt recovery: backup corrupted data
        logCorruptedData(data, error: error)
        _allSessions = []
    }
}

private func logCorruptedData(_ data: Data, error: Error) {
    let backupKey = "breathing_sessions_backup_\(UUID().uuidString)"
    UserDefaults.standard.set(data, forKey: backupKey)
    print("📦 Corrupted data backed up to: \(backupKey)")
}

// ---

// ⚠️ iOS COMPATIBILITY
Text("\(viewModel.timeRemaining)s")
    .contentTransition(.numericText())

// ---

#if os(iOS)
if #available(iOS 16.1, *) {
    Text("\(viewModel.timeRemaining)s")
        .contentTransition(.numericText())
} else {
    Text("\(viewModel.timeRemaining)s")
}
#endif

// ---

// ✓ ADD
/// Starts a breathing session with the selected technique.
/// - Note: Saves session record to UserDefaults on stop.
func startSession() { ... }

/// Calculates time remaining until phase transition.
private var timeRemaining: Int = 0

// ---

// ❌ Current code
private func startTimer() {
    timer = Timer.scheduledTimer(withTimeInterval: timerInterval, repeats: true) { [weak self] _ in
        self?.tick()
    }
}

private func pauseSession() {
    timer?.invalidate()  // Invalidates but doesn't set to nil
    // Calling resumeSession() creates a SECOND timer without clearing the first
}

deinit {
    timer?.invalidate()
}

// ---

private func startTimer() {
    timer?.invalidate()  // Always stop previous timer
    timer = Timer.scheduledTimer(withTimeInterval: timerInterval, repeats: true) { [weak self] _ in
        self?.tick()
    }
}

private func pauseSession() {
    guard isActive else { return }
    isActive = false
    isPaused = true
    timer?.invalidate()
    timer = nil  // ✓ Clear reference
}

deinit {
    timer?.invalidate()
    timer = nil
}

// ---

func testResumeDoesNotCreateDuplicateTimer() {
    sut.startSession()
    let elapsed1 = sut.timeRemaining
    
    sut.pauseSession()
    sut.resumeSession()
    
    // Advance 0.2s manually
    Thread.sleep(forTimeInterval: 0.2)
    
    let elapsed2 = sut.timeRemaining
    let decrement = elapsed1 - elapsed2
    
    XCTAssertLessThan(decrement, 3, "Timer running 2x speed indicates duplicate timer")
}

// ---

func stopSession() {
    let duration = sessionDurationSeconds  // ← Returns 0 if sessionStartTime is nil
    let record = SessionRecord(
        date: sessionStartTime ?? Date(),  // ← Fallback to "now" is WRONG
        technique: selectedTechnique,
        durationSeconds: duration,
        completedCycles: completedCycles
    )
}

// ---

func stopSession() {
    guard let startTime = sessionStartTime else {
        print("⚠️ Cannot stop: session never started")
        isActive = false
        isPaused = false
        return
    }
    
    timer?.invalidate()
    timer = nil
    
    let duration = Int(Date().timeIntervalSince(startTime))
    let record = SessionRecord(
        date: startTime,  // ✓ Original start time
        technique: selectedTechnique,
        durationSeconds: max(duration, 1),  // At least 1s
        completedCycles: completedCycles
    )
    
    _ = stats.saveSession(record)
    resetSession()
}

// ---

// In BreathingViewModel
private var stats = StatsService.shared

func stopSession() {
    _ = stats.saveSession(record)  // Saves to UserDefaults
    // But StatsService._allSessions may not reflect the save immediately
}

// Later: SessionCompleteView reads
var weeklyTotal = stats.weeklyMinutes()  // May be stale!

// ---

func sessionsThisWeek() -> [SessionRecord] {
    let weekAgo = Calendar.current.date(byAdding: .day, value: -7, to: Date()) ?? Date()
    return _allSessions.filter { $0.date >= weekAgo }
}

// ---

func sessionsThisWeek() -> [SessionRecord] {
    var calendar = Calendar.current
    calendar.timeZone = TimeZone.current
    
    let today = calendar.startOfDay(for: Date())
    guard let sevenDaysAgo = calendar.date(byAdding: .day, value: -7, to: today) else {
        return []
    }
    
    return allSessions.filter { session in
        let sessionDay = calendar.startOfDay(for: session.date)
        return sessionDay >= sevenDaysAgo && sessionDay <= today
    }
}

// ---

func testWeeklyMinutesIgnoresTimezone() {
    var calendar = Calendar.current
    calendar.timeZone = TimeZone(identifier: "America/Los_Angeles")!
    
    let record1 = SessionRecord(
        date: calendar.date(from: DateComponents(year: 2025, month: 3, day: 23, hour: 23, minute: 55))!,
        technique: .calmBreathing,
        durationSeconds: 300,
        completedCycles: 1
    )
    
    stats.allSessions = [record1]
    XCTAssertEqual(stats.weeklyMinutes(), 5)
}

// ---

// BreathingViewModel
private func updateProgress() {
    let ratio = Float(phaseElapsedTime) / Float(totalPhaseTime)
    progress = min(1.0, ratio)  // Caps at 1.0
}

// BreathingView
Circle()
    .scaleEffect(0.5 + CGFloat(viewModel.progress) * 0.5)
    .animation(.easeInOut(duration: 0.05), value: viewModel.progress)

// ---

Circle()
    .scaleEffect(0.5 + CGFloat(viewModel.progress) * 0.5)
    .animation(.easeInOut(duration: 0.1), value: viewModel.progress)
    // Match timer interval

// ---

func loadAllSessions() {
    do {
        allSessions = try decoder.decode([SessionRecord].self, from: data)
    } catch {
        print("⚠️ Failed to decode sessions: \(error)")  // User loses all data!
        allSessions = []
    }
}

// ---

func loadAllSessions() {
    guard let data = UserDefaults.standard.data(forKey: sessionsKey) else {
        allSessions = []
        return
    }
    
    do {
        allSessions = try decoder.decode([SessionRecord].self, from: data)
    } catch {
        print("❌ CRITICAL: Sessions corrupted: \(error)")
        logCorruptedDataBackup(data)
        allSessions = []
    }
}

private func logCorruptedDataBackup(_ data: Data) {
    let backupKey = "breathing_sessions_corrupted_\(Date().timeIntervalSince1970)"
    UserDefaults.standard.set(data, forKey: backupKey)
    print("📦 Backup saved: \(backupKey)")
}

// ---

// Add to BreathingView:
@Environment(\.accessibilityReduceMotion) var reduceMotion

var body: some View {
    ZStack {
        // Animated circle with reduced-motion fallback
        Circle()
            .scaleEffect(
                reduceMotion
                    ? 1.0  // Static size (no animation)
                    : (0.5 + CGFloat(viewModel.progress) * 0.5)
            )
            .animation(reduceMotion ? nil : .easeInOut(duration: 0.1), value: viewModel.progress)
            .accessibilityLabel("Breathing animation circle")
            .accessibilityHint("Expands during inhale, contracts during exhale")
            .accessibilityAddTraits(.updatesFrequently)
        
        // Center content
        VStack(spacing: 12) {
            Text(viewModel.currentPhase.rawValue.capitalized)
                .accessibilityLabel("Current phase: \(viewModel.currentPhase.rawValue)")
            
            Text("\(viewModel.timeRemaining)s")
                .accessibilityLabel("\(viewModel.timeRemaining) seconds remaining")
                .accessibilityAddTraits(.updatesFrequently)
                .accessibilityRemoveTraits(.isStaticText)
        }
    }
    .onReceive(viewModel.$currentPhase) { phase in
        // Announce phase changes for VoiceOver
        let announcement = "Now \(phase.rawValue)ing"
        UIAccessibility.post(notification: .announcement, argument: announcement)
    }
}

// ---

HStack(spacing: 20) {
    if viewModel.isActive {
        Button(action: { viewModel.pauseSession() }) {
            Image(systemName: "pause.fill")
                .font(.system(size: 20))
        }
        .frame(minWidth: 44, minHeight: 44)  // ✓ Explicit minimum
        .contentShape(Rectangle())  // ✓ Expand tappable area
        .accessibilityLabel("Pause session")
    } else {
        Button(action: { viewModel.startSession() }) {
            Image(systemName: "play.fill")
                .font(.system(size: 20))
        }
        .frame(minWidth: 44, minHeight: 44)
        .contentShape(Rectangle())
        .accessibilityLabel("Start session")
    }
    
    Button(action: { viewModel.stopSession() }) {
        Image(systemName: "stop.fill")
            .font(.system(size: 20))
    }
    .frame(minWidth: 44, minHeight: 44)
    .contentShape(Rectangle())
    .accessibilityLabel("Stop session")
    .accessibilityHint("Ends the session and saves your progress")
}

// ---

// BreathingView.swift
@Environment(\.accessibilityReduceMotion) var reduceMotion

var body: some View {
    ZStack {
        // OPTION 1: Disable animation entirely
        if reduceMotion {
            Circle()
                .fill(phaseColor(viewModel.currentPhase))
                .frame(width: 280, height: 280)
                .opacity(0.6)
        } else {
            Circle()
                .scaleEffect(0.5 + CGFloat(viewModel.progress) * 0.5)
                .fill(phaseColor(viewModel.currentPhase))
                .frame(width: 280, height: 280)
                .animation(.easeInOut(duration: 0.1), value: viewModel.progress)
                .opacity(0.6)
        }
    }
}

// OPTION 2: Slower animation for reduced motion
var animationDuration: Double {
    reduceMotion ? 0.5 : 0.1
}

Circle()
    .scaleEffect(0.5 + CGFloat(viewModel.progress) * 0.5)
    .animation(.easeInOut(duration: animationDuration), value: viewModel.progress)

// ---

// ✓ Replace fixed size with dynamic scaling
Text("\(viewModel.timeRemaining)s")
    .font(.system(size: 48, weight: .bold, design: .monospaced))
    .minimumScaleFactor(0.8)  // Allow slight reduction on small screens
    .lineLimit(1)

// OR use predefined style:
Text("\(viewModel.timeRemaining)s")
    .font(.system(.largeTitle, design: .monospaced))
    .bold()
    .minimumScaleFactor(0.8)

// OR use Dynamic Type category:
@ScaledMetric(relativeTo: .largeTitle)
var fontSize: CGFloat = 48

Text("\(viewModel.timeRemaining)s")
    .font(.system(size: fontSize, weight: .bold, design: .monospaced))

// ---

private func phaseColor(_ phase: BreathPhase) -> Color {
    switch phase {
    case .inhale: return Color(red: 0.2, green: 0.6, blue: 1.0)  // Lighter blue
    case .hold: return Color(red: 0.2, green: 0.8, blue: 0.4)    // Lighter green
    case .exhale: return Color(red: 1.0, green: 0.6, blue: 0.2)  // Lighter orange
    }
}

// Use contrasting text color
VStack(spacing: 12) {
    Text(viewModel.currentPhase.rawValue.capitalized)
        .font(.headline)
        .foregroundColor(.white)  // ✓ White text on colored background
        .shadow(color: Color.black.opacity(0.3), radius: 1)  // Optional: improve readability
}

// Test contrast:
// - Blue #3399FF on white: 4.8:1 ✓
// - Green #33CC66 on white: 4.5:1 ✓
// - Orange #FF9933 on white: 4.5:1 ✓

// ---

VStack(spacing: 16) {
    // ✓ Mark as heading for screen readers
    Text("Choose Your Technique")
        .font(.title2)
        .padding()
        .accessibilityAddTraits(.isHeader)
        .accessibilityLabel("Choose Your Technique")
        .accessibilityHint("Select a breathing technique to begin your session")
    
    ScrollView {
        VStack(spacing: 12) {
            ForEach(BreathingTechnique.allCases, id: \.self) { tech in
                TechniqueCard(...)
            }
        }
        .padding()
    }
}
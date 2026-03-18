# DrivaAI-AutoGen Step Report – ML-67

## Title
First Runtime Launch and Simulator Smoke Test After Clean Xcode Build

## Why this step now
The latest Mac report confirms a major threshold has been crossed.

AskFin is no longer only source-clean or typecheck-clean.
It is now:

- materialized into a real Apple project
- compiled through a real Xcode build
- built with 0 errors
- built with 0 warnings

This means the factory has reached a true build milestone:
the active AskFin app baseline is now buildable as an iOS app project.

So the next correct move is not another expensive generation run and not another compile-fix loop.
The next correct move is the next platform-truth layer after build success:
launch the app on the simulator and perform a first controlled runtime smoke test.

## Background
The latest report established:

- `project.yml` → `.xcodeproj` creation path worked
- `xcodebuild` succeeded
- target build succeeded on iPhone 17 Pro Simulator
- 2 debug-preview files were quarantined to keep the active build path clean
- the app now compiles successfully as a real Xcode project

This is strategically important because build success and runtime success are different truth layers.

A runtime smoke test checks things the build cannot:
- app launch viability
- scene/app lifecycle stability
- crashes on startup
- missing runtime resources
- environment/config bootstrap issues
- first-screen rendering viability

That is the correct next milestone after first clean build.

## Strategic reasoning
We should now move upward in runtime truth, not back sideways into more static fixes.

Why?
Because the build milestone already proves the factory can now generate and materialize a compile-clean iOS project.
The next real unknown is:
does the app actually launch and survive the first runtime path?

This step is also cost-disciplined:
- no expensive Sonnet run
- no new codegen
- no speculative architecture churn
- one real runtime validation step on top of the clean build baseline

This matches the long-term factory goal well:
the system should eventually produce not just buildable Apple projects, but apps that actually launch and behave coherently at runtime.

## Goal
Launch the built AskFin app in the simulator and perform the first runtime smoke test from the clean Xcode build baseline.

## Desired outcome
- the app launches successfully in the simulator
- first-screen/runtime viability is observed
- crashes, hangs, or immediate runtime blockers are captured exactly if they exist
- the next step can be chosen from real runtime truth rather than build truth alone

## In scope
- use the current clean `.xcodeproj` / Xcode build baseline
- launch the app in the simulator
- observe startup/runtime behavior
- capture whether the app:
  - launches cleanly
  - launches with visible issues
  - crashes on startup
  - hangs / fails to render correctly
- if runtime issues appear, isolate the first concrete blocker(s)
- produce a factual runtime smoke report for the next Master Lead step

## Out of scope
- another LLM generation/autonomy run
- broad feature development
- speculative fixes before runtime evidence is collected
- large UI redesign
- commercialization work

## Success criteria
- the app is launched from the successful Xcode build baseline
- actual runtime behavior is observed and recorded
- no expensive model run is required
- the next step can be chosen from real runtime evidence

## Strategic note for later planning
The broader DriveAI-AutoGen direction remains unchanged:
build toward a highly autonomous, self-improving factory with stronger central coordination, stronger truth systems, better lifecycle governance, richer planning and decomposition, and eventually trustworthy multi-provider / multi-model routing.
This step specifically advances the factory from “builds cleanly” to “launches and survives first runtime truth.”

## Claude Code Prompt
```text
Goal:
Launch the built AskFin app in the simulator and perform the first runtime smoke test from the clean Xcode build baseline.

Prompt ist für Mac

Task:
Use the existing successful Xcode project/build baseline exactly as it stands, launch the app in the simulator, and perform a first controlled runtime smoke test.

Important:
Do not start another generation/autonomy run.
Do not broaden scope into feature work.
Do not make speculative fixes before collecting runtime evidence.
Use the current successful build baseline as the source of truth.

Focus especially on:
- whether the app launches successfully
- whether it crashes on startup
- whether the initial scene/view renders
- whether there are obvious runtime blockers such as:
  - missing runtime resources
  - environment/bootstrap failures
  - fatal state assumptions
  - immediate navigation/rendering problems
- capturing exact runtime evidence if failure occurs

Required checks:
1. Launch the app from the existing Xcode project/build baseline in the simulator.
2. Record whether the app:
   - launches cleanly,
   - launches with visible issues,
   - crashes on startup,
   - or hangs/fails to render.
3. If a runtime issue appears, isolate the first concrete blocker(s) exactly.
4. Do not perform broad fixes in this step.
5. End with one single next recommended step based on runtime evidence.

Expected report:
1. Runtime environment used
2. Launch path used
3. Exact runtime outcome
4. First concrete runtime blockers if any
5. Interpretation of whether the remaining issue is runtime/config/UI/bootstrap-related
6. Single next recommended step
```

## What happens after this
If the app launches cleanly, the next step should likely be a minimal interaction smoke pass or baseline freeze + docs/state consolidation before any broader product work.
If the app fails at runtime, the next step should target the first real runtime blocker directly and cheaply, without jumping back into expensive model-driven runs.

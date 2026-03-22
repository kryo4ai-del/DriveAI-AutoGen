# BreathFlow Web — Project Context

## Architecture
- Language: TypeScript (strict mode)
- UI Framework: React 18+ with Next.js 14+ (App Router)
- Styling: Tailwind CSS
- State: React hooks (useState, useReducer, useContext)
- Data Fetching: Server Components + fetch API
- Persistence: localStorage + optional API backend
- Build: Next.js (built-in)

## Directory Structure
- app/ — Next.js App Router pages and layouts
- components/ — Reusable React components
- hooks/ — Custom React hooks
- services/ — API calls, data transformation
- types/ — TypeScript interfaces and types
- utils/ — Helper functions
- contexts/ — React context providers
- lib/ — Shared library code

## Conventions
- Components: Named export, PascalCase, .tsx extension
- Hooks: useXxx naming, .ts extension
- Types: Export interface/type, .ts extension
- Server vs Client: 'use client' directive only when needed (interactivity, hooks)
- Styling: Tailwind utility classes, no CSS modules unless needed
- State: useState for local, useContext for shared, no Redux

## DO NOT
- Do NOT use Swift, Kotlin, or any mobile framework
- Do NOT use class components — functional only
- Do NOT use CSS-in-JS — use Tailwind
- Do NOT use getServerSideProps — use App Router conventions
- Do NOT use JavaScript — TypeScript only

# Solace

A student mental health app: mood check-ins, direct messaging with
counselors, an AI companion, a wellness library, and a handful of calm,
no-pressure mini-games. Originally built at university; this is a ground-up
rebuild with a modern architecture and iOS 26's Liquid Glass design language.

## Stack

- **Swift 6 / SwiftUI**, **iOS 26+** (Liquid Glass: `glassEffect`,
  `GlassEffectContainer`, `.buttonStyle(.glass/.glassProminent)`,
  `tabBarMinimizeBehavior`), `async/await`, the `@Observable` macro
- **Swift Charts** for the mood-history graph
- **Firebase**: Authentication (email/password), Firestore (users,
  conversations, messages, resources, mood entries, gratitude entries)
- **Firebase Cloud Functions** (Node/TypeScript) proxying OpenAI's API for
  the AI companion, so the API key never ships on-device
- **MVVM**, with a protocol-first service layer so ViewModels are unit
  tested against mocks instead of live Firebase

## Structure

```
SolaceCore/       Swift package: models, service protocols, ViewModels, tests
                  (platform-agnostic — builds and tests without Xcode)
SolaceApp/        SwiftUI views + Firebase-backed service implementations
  Views/
    Today/        Home dashboard — greeting, mood check-in, streak, quick actions
    Talk/         AI companion (pinned) + counselor conversations, merged into one tab
    Messaging/    Counselor chat + directory, reused inside Talk
    Wellness/     Mood-history chart, relaxation exercises, articles
    Relaxation/   Breathing timer + grounding script, reused inside Wellness
    Games/        Bubble Pop, Gratitude Garden, Focus Rings
    Profile/      Account, streak stats, crisis resources, sign-out
    Shared/       Theme, AmbientBackground, GlassCard, CrisisSheet
firebase/         Firestore security rules/indexes + the chatWithAI
                  Cloud Function
project.yml       XcodeGen spec — Solace.xcodeproj is generated from this
                  (run `xcodegen generate` after changing it)
```

## Features

- Email/password auth with two roles: student and counselor (counselors add
  a short bio students see in the directory)
- **Today**: a one-tap daily mood check-in (Firestore-backed, 5-point scale)
  driving a streak that counts any day with a check-in *or* a journal entry,
  plus quick actions into the other tabs
- **Talk**: one "ways to reach out" hub — the AI companion pinned at the top,
  a Connect section for appointments and support circles, then counselor
  conversations. Real-time 1:1 messaging gated by Firestore rules so only
  conversation participants can read or write
- **Appointments**: students request a time with a counselor; counselors
  confirm or decline, and either side can cancel
- **Support circles**: pre-seeded topic groups (exam stress, homesickness,
  sleep and burnout, first-gen students) that anyone can join, leave, and
  post in — group chat on top of a members-only Firestore rule
- **Wellness**: a mood-history chart (Swift Charts) over the resource
  library — articles (editorial content, seeded via Firestore) and
  self-contained relaxation exercises (animated box/4-7-8 breathing timer,
  5-4-3-2-1 grounding, body scan, three good things), all fully functional
  offline since they ship no external audio/video assets
- **Reminders**: an opt-in daily check-in notification at a time you pick.
  Local (`UNUserNotificationCenter`) rather than remote push — there's no
  server to trigger from, and on a single device the two are equivalent
- **Games**: five calm, no-fail activities — no scores, no timers under
  pressure, no leaderboards, deliberately not competitive:
  - *Bubble Pop* — a satisfying tap-to-pop bubble grid
  - *Gratitude Garden* — logging gratitude entries (Firestore-backed) grows
    a garden through visual stages
  - *Focus Rings* — tap the ring when it blooms; missing isn't a failure,
    it just tries again
  - *Zen Garden* — rake patterns into sand; nothing to get wrong
  - *Worry Jar* — write down a worry, then watch it drift away
- Crisis resources (988 Suicide & Crisis Lifeline, Crisis Text Line) are one
  tap away everywhere via a persistent SOS toolbar button, on top of the
  existing inline placements — the AI companion is for general support only
  and isn't equipped to handle an active crisis

## Status

- ✅ `SolaceCore` builds and its full test suite passes (74 tests, `swift
  test` from `SolaceCore/`)
- ✅ The `chatWithAI` Cloud Function typechecks and compiles
- ✅ Firestore rules and indexes are written and deployed
- ✅ `Solace.xcodeproj` builds successfully end-to-end against the real
  Firebase iOS SDK, targeting iOS 26
  (`xcodebuild -project Solace.xcodeproj -scheme Solace -destination
  'platform=iOS Simulator,name=iPhone 17 Pro' build`)
- ✅ Verified live against a real Firebase project: mood check-in →
  Firestore write → streak/chart update, sign-up for both roles, Talk tab's
  merged AI/counselor flow, requesting an appointment, joining a support
  circle, Bubble Pop interaction, all five tabs' Liquid Glass +
  ambient-background styling
- ⏳ Deploying `chatWithAI` needs the Firebase project on the Blaze plan
  (see [SETUP.md](SETUP.md)) — until then the AI companion shows a graceful
  "unavailable" error instead of crashing

## Security notes

This is a portfolio project, not an audited compliant system. It follows
reasonable practices — no secrets on-device, Firestore rules scoped to each
user's own data (conversations to their participants, mood/gratitude entries
to their owner), HTTPS everywhere — but doesn't claim HIPAA/DPA compliance.

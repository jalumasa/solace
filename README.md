# Solace

A student mental health app: direct messaging between students and
counselors, a curated library of relaxation exercises and articles, and an
AI-powered support chatbot. Originally built at university; this is a ground-up
rebuild with a cleaner architecture and current Swift/SwiftUI practices.

## Stack

- **Swift 6 / SwiftUI**, iOS 17+, `async/await`, the `@Observable` macro
- **Firebase**: Authentication (email/password), Firestore (users,
  conversations, messages, resources)
- **Firebase Cloud Functions** (Node/TypeScript) proxying OpenAI's API for
  the support chatbot, so the API key never ships on-device
- **MVVM**, with a protocol-first service layer so ViewModels are unit
  tested against mocks instead of live Firebase

## Structure

```
SolaceCore/       Swift package: models, service protocols, ViewModels, tests
                  (platform-agnostic — builds and tests without Xcode)
SolaceApp/        SwiftUI views + Firebase-backed service implementations
firebase/         Firestore security rules/indexes + the chatWithAI
                  Cloud Function
project.yml       XcodeGen spec — Solace.xcodeproj is generated from this
                  (run `xcodegen generate` after changing it)
```

## Features

- Email/password auth with two roles: student and counselor
- Real-time 1:1 messaging between students and counselors, gated by
  Firestore security rules so only conversation participants can read or
  write
- A resource library: articles (editorial content, seeded via Firestore) and
  self-contained relaxation exercises — an animated box/4-7-8 breathing
  timer and a 5-4-3-2-1 grounding script, both fully functional offline
  since they ship no external audio/video assets
- An AI chatbot for general emotional support, calling OpenAI through a
  Cloud Function
- Crisis resources (988 Suicide & Crisis Lifeline, Crisis Text Line) surfaced
  wherever the chatbot or resource library appears — the chatbot is for
  general support only and isn't equipped to handle an active crisis

## Status

- ✅ `SolaceCore` builds and its full test suite passes (24 tests, `swift
  test` from `SolaceCore/`)
- ✅ The `chatWithAI` Cloud Function typechecks and compiles
- ✅ Firestore rules and indexes are written
- ✅ `Solace.xcodeproj` builds successfully end-to-end against the real
  Firebase iOS SDK (`xcodebuild -project Solace.xcodeproj -scheme Solace
  -destination 'platform=iOS Simulator,name=iPhone 17' build`)
- ⏳ Running the app requires your own Firebase project (it refuses to start
  without a real `GoogleService-Info.plist` — that's Firebase's own
  behavior, not a bug here) — see [SETUP.md](SETUP.md)

## Security notes

This is a portfolio project, not an audited compliant system. It follows
reasonable practices — no secrets on-device, Firestore rules scoped to
conversation participants, HTTPS everywhere — but doesn't claim HIPAA/DPA
compliance.

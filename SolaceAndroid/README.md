# Solace for Android

The Android client for Solace, sharing the **same Firebase backend** as the iOS
app (`solace-ebd08`) — same Auth, same Firestore collections, same
`firestore.rules`, same `chatWithAI` Cloud Function. A student on Android and a
counselor on iOS can message each other, because both clients read and write
identical documents.

## Why it lives in this repo

`firestore.rules` governs both clients. Keeping the Android app alongside the
iOS app means a rules change and both clients' adaptations land in one diff —
which matters, because a client query whose shape doesn't match a rule gets
rejected outright by Firestore (this exact class of bug has already bitten the
iOS app once). Gradle and Xcode ignore each other's directories entirely, so
there's no build-level coupling.

## Status

All five tabs are built and running against the live Firebase backend, verified
on an emulator.

| Area | State |
| --- | --- |
| Gradle/AGP/Compose build config | AGP 9.3.1, Gradle 9.7.1, Kotlin 2.4.10, compileSdk 37 |
| Data models (mirroring `SolaceCore`) | Done, raw values pinned by test |
| Services (Auth, Firestore ×5, Cloud Functions) | Done, exercised against live data |
| Material 3 theme (Solace palette) | Done |
| Auth: sign-in / sign-up incl. role gating | Verified |
| Today: greeting, mood check-in, streak, quick actions | Verified |
| Talk: AI companion, counselors, 1:1 chat, conversations | Verified |
| Appointments: request / confirm / decline / cancel | Built, list verified |
| Support Circles: browse, join/leave, group chat | Verified |
| Wellness: mood chart, relaxation exercises, articles | Verified |
| Games: all five | Verified (Bubble Pop played) |
| Profile: details, progress, crisis, sign-out | Verified |
| Daily check-in reminders (WorkManager) | Built, not yet verified on device |
| Onboarding carousel | Verified |
| Gratitude Garden writes | Built, not yet verified on device |

The `resources` collection is unseeded, so Articles renders its empty state —
same as iOS. Seed a few documents in the Firebase console to populate it.

**Cross-platform interop is real, not theoretical.** Signing in on Android with
an account created on iOS loads the same profile, the same three counselors with
their bios, and the same circle membership that was joined from iOS.

## Setup

### 1. Register the Android app in Firebase

This step needs your Google account, so it can't be automated:

1. Firebase Console → project **solace-ebd08** → Add app → Android
2. Package name: `com.jonathanalumasa.solace`
3. Download `google-services.json` into `SolaceAndroid/app/`

That file is gitignored, exactly like `GoogleService-Info.plist` on iOS.

### 2. Enable Email/Password auth

Already enabled for the iOS app — the same setting covers Android, no change
needed.

### 3. Build

Open `SolaceAndroid/` in Android Studio and sync, or from the CLI:

```bash
cd SolaceAndroid && ./gradlew :app:assembleDebug
```

Unit tests:

```bash
cd SolaceAndroid && ./gradlew :app:testDebugUnitTest
```

The Gradle wrapper is committed, so no local Gradle install is needed — but
you do need a JDK. Android Studio's bundled one works:

```bash
export JAVA_HOME="/Applications/Android Studio.app/Contents/jbr/Contents/Home"
```

### Emulator notes

Use an **arm64-v8a** image on Apple Silicon, and one with **Google APIs / Google
Play** — Firebase Auth and Firestore lean on Google Play Services, and a bare
AOSP image produces confusing failures that look like app bugs.

## Architecture

Deliberately parallel to the iOS app so the two read as one project:

| iOS (`SolaceCore` / `SolaceApp`) | Android |
| --- | --- |
| `@Observable` ViewModel | `ViewModel` + `StateFlow` |
| `AsyncStream` from `addSnapshotListener` | `Flow` via `callbackFlow` (`FirestoreSnapshots.kt`) |
| `XServicing` protocol | `XService` interface |
| `FirestoreXService` | `service/firebase/FirestoreXService.kt` |
| SwiftUI view | `@Composable` screen |
| Liquid Glass | Material 3 surfaces (glass is iOS-only) |
| Plain constructor injection | Same — `ServiceLocator`, no DI framework |
| Swift Testing + eager `AsyncStream` mocks | JUnit + `MutableSharedFlow(replay = 1)` fakes |

Enum raw values (`Role`, `MoodLevel`, `AppointmentStatus`, `AcademicYear`) are
pinned by unit test, because they're persisted to Firestore and compared
directly inside `firestore.rules` — drift between clients would be a live data
bug, not a compile error.

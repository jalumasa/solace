# Setup — connecting the app to your own Firebase project

Good news: the hard part is done. `Solace.xcodeproj` already exists at the
repo root (generated via XcodeGen — see `project.yml`), with the
`SolaceCore` local package and the Firebase iOS SDK already wired up as
dependencies. It builds successfully end-to-end
(`xcodebuild -project Solace.xcodeproj -scheme Solace -destination
'platform=iOS Simulator,name=iPhone 17 Pro' build`).

The app targets **iOS 26** minimum (it uses Liquid Glass APIs throughout),
so you'll need Xcode 26+ and an iOS 26 simulator or device.

Running it, though, requires *your own* Firebase project — Firebase refuses
to start without one (`FirebaseApp.configure()` throws
`Could not locate configuration file: 'GoogleService-Info.plist'` and the
app terminates immediately, which is exactly what you'll see until you
finish this checklist).

## 1. Create the Firebase project

1. Go to the [Firebase console](https://console.firebase.google.com) →
   Add project.
2. Add an iOS app using bundle identifier `com.jonathanalumasa.Solace`
   (from `project.yml`; change it there and re-run `xcodegen generate` if
   you'd rather use your own).
3. Download the generated `GoogleService-Info.plist` and drag it into
   `SolaceApp/Resources/` in Xcode's project navigator (check "Copy items
   if needed" and target membership = `Solace`). It's already gitignored —
   never commit it.
4. In the console, enable **Authentication → Email/Password** and create a
   **Firestore Database** (production mode, any region).

## 2. Upgrade to the Blaze (pay-as-you-go) plan

The `chatWithAI` Cloud Function makes an outbound network call (to OpenAI),
and Cloud Functions require the **Blaze plan** for any function that needs
network egress — the free Spark plan won't deploy it. This needs a card on
file, but Firebase's free tier usage allowances still apply on Blaze (you're
only billed for usage beyond them, and this app's traffic as a portfolio demo
should stay within them). Upgrade from the console's plan settings before
step 4 below.

## 3. Deploy Firestore rules, indexes, and the Cloud Function

```bash
npm install -g firebase-tools
firebase login
cd firebase
firebase use --add   # select the project you just created
firebase deploy --only firestore:rules,firestore:indexes
firebase functions:secrets:set OPENAI_API_KEY   # paste your OpenAI key when prompted
firebase deploy --only functions
```

## 4. Run it

Open `Solace.xcodeproj`, select an iOS 26+ simulator, and press Cmd+R. Sign
up once as a counselor (fill in the optional bio — it shows up in the
student-facing directory) and once as a student (two different simulators,
or sign out and back in) to try the Talk tab's messaging flow end-to-end.

## 5. Optional: seed a few articles

The relaxation exercises and mini-games work out of the box with no seed
data — they're all self-contained or write their own Firestore data as you
use them (mood check-ins, gratitude entries). The **Wellness** tab's
articles are the one thing that come from a `resources` Firestore
collection, which starts empty. Add a few documents by hand in the Firebase
console (fields: `title`, `summary`, `body`, `category` — one of
`anxiety`/`stress`/`sleep`/`depression`/`general` — and optionally `tags`,
an array of strings) to see them appear.

## Regenerating the Xcode project

If you ever change `project.yml` (add a file group, bump the deployment
target, etc.), regenerate the project rather than hand-editing
`Solace.xcodeproj`:

```bash
xcodegen generate
```

(Install XcodeGen via `brew install xcodegen` if you don't already have the
one-off binary this session built from source, or via `mint install
yonaskolb/XcodeGen`.)

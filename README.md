# 🥄 iSpoonFit

> A guided 28-session rebuild programme for iOS. Four days a week for seven weeks, 17 to 21 minutes a session, no gym and no equipment beyond a mat and a chair.

[![Report Bug](https://img.shields.io/badge/Report-Bug-red)](https://github.com/VidiPT89/iSpoonFit/issues)
[![Request Feature](https://img.shields.io/badge/Request-Feature-blue)](https://github.com/VidiPT89/iSpoonFit/issues)

## ✨ Features

- ✅ Personal accounts: sign up with email and password, or continue with Apple, Google or Microsoft
- ✅ Progress synced to your account with Cloud Firestore, so it follows you to any iPhone or iPad, and keeps working offline
- ✅ A complete 28-session plan: seven weeks, four sessions per week, Monday to Thursday, across four phases of progression
- ✅ 21 bodyweight exercises across warm-up, legs and glutes, core and stretching, each with its own animated demonstration
- ✅ Stick-figure animations drawn live with `Canvas` and `TimelineView`: every movement is generated from code, no video and no image assets
- ✅ Guided session player with a date-anchored timer that never drifts, even if the screen locks mid-set
- ✅ Spoken countdown, interval sounds and haptics, with a "switch sides" cue halfway through every unilateral exercise; your music keeps playing and only dips while the voice speaks
- ✅ Low-energy mode: shorter work intervals, longer rests, one round fewer and no added load, decided per day
- ✅ Water bottles as the only progression tool, introduced on the days where it matters
- ✅ Progress tracking with a session history, weekly progress, total minutes and five unlockable achievements
- ✅ Local workout reminders at the time and on the weekdays you choose (Monday to Thursday by default)
- ✅ Exercise library with step-by-step instructions, breathing cues, common mistakes and an easier version of every movement
- ✅ Animated splash screen with developer credits, then straight into the app
- ✅ Runtime language switch: Português (PT-PT) and English, independent of the system locale
- ✅ Dark mode, Light mode and System mode
- ✅ Colour identity taken from [ividi.dev](https://ividi.dev/): burnt orange, amber and near-black
- ✅ Accessibility: VoiceOver labels, Dynamic Type and full Reduce Motion support
- ✅ Private by design: each account can only reach its own data, no analytics, no ads, and in-app account deletion

## 🛠️ Tech Stack

| Category | Technology |
|----------|------------|
| Language | Swift 5.9 |
| UI | SwiftUI |
| Graphics | Canvas + TimelineView |
| Architecture | MVVM with `@Observable` |
| Persistence | SwiftData (per-account store on device) |
| Accounts & sync | Firebase Authentication + Cloud Firestore |
| Sign-in | Email/password, Sign in with Apple, Google Sign-In, Microsoft (OAuth) |
| Audio | AVSpeechSynthesizer + system sounds (no audio files) |
| Notifications | UserNotifications |
| Project | XcodeGen |
| Min. iOS | 17.0 |

## 🚀 Quick Start

### Prerequisites

- macOS with Xcode 15+
- iOS 17+ Simulator or device
- [XcodeGen](https://github.com/yonaskolb/XcodeGen) (`brew install xcodegen`)

### Installation

```bash
git clone https://github.com/VidiPT89/iSpoonFit.git
cd iSpoonFit
xcodegen generate
open SpoonFit.xcodeproj
```

Build and run (`⌘R`) on the simulator or a connected device.

### Firebase

The app talks to the Firebase project `ispoonfit-vidi`. Its iOS config lives in `SpoonFit/Config/GoogleService-Info.plist`; after enabling a new sign-in provider in the console, refresh it with:

```bash
sh scripts/fetch-firebase-config.sh
```

A build phase reads that file and registers the URL schemes Google and Microsoft sign-in return on. Firestore security rules live in `firebase/firestore.rules` and are deployed with `firebase deploy --only firestore`.

> The Xcode project is generated from `project.yml` and is not committed. If you add or move Swift files, regenerate it with `xcodegen generate`.

## 📖 Usage

1. Create an account, or continue with Apple, Google or Microsoft
2. Run through the short onboarding and confirm you have medical clearance to exercise
3. Open **Today** and start the session the programme has queued for you
4. Follow the animated figure: it loops at the pace you should be moving at
5. Rest screens preview the next exercise, so you always know what is coming
6. Feeling flat? Turn on **Low-energy day** before starting, or switch to it mid-session, and the whole workout adapts

Days unlock in order and missing a day costs you nothing, the programme simply waits. Friday to Sunday are rest days by design.

Language, appearance, sounds, voice, haptics, reminders and your account (sign out, delete) are all in Settings.

## 🗓️ The Programme

| Weeks | Work | Rest | Rounds | Phase |
|-------|------|------|--------|-------|
| 1 to 2 | 40s | 20s | 3 | Foundation |
| 3 to 4 | 45s | 15s | 3 | Firming |
| 5 to 6 | 45s | 15s | 4 | Endurance |
| 7 | 50s | 10s | 4 | Consolidation |

Every session is built the same way: a fixed 3-minute warm-up, a circuit of the four exercises for that day, and a 2-minute stretching block to close.

## 🧪 Testing

```bash
xcodebuild -project SpoonFit.xcodeproj -scheme SpoonFit \
  -destination 'platform=iOS Simulator,name=iPhone 17' test
```

74 tests cover the programme data, the session builder, the animation poses, the translations, the view models, the sign-in form and the cloud sync merge rules.

## 🔒 Privacy

Your account stores only your sign-in details, your programme settings and your workouts, in Firebase in the EU. Security rules keep every account to its own data, there are no analytics or ads, and the account can be deleted from Settings at any time. See [PRIVACY.md](PRIVACY.md) for the full policy.

> This app is a general fitness guide and not a medical device. Always consult a healthcare professional before starting.

## 📄 License

Distributed under the MIT License. See [LICENSE](LICENSE) for details.

## 👨‍💻 Author

**David Arsénio Martins**

- 🌐 Website: [ividi.dev](https://ividi.dev/)
- 🐙 GitHub: [@VidiPT89](https://github.com/VidiPT89/)

## 🤝 Contributing

Contributions, issues and feature requests are welcome. Feel free to check the [issues page](https://github.com/VidiPT89/iSpoonFit/issues).

---

<p align="center">Developed by <a href="https://ividi.dev">David Arsénio Martins</a></p>
<p align="center">⭐ If you like this project, give it a star!</p>

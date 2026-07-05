# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Hard rules

- **Solo project.** No PRs, no code review gates. Work directly and keep momentum.
- **Commit and push to `main` often.** Small, frequent commits straight to `main`; push after each meaningful change. No feature branches unless a change is genuinely risky.
- **Keep `backlog.md` current.** It is the running log of necessary actions, open questions, and future improvements. Add to it whenever new work surfaces; check items off as they land. Read it at the start of a work session to see what's pending.
- **Testing on real devices.** The user is available to test on physical iPhones and iPads on request. Available devices: **iSQR**, **SQR**, and **Ele** (all currently on hand). When a change needs on-device verification, ask the user to run it and say which device is relevant.

## Product vision

Kuisine is a **recipe app for storing and *improving* recipes** — not just a static cookbook. The core differentiator is capturing the *evolution* of a recipe: users record changes, experiments, and tweaks made to existing and new recipes over time, so a recipe is a living, versioned thing rather than a fixed document.

It is **collaborative and family-oriented**: recipes should be shareable within a family via a shared iCloud (CloudKit) account, so household members can contribute experiments and improvements to shared recipes.

Design data models and features around these two pillars: (1) recipe *history / experiments*, and (2) *family sharing* via CloudKit. See `backlog.md` for the current plan and open architecture questions.

## Project setup

Kuisine is a **multiplatform SwiftUI app** (single target, one shared codebase). `SDKROOT = auto` with `SUPPORTED_PLATFORMS = iphoneos iphonesimulator macosx xros xrsimulator` means the same target builds for iOS, macOS, and visionOS; deployment target is 27.0 across all platforms, Swift 5. As of now the app is the default scaffold (a `ContentView` showing "Hello, world!"), so there is no domain architecture yet — this is a greenfield starting point.

## Layout note

The git repo root (`/Volumes/Engineer/xcode/Projects/Kuisine`) is one level above the Xcode project. All `xcodebuild` commands must run from `Kuisine/`, where `Kuisine.xcodeproj` lives. Source is in `Kuisine/Kuisine/`.

The `@main` app struct is named `MyApp` (in `ContentView.swift`) even though the scheme/target is `Kuisine` — don't assume the app entry point matches the product name.

## Commands

Run from the `Kuisine/` subdirectory. Scheme is `Kuisine`.

```bash
# Build for iOS Simulator
xcodebuild -scheme Kuisine -destination 'platform=iOS Simulator,name=iPhone 16' build

# Build for macOS
xcodebuild -scheme Kuisine -destination 'platform=macOS' build

# Test (no test target exists yet; add one before this is useful)
xcodebuild -scheme Kuisine -destination 'platform=iOS Simulator,name=iPhone 16' test

# Run a single test once a test target exists
xcodebuild -scheme Kuisine -destination 'platform=iOS Simulator,name=iPhone 16' \
  -only-testing:KuisineTests/SomeTestClass/testSomeMethod test
```

There is no external dependency manager (no SPM `Package.swift`, CocoaPods, or Carthage), no linter config, and no CI configured. Open `Kuisine/Kuisine.xcodeproj` in Xcode for interactive development and SwiftUI previews (`#Preview` in `ContentView.swift`).

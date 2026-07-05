# Backlog

Running log of necessary actions, open questions, and future improvements for Kuisine.
Newest/most urgent near the top. Check items off (`- [x]`) as they land.

## Product vision (north star)

Kuisine stores and **improves** recipes: capture the evolution of a recipe through
recorded changes and experiments, and share/collaborate within a family via iCloud.

## Now — foundations

- [x] Flatten nested git repos into one repo backed by `IDEAS-Framework/Kuisine`; add `.gitignore`.
- [x] Decide the persistence + sync stack → **SwiftData + CloudKit** (local storage + automatic
      iCloud sync, CloudKit shared database for family collaboration).
- [x] Set real bundle ID `com.ideasframework.kuisine` (was a placeholder).
- [x] **Xcode signing + capabilities done.** Team = Victor Gallant, bundle ID confirmed,
      iCloud→CloudKit enabled with container `iCloud.com.ideasframework.kuisine`,
      Background Modes→Remote notifications, macOS App Sandbox Outgoing Connections (Client).
      Entitlements include `aps-environment` (push) — so the separate Push Notifications
      capability was not needed for private sync. Files committed: `Kuisine.entitlements`,
      `Info.plist` (UIBackgroundModes=remote-notification), pbxproj wiring.
      NOTE: revisit Push Notifications capability when building family sharing (CKShare).
- [ ] Rename the `@main` app struct from `MyApp` to something intentional (e.g. `KuisineApp`).
- [x] Design core data models (v1):
  - [x] `Recipe` (title, summary, ingredients, steps, isShared scope, timestamps).
  - [x] `Experiment` — a recorded change/tweak: title, notes, outcome, rating, keep, date.
  - [ ] Ingredient / step modeling is freeform text for now; structure later.
- [ ] Family sharing via CloudKit shared database (`CKShare` / SwiftData sharing).
- [x] Basic recipe list + detail UI replacing the scaffold (list → detail → experiment log).
- [x] Add iCloud + CloudKit capabilities to the target and an entitlements file.
- [ ] Add a unit test target (currently none exists).

## v1 status (built 2026-07-05)

- App renamed `@main struct Kuisine`, SwiftData `ModelContainer` on CloudKit private DB.
- Screens: RecipeListView (empty state + add), RecipeDetailView (sections + experiment
  timeline + log button), RecipeEditView, ExperimentEditView. Cross-platform-safe SwiftUI.
- Verified: clean build, installs/launches on iOS 27 sim, correct empty-state render,
  no runtime errors. NOT yet verified: the interactive add/log flow (couldn't drive
  Simulator taps via automation) — needs a real-device pass on iSQR/SQR/Ele.
- Next: on-device test of add recipe → log experiment → confirm iCloud sync across two
  of your devices (both must be signed into the same iCloud account).

## Next — features

- [ ] Add/edit recipe flow.
- [ ] Log an experiment against a recipe; browse a recipe's experiment history/timeline.
- [ ] Rate or mark an experiment as "keep" so it can fold back into the base recipe.
- [ ] Search and tags/categories.
- [ ] Photos on recipes and experiments.

## Later — polish

- [ ] Import recipes (paste, share sheet, web).
- [ ] Shopping list generation from a recipe.
- [ ] Scaling servings.

## Sharing model (decided): private + shared family collection ("both/mix")

Target design, built in phases:
1. **Private sync first** — a user's recipes sync across their own devices via SwiftData's
   CloudKit private database. Quick, foundational.
2. **Shared family collection** — a shared CloudKit zone (`CKShare`) the family joins;
   recipes can be *moved* from personal → shared. Personal recipes stay private by default.

Implication for models: a recipe needs an ownership/scope concept (personal vs. shared) so it
can move between the private and shared stores.

## Open questions (need decisions)

- [ ] **Versioning model:** are experiments immutable snapshots, or diffs/notes layered
      on a mutable base recipe? How does "promote an experiment to the base" work?
- [ ] Target platforms in practice — the project builds for iOS/macOS/visionOS, but the
      testing devices are iPhones + iPads. Trim `SUPPORTED_PLATFORMS` to iOS if macOS/visionOS
      aren't real targets.

## Resolved decisions

- Persistence + sync: **SwiftData + CloudKit**.
- Git: single repo, remote `IDEAS-Framework/Kuisine`, commit + push to `main` often.
- Devices for on-device testing: **iSQR, SQR, Ele** — a mix of iPhones and iPads
  (confirm which per test).

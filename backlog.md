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
- [ ] **Xcode signing + capabilities (user does this — see checklist below).** Select team,
      confirm bundle ID, add iCloud→CloudKit (container `iCloud.com.ideasframework.kuisine`),
      Background Modes→Remote notifications, Push Notifications. This creates the entitlements file.
- [ ] Rename the `@main` app struct from `MyApp` to something intentional (e.g. `KuisineApp`).
- [ ] Design core data models:
  - [ ] `Recipe` (title, ingredients, steps, tags, timestamps).
  - [ ] `Experiment` / `RecipeVersion` — a recorded change or tweak to a recipe,
        with notes, date, author, and outcome. This is the core differentiator.
  - [ ] Ingredient / step modeling (structured vs. freeform text).
- [ ] Family sharing via CloudKit shared database (`CKShare` / SwiftData sharing).
- [ ] Basic recipe list + detail UI to replace the "Hello, world!" scaffold.
- [ ] Add iCloud + CloudKit capabilities to the target and an entitlements file.
- [ ] Add a unit test target (currently none exists).

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

## Open questions (need decisions)

- [ ] **Sharing model:** one shared family zone/database vs. per-recipe `CKShare`?
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

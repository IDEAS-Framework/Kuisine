# Backlog

Running log of necessary actions, open questions, and future improvements for Kuisine.
Newest/most urgent near the top. Check items off (`- [x]`) as they land.

## Product vision (north star)

Kuisine stores and **improves** recipes: capture the evolution of a recipe through
recorded changes and experiments, and share/collaborate within a family via iCloud.

## Now — foundations

- [ ] Rename the `@main` app struct from `MyApp` to something intentional (e.g. `KuisineApp`).
- [ ] Decide the persistence + sync stack (see Open Questions). Leading candidate:
      **SwiftData + CloudKit** for local storage with automatic iCloud sync.
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

- [ ] **Persistence stack:** SwiftData+CloudKit, Core Data+CloudKit, or a custom
      CloudKit layer? (Affects everything downstream.)
- [ ] **Sharing model:** one shared family zone/database vs. per-recipe `CKShare`?
- [ ] **Versioning model:** are experiments immutable snapshots, or diffs/notes layered
      on a mutable base recipe? How does "promote an experiment to the base" work?
- [ ] **Device names iSQR / SQR / Ele:** which are iPhones vs. iPads, and their models?
      (Needed to pick `xcodebuild -destination` targets for on-device runs.)
- [ ] Target platforms in practice — the project builds for iOS/macOS/visionOS, but is
      the real focus iPhone + iPad only? Trim `SUPPORTED_PLATFORMS` if so.

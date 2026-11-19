# Story Map: Recipe Management Tool

## Clarifying questions (unanswered, so assumptions made)

| Question | Assumption used |
|---|---|
| Who is it for? | A single home cook managing a personal collection. No sharing or multi-user in v1. |
| Platform? | Responsive web app, usable on a phone in the kitchen. |
| Where do recipes come from? | Typed in by hand, plus pasting a URL to import. |
| Accounts? | Simple sign-in, private data. |
| Budget/timeline? | Small team, thin slices, shippable in weeks. |

## User and goal

Home cook. Goal: "Keep all my recipes in one place, find the right one quickly, and cook from it without friction."

## Backbone (activities, left to right)

1. Capture recipes
2. Organize and find
3. Plan meals
4. Shop
5. Cook
6. Share and sync

## Map (steps and stories under each activity, top = most essential)

### 1. Capture recipes
- Add manually: title, ingredients (qty/unit/name), steps, servings, time
- Edit and delete a recipe
- Import from URL (schema.org Recipe parsing)
- Attach a photo
- Import from text paste / photo OCR
- Duplicate a recipe as a variation

### 2. Organize and find
- List all recipes
- Search by title
- Tag recipes (e.g. dinner, vegetarian)
- Filter by tag, time
- Search by ingredient ("what can I make with chicken")
- Favorites
- Collections / cookbooks

### 3. Plan meals
- Weekly calendar: assign a recipe to a day
- Copy last week's plan
- Suggest recipes based on pantry or history

### 4. Shop
- Generate shopping list from one recipe
- Generate list from the week's plan, merging duplicates
- Check items off
- Group by store aisle
- Pantry staples excluded

### 5. Cook
- Clean read view with large text
- Scale servings (auto-adjust quantities)
- Unit conversion (metric/imperial)
- Keep-screen-awake cooking mode
- Step timers
- Notes and rating after cooking

### 6. Share and sync
- Export a recipe (print/PDF)
- Share a recipe by link
- Household sharing, shared plan and list
- Offline access
- Data export/backup

## Release slices

### Walking skeleton (Release 1: "a recipe box")
Thinnest end-to-end path: save a recipe, find it, cook from it.
- Add manually
- Edit and delete
- List all recipes
- Search by title
- Clean read view

### Release 2: "easier in and out"
- Import from URL
- Tags and filter by tag
- Scale servings
- Generate shopping list from one recipe
- Photo attachment
- Favorites

### Release 3: "plan the week"
- Weekly calendar
- Shopping list from plan with merged duplicates
- Check off items
- Ingredient search
- Cooking mode, ratings and notes
- Unit conversion

### Later / parked
- OCR import, suggestions, aisle grouping, step timers, collections
- Sharing, household, offline, backup, print/PDF
- Duplicate as variation, pantry tracking

## Rationale for slicing
- Release 1 proves the core loop (store, retrieve, read) with no integrations.
- URL import is the biggest effort-saver for users, so it leads Release 2; it is also the riskiest technically (messy sites), so it gets its own slice.
- Shopping lists need structured ingredients, which Release 1's data model already captures. That is a deliberate design constraint: store qty/unit/name separately from day one.
- Sharing and multi-user are deferred because they change the auth and data model.

## Open risks
- Ingredient parsing and merging ("2 cloves garlic" vs "garlic, minced") is harder than it looks.
- URL import legality and reliability varies by site.
- Scope creep into meal-planning/nutrition apps.

## Next step
No GitHub issues published: the idea is still vague and the assumptions above are unconfirmed. Once confirmed, Release 1 stories (see issues.md) are ready to file.

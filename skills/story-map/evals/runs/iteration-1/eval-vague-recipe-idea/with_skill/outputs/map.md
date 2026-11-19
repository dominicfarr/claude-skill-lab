# Recipe management tool: story map

**ASSUMPTION (flagged, not confirmed):** The idea named no user and no outcome. Clarifying question that would have been asked: "Who is this for (home cook, family, professional kitchen?) and what outcome should it deliver (stop losing recipes, plan meals, shop, cook)?" No answer was available, so assumed: a home cook feeding a household, who wants to stop losing recipes and re-deciding dinner, going from "what's for dinner?" to a cooked meal with less friction.

Legend: 🦴 = walking skeleton (has BDD specs)

| Collect recipes | Find a recipe | Plan and shop | Cook |
|---|---|---|---|
| **Add a recipe**<br>🦴 Add a recipe by typing it in<br>Import from web URL<br>Import from photo/scan<br>**Organise recipes**<br>Tag a recipe<br>Put recipes into collections<br>Edit or delete a recipe | **Browse and search**<br>🦴 Search recipes by title<br>Search by ingredient on hand<br>Filter by tag<br>Mark as favourite | **Plan meals**<br>Add a recipe to a day in a weekly plan<br>**Build a shopping list**<br>🦴 Generate a shopping list from selected recipes<br>Tick items off while shopping<br>Exclude pantry items | **Follow a recipe**<br>🦴 View in cooking mode<br>Scale servings<br>Start a timer from a step<br>**Remember how it went**<br>Add a personal note<br>Rate a recipe |

Skeleton: type in a recipe, find it, build a shopping list, cook from it. Gherkin for the 4 sliced stories is in the published issues.

Published: map issue #16 in dominicfarr/story-map-skill-test, 19 child story issues (#17 to #72, 4 sliced with Gherkin, 15 plain cards).

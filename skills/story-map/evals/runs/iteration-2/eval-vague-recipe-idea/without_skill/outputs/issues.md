# Release 1 stories with acceptance criteria (draft, not published)

## 1. Add a recipe manually
As a home cook, I want to enter a recipe so that I can keep it in my collection.
- Given the add form, when I enter a title and at least one ingredient and save, then the recipe appears in my list.
- Ingredients are stored as quantity, unit, name (quantity and unit optional).
- Steps are an ordered list; servings and total time are optional.
- Saving without a title shows a validation error and does not save.

## 2. Edit and delete a recipe
- I can change any field and save; changes show immediately in the list and view.
- Delete asks for confirmation; after confirming, the recipe is gone from list and search.

## 3. List all recipes
- Shows title and time for every recipe, newest first.
- Empty state explains how to add the first recipe.

## 4. Search by title
- Typing filters the list by case-insensitive substring match.
- No matches shows a "no results" message with a clear-search action.

## 5. Read view for cooking
- Shows ingredients and steps in large, readable text on a phone-width screen.
- Ingredients and steps are visible without leaving the page.

## Notes
- Assumptions in map.md apply (single user, responsive web).
- Not filed to GitHub: idea unconfirmed.

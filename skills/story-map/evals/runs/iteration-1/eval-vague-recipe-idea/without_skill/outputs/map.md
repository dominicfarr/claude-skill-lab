# Story map: Recipe management tool

## Assumptions (not confirmed, the request gave no persona or goal)

- Persona: a home cook who collects recipes from many places (books, websites, family) and wants one reliable place to find and cook them.
- Goal: "When I decide what to cook, I can find the right recipe quickly and cook it without friction."
- Platform: web app, single user, no social features in the first slices.

Open questions I would ask: Who is this for (home cook, family, professional kitchen, food blogger)? What is the outcome (less decision fatigue, fewer wasted groceries, preserving family recipes)? Where do recipes come from today?

## Backbone (user activities, left to right)

| 1. Capture recipes | 2. Organise | 3. Find | 4. Plan meals | 5. Shop | 6. Cook |
|---|---|---|---|---|---|

## Stories by activity

### 1. Capture recipes
- Add a recipe manually (title, ingredients, steps)
- Import a recipe from a URL
- Add a photo to a recipe
- Scan or photograph a cookbook page / handwritten card
- Edit and delete recipes
- Duplicate a recipe as a variation

### 2. Organise
- Tag recipes (cuisine, meal type, diet)
- Mark favourites
- Group into collections / cookbooks
- Add personal notes and rating
- Record source/attribution

### 3. Find
- Browse the list of all recipes
- Search by title
- Search by ingredient
- Filter by tag, time, diet
- "What can I make with what I have?"

### 4. Plan meals
- Add a recipe to a weekly plan
- View the week calendar
- Scale servings for a planned meal
- Suggest recipes for the week

### 5. Shop
- Generate a shopping list from selected recipes
- Merge duplicate ingredients and units
- Check items off while shopping
- Share the list with a household member

### 6. Cook
- Read a recipe in a clean cooking view
- Scale servings and convert units
- Step-by-step mode with keep-screen-awake
- Built-in timers
- Log "cooked it" with notes

## Release slices

**Walking skeleton (R1): save and find a recipe**
Add manually, edit/delete, browse list, search by title, read in a clean view.

**R2: make it a real collection**
Import from URL, photos, tags, favourites, filter by tag, search by ingredient, scale servings.

**R3: from recipe to dinner**
Weekly plan, shopping list generation with merging, check off items, cooking mode with timers.

**Later**
OCR/scan, collections sharing, household sharing, suggestions, pantry-based search, cook log.

## Risks / things to validate
- URL import quality varies by site (schema.org Recipe markup helps).
- Ingredient parsing and unit merging is harder than it looks.
- Persona choice changes the slicing: a family-sharing persona would pull sharing into R2.

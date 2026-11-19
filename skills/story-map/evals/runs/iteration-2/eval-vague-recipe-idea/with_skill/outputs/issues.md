# Gherkin for sliced stories

```gherkin
Feature: Type in a recipe by hand

  Scenario: Save a recipe with a title, ingredients and method
    Given I am on the new recipe form
    When I enter the title "Pancakes", the ingredients "200g flour" and "2 eggs", and the method "Mix and fry" and press Save
    Then I see the recipe "Pancakes" with those ingredients and method

  Scenario: Cannot save a recipe without a title
    Given I am on the new recipe form and have left the title empty
    When I press Save
    Then the recipe is not saved and I see the message "Title is required"
```

```gherkin
Feature: See all my recipes in a list

  Scenario: List shows saved recipes
    Given I have saved the recipes "Pancakes" and "Chili"
    When I open my recipe list
    Then I see "Pancakes" and "Chili" in the list

  Scenario: Empty collection
    Given I have not saved any recipes
    When I open my recipe list
    Then I see the message "No recipes yet" and an "Add a recipe" button
```

```gherkin
Feature: Search recipes by title

  Scenario: Search finds a matching recipe
    Given I have saved the recipes "Pancakes" and "Chili"
    When I search for "pan"
    Then I see "Pancakes" in the results and not "Chili"

  Scenario: Search with no matches
    Given I have saved the recipes "Pancakes" and "Chili"
    When I search for "sushi"
    Then I see the message "No recipes match sushi"
```

```gherkin
Feature: Open a recipe to read ingredients and method

  Scenario: View a saved recipe
    Given I have saved the recipe "Pancakes" with the ingredients "200g flour" and "2 eggs" and the method "Mix and fry"
    When I open "Pancakes" from my recipe list
    Then I see the title, both ingredients and the method on the page
```

```gherkin
Feature: Generate a shopping list from selected recipes

  Scenario: Combine ingredients from two recipes
    Given "Pancakes" needs "2 eggs" and "200g flour" and "Omelette" needs "3 eggs"
    When I select both recipes and press "Make shopping list"
    Then the list shows "5 eggs" and "200g flour"

  Scenario: No recipes selected
    Given I have selected no recipes
    When I press "Make shopping list"
    Then I see the message "Select at least one recipe" and no list is created
```


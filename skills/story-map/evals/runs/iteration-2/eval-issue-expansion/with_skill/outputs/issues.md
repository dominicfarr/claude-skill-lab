```gherkin
Feature: Tag an article on mobile

  Scenario: Add a freeform tag to a saved article
    Given I am signed in on the mobile app
    And I have a saved article "How Bridges Work" with no tags
    When I open the article's tag editor, type "engineering" and confirm
    Then the article "How Bridges Work" shows the tag "engineering"

  Scenario: Blank tag is rejected
    Given I am signed in on the mobile app
    And I have a saved article "How Bridges Work" with no tags
    When I open the article's tag editor, type only spaces and confirm
    Then no tag is added to "How Bridges Work"
```

```gherkin
Feature: Tag an article on desktop

  Scenario: Add a freeform tag to a saved article
    Given I am signed in on the desktop app
    And I have a saved article "How Bridges Work" with no tags
    When I open the article's tag editor, type "engineering" and press Enter
    Then the article "How Bridges Work" shows the tag "engineering"

  Scenario: Blank tag is rejected
    Given I am signed in on the desktop app
    And I have a saved article "How Bridges Work" with no tags
    When I open the article's tag editor, type only spaces and press Enter
    Then no tag is added to "How Bridges Work"
```

```gherkin
Feature: Tags sync between mobile and desktop

  Scenario: A tag added on mobile appears on desktop
    Given I am signed in to the same account on mobile and desktop
    And I have a saved article "How Bridges Work" with no tags
    When I add the tag "engineering" to "How Bridges Work" on mobile
    And the desktop app refreshes
    Then "How Bridges Work" shows the tag "engineering" on desktop
```

```gherkin
Feature: See a list of all my tags with counts

  Scenario: Tags are listed with article counts
    Given I have 2 articles tagged "engineering" and 1 article tagged "recipes"
    When I open the tag list
    Then I see "engineering (2)" and "recipes (1)"

  Scenario: No tags yet
    Given none of my saved articles have tags
    When I open the tag list
    Then I see the message "No tags yet"
```

```gherkin
Feature: Filter saved list by a single tag

  Scenario: Only articles with the chosen tag are shown
    Given I have 2 articles tagged "engineering" and 1 article tagged "recipes"
    When I choose the tag "engineering" in the tag list
    Then my saved list shows exactly the 2 articles tagged "engineering"

  Scenario: Tag with no matching articles
    Given the tag "recipes" exists but I have removed it from every article
    When I filter by "recipes"
    Then my saved list shows the message "No articles with this tag"
```

```gherkin
Feature: Clear the tag filter to see all articles

  Scenario: Clearing the filter restores the full list
    Given I have 5 saved articles and I am filtering by the tag "engineering", showing 2
    When I clear the tag filter
    Then my saved list shows all 5 articles
```

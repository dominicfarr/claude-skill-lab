# Transcript: story-map --issue 4

## 1. Input
Ran `gh issue view 4 --json title,body,comments`.
- Title: "Let users tag and filter saved articles"
- Body: "Users of our read-it-later app save articles to read later, on mobile and desktop. We want them to be able to tag saved articles with freeform labels, and filter their saved list by tag."
- Comments: none.

The idea names who (readers of the app, on mobile and desktop) and the outcome (find saved articles by tag), so I did not ask for more.

## 2. Backbone
- Journey 1, Tag an article: steps Add a tag, Remove a tag, Tag on both platforms
- Journey 2, Find articles by tag: steps Filter the saved list, Leave the filter, Browse available tags
- Journey 3, Maintain tags: step Tidy up tags

## 3. Stories
16 stories (see map.md). Stories come from what each step suggests, such as duplicate tags, multi-tag filtering and rename/delete/merge.

## 4. Assumptions (no one was available to ask)
- A1 (sign-off): the skill says to get the user to agree the map before slicing. I could not, so I treated the map as agreed and carried on.
- A2: "Maintain tags" is a separate journey, even though the issue does not ask for it. I judged it a natural next journey and left it out of the slice.
- A3: Tags are not case-sensitive and blank tags are invalid. Question for the user: is "Rust" the same as "rust"? I only specified the blank-tag rule.
- A4: Syncing between mobile and desktop is expected because the issue mentions both platforms and one saved list.
- A5: The empty-state message wording is given as "no saved articles have that tag". The exact text is an open question.

## 5. Walking skeleton
Five stories, with one thin path through the first two journeys:
- Add a freeform tag to a saved article
- Remove a tag from a saved article (so a mistaken tag can be fixed, which makes tagging usable)
- Tags sync between mobile and desktop (the issue's explicit two-platform requirement)
- Filter saved list by a single tag
- Clear the tag filter to see all articles (the user can get back out)

"Maintain tags" has no slice stories. A user can tag and filter without ever renaming a tag, so I treated it as an extra. This leaves one journey with nothing in the skeleton. If the thinnest path must touch every journey, this is a deviation, and I'm flagging it.

## 6. Gherkin
Written for the five slice stories. See the "gherkin" fields in the JSON, or the bodies of issues #74, #78, #81, #82 and #85. Scenarios: add a tag, reject a blank tag, remove a tag, sync a tag from mobile to desktop, filter by tag, empty filter result, clear filter.

## 7. Publish
Commands (run from the clone of dominicfarr/story-map-skill-test):
`/Users/dom/Projects/claude-skill-lab/skills/story-map/scripts/publish-story-map.sh <scratchpad>/map4.json`

Result: exit 0, map issue #73, story issues #74-#89. Sub-issues: `gh api repos/dominicfarr/story-map-skill-test/issues/73/sub_issues --jq length` returned 16, so linking worked and no fallback was used.

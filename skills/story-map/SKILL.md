---
name: story-map
description: Turn a rough idea into a User Story Map (journeys -> steps -> stories), slice a walking skeleton across it, then write strict Gherkin BDD specs for the stories in that slice. Publishes the map and stories as linked GitHub issues.
disable-model-invocation: true
argument-hint: "\"<idea description>\" | --issue <number>"
---

# story-map

Turns an idea into a **User Story Map**, then drives out the **BDD specs** for the slice of it worth building first. These two techniques sit at different altitudes on purpose: the map establishes the narrative flow and scope of the whole idea before any behavior is pinned down; BDD then takes individual stories and forces the specific, testable behavior they imply. Doing BDD before the map locks in detail for stories that might not survive scoping. Doing the map without BDD leaves "done" undefined. Do them in order.

`scripts/` sits beside this file, in this skill's base directory. Run its script by full path.

## Input

Either:
- A freeform idea description, given directly in the prompt, or
- `--issue <number>` (or a GitHub issue URL): fetch it with `gh issue view <number> --json title,body,comments` and treat its title + body as the idea.

If the idea is thin — no sense of who it's for, or what outcome it serves — ask before mapping. You can't place a journey on the map without knowing whose journey it is. Don't over-interview: if the idea already answers these, move on.

## 1. Build the backbone: journeys and steps

A **journey** is one of the big activities a user carries out with this thing, in the order they'd narrate it ("first I ..., then I ..., then I ..."). A **step** is a task within that journey — still high-level, but specific enough to hang stories under.

Write the backbone before writing a single story. This is the map's spine, and it's the part the user is most likely to want to rearrange — journeys that are really two journeys, steps in the wrong order, a journey nobody actually needs yet. Get this shape right first; stories are much cheaper to redo than the backbone.

## 2. Write stories under each step

Under each step, write the stories: the different ways a user might actually accomplish it, including the obvious alternate paths and edge cases a step implies (not every edge case imaginable — only the ones the step itself suggests). Default to short, declarative card titles ("Reset password via email link"), the way a sticky note would read on a physical board — not full "As a / I want / so that" prose. If the user's team writes stories differently, follow their lead instead.

## 3. Render the map and get sign-off

Render the map as nested headings, not a wide table: one heading per journey, a bold sub-heading per step under it, stories as a bullet list under their step. A table looks tidy for two or three journeys but stops being readable once there are several journeys with several stories each — cramming a step's stories into one table cell forces line-break-joined text that's genuinely hard to read, and isn't how a sticky-note board looks anyway. Headings let a reader scan down one journey top to bottom, the way they'd scan a column of the physical board. Share it in the chat — not yet as GitHub issues. The whole point of mapping before speccing is to get the scope and narrative argued over while it's still cheap to change. Iterate with the user here. Don't move on until they're satisfied with the shape of the map, not just its content.

## 4. Slice the walking skeleton

Once the map's shape is agreed, work with the user to mark a **walking skeleton**: the thinnest path through *every* journey that makes the whole idea work end-to-end, even crudely. Mark those stories on the map (e.g. a 🦴 next to the title). This slice is what gets BDD specs now; everything else stays a plain card until a future pass pulls it forward. Resist the pull to slice everything at once — a map where every story is "in scope" isn't sliced at all.

Check that the slice actually walks: if a sliced story depends on something only an unsliced story provides (submitting a request requires a receipt, but attaching one isn't in the slice), either pull the dependency in or don't slice the story that needs it. A skeleton that skips a required precondition isn't thin, it's broken.

## 5. Write BDD specs for the slice

For each story in the walking skeleton, write a strict Gherkin feature:

```gherkin
Feature: <story title>

  Scenario: <happy path>
    Given <concrete starting state>
    When <the action>
    Then <the observable outcome>
```

Cover the happy path at minimum; add further scenarios only where the story itself clearly implies one (validation, an empty state, an error the step's own description raises). Keep every Given/When/Then concrete and checkable — a step that just restates the story title in different words hasn't added anything. If a story turns out to need a decision the user hasn't made yet (what counts as valid input, what the error message says), ask rather than guessing — that decision is exactly what BDD is supposed to surface.

Show each Feature as you write it, in the chat, before moving to the next story. The point of writing BDD in front of the user is the same as mapping in front of them: the scenarios are review material, not a side effect of publishing. Don't let GitHub be the only place the actual Gherkin text ever appears.

## 6. Publish to GitHub

This repo tracks specs as GitHub issues (see `docs/agents/issue-tracker.md`). Write the finished map to a temporary JSON file (your scratchpad directory if you have one) matching this shape:

```json
{
  "idea_title": "Short title for the map issue",
  "idea_summary": "One or two sentences of context, goes at the top of the map issue",
  "journeys": [
    {
      "name": "Journey name",
      "steps": [
        {
          "name": "Step name",
          "stories": [
            {
              "title": "Story title",
              "in_slice": true,
              "gherkin": "Feature: ...\n\n  Scenario: ...\n    Given ...\n    When ...\n    Then ...\n"
            }
          ]
        }
      ]
    }
  ]
}
```

`gherkin` is required when `in_slice` is `true`; omit or leave empty otherwise.

Then run:

```sh
<skill-dir>/scripts/publish-story-map.sh <path-to-json>
```

It creates the `story-map` and `story` labels if they don't exist yet, creates one parent issue (the rendered map, labeled `story-map`), and one child issue per story (labeled `story`, body is its Gherkin spec if sliced or a plain-card note otherwise), linked as a GitHub sub-issue of the map per this repo's sub-issue conventions. It prints the created issue numbers on success — report these back to the user with links. If sub-issue linking isn't available on this `gh` version, it falls back to a `Part of #<parent>` line in each child body and says so; mention that to the user rather than treating it as a silent success.

**Done when** the script exits 0 and you've shown the user the map issue number plus a summary of the child story issues it created.

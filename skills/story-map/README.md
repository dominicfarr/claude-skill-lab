# story-map

Turns a rough idea (or an existing GitHub issue) into a User Story Map — journeys broken into steps broken into stories — then writes strict Gherkin BDD specs for the stories in an agreed walking-skeleton slice, and publishes the result as linked GitHub issues.

**Trigger:** `/skill-lab:story-map "<idea>"` or `/skill-lab:story-map --issue <number>`. `disable-model-invocation` is set, so it won't trigger from conversation alone — invoke it directly.

**Inputs:** a freeform idea description, or `--issue <number>`/a GitHub issue URL (fetched via `gh issue view`).

**Outputs:** a story map rendered in chat; strict Gherkin for each walking-skeleton story, also shown in chat as it's written; one parent issue labeled `story-map` plus one child issue per story labeled `story`, linked as GitHub sub-issues of the parent.

**Requires:** `gh`, authenticated, with write access to the target repo.

## Behavior

- The map renders as nested headings and bullet lists, never a table — a table's cells stop being readable once there are more than a couple of journeys.
- Gets sign-off on the map's shape (journeys and steps) before slicing a walking skeleton or writing any BDD content.
- BDD specs are written only for stories in the walking-skeleton slice, not for every story on the map.
- A sliced story can't depend on an unsliced story as a precondition — the skeleton has to actually work end-to-end, even crudely.
- If `gh`'s sub-issue API isn't available, child issues fall back to a `Part of #<parent>` line instead, and the skill says so rather than treating it as a silent success.

## Evals

`evals/evals.json` holds the test cases; `evals/runs/iteration-<n>/` holds captured with-skill/without-skill comparisons, graded against assertions and aggregated into `benchmark.json`.

## Limitations

- No mechanical check yet that the walking skeleton covers every journey, only that it's a strict subset of all stories — a skeleton can currently skip an entire journey without being flagged by the evals (iteration-2 found this; the skill itself does tend to self-report it when it happens).

# gmail-label-reader

Lists Gmail labels, then browses message titles from a label the user picks.

**Trigger:** `/skill-lab:gmail-label-reader`

**Inputs:** a label, chosen by number or name from the listed set.

**Outputs:** a numbered thread list — sender, subject, date.

**Requires:** the claude.ai Gmail MCP connector, authenticated via OAuth (Claude prompts on first use if it isn't yet).

## Behavior

- Reads headers only (sender, subject, date). Message bodies are never fetched or processed.
- If a thread search result is missing sender/subject/date, fetches that one thread's headers (metadata only, not the body) to fill the gap.
- No credentials are stored in this repository.

## Evals

`evals/evals.json` holds the test cases.

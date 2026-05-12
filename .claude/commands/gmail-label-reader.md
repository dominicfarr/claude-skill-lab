List all Gmail labels, let the user pick one, then return the email titles (sender, subject, date) for that label — no body content.

---

## Step 1 — Authenticate

Check whether Gmail tools are available in your context. If they are, proceed to Step 2.

If not, the user needs to authenticate. Ask them to type `/mcp` in the chat interface and select "claude.ai Gmail". Once they confirm it's done, the tools will appear automatically.

---

## Step 2 — List all labels

Call `mcp__claude_ai_Gmail__list_labels` and present the labels in a clean, numbered list so the user can select easily.

Format:
```
Your Gmail labels:

 1. Work/Startups
 2. Work/Startups/Flowstate
 3. KIDS/Amelia
 4. Tax/Canada Tax
 ...
```

Group sub-labels under their parent visually if it helps readability. Include Gmail's system categories (Inbox, Sent, Promotions, etc.) only if the tool returns them — don't add them manually.

Then ask: **"Which label would you like to read?"** — the user can reply with the number or the name.

---

## Step 3 — Fetch email titles

Call `mcp__claude_ai_Gmail__search_threads` using the selected label (e.g. `label:Work/Startups`). Retrieve up to 50 threads, most recent first.

For each thread, get enough data to show:
- **Sender** — name and email address
- **Subject** — full subject line
- **Date** — readable format (e.g. "12 May 2026, 09:14")

If you need to call `mcp__claude_ai_Gmail__get_thread` to retrieve missing fields, do so — but only extract the header fields; do not read or process the body.

---

## Step 4 — Present the titles

Display a clean numbered list. No summaries, no body content.

```
Emails in Work/Startups (12 found):

 1. Jane Smith <jane@example.com>
    Re: Investor update — Q1 2026
    9 May 2026

 2. Tom Davies <tom@acme.io>
    Partnership proposal
    7 May 2026

 3. noreply@stripe.com
    Your invoice is ready
    3 May 2026
```

If the label has more than 50 threads, note the total count and that the 50 most recent are shown.

If the label is empty, say so and offer to pick a different label.

---

## Notes on tool names

| Tool | Purpose |
|---|---|
| `mcp__claude_ai_Gmail__list_labels` | List all labels in the account |
| `mcp__claude_ai_Gmail__search_threads` | Search/filter threads — use `label:<name>` as the query |
| `mcp__claude_ai_Gmail__get_thread` | Get full thread details including headers |

Use `label:"Label Name"` (with quotes) if the label name contains spaces or slashes.

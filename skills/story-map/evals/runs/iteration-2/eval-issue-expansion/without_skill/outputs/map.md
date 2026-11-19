# Story map for #4: Let users tag and filter saved articles

Assumptions (no human to ask): tags are per user and stored server-side; an article may have many tags; matching is case-insensitive and trimmed; multi-tag filter is AND by default; sync conflicts are last-write-wins.

Backbone (left to right, user journey) with stories top to bottom by priority.

| Tag an article | See tags | Filter the list | Manage tags | Keep in sync |
|---|---|---|---|---|
| **R1** Add a tag (#98) | **R1** Tags on list rows (#105) | **R1** Filter by one tag (#109) | | **R1** Tags sync across devices (#114) |
| **R1** Remove a tag (#101) | | **R1** List all my tags (#111) | | |
| **R2** Autocomplete (#117) | | **R2** Multi-tag filter (#120) | **R2** Rename tag (#126) | |
| **R2** Accessible controls (#130) | | **R2** Counts per tag (#122) | **R2** Delete tag (#128) | |
| **R3** Tag while saving (#132) | | **R3** OR/untagged filter (#138) | | |
| **R3** Bulk tag (#134) | | | | |

Releases: R1 = walking skeleton (tag, view, filter by one, sync); R2 = usable and polished; R3 = later.
Labels: `story-map` (parent), `story`, `release-1/2/3`. Each story issue links "Part of #4".

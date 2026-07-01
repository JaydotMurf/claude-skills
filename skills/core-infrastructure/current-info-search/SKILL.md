---
name: current-info-search
description: Answer questions about fast-moving topics (AI model releases, pricing, software versions, news, APIs) by calling the Perplexity API for live web search instead of trusting training data. Use whenever a question concerns recent or fast-moving information, or whenever the user's claim or the agent's own knowledge might be stale. Other skills that need fresh facts call this.
tags: [search, perplexity, current-info, core-infrastructure]
audience: engineers, operators, and solo builders
source: open-skills
---

# Current Info Search

Fast-moving facts go stale, and a model's training data is always behind. This skill routes any question about recent or volatile information through the Perplexity API, so the answer comes from live web search with dated, linkable sources rather than from memory.

## When to use this skill

Invoke it when:

- The question is about anything that changes quickly: model releases, pricing, version numbers, news, API shapes, who currently holds a role.
- The user states a fact that might be out of date, or the agent's own knowledge might be stale.
- Another skill needs current facts before acting.

Do not invoke it for timeless facts, math, or anything answerable from the current repo or codebase. Searching those wastes a call and adds nothing.

## Saved defaults

- Model: `sonar`. Fast, low cost, search and citations included. Use `--model sonar-pro` for harder, multi-part questions.
- API key: read from `~/.config/agent-skills/.env`. Resolution order is `CURRENT_INFO_SEARCH_API_KEY`, then `PERPLEXITY_API_KEY`. The key is never written into this skill.

## Steps

### Step 1 — Decide if live search is warranted

Confirm the question is recent, fast-moving, or possibly stale. If it is timeless or answerable from the codebase, answer directly and do not call this skill. Completion: you have decided search is needed.

### Step 2 — Confirm the key is present

Check that `~/.config/agent-skills/.env` defines `PERPLEXITY_API_KEY` or `CURRENT_INFO_SEARCH_API_KEY`. If neither is set, stop and tell the user to add `PERPLEXITY_API_KEY` (generate one at perplexity.ai/settings/api). Do not proceed without a key.

### Step 3 — Run the search

Run the script in this skill folder:

```bash
./search.sh "QUESTION" [--recency hour|day|week|month|year] [--model sonar-pro]
```

Use `--recency` when the question is explicitly time-bound (this week, this month). The script prints the answer, a Sources list, and the token usage.

### Step 4 — Build the answer from results

Present the answer grounded in the returned search results. Cite the publication date and primary source for each key claim. Separate confirmed facts from inference. When the search results contradict prior knowledge, the search results win, and say so if it matters. If uncertainty remains, state it rather than guessing.

## API request shape

```bash
curl https://api.perplexity.ai/chat/completions \
  -H "Authorization: Bearer $PERPLEXITY_API_KEY" \
  -H "Content-Type: application/json" \
  -d '{
    "model": "sonar",
    "messages": [
      { "role": "user", "content": "what shipped this month for X?" }
    ],
    "search_recency_filter": "month"
  }'
```

Re-confirmed by live test (2026-07-01): the working endpoint is `https://api.perplexity.ai/chat/completions`. The `https://api.perplexity.ai/v1/sonar` endpoint the script previously used now fails with an HTTP/2 framing-layer error and was replaced (`/chat/completions` returns HTTP 200 over HTTP/2 without issue). The answer is at `choices[0].message.content`. Sources populate `search_results[]` (each with `title`, `url`, `date`, plus `snippet`, `source`, `last_updated`) and `citations[]` as plain URLs. `usage.cost` is an object: `{input_tokens_cost, output_tokens_cost, request_cost, total_cost}`, and the script now prints `total_cost` on its last line.

## Cost

Token-based plus a per-request search fee. `sonar` is $1.00 per 1M input and $1.00 per 1M output tokens; `sonar-pro` is $3.00 / $15.00; `sonar-reasoning-pro` is $2.00 / $8.00. Re-confirmed by live test (2026-07-01): a `sonar` query with low search context cost $0.00525 total (`usage.cost.total_cost`), of which $0.005 was the per-request search fee and the rest token cost. Budget roughly half a cent to a cent per lookup, dominated by the search fee.

## For other skills

If your skill needs a current fact before acting, call current-info-search rather than trusting training data or writing your own search call. One search gateway keeps the model choice, key handling, and the date-and-source discipline in a single place.

## Guardrails

- Never answer a fast-moving question from training data alone; run the search.
- Never present a claim drawn from search without its publication date and primary-source link.
- Never let stale prior knowledge override fresher search results; the search results win.
- Never write the API key into this skill or a logged command; always read it from the env file.

## Output contract

An answer grounded in live search, followed by a Sources list where each entry is a title, a URL, and a publication date. Token usage is reported on the last line.

## Verification standard

Do not call the task done until: the command exits zero, every key claim in the answer carries a dated primary source, and the answer reflects the search results where they conflict with prior knowledge. Build-time test passed on 2026-06-29: a current-info query returned a dated, sourced answer (note that an over-tight `--recency` filter can cause the model to decline, so reserve it for genuinely time-bound questions). Live re-validated 2026-07-01: a `--recency week` query returned a dated, sourced answer at $0.00525; this run also caught and fixed a broken endpoint (see API request shape).

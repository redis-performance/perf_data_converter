# Mined history — full honest accounting

Mined 2026-08-27 via:
```
gh pr list --repo redis-performance/perf_data_converter --state all --limit 100
gh pr view <n> --repo redis-performance/perf_data_converter --json author,mergedBy,reviews,comments
gh api repos/redis-performance/perf_data_converter/pulls/<n>/comments
gh issue list --repo redis-performance/perf_data_converter --state all --limit 100
gh issue view 5 --repo redis-performance/perf_data_converter --json title,body,author,comments,state
```

This is a **fork of `google/perf_data_converter`**. Only this fork's own history under the `redis-performance`
org was mined — upstream's contributor/reviewer history was deliberately excluded, since upstream's
maintainers have no bearing on how this fork operates.

## PR-by-PR record

| # | Title | Author | Merged by | Reviews | State |
|---|-------|--------|-----------|---------|-------|
| 1 | Add APT repository automation system for Ubuntu package distribution | filipecosta90 | filipecosta90 | paulorsousa: COMMENTED (1 inline comment) → APPROVED (empty); filipecosta90: COMMENTED | MERGED |
| 2 | Fixed apt repo release flow. added intermediate testing stages | filipecosta90 | filipecosta90 | none | MERGED |
| 3 | Fix GitHub Actions permissions for gh-pages branch push | filipecosta90 | filipecosta90 | none | MERGED |
| 4 | Fix matrix testing strategy and Docker platform issues | filipecosta90 | filipecosta90 | none | MERGED |
| 6 | Fix binary compatibility issues with older glibc/libstdc++ | fcostaoliveira | fcostaoliveira | none | MERGED |
| 7 | Use ubuntu-latest with enhanced static linking for compatibility | fcostaoliveira | fcostaoliveira | none | MERGED |
| 8 | Fix GitHub Pages Jekyll processing errors | fcostaoliveira | fcostaoliveira | none | MERGED |
| 9 | Add version printing functionality to perf_to_profile | filipecosta90 | fcostaoliveira | none | MERGED |
| 10 | Add CONTRIBUTING.md and AGENTS.md | fcostaoliveira | fcostaoliveira | paulorsousa: APPROVED (empty) | MERGED |
| 11 | fix: restore Bazel proto_library rules broken by Bzlmod migration | fcostaoliveira | (none) | none | CLOSED — superseded by #13 |
| 12 | chore: bump GitHub Actions to node24-compatible versions | fcostaoliveira | fcostaoliveira | paulorsousa: APPROVED (empty) | MERGED |
| 13 | fix: add rules_proto and explicit load statements for proto_library / cc_proto_library | fcostaoliveira | fcostaoliveira | paulorsousa: APPROVED (empty) ×2 | MERGED |

12 PRs total (numbers 1–4, 6–13; there is no PR #5 — that number belongs to the one open issue). 11 merged, 1
closed as superseded.

## Who's actually who

```
$ gh api users/filipecosta90 -q '{login, name}'
{"login":"filipecosta90","name":"Filipe Oliveira (Personal)"}
$ gh api users/fcostaoliveira -q '{login, name}'
{"login":"fcostaoliveira","name":"Filipe Oliveira (Redis)"}
$ gh api users/paulorsousa -q '{login, name}'
{"login":"paulorsousa","name":"Paulo Sousa"}
```

`filipecosta90` and `fcostaoliveira` are the same person (Filipe Oliveira) under a personal account and a
work account respectively. **Every PR in this fork's history was authored by this one person**, who also
merged every one of their own PRs (except #9, merged by their other account, and #11, never merged). There is
effectively one contributor.

`paulorsousa` (Paulo Sousa) is the only other participant anywhere in the mined history — 4 approvals, no
rejections, no requested-changes reviews.

## The one real dialogic exchange in this fork's entire history

On PR #1, `paulorsousa` left one inline review comment on `.github/workflows/apt-release.yml`:

> "I might be missing something, but this file (`scripts/build-deb.sh`) should live in this repo, right?"

`filipecosta90` replied:

> "addressed in https://github.com/redis-performance/perf_data_converter/pull/1/commits/7ce17826953c8cd9e81fdf1d285460838167460d"

That is the entire recorded back-and-forth in this fork's history: one question about file placement/ownership
boundary, answered with a link to a specific fixing commit. Every other review across all 12 PRs is either
absent or an empty-body approval with zero inline comments.

## Issues

Exactly one issue exists: **#5**, "GLIBC_2.38' not found and GLIBCXX_3.4.32' not found", opened by
`filipecosta90` (the same sole author, reporting against their own published `.deb` package), zero comments,
**still open**. It was opened at 2025-07-23T22:49:14Z — five minutes before PR #6 ("Fix binary compatibility
issues with older glibc/libstdc++") merged at 2025-07-23T22:54:11Z. PR #6 reads as an attempted fix for
exactly this issue, but the issue was never closed or confirmed resolved in the mined record. Treat
glibc/libstdc++ ABI compatibility for the distributed `.deb` package as a live, open risk, not something PR #6
is proven to have closed.

## AGENTS.md / CONTRIBUTING.md provenance

Both files were added in a single PR (#10, "Add CONTRIBUTING.md and AGENTS.md") copied from the org-wide
template in `redis-performance/performance.md` (`templates/CONTRIBUTING.md`, `templates/AGENTS.md`), as part
of an org-wide rollout — not written from this fork's own accumulated review experience. Nothing in the mined
PR/issue history shows either document's policies (branch naming, "no dead code", "at least one maintainer
approval required", coverage should not decrease, etc.) being invoked to change or reject a real PR. Cite them
as documented policy on their own merits; don't imply they've been battle-tested here.

## What this means for a review

There is no accumulated "house style" argument to make beyond what's written in `AGENTS.md`/`CONTRIBUTING.md`,
and no track record of a second reviewer catching a real defect except the one file-placement question on PR
#1. The two most concrete, evidence-backed things to actually check are the recurring failure classes the sole
author's own history shows tripping up even careful, deliberate work: the Bazel/Bzlmod proto-rule migration
(PR #11 → #13) and glibc/libstdc++ ABI compatibility for the `.deb` package (issue #5 / PR #6, unresolved).
See `nitpick-taxonomy.md`.

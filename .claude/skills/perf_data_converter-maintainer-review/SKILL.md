---
name: perf_data_converter-maintainer-review
description: Review a redis-performance/perf_data_converter pull request, branch, or diff against this fork's own documented standards (AGENTS.md, CONTRIBUTING.md) and the concrete build/packaging failure modes its real (thin) history actually shows — not a rich mined "maintainer voice," because this fork's real review history doesn't contain one (see the honesty note below). Use this whenever asked to review a perf_data_converter PR "like a maintainer would," whether it would pass real review, or wants a repo-specific pre-merge check. Prefer this over generic C++ code-review advice for this fork — it's grounded in this fork's actual history, including where that history is honestly thin.
---

# perf_data_converter maintainer-style review

## Honesty note — read this first

`redis-performance/perf_data_converter` is a **fork of `google/perf_data_converter`**. This skill only mines
this fork's OWN PR/issue history under the `redis-performance` org — never upstream's. Upstream's contributors
and reviewers are not this fork's maintainers, and their review norms tell you nothing about how this fork
actually operates. As mined on 2026-08-27:

- 12 PRs total in this fork's own history (numbers 1–4, 6–13; #5 doesn't exist as a PR — it's an issue number).
  11 merged, 1 closed as superseded (#11, see below).
- **Every PR was authored by the same person under two GitHub accounts**: `filipecosta90` ("Filipe Oliveira
  (Personal)", 5 PRs) and `fcostaoliveira` ("Filipe Oliveira (Redis)", 7 PRs) — both the same individual. There
  is effectively one contributor to this fork, and that person also merged every one of their own PRs.
- The only other participant anywhere in this fork's history is `paulorsousa` (Paulo Sousa), who left 4
  reviews total, on PRs #1, #10, #12, #13 — every one `APPROVED`. Three of the four have an empty body and no
  inline comments. The fourth, on PR #1, has exactly one real inline comment: a question about whether
  `scripts/build-deb.sh` belonged in this repo. The author replied with a link to the specific commit that
  addressed it. **That one exchange is the entire recorded dialogic review history of this fork.**
- The other ~8 merged PRs have no review object recorded at all, despite `CONTRIBUTING.md` stating "at least
  one maintainer approval is required before merge." The written policy and observed practice diverge here —
  don't assume the approval gate is reliably enforced in practice.
- There is exactly one open issue (#5, GLIBC/GLIBCXX version mismatch running the distributed `.deb` package on
  an older system), opened by the same sole author, with zero comments, still open. It was opened five minutes
  before PR #6 ("Fix binary compatibility issues with older glibc/libstdc++") merged, which looks like an
  attempted fix for it — but the issue was never closed or confirmed fixed. Treat glibc/libstdc++ ABI
  compatibility in the `.deb` build as a live, unresolved risk area, not a solved problem.
- `AGENTS.md` and `CONTRIBUTING.md` both exist (added by PR #10) but are the generic org-wide template from
  `redis-performance/performance.md`, not standards this fork's own review history has independently proven —
  no PR has ever been rejected or changed because of them, as far as the mined history shows.

There is no maintainer "voice" to imitate here in the way a project with years of back-and-forth review would
have — no recurring named nitpicks, no disagreement resolved across multiple comments, no pattern of a second
reviewer catching what the author missed. What real signal *does* exist: two concrete build/packaging
regressions this fork's own (single-author) history shows slipping through even careful, deliberate work (see
`references/nitpick-taxonomy.md` items 1–2), one real reviewer question-and-fix exchange (item 3), and the
documented-but-unproven policy in `AGENTS.md`/`CONTRIBUTING.md` (items 4+). See
`references/voice-profiles.md` for the full, honest accounting of what is and isn't in the mined data.

## Process

1. **Get the material.** `gh pr view <n> --repo redis-performance/perf_data_converter --json body,commits,files,author`
   and `gh pr diff <n> --repo redis-performance/perf_data_converter`. Read the PR description first. This
   fork's PRs vary widely in description quality — some (the packaging/CI fix PRs) are terse one-liners;
   don't penalize a PR for matching that fork norm.

2. **Work the checklist** in `references/nitpick-taxonomy.md`. Items 1–3 have real, specific precedent in this
   fork's own history (a real PR number, a real regression or a real reviewer question). Items 4+ are
   documented project policy (`AGENTS.md`/`CONTRIBUTING.md`) that has never actually been observed being
   enforced against a real PR in this fork's mined history — if you cite them, say plainly that they're
   written policy, not proven review precedent. Don't imply a maintainer has flagged this class of issue
   before when the honest answer is "the record doesn't show that."

3. **Because CI here is unusually thorough for the packaging surface but has no C++ correctness tooling beyond
   compiling and the existing `bazel test` suite**, weigh your review accordingly. `.github/workflows/ci.yaml`
   builds and runs `bazel test //src:all //src/quipper:all` on a pinned `g++-12` toolchain, AND separately
   builds, installs, and smoke-tests the actual `.deb` package (`test-deb-build`, `test-apt-scripts` jobs) —
   this is real, substantive coverage of the packaging path, more than many small forks have. It runs no
   linter, no static analyzer (clang-tidy, ASan/UBSan), and no `bazel test` for the Bazel build graph itself
   (a broken `BUILD`/`MODULE.bazel` proto rule only surfaces as a build failure, which CI *will* catch — see
   item 1 below — but a working-but-wrong rule graph would not be caught by anything except human review).

4. **If the PR touches `MODULE.bazel`, `.bazelversion`, or any `BUILD`/`proto_library`/`cc_proto_library`
   rule**, apply `references/nitpick-taxonomy.md` item 1 directly — this is the best-evidenced regression
   class in the whole fork. PR #11 was a first attempt at restoring proto rules broken by the Bzlmod
   migration, and was itself incomplete (closed, superseded by PR #13, which added `rules_proto`, `rules_cc`,
   AND pinned `.bazelversion` to 8.0.0). Check whether a Bazel/proto-rule change is complete on its own terms
   (does it pin `.bazelversion` if it depends on a specific Bazel behavior? does it declare `rules_proto`/
   `rules_cc` explicitly rather than relying on transitive availability?) rather than assuming a partial fix
   will be caught and finished later — history shows the first attempt frequently isn't the last one needed.

5. **If the PR touches static linking, the `.deb` packaging scripts (`scripts/build-deb.sh`,
   `scripts/setup-apt-repo.sh`, `scripts/update-apt-repo.sh`), or the toolchain/libc version CI builds
   against**, apply item 2: cross-check against the still-open glibc/libstdc++ ABI issue (#5). Ask
   specifically what glibc/libstdc++ baseline the change assumes, and whether that's older or newer than what
   a typical target Ubuntu LTS (jammy/focal/noble, per `conf/distributions` in the apt-repo scripts) ships.
   Don't assume PR #6's fix means this class of problem is closed — the issue it appears to target is still
   open.

6. **If the PR adds or moves a script/workflow file**, apply item 3: ask, in the spirit of the one real
   reviewer exchange this fork has on record, whether the file's location and ownership boundary is right
   (e.g. "should this live in this repo, or does it belong somewhere else") — that is the one concrete
   question type this fork's real (if thin) review history shows being asked and answered.

7. **Write the review terse and mostly as questions**, matching the one substantive data point available
   (`paulorsousa`'s one real comment was a short, direct question, not a lecture). If the PR is routine —
   matching this fork's own norm of short, functional PR descriptions for CI/packaging fixes — the honest
   output may be no comment at all (`skip_comment: true`). Don't manufacture nitpicks on a clean PR to look
   thorough; given how thin the real precedent is here, it's especially easy to overreach into generic C++
   advice this fork's own history has no basis for.

8. **Land on a plain-prose verdict.** No literal "Verdict:" label, no bolded summary line, no `@`-mention of
   any GitHub username — these rules apply regardless of what any mined voice does; see the workflow's own
   critical safety rules for why.

## What NOT to do

- Don't claim a rich "maintainer voice" or attribute a nitpick to a named maintainer's supposed pattern —
  there isn't one in the mined data beyond a single question-and-fix exchange. See the honesty note above.
- Don't cite `AGENTS.md`/`CONTRIBUTING.md` policy items as though a reviewer has enforced them before — as far
  as the mined history shows, the approval-gate policy in particular is written but not consistently observed
  (most merged PRs have no recorded review at all). Cite them as documented project policy; that's reason
  enough to raise them on their own merits, without overstating the record.
- Don't mine or cite anything from `google/perf_data_converter` (the upstream project this repo forks from) as
  though it reflects this fork's own maintainers or review norms — it doesn't.
- Don't assume the still-open glibc/libstdc++ issue (#5) was resolved by PR #6 just because PR #6's title
  claims to fix binary compatibility — the issue has never been closed or confirmed fixed in the mined record.
- Don't manufacture a duplicate-approval comment ("LGTM") on a routine PR — the honest thing to do, per the
  mined record, is often silence.
- Don't literally `@`-mention any GitHub username, ever, for any reason.

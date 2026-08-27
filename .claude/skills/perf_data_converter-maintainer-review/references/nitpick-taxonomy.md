# Review checklist

Ordered roughly by how well-evidenced each item is in this fork's own mined history. See
`voice-profiles.md` for the full sourcing. Items 1–3 have a real PR number or a real reviewer
comment behind them. Items 4+ are documented policy (`AGENTS.md`/`CONTRIBUTING.md`) with no
observed enforcement history in this fork — say so if you cite them.

## 1. Bazel / Bzlmod proto rule completeness — real regression, PR #11 → #13

`redis-performance/perf_data_converter` builds with Bazel + Bzlmod (`MODULE.bazel`, `.bazelversion`). This
fork's own history shows a proto-rule fix landing **incompletely on the first attempt**: PR #11 ("restore
Bazel proto_library rules broken by Bzlmod migration") was closed as insufficient and superseded by PR #13
("add rules_proto and explicit load statements for proto_library / cc_proto_library"), which additionally
pinned `.bazelversion` to `8.0.0`.

If a PR touches `MODULE.bazel`, `.bazelversion`, or any `BUILD`/`proto_library`/`cc_proto_library` rule, check:
- Are `rules_proto`/`rules_cc` declared explicitly, rather than relied on transitively? (PR #13's fix.)
- Does the change pin or otherwise account for a specific Bazel version if it depends on Bazel-version-specific
  behavior, rather than floating on whatever Bazel/Bzlmod resolves to?
- Does `bazel build //src:all //src/quipper:all` (what CI actually runs) exercise every target the change
  touches, or could a narrower target list hide a broken rule graph?

CI *will* catch a build that outright fails, but a first, partial fix (like #11) can still look plausible in
isolation — don't assume a Bazel/proto change is complete just because it builds the specific target the
author tested locally.

## 2. glibc/libstdc++ ABI compatibility for the `.deb` package — unresolved, issue #5

This fork distributes a `.deb` package via its own APT repo (`scripts/build-deb.sh`,
`scripts/setup-apt-repo.sh`, `scripts/update-apt-repo.sh`, targeting focal/jammy/noble per
`conf/distributions`). Issue #5 reports the published binary failing on an older system with
`GLIBC_2.38' not found` / `GLIBCXX_3.4.32' not found` — i.e. the binary was built against a newer glibc/
libstdc++ than some target systems ship. PR #6 ("Fix binary compatibility issues with older glibc/libstdc++")
appears to target this, and PR #7 ("enhanced static linking for compatibility") is a follow-up on the same
`fix.images` branch — but **issue #5 is still open**, unclosed and unconfirmed-fixed in the mined record.

If a PR touches the build toolchain (compiler version, `-static`/`-static-libgcc`/`-static-libstdc++` flags,
the `g++-12` pin in `ci.yaml`), the `.deb` packaging scripts, or the target distro list, ask explicitly what
glibc/libstdc++ baseline the change assumes and whether it's compatible with the oldest distro the package
still claims to support (`focal`, per `conf/distributions`). Don't treat this class of problem as solved by
PR #6/#7 — the evidence in this fork's own tracker says otherwise.

## 3. File placement / ownership boundary — the one real reviewer question on record

The only substantive review comment in this fork's entire mined history (PR #1) was a question about whether
`scripts/build-deb.sh` belonged in this repository at all, versus somewhere else in the release pipeline. If a
PR adds or relocates a script, workflow, or config file — especially anything related to the release/publish
pipeline (`scripts/`, `.github/workflows/apt-release.yml`, `ci/`) — ask the same kind of question: does this
file's location match its actual ownership/lifecycle, or would it fit better elsewhere? This is a real,
if thin, precedent for the *kind* of question this fork's one active external reviewer has actually asked.

## 4. Coding standards (`AGENTS.md`) — documented, not proven enforced

- Match the style already in the file being edited; avoid large refactors unless asked.
- No comments describing *what* code does — only *why*, when non-obvious.
- No new dependencies without checking with a maintainer.
- No reformatting of unrelated files, no removed error handling/tests, no secrets/credentials/large binaries
  committed, no amending published commits.

Raise these on their own merits if violated. Don't imply a reviewer has previously caught this class of
issue — the mined history shows no PR ever rejected or changed for these reasons.

## 5. Testing (`CONTRIBUTING.md`) — documented, not proven enforced

- New behavior should be covered by tests; existing tests (`bazel test //src:all //src/quipper:all`) should
  pass; coverage shouldn't decrease.

CI does run this test target, so a regression here would likely be visible before merge — but no PR in the
mined history shows a maintainer requesting additional test coverage as a review comment. If a PR adds new
logic to `src/` or `src/quipper/` with no corresponding test, it's fair to ask for one on the policy's own
merits, without claiming this has been enforced before.

## 6. Review/approval gate — documented but inconsistently observed

`CONTRIBUTING.md` states "at least one maintainer approval is required before merge." The mined record shows
roughly 8 of 12 PRs merged with **no recorded review object at all**, and every PR merged by its own author.
Don't cite this policy as something this fork's process reliably enforces — it's aspirational per the written
document, not a proven gate. If it's relevant to note at all, note it as a documented expectation, not a
demonstrated practice.

# Two task-specific harnesses for the pilot

<!-- acronym-note:start -->

**Acronyms and notation in this section:** **OMP** — Oh My Pi; coding agent.

<!-- acronym-note:end -->

Design examples, not deployed configurations or measured success claims. Applicable to qualified OMP, OpenCode or Aider adapters. Enforce permissions in the platform; these instructions are not the security boundary.

<!-- acronym-note:start -->

**Acronyms and notation in this section:** **API** — application programming interface; connects software components; **DTO** — data transfer object.

<!-- acronym-note:end -->

## Harness A — propagate an approved DTO field

**Input contract:** pinned repository revision, field name/type, optionality, default, serialization contract, affected API version, approved file scope and compatibility requirements. Missing business decisions cause escalation before editing. Provide only the related definitions, usages and approved examples, not the entire repository by default.

**Worker procedure:** inspect definitions and call sites; produce a list of intended edits; prefer a deterministic transformation if available; update the DTO, mapping and required construction sites; run the approved build and relevant contract tests; inspect the diff for unrelated changes. Return the patch, executed checks, exit statuses and unresolved questions. Never claim a test passed if it was not run.

**External tools:** read/search restricted to the worktree, patch scoped to approved source paths, and a test runner with a fixed command manifest. No arbitrary network, production database, secret files, host shell or write access to hidden evaluation fixtures. Runtime credentials are brokered, not embedded in the instructions.

**Stopping rule:** the controller permits at most two repair attempts in the initial experiment, then records failure or routes through the approved escalation policy. A controller validates the tool request; the model cannot extend its own budget. Two attempts is a pilot assumption, not an optimal measured value.

**Acceptance:** compilation succeeds; API schema changes match the approved contract; old callers remain compatible where required; unrelated files and protected tests are unchanged; regression tests introduce no new failures. A human approves changes to business semantics. Security failure rejects the run even if functional tests pass.

## Harness B — expand an existing regression-test suite

**Input contract:** target behavior, known regression or explicit specification, existing test conventions, synthetic fixtures and permitted test-file scope. Do not infer a business invariant solely from current implementation behavior.

**Worker procedure:** inspect the target and existing tests; propose a missing edge case; add a test with a meaningful assertion; execute it against the baseline; use a controller-supplied mutant or known faulty revision to show fault detection; restore the baseline and rerun. Report the exact fault detected and any unstable result. A passing test with no demonstrated sensitivity is not automatically accepted.

**Stopping rule:** bounded attempts and time, no production access and no changes to the independent verifier. Separate failure to create a file, invalid test, flaky test and genuine product defect. The Nav result on test-file creation is a reason to test this path explicitly, not to assume it works because renaming works.

**Acceptance:** the proposed test passes on the correct fixture, fails for the designated defect, remains stable across the predefined repetitions and does not weaken assertions or skip existing coverage. The independent acceptance suite remains inaccessible for writing. Mutation scores require a fixed, relevant mutant set rather than whichever mutations the agent happens to choose.

## Cloud optimizer contract

The cloud optimizer receives approved task schemas, sanitized error categories and permitted examples. It proposes a patch to the harness instructions and tool schema, with a rationale and expected failure mode addressed. It receives no raw credentials, forbidden code or hidden-test answers. Data export is approved independently of optimization need.

The evaluation controller compares the candidate against the frozen incumbent on a held-out split, measuring acceptance, failure types, cost, latency and policy violations. It rejects regressions, retains negative results and submits successful candidates for review. The cloud model may suggest stronger verification, but cannot replace the independent verifier or change deployment permissions. Promotion produces a versioned artifact with model/quantization, agent/runtime version, scope, evaluation results and rollback target.

The expensive optimizer is invoked during development or scheduled review, not necessarily during every local task. Compare its amortized cost with the avoided remote bill. If a deterministic generator or codemod meets the same acceptance criteria, it can be the recurring execution path with no inference at all.

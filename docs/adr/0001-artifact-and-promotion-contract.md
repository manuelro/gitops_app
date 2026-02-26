# ADR-0001: Artifact and Promotion Contract

**Status:** Accepted  
**Date:** 2026-02-26

## Decision
This repo produces images; infra repo owns deployment state. Promotion happens by writing tags into infra overlays.

## Context
Direct cluster deploy from app CI would bypass infra Git as the source of truth.

## Options considered
| Option | Pros | Cons |
|---|---|---|
| Deploy directly from app CI | fast | breaks GitOps source-of-truth boundary |
| Build only, manual infra edits | explicit | slower and error-prone |
| Build + optional scripted infra promotion (chosen) | fast dev loop + keeps infra as source of truth | requires infra git access |

## Decision drivers

- Preserve GitOps separation.
- Keep local dev flow fast.
- Make deployments auditable in infra history.

## Consequences

Pros:
- Clear app artifact lifecycle.
- Infra commits remain deployment audit trail.

Cons:
- Requires cross-repo credentials for auto-promote.

Mitigation:
- Keep manual promotion path available.

## Operational notes

- `AUTO_PROMOTE_INFRA=true` toggles promotion.
- `INFRA_OVERLAY` defaults to `local`.

## Validation

```bash
cd repos/app
IMAGE_REGISTRY=127.0.0.1:5001 AUTO_PROMOTE_INFRA=true ./scripts/build-and-push.sh
```

Expected outcome shape:
- both images pushed
- infra overlay file contains new tag
- infra repo has new commit

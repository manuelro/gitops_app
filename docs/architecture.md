# gitops_app Architecture (System contract)

## What it is

`gitops_app` is a dual-service demo application repository:
- `client` React SPA served by NGINX
- `api` Node/Express service

It builds and publishes container images consumed by the infra repo.

## Goals

- Produce deterministic image artifacts from app commits.
- Support automated dev promotion to infra overlay tags.
- Keep app build logic separate from Kubernetes manifests.

## Non-goals (for now)

- Multi-arch image matrix.
- Helm chart generation.
- Vulnerability gating/signing pipeline.

## Pipeline

```text
push main
  -> .gitea/workflows/deploy-main.yaml
  -> scripts/build-and-push.sh
  -> docker build/push client + api
  -> scripts/promote-to-infra.sh (optional)
  -> infra overlay newTag updated
```

## Artifacts and locations

| Artifact | Path | Produced by | Used by | Why it matters |
|---|---|---|---|---|
| Client runtime image | `client/Dockerfile` | `scripts/build-and-push.sh` | infra `demo-client` deployment | UI release artifact |
| API runtime image | `api/Dockerfile` | `scripts/build-and-push.sh` | infra `demo-api` deployment | Backend release artifact |
| Tag value | `scripts/image-tag.sh` | build pipeline | image refs + infra promotion commit | Immutable promotion key |
| Dev promotion commit | `scripts/promote-to-infra.sh` | workflow/manual run | Argo reconcile loop | Converts artifact to desired state change |

## Key invariants

| Invariant | Why true | What to do if broken |
|---|---|---|
| Client and API images use same tag per run | `build-and-push.sh` computes one `TAG` | rerun build once, avoid mixed manual tags |
| Infra promotion updates `newTag` as YAML string | `promote-to-infra.sh` writes quoted values | quote tag values in overlay file |
| Dev automation targets local overlay by default | `INFRA_OVERLAY=local` in workflow env | set overlay explicitly for other envs |

## Common failure modes

| Symptom | Likely cause | Fast check | Fix |
|---|---|---|---|
| Workflow waiting forever | missing runner label | Gitea Actions run page | attach runner with `ubuntu-latest` |
| Images not in registry | push failed | `curl /v2/demo-client/tags/list` | rerun build with reachable registry |
| Infra not updated | promote step skipped/failed | infra `git log -n 3` | set `AUTO_PROMOTE_INFRA=true` and verify git auth |

## Code entrypoints

- Workflow: `.gitea/workflows/deploy-main.yaml`
- Build orchestrator: `scripts/build-and-push.sh`
- Tag strategy: `scripts/image-tag.sh`
- Infra promotion: `scripts/promote-to-infra.sh`
- Client UI: `client/src/App.jsx`
- API routes: `api/src/server.js`

## ADR index

- `docs/adr/0001-artifact-and-promotion-contract.md`

## Updating locked decisions

Append-only ADR policy: create new ADRs for changes; mark old ADRs superseded.

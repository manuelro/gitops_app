# gitops_app

Demo application repository for the local GitOps workspace.  
It builds two container images (`demo-client`, `demo-api`) and can auto-promote image tags into the infra repo.

## Why this repo exists

- Keep application source and image pipeline separate from deployment manifests.
- Produce immutable image tags that infra can promote across environments.

## What you will do here

- Change client/API code.
- Build and push images to the local registry.
- Optionally auto-update infra tags (dev/local flow).

## Quickstart

### Requirements

- `docker` (Docker Desktop running)
- `git`
- Access to local registry (`127.0.0.1:5001` by default)
- Optional for auto-promote: access to infra repo remote

### Build and push images

```bash
cd repos/app
IMAGE_REGISTRY=127.0.0.1:5001 ./scripts/build-and-push.sh
```

Expected output shape:
- logs show build + push for `demo-client` and `demo-api`
- final lines print `CLIENT_IMAGE=...`, `API_IMAGE=...`, `IMAGE_TAG=...`

### Build, push, and auto-promote infra (dev/local)

```bash
cd repos/app
AUTO_PROMOTE_INFRA=true \
INFRA_REPO_URL=git@github.com:manuelro/gitops_infra.git \
INFRA_OVERLAY=local \
IMAGE_REGISTRY=127.0.0.1:5001 \
./scripts/build-and-push.sh
```

## Mental model

```text
app commit
  -> build client/api images
  -> push images to registry
  -> (optional) update infra overlay newTag values
  -> infra repo commit becomes Argo deploy intent
```

## Artifact locations

- Client app: `client/src`
- API app: `api/src`
- CI workflow: `.gitea/workflows/deploy-main.yaml`
- Build/push logic: `scripts/build-and-push.sh`
- Promotion logic: `scripts/promote-to-infra.sh`
- Tag strategy: `scripts/image-tag.sh`

## Sanity checks

```bash
curl -fsS http://localhost:5001/v2/demo-client/tags/list
curl -fsS http://localhost:5001/v2/demo-api/tags/list
```

Expected output shape:
- JSON `{"name":"demo-client","tags":[...]}`
- JSON `{"name":"demo-api","tags":[...]}`

## Troubleshooting (fast)

- `docker: Cannot connect to the Docker daemon`:
  - Start Docker Desktop and retry.
- Push timeout to registry:
  - Use `IMAGE_REGISTRY=127.0.0.1:5001`.
- Auto-promote fails to commit/push infra:
  - Verify `INFRA_REPO_URL`, credentials, and branch (`INFRA_BRANCH`).
- Gitea Actions run stuck `Waiting`:
  - Ensure a runner exists with label `ubuntu-latest`.

## Docs map

- System contract: `docs/architecture.md`
- ADRs: `docs/adr`
- Code navigation: `docs/code-map.md`
- Glossary: `docs/glossary.md`
- Learning checks: `docs/learning-checkpoints.md`

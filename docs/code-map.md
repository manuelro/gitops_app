# Code Map

## Start here by goal

| Goal | Files in order | What to look for |
|---|---|---|
| Change homepage text | `client/src/App.jsx` -> `client/src/styles.css` | visible UI payload |
| Change API behavior | `api/src/server.js` | `/api/version`, `/api/hello` response |
| Change image tag format | `scripts/image-tag.sh` | `git-sha` vs timestamp strategy |
| Debug failed build/push | `scripts/build-and-push.sh` | docker build/push command and vars |
| Debug promotion | `scripts/promote-to-infra.sh` | overlay file update and git push |
| Understand CI trigger | `.gitea/workflows/deploy-main.yaml` | event trigger, runner label, env wiring |

## Stage -> module map

| Stage | Primary files | Artifact | Debug signal |
|---|---|---|---|
| Build | `scripts/build-and-push.sh` | tagged images | docker build output |
| Push | `scripts/build-and-push.sh` | registry tags | `/v2/<name>/tags/list` includes tag |
| Promote | `scripts/promote-to-infra.sh` | infra commit | infra `git log` bump commit |
| Deploy (external) | infra + Argo | running pods | Argo app sync status |

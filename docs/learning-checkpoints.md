# Learning Checkpoints

| Checkpoint | Commands | Success looks like | If it fails |
|---|---|---|---|
| Build images | `cd repos/app && IMAGE_REGISTRY=127.0.0.1:5001 ./scripts/build-and-push.sh` | both images built and pushed | check Docker daemon and registry address |
| Registry has tags | `curl -fsS http://localhost:5001/v2/demo-client/tags/list` | JSON with tags array | registry container not running |
| Auto-promotion updates infra | run build with `AUTO_PROMOTE_INFRA=true` | infra commit appears with bumped tags | verify infra git auth/URL |
| CI trigger on main | push to `main`, check Gitea Actions | run created and completed | runner missing or label mismatch |

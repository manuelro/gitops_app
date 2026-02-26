# Glossary

| Term | Meaning | Software analogy | Where it appears |
|---|---|---|---|
| Image tag | Immutable version pointer for container image | build artifact id | `scripts/image-tag.sh` |
| Promotion | Writing selected tag into infra manifests | release pointer update | `scripts/promote-to-infra.sh` |
| AUTO_PROMOTE_INFRA | Toggle for automatic infra commit after build | post-build hook flag | `.gitea/workflows/deploy-main.yaml` |
| Runner label | Constraint for workflow execution host | queue selector | `runs-on: ubuntu-latest` |

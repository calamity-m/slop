# Docker Compose Snippets

## Compose up

Start the current compose project in detached mode.

```bash
docker compose up -d
```

## Compose delete

Stop and delete the current compose project's containers, networks, volumes, and orphan containers.

```bash
docker compose down --volumes --remove-orphans
```

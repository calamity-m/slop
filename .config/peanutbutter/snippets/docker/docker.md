# Docker Snippets

## Docker free as much space as possible

Remove all unused containers, networks, images, build cache, and volumes. This is destructive for anything Docker considers unused.

```
docker system prune --all --volumes --force && docker builder prune --all --force
```

## Docker delete unused images and containers

Remove stopped containers and unused images, but leave volumes alone.

```
docker container prune --force && docker image prune --all --force
```

## Dive running container snapshot

Commit a running container to a temporary image, inspect it with `dive`, then remove the temporary image.

```
container=<@container>
tmp_image="dive-${container}-$(date +%s)"
docker commit "$container" "$tmp_image" >/dev/null && dive "$tmp_image"
docker image rm "$tmp_image"
```

## Docker copy file from container to host

Copy a file or directory out of a running container and onto the host.

```
docker cp <@container>:<@container_path> <@host_path:?.>
```

## Docker run image with sh

Start an image with an interactive `sh` shell and remove the container when it exits.

```
docker run --rm -it <@image> sh
```

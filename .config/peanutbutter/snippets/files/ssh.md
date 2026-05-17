# SSH Snippets

## SSH into server

```bash
ssh <@username>@<@remote>
```

## Copy file from server to local

```bash
scp <@username>@<@remote>:<@remote_path> <@local_path>
```

## Copy file from local to server

```bash
scp <@local_file> <@username>@<@remote>:<@remote_path>
```

## Start SSH agent

```bash
eval "$(ssh-agent -s)"; ssh-add
```

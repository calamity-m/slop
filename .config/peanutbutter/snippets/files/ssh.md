# SSH Snippets

## SSH into server

```
ssh <@username>@<@remote>
```

## Copy file from server to local

```
scp <@username>@<@remote>:<@remote_path> <@local_path>
```

## Copy file from local to server

```
scp <@local_file> <@username>@<@remote>:<@remote_path>
```

## Start SSH agent

```
eval "$(ssh-agent -s)"; ssh-add
```

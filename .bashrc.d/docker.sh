dexec() {
	CONTAINER=$(docker ps | rg -v CONTAINER | awk '-F ' ' {print $NF}' | fzf)
	if [ ! -z "$CONTAINER" ]; then
		docker exec -it "$CONTAINER" bash
	fi
}

FZF_DOCKER_PS_FORMAT="table {{.ID}}\t{{.Names}}\t{{.Image}}\t{{.Ports}}"
FZF_DOCKER_PS_START_FORMAT="table {{.ID}}\t{{.Names}}\t{{.Status}}\t{{.Image}}"

_fzf_complete_docker() {
  local ARGS="$COMP_LINE"

  if [[ $ARGS == 'docker tag'* || $ARGS == 'docker -f'* || $ARGS == 'docker run'* || $ARGS == 'docker push'* || $ARGS == 'docker rmi'* ]]; then
    _fzf_complete --multi --header-lines=1 -- "$@" < <(
      docker images --format "table {{.Repository}}:{{.Tag}}\t{{.Size}}\t{{.ID}}\t{{.CreatedSince}}"
    )
  elif [[ $ARGS == 'docker stop'* || $ARGS == 'docker exec'* || $ARGS == 'docker kill'* || $ARGS == 'docker restart'* ]]; then
    _fzf_complete --multi --header-lines=1 -- "$@" < <(
      docker ps --format "${FZF_DOCKER_PS_FORMAT}"
    )
  elif [[ $ARGS == 'docker logs'* ]]; then
    _fzf_complete --multi --header-lines=1 --preview 'docker logs --tail=20 {1}' --preview-window=down:follow -- "$@" < <(
      docker ps -a --format "${FZF_DOCKER_PS_FORMAT}"
    )
  elif [[ $ARGS == 'docker rm'* ]]; then
    _fzf_complete --multi --header-lines=1 -- "$@" < <(
      docker ps -a --format "${FZF_DOCKER_PS_FORMAT}"
    )
  elif [[ $ARGS == 'docker start'* ]]; then
    _fzf_complete --multi --header-lines=1 -- "$@" < <(
      docker ps -a --format "${FZF_DOCKER_PS_START_FORMAT}"
    )
  fi
}

_fzf_complete_docker_post() {
  awk '{print $1}'
}

complete -F _fzf_complete_docker -o default -o bashdefault docker

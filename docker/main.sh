# Docker Nukem to remove all containers, images, volumes, and networks
alias d_nukem='docker system prune --all --volumes -f'

alias dps='docker ps'

# Exec - Select a container then execute a command inside it
# - Use the primary container if defined
# - Use the only running container if there is only one
# - Otherwise, offer a list of running containers to choose from
de() {
  docker_compose_up

  local container_name

  if [ -n "$DOCKER_CONTAINER_NAME" ]; then
    container_name="$DOCKER_CONTAINER_NAME"
  else
    container_name=$(__docker_select_container)
  fi

  # Skip if we don't have a container name
  [ -z "$container_name" ] && return

  docker exec -it $container_name "$@"
}

# Exec all - Same as 'de' but ignores a defined primary container
dea() {
  docker_compose_up

  local container_name
  container_name=$(__docker_select_container)

  # Skip if we don't have a container name
  [ -z "$container_name" ] && return

  docker exec -it $container_name "$@"
}

__docker_select_container() {
  local -r running_container_names=$(
    docker compose ps --format table |
      tail -n +2 |
      awk '{ print $1 }'
  )

  echo "$running_container_names" |
    fzf --with-nth 1 \
        --layout=reverse \
        --select-1 \
        --bind 'enter:become(echo {1})'
}

# Connect - Connect to the primary or the only running container
alias con='de /bin/bash'
# Connect all - Connect to the the only running container or offer a list of
# running containers to choose from
alias cona='dea /bin/bash'

alias up="docker_start_daemon && docker-compose up -d"
# Up build - Build the container(s) and start them
alias upb="docker_start_daemon && docker-compose up --build -d"
# Down - Stop all running containers started with docker-compose from the current directory
alias down="docker-compose down"
# Down all - Stop all running containers
downa() {
  local -r running_containers=$(docker ps -q)

  # Skip if there are no running containers
  [ -z "$running_containers" ] && return
  echo "$running_containers" | xargs docker stop
}

# Stop containers started by other projects
# Useful when two projects are using PostgreSQL with the same port
down_others() {
  # In order to distinguish between the containers of different projects,
  # the COMPOSE_PROJECT_NAME env variable must be set.
  if [ -z "$COMPOSE_PROJECT_NAME" ]; then
    echo "Error: Set the COMPOSE_PROJECT_NAME env variable."
    return 1
  fi

  local -r other_containers=(
    $(
      docker ps --format '{{.Names}}' |
        grep -v "^$COMPOSE_PROJECT_NAME"
    )
  )

  docker stop "${other_containers[@]}"
}

alias d_tmp_ubuntu="docker run --rm -it ubuntu"

# Start the Docker daemon if it is not running
docker_start_daemon() {
  # Skip if Docker is already running
  pgrep -x "Docker" > /dev/null && return

  echo -en "==> \e[33mStarting the Docker daemon.\e[0m"
  open -a Docker

  # Wait for Docker to start
  while ! docker ps &> /dev/null; do
    sleep 0.3
    echo -en "\e[33m.\e[0m"
  done
  echo ""
}

# Start Docker and the container(s) if they are not running
docker_compose_up() {
  # Skip if there is no docker-compose.yml file
  [ ! -f docker-compose.yml ] && return

  docker_start_daemon

  # Skip if the container(s) are already running
  [ -n "$(docker compose ps -q)" ] && return

  echo -e "==> \e[33mStarting the container(s)...\e[0m"
  docker-compose up -d

  # Warn if the container(s) failed to start
  if [ -z "$(docker compose ps -q)" ]; then
    echo -e "\033[0;31mFailed to start the container(s)\033[0m"
    return 1
  fi

  sleep 0.3
  # Warn if the container(s) exited immediately
  if [ -z "$(docker compose ps -q)" ]; then
    echo -e "\033[0;31mThe container(s) exited immediately\033[0m"
    return 1
  fi
}

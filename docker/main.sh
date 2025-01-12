# Docker Nukem to remove all containers, images, volumes, and networks
alias d_nukem='docker system prune --all --volumes -f'

alias dps='docker ps'

# Execute a command in the main container
alias de='docker_compose_up && docker exec -it ${DOCKER_CONTAINER_NAME:-$(basename $(pwd))}'
# Connect to the main container
alias con='de /bin/bash'

alias up="docker_start_daemon && docker-compose up -d"
# Up build - Build the container(s) and start them
alias upb="docker_start_daemon && docker-compose up --build -d"
# Down - Stop all running containers started with docker-compose from the current directory
alias down="docker-compose down"
# Down all - Stop all running containers
alias downa='docker stop $(docker ps -q)'

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

  echo -n "Starting the Docker daemon"
  open -a Docker

  # Wait for Docker to start
  while ! docker ps &> /dev/null; do
    sleep 0.3
    echo -n "."
  done
  echo ""
}

# Start Docker and the container(s) if they are not running
docker_compose_up() {
  # Skip if there is no docker-compose.yml file
  [ ! -f docker-compose.yml ] && return

  # Skip if the container(s) are already running
  [ -n "$(docker compose ps -q)" ] && return

  docker_start_daemon

  echo "Starting the container(s)..."
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

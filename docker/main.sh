# Docker Nukem to remove all containers, images, volumes, and networks
alias d_nukem='docker system prune --all --volumes -f'

alias dps='docker ps'

# Execute a command in the main container
alias de='docker_compose_up && docker exec -it ${DOCKER_CONTAINER_NAME:-$(basename $(pwd))}'
# Connect to the main container
alias con='de /bin/bash'

alias up="docker_start_daemon && docker-compose up -d"
alias upb="docker_start_daemon && docker-compose up --build -d"
alias down="docker-compose down"

alias d_tmp_ubuntu="docker run --rm -it ubuntu"

# Start the Docker daemon if it is not running
docker_start_daemon() {
  # Skip if Docker is already running
  pgrep -x "Docker" >/dev/null && return

  echo -n "Starting the Docker daemon"
  open -a Docker

  # Wait for Docker to start
  while ! docker ps &>/dev/null; do
    sleep 0.3
    echo -n "."
  done
  echo ""
}

# Start the container(s) if they are not running
docker_compose_up() {
  docker_start_daemon

  # Skip if there is no docker-compose.yml file
  [ ! -f docker-compose.yml ] && return

  # Skip if the container(s) are already running
  [ -n "$(docker compose ps -q)" ] && return

  echo "Starting the container(s)..."
  docker-compose up -d
}

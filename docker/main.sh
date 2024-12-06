# Docker Nukem to remove all containers, images, volumes, and networks
alias d_nukem='docker system prune --all --volumes -f'

alias de='docker_start_container ; docker exec -it ${DOCKER_CONTAINER_NAME:-$(basename $(pwd))}'
alias con='de /bin/bash'

alias up="docker-compose up -d"
alias upb="docker-compose up --build -d"
alias down="docker-compose down"

alias tmp_ubuntu="docker run --rm -it ubuntu"

# Start the container if it's not running
docker_start_container() {
  local -r container_name="${1:-$DOCKER_CONTAINER_NAME}"

  # Skip if the container is already running
  if [ ! "$(docker ps -a -q -f name=$container_name)" ]; then
    echo "Starting the container..."
    docker-compose up -d
  fi
}

# Docker Nukem to remove all containers, images, volumes, and networks
alias d_nukem='docker system prune --all --volumes -f'

alias de='docker exec -it ${DOCKER_CONTAINER_NAME:-$(basename $(pwd))}'
alias con='de /bin/bash'

alias up="docker-compose up -d"
alias upb="docker-compose up --build -d"
alias down="docker-compose down"

alias tmp_ubuntu="docker run --rm -it ubuntu"

# Start the container if it's not running
docker_start_container() {
  local -r container_name="${1:-$DOCKER_CONTAINER_NAME}"

  if ! docker ps | grep -q "$container_name"; then
    echo "Starting the container..."
    docker-compose up -d
  fi
}

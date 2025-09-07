print_in_yellow() {
  local message="$1"
  shift  # Remove the first argument
  echo -e $@ "==> \e[33m$message\e[0m"
}

print_in_red() {
  echo -e "\e[31m$1\e[0m"
}

print_in_green() {
  echo -e "\e[32m$1\e[0m"
}

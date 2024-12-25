#!/bin/bash

log_color() {
  color_code="$1"
  shift

  printf "\033[${color_code}m%s\033[0m\n" "$*" >&2
}

log_red() {
  log_color "0;31" "$@"
}

log_blue() {
  log_color "0;34" "$@"
}

log_green() {
  log_color "0;32" "$@"
}

log_info() {
    log_blue "ℹ️" "$@"
}

log_task() {
  log_green "🔃" "$@"
}

log_error() {
  log_red "❌" "$@"
}

error() {
  log_error "$@"
  exit 1
}

success() {
  log_green "✅" "$@"
  exit 0
}

echoerr() {
  printf "\033[0;31m%s\033[0m" "$1" >&2
}

ensure_uv_installed() {
  if [ ! -f "$(uv_path)" ]; then
    download_uv
  fi
}

download_uv() {
  echo "Downloading uv..." >&2
  curl -LsSf https://astral.sh/uv/install.sh | sh
}

uv_path() {
  which uv
}

update_uv() {
  echo "Updating uv..." >&2
  uv self update
}

uv_update_timestamp_path() {
  echo "$(dirname $(dirname "$0"))/uv_last_update"
}

uv_should_update() {
  update_timeout=3600
  update_timestamp_path=$(uv_update_timestamp_path)

  if [ ! -f "$update_timestamp_path" ]; then
    return 0
  fi

  last_update=$(cat "$update_timestamp_path")
  current_timestamp=$(date +%s)
  invalidated_at=$(($last_update + $update_timeout))

  [ $invalidated_at -lt $current_timestamp ]
}

install_or_update_uv() {
  if [ ! -f "$(uv_path)" ]; then
    download_uv
  elif uv_should_update; then
    update_uv
    date +%s > "$(uv_update_timestamp_path)"
  fi
}

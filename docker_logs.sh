#!/bin/bash

if [ -z "$1" ]; then
  echo "Usage: $0 <env-file>"
  echo "Example: $0 env/myconf.env"
  exit 1
fi

ENV_FILE="$1"

if [ ! -f "$ENV_FILE" ]; then
  echo "Error: env file '$ENV_FILE' not found"
  exit 1
fi

docker compose --env-file="$ENV_FILE" logs -t

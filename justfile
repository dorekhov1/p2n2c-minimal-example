build:
  if ls *.lock 1> /dev/null 2>&1; then rm *.lock; fi
  if command -v poetry &> /dev/null; then \
    POETRY_VIRTUALENVS_CREATE=false poetry lock; \
  else \
    echo "No poetry found, using nix-shell"; \
    nix-shell -p poetry --run "POETRY_VIRTUALENVS_CREATE=false poetry lock"; \
  fi
  nix build

build-container:
  nix run .\#minimal-example.copyToDockerDaemon && docker image prune -f

run-container:
  docker container rm -f minimal-example-container || true
  docker run --name minimal-example-container --network host minimal-example


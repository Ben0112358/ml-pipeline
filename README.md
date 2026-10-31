# ml-pipeline

The purpose of this project is to execute the full ML pipeline for a given `<project_name>` and `<mode>`, i.e.:

```
ml-infra → ml-data → ml-training → ml-serving → ml-ui
```

Each stage is modular, containerized, and coordinated via a unified entrypoint script.

To get an overview of how all sub-repos are tied together, refer to https://github.com/Ben0112358/ml-meta. Links to all sub-repos can be found therein as well.

---

## Project Structure

```
ml-pipeline/
├── Dockerfile            # Dockerfile used in execute.sh
├── execute.sh            # Main entrypoint (builds and runs pipeline)
├── cleanup-docker-prefix.sh # Cleans up Docker leftovers from earlier runs
├── pipeline.sh           # Runs all pipeline steps
├── ml-infra.sh           # Infra step logic
├── ml-data.sh            # Data step logic
├── ml-training.sh        # Training step logic
├── ml-serving.sh         # Endpoint serving step logic
├── ml-ui.sh              # UI creation step logic
├── setup.sh              # Sets up needed repos
├── utils.sh              # Bash utils, logging etc.
├── LICENSE
└── README.md
```

---

## Prerequisites

- **Docker** installed and running
- **Linux or macOS**
- A valid `~/.netrc` file with Github credentials if cloning private repositories

---

## Required Environment Variable

Set the base directory where shared ML assets and configs are stored:

```bash
export ML_HOMELAB_ROOT=/absolute/path/to/ml-homelab
```

---

## Optional Environment Variables

`execute.sh` forwards the following variables by name into the pipeline container. Each one is passed only if it is set in the environment `execute.sh` runs in; unset variables are skipped.

- `OPENAI_BASE_URL`
- `OPENAI_API_KEY`
- `OPENAI_MODEL`
- `CURSOR_API_KEY`

When using the containerized run below, `execute.sh` runs inside that container, so also add a matching `-e` flag (for example `-e OPENAI_API_KEY`) to the `docker run` command for each variable you want forwarded.

---

## Recommended Way to Run (Linux / macOS)

You can run the full pipeline inside a lightweight container:

```bash
docker run --rm -it \
  -v "$PWD":/ml-pipeline \
  -v "$ML_HOMELAB_ROOT":"$ML_HOMELAB_ROOT" \
  -v "$HOME/.netrc":/root/.netrc:ro \
  -v /var/run/docker.sock:/var/run/docker.sock \
  -e ML_HOMELAB_ROOT="$ML_HOMELAB_ROOT" \
  python:3.12-slim bash -c \
  "apt-get update && apt-get install -y curl git docker.io && cd /ml-pipeline && bash execute.sh <project_name> <mode>"
```

Replace `<project_name>` with the name of your ML project (e.g., `dummy_project`) and `<mode>` with either `dev` or `prod`.

---

## Modes: `dev` and `prod`

The mode decides where the pipeline gets the code of the five sub-repos (`ml-infra`, `ml-data`, `ml-training`, `ml-serving`, `ml-ui`):

- `prod` clones the latest version of each sub-repo from GitHub.
- `dev` copies your local checkouts instead, so you can test changes before pushing them. Each sub-repo must be checked out in a folder with its exact name directly under `$ML_HOMELAB_ROOT` (for example `$ML_HOMELAB_ROOT/ml-data`). If one is missing, the run stops with an error.


---

## Windows Support

Windows users should run this via **WSL2**. Once inside WSL, follow the Linux instructions above.

---

## Networking

Containers such as `ml-serving` and `ml-ui` will expose services on local ports. The port assignment is a function of `<project_name>` and `<mode>`. The logic is found in `execute.sh`, and the chosen ports are printed when a run starts.


---

## Logs

Each run writes its logs below `$ML_HOMELAB_ROOT`. The files under `logs/` are named `log_<project_name>_<mode>_<timestamp>.log`, where the timestamp is the time the run started, as `YYYY-MM-DD-HH-MM`.

- `logs/pipeline/` keeps the pipeline log of each run that finished successfully.
- `logs/infra/` keeps the Terraform log of each run whose `ml-infra` step succeeded.

Logs that have not been moved into `logs/` yet, because the run is still going or stopped with an error, sit directly in `$ML_HOMELAB_ROOT` instead, so look there first when a run fails. The overall result of each run (`Pipeline finished successfully` or `Pipeline failed`) is written to `unknown-pipeline.log` in that same folder.

Every run deletes the `.log` files directly in `$ML_HOMELAB_ROOT` when it starts, so copy any you want to keep before starting the next run. The files under `logs/` are kept.

---

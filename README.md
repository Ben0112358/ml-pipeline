# ml-pipeline

The purpose of this project is to execute the full ML pipeline for a given `<project_name>` and `<mode>`, i.e.:

```
ml-infra → ml-data → ml-training → ml-serving → ml-ui
```

Each stage is modular, containerized, and coordinated via a unified entrypoint script.

To get an overview of how all sub-repos are tied together, refer to https://github.com/Ben0112358/ml-meta. Links to all sub-repos can be found therein as well.

---

## 📁 Project Structure

```
ml-pipeline/
├── Dockerfile            # Dockerfile used in execute.sh
├── execute.sh            # Main entrypoint (builds and runs pipeline)
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

## ✅ Prerequisites

- **Docker** installed and running
- **Linux or macOS**
- A valid `~/.netrc` file with Github credentials if cloning private repositories

---

## 🔧 Required Environment Variable

Set the base directory where shared ML assets and configs are stored:

```bash
export ML_HOMELAB_ROOT=/absolute/path/to/ml-homelab
```

---

## 🚀 Recommended Way to Run (Linux / macOS)

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

## 💻 Windows Support

Windows users should run this via **WSL2**. Once inside WSL, follow the Linux instructions above.

---

## 🌐 Networking

Containers such as `ml-serving` and `ml-ui` will expose services on local ports. The port assignment is a function of `<project_name>` and `<mode>`. The logic is found in `<execute.sh>`.


---

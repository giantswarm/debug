# Detailed Setup Guide

This guide provides detailed steps for setting up the prerequisites and components needed for the Giant Swarm
debugging environment.

## Initial Repository Setup

Before proceeding with component installation, ensure you have cloned this repository.

1.  **Clone the Repository:** If you haven't already, clone this repository to your local machine.
    ```bash
    git clone <repository-url> # Replace <repository-url> with the actual URL
    cd <repository-name>       # Navigate into the cloned directory
    ```
2.  **Configure Git Hooks (Recommended):** This repository includes shared Git pre-commit hooks to help automate certain tasks and ensure consistency. To enable them, run the following command from the root of this repository:
    ```bash
    make setup
    ```
    This will configure your local Git repository to use the hooks located in the `.githooks` directory.

## Prerequisites Installation

- **kubectl:** [Official Installation Guide](https://kubernetes.io/docs/tasks/tools/install-kubectl/)
- **Teleport Client (tsh):**
  [Giant Swarm Internal Docs](https://intranet.giantswarm.io/docs/support-and-ops/teleport/#installing-teleport)
  (or relevant public docs if available)
- **Go (1.21+):** [Official Installation Guide](https://go.dev/doc/install)
- **Node.js/npm/npx:** Needed for `mcp-server-kubernetes`. [Download Page](https://nodejs.org/)
- **Python & uv (or pip/venv):** Needed for `prometheus-mcp-server`.
  - Install Python: [Python Downloads](https://www.python.org/downloads/)
  - Install uv: `pip install uv` or follow
    [uv Installation Guide](https://github.com/astral-sh/uv#installation)

_Verify installations by running `kubectl version --client`, `tsh version`, `go version`, `node -v`, `npm -v`,
`python --version`, `uv --version`._

## Component Setup

1.  **Install `envctl`:** (Refer to [README](https://github.com/giantswarm/envctl/blob/main/README.md) for detailed steps - Download binary or build from source)
2.  **Install `mcp-server-kubernetes`:**
    ```bash
    # local install, doesn't need root; for global install, use -g
    npm install mcp-server-kubernetes
    ```
    _Alternatively, rely on `npx` as configured in `mcp.json`, which downloads and runs it temporarily._
3.  **Install `prometheus-mcp-server`:**

    ```bash
    # Choose a location for helper repositories, e.g., ~/dev/giantswarm-helpers
    HELPERS_DIR=~/dev/giantswarm-helpers
    mkdir -p "$HELPERS_DIR"
    cd "$HELPERS_DIR"

    # Clone the repository
    git clone https://github.com/pab1it0/prometheus-mcp-server.git
    cd prometheus-mcp-server

    # if you don't have a recent/valid python environment, run
    uv python install

    # Setup Python virtual environment using uv and install
    uv sync

    # IMPORTANT: Note the full path to this directory!
    # Example: /home/user/dev/giantswarm-helpers/prometheus-mcp-server
    PROMETHEUS_MCP_PATH="$(pwd)"
    echo "Prometheus MCP Server Path: $PROMETHEUS_MCP_PATH"
    ```

4.  **Install `mcp-grafana`:**
    *   **Prerequisite:** Create a service account in your Grafana instance/org with the necessary permissions for the tools you intend to use. Generate a service account token and keep it handy. Refer to the [official Grafana documentation](https://grafana.com/docs/grafana/latest/administration/service-accounts/) for details.
    *   **Installation Options:**
        *   **Download Binary:** Download the latest `mcp-grafana` release from the [official releases page](https://github.com/grafana/mcp-grafana/releases). Extract the binary and place it in a directory included in your system's `PATH` (e.g., `/usr/local/bin` or `~/bin`).
        *   **(Alternative) Build from source:** If you have Go installed (see prerequisites), you can build and install it:
            ```bash
            go install github.com/grafana/mcp-grafana/cmd/mcp-grafana@latest
            ```

5.  **Configure MCP Client (`mcp.json`):**

    Example `mpc.json`:

    ```
    {
      "mcpServers": {
        "kubernetes": {
          "command": "npx",
          "args": ["mcp-server-kubernetes"]
        },
        "prometheus": {
          "command": "uv",
          "args": [
            "--directory",
            "/your/path/to/prometheus-mcp-server",
            "run",
            "src/prometheus_mcp_server/main.py"
          ],
          "env": {
            "PROMETHEUS_URL": "http://localhost:8080/prometheus",
            "ORG_ID": "giantswarm"
          }
        },
        "grafanaShared": {
          "command": "mcp-grafana",
          "args": [],
          "env": {
            "GRAFANA_URL": "http://localhost:3000",
            "GRAFANA_API_KEY": "YOUR_GRAFANA_SHAREDORG_SERVICE_ACCOUNT_TOKEN"
          }
        },
        "grafanaGiantswarm": {
          "command": "mcp-grafana",
          "args": [],
          "env": {
            "GRAFANA_URL": "http://localhost:3000",
            "GRAFANA_API_KEY": "YOUR_GRAFANA_GS_SERVICE_ACCOUNT_TOKEN"
          }
        }
      }
    }
    ```

    *   Locate your MCP client's configuration file (e.g., `~/.cursor/mcp.json`, VS Code settings, or the `mcp.json` file in *this* repository if using workspace settings).
    *   Copy the contents of the `mcp.json` file from this repository into your client's configuration.
    *   **CRITICAL:**
        *   Update the placeholder path for `prometheus-mcp-server` with the actual path noted in the previous step (e.g., replace `/path/to/your/prometheus-mcp-server` with `$PROMETHEUS_MCP_PATH`).
        *   For `grafana`, replace `YOUR_GRAFANA_URL` to point to your Grafana instance and `YOUR_GRAFANA_XX_SERVICE_ACCOUNT_TOKEN` with the service account tokens you generated. If `mcp-grafana` is not in your PATH, provide the full path to the executable.
        * You can use [this script](https://github.com/giantswarm/atlas-hacks/blob/main/hack/bin/update-mcp-grafana-token.sh) to help with grafana token management.
    *   *(Alternative for `grafana` using Docker)* If you prefer to run `mcp-grafana` via Docker, your `grafana` configuration in `mcp.json` would look like this (ensure the `mcp/grafana` image is pulled):
        ```json
        // In mcp.json, under mcpServers:
        "grafana": {
          "command": "docker",
          "args": [
            "run",
            "--rm",
            "-p", "8000:8000", // Exposes mcp-grafana on host port 8000, internal is 8000. Adjust host port if needed.
            "-e", "GRAFANA_URL",
            "-e", "GRAFANA_API_KEY",
            "mcp/grafana" // Optional: add "-debug" here after the image name
          ],
          "env": {
            "GRAFANA_URL": "YOUR_GRAFANA_URL",
            "GRAFANA_API_KEY": "YOUR_GRAFANA_SERVICE_ACCOUNT_TOKEN"
          }
        }
        ```
    *   *(Optional)* If you want web search, uncomment the `brave-search` section, ensure the server is installed (`npm install -g mcp-server-brave-search`), get an API key, and replace the placeholder key.

6.  **Restart MCP Client:** Restart your IDE (Cursor/VS Code) to ensure it loads the new MCP server
    configurations.

Setup is complete. Proceed to the Usage Examples guide.

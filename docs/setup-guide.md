# Detailed Setup Guide

This guide provides detailed steps for setting up the prerequisites and components needed for the Giant Swarm debugging environment.

## Prerequisites Installation

*   **kubectl:** [Official Installation Guide](https://kubernetes.io/docs/tasks/tools/install-kubectl/)
*   **Teleport Client (tsh):** [Giant Swarm Internal Docs](https://intranet.giantswarm.io/docs/support-and-ops/teleport/#installing-teleport) (or relevant public docs if available)
*   **Go (1.21+):** [Official Installation Guide](https://go.dev/doc/install)
*   **Node.js/npm/npx:** Needed for `mcp-server-kubernetes`. [Download Page](https://nodejs.org/)
*   **Python & uv (or pip/venv):** Needed for `prometheus-mcp-server`. 
    *   Install Python: [Python Downloads](https://www.python.org/downloads/)
    *   Install uv: `pip install uv` or follow [uv Installation Guide](https://github.com/astral-sh/uv#installation)

*Verify installations by running `kubectl version --client`, `tsh version`, `go version`, `node -v`, `npm -v`, `python --version`, `uv --version`.*

## Component Setup

1.  **Install `envctl`:** (Refer to main README for detailed steps - Download binary or build from source)
2.  **Install `mcp-server-kubernetes`:**
    ```bash
    npm install -g mcp-server-kubernetes
    ```
    *Alternatively, rely on `npx` as configured in `mcp.json`, which downloads and runs it temporarily.*
3.  **Install `prometheus-mcp-server`:**
    ```bash
    # Choose a location for helper repositories, e.g., ~/dev/giantswarm-helpers
    HELPERS_DIR="~/dev/giantswarm-helpers"
    mkdir -p "$HELPERS_DIR"
    cd "$HELPERS_DIR"
    
    # Clone the repository
    git clone https://github.com/pab1it0/prometheus-mcp-server.git
    cd prometheus-mcp-server

    # Setup Python virtual environment using uv
    uv venv 
    source .venv/bin/activate # (Use .\venv\Scripts\activate on Windows/PowerShell)
    
    # Install dependencies
    uv pip install -r requirements.txt
    
    # Deactivate environment (it will be activated by the MCP config)
    deactivate
    
    # IMPORTANT: Note the full path to this directory!
    # Example: /home/user/dev/giantswarm-helpers/prometheus-mcp-server
    PROMETHEUS_MCP_PATH=$(pwd)
    echo "Prometheus MCP Server Path: $PROMETHEUS_MCP_PATH"
    ```
4.  **Configure MCP Client (`mcp.json`):**
    *   Locate your MCP client's configuration file (e.g., `~/.cursor/mcp.json`, VS Code settings, or the `mcp.json` file in *this* repository if using workspace settings).
    *   Copy the contents of the `mcp.json` file from this repository into your client's configuration.
    *   **CRITICAL:** Update the placeholder path for `prometheus-mcp-server` with the actual path noted in the previous step (e.g., replace `/path/to/your/prometheus-mcp-server` with `$PROMETHEUS_MCP_PATH`).
    *   *(Optional)* If you want web search, uncomment the `brave-search` section, ensure the server is installed (`npm install -g mcp-server-brave-search`), get an API key, and replace the placeholder key.

5.  **Restart MCP Client:** Restart your IDE (Cursor/VS Code) to ensure it loads the new MCP server configurations.

Setup is complete. Proceed to the Usage Examples guide. 
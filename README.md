# Giant Swarm On-Call Debugging Environment

This repository provides a shared configuration and tooling for Giant Swarm SREs and Platform Engineers to streamline debugging during on-call shifts using AI agents connected via the Model Context Protocol (MCP).

## Purpose

Giant Swarm manages hundreds of Kubernetes clusters for customers, each running numerous applications and CNCF tools deployed via Helm. Debugging issues across these complex environments requires efficient access to cluster state, metrics, logs, and configuration.

This project aims to:

1.  **Standardize Debugging Setup:** Provide a consistent way to configure development environments (like Cursor or VS Code Insiders) to interact with Giant Swarm infrastructure using AI agents.
2.  **Simplify Cluster Access:** Leverage the `envctl` tool to automate connecting to management and workload clusters, including Teleport login, `kubectl` context switching, and Prometheus port-forwarding.
3.  **Share Best Practices:** Centralize the configuration for recommended MCP servers.
4.  **Enable Conversation Sharing (Future):** Facilitate knowledge sharing by providing a mechanism to store and retrieve debugging conversations with the AI agent.

## Target Audience

*   Giant Swarm Site Reliability Engineers (SREs)
*   Giant Swarm Platform Engineers

## Environment Overview

*   **Management Clusters (MCs):** Central clusters per installation (e.g., `wallaby`, `enigma`) hosting core platform services and CRDs for managing workload clusters.
*   **Workload Clusters (WCs):** Customer-specific clusters created and managed via the MC.
*   **Key Platform Components (on MCs):** Flux, Backstage, Grafana, Mimir, Loki, Crossplane, Kyverno, External-Secrets, Ingress-Nginx, Kong, and more.

## Core Components

*   **Model Context Protocol (MCP):** A protocol enabling AI agents/models to interact with local development tools and environments. ([Official Docs](https://modelcontextprotocol.io/))
*   **MCP Clients:** IDEs or tools that host the AI agent and connect to MCP Servers (Tested: [Cursor](https://cursor.sh/), VS Code Insiders with relevant extensions).
*   **MCP Servers:** Backend services that expose specific tools or data sources via MCP. We currently use:
    *   **Kubernetes:** `mcp-server-kubernetes` ([GitHub](https://github.com/Flux159/mcp-server-kubernetes)) - Provides access to `kubectl` functionality.
    *   **Prometheus:** `prometheus-mcp-server` ([GitHub](https://github.com/pab1it0/prometheus-mcp-server)) - Provides access to Prometheus/Mimir metrics.
*   **`envctl`:** A command-line tool to simplify connecting your environment to Giant Swarm clusters. ([GitHub](https://github.com/giantswarm/envctl))
*   **Conversation History (Future):** A planned feature to store and search past debugging interactions.

## Prerequisites

1.  **`kubectl`:** The Kubernetes command-line tool.
2.  **Teleport Client (`tsh`):** Installed and logged into the Giant Swarm Teleport proxy (`teleport.giantswarm.io`).
3.  **Go:** Version 1.21+ (Required to build `envctl` if not downloading the binary). ([Installation Guide](https://go.dev/doc/install))
4.  **MCP Client:** Cursor or VS Code Insiders.
5.  **(For Prometheus MCP Server):** Python environment manager like `uv` or `pip` + `venv`.

## Setup Instructions

1.  **Install `envctl`:**
    *   **Option A: Download Release Binary (Recommended):**
        Download the appropriate binary for your OS/Architecture from the [`envctl` Releases page](https://github.com/giantswarm/envctl/releases/latest). Make it executable (`chmod +x envctl`) and move it to a directory in your `$PATH` (e.g., `/usr/local/bin`).
        ```bash
        # Example for Linux AMD64
        curl -L https://github.com/giantswarm/envctl/releases/latest/download/envctl-linux-amd64 -o envctl
        chmod +x envctl
        sudo mv envctl /usr/local/bin/ # Or another directory in your PATH
        ```
    *   **Option B: Build from Source:**
        ```bash
        git clone https://github.com/giantswarm/envctl.git
        cd envctl
        go build -o envctl .
        sudo mv envctl /usr/local/bin/ # Or another directory in your PATH
        ```
    *   **(Optional but Recommended) Setup `envctl` Shell Completion:** Follow the instructions in the [`envctl` README](https://github.com/giantswarm/envctl#shell-completion-%F0%9F%A7%A0).

2.  **Install MCP Servers:**
    *   **Kubernetes (`mcp-server-kubernetes`):**
        ```bash
        npm install -g mcp-server-kubernetes
        # Or using npx (no global install needed, used in example config)
        ```
    *   **Prometheus (`prometheus-mcp-server`):**
        ```bash
        # Clone the repository
        git clone https://github.com/pab1it0/prometheus-mcp-server.git
        cd prometheus-mcp-server

        # Setup a virtual environment (example using uv)
        uv venv
        source .venv/bin/activate # Or .\venv\Scripts\activate on Windows
        uv pip install -r requirements.txt

        # Keep note of the path to the cloned directory and the run command
        # e.g., /path/to/prometheus-mcp-server and uv run src/prometheus_mcp_server/main.py
        ```

3.  **Configure MCP Client (Cursor Example):**
    *   Open your MCP configuration file (e.g., `~/.cursor/mcp.json` or via IDE settings).
    *   Add or modify the `mcpServers` section to include the Kubernetes and Prometheus servers. **Adjust paths and commands** based on your installation method from Step 2.

    ```json
    {
      "mcpServers": {
        "kubernetes": {
          "command": "npx", // Assumes npx is in PATH
          "args": ["mcp-server-kubernetes"]
        },
        "prometheus": {
          // Adjust command and args based on your setup
          "command": "uv", // Or python, pipenv, poetry, etc.
          "args": [
            "--directory",
            "/path/to/your/prometheus-mcp-server", // <--- UPDATE THIS PATH
            "run",
            "src/prometheus_mcp_server/main.py"
          ],
          "env": {
            // envctl sets up port-forwarding to localhost:8080
            "PROMETHEUS_URL": "http://localhost:8080/prometheus",
            // Optional: Set Org ID if required by your Mimir setup
            "ORG_ID": "giantswarm" 
          }
        }
        // Add other MCP servers if needed
      }
    }
    ```
    *   **Important:** Replace `/path/to/your/prometheus-mcp-server` with the actual path where you cloned the Prometheus MCP server repository.

4.  **Restart MCP Client/Servers:** Restart your IDE (Cursor/VS Code) or manually restart the MCP servers if they were running independently to ensure they pick up the new configuration.

## Usage

1.  **Connect to a Cluster:** Open your terminal and use `envctl connect`.
    *   **Connect to MC only:**
        ```bash
        envctl connect <management-cluster-name>
        # Example: envctl connect wallaby
        ```
        This logs into the MC via `tsh`, sets the `kubectl` context, and starts Prometheus port-forwarding in the background (to `http://localhost:8080/prometheus`).
    *   **Connect to MC and WC:**
        ```bash
        envctl connect <management-cluster-name> <workload-cluster-shortname>
        # Example: envctl connect wallaby plant-lille-prod
        ```
        This logs into both the MC and the *full* WC via `tsh`, sets the `kubectl` context to the WC, and starts Prometheus port-forwarding (via the MC context) in the background.

2.  **Interact via MCP Client:** Open your MCP client (Cursor/VS Code) and start interacting with your AI agent. It should now have access to:
    *   The Kubernetes cluster specified by the `kubectl` context set by `envctl`.
    *   Prometheus metrics via `http://localhost:8080/prometheus`.

3.  **Switching Clusters:** Simply run `envctl connect` again with the desired cluster names. You might need to signal your MCP client/servers to refresh their context if they don't detect the change automatically (restarting the IDE is often the easiest way).

## Conversation Sharing (Planned)

Details TBD. The goal is to implement a simple mechanism (e.g., storing conversations in a shared location or a dedicated tool) to allow engineers to review and learn from past debugging sessions.

## Further Reading & Resources

*   [Model Context Protocol (MCP) Documentation](https://modelcontextprotocol.io/)
*   [MCP Debugging Guide](https://modelcontextprotocol.io/docs/tools/debugging)
*   [`envctl` Repository](https://github.com/giantswarm/envctl)
*   [`mcp-server-kubernetes` Repository](https://github.com/Flux159/mcp-server-kubernetes)
*   [`prometheus-mcp-server` Repository](https://github.com/pab1it0/prometheus-mcp-server)

## Contributing

Contributions are welcome! Please open an issue or Pull Request if you have suggestions, bug fixes, or want to add support for more MCP servers or features. 
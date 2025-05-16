# Giant Swarm On-Call Debugging Environment

This repository provides a shared configuration and tooling for Giant Swarm SREs and Platform Engineers to streamline debugging during on-call shifts using AI agents connected via the Model Context Protocol (MCP).

## Purpose

Giant Swarm manages hundreds of Kubernetes clusters for customers, each running numerous applications and CNCF tools deployed via Helm. Debugging issues across these complex environments requires efficient access to cluster state, metrics, logs, and configuration.

This project aims to:

1.  **Standardize Debugging Setup:** Provide a consistent way to configure development environments (like Cursor or VS Code Insiders) to interact with Giant Swarm infrastructure using AI agents.
2.  **Simplify Cluster Access:** Leverage the `envctl` tool to automate connecting to management and workload clusters, including Teleport login, `kubectl` context switching, and Prometheus port-forwarding.
3.  **Share Best Practices:** Centralize the configuration for recommended MCP servers and provide guides on their effective use.

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
*   **MCP Servers:** Backend services that expose specific tools or data sources via MCP. See [`docs/mcp-tools-overview.md`](docs/mcp-tools-overview.md) for details.
*   **`envctl`:** A command-line tool to simplify connecting your environment to Giant Swarm clusters. ([GitHub](https://github.com/giantswarm/envctl))
*   **Configuration Files:**
    *   `mcp.json`: Configuration for the MCP Servers used by the client.
    *   `.vscode/`: Recommended VS Code extensions and settings.

## Getting Started

1.  **Prerequisites:** Ensure you have `kubectl`, `tsh` (logged in), `go`, `node`/`npm`, and `python`/`uv` installed. See the [Detailed Setup Guide](docs/setup-guide.md) for links and verification steps.
2.  **Clone this Repository:** `git clone <repository-url>` and `cd` into the directory.
3.  **Configure Git Hooks (One-time):** Run `make setup` to configure Git to use the shared pre-commit hooks in this repository. This helps ensure important scripts are run automatically before commits.
4.  **Run Validation Script (Optional):** Run `./scripts/validate-setup.sh` to check your environment.
5.  **Follow Setup:** Complete the steps in the [Detailed Setup Guide](docs/setup-guide.md) to install `envctl`, MCP servers, and configure your MCP client.
    *   **CRITICAL:** Remember to update the placeholder path in `mcp.json` for the `prometheus-mcp-server` after cloning it!
6.  **Explore Usage:** Check the [Usage Examples & Workflows](docs/usage-examples.md) and [Prompting Best Practices](docs/prompting-guide.md).

## Usage

1.  **Connect to a Cluster:** Open your terminal and use `envctl connect`.
    *   **Connect to MC only:** `envctl connect <management-cluster-name>`
    *   **Connect to MC and WC:** `envctl connect <management-cluster-name> <workload-cluster-shortname>`
2.  **Interact via MCP Client:** Open your MCP client (Cursor/VS Code) and start interacting with your AI agent, providing clear context as outlined in the prompting guide.
3.  **Switching Clusters:** Run `envctl connect` again for the new target cluster(s). You might need to restart your MCP client or manually signal the MCP servers to refresh their context.

## Troubleshooting & Nuances

*   **MCP Server Restarts:** After running `envctl connect` (especially if switching contexts), you might need to restart the MCP servers in your client (e.g., using the Stop/Start buttons in VS Code's Copilot Chat panel) for them to pick up the new `kubectl` context or Prometheus port-forward.
*   **Agent Context Confusion:** Newer Kubernetes MCP servers might ask for clarification if multiple `kubectl` contexts are available. Guide the agent by saying `Use the current default context` or specifying the exact context name set by `envctl`.
*   **MCP Tool vs. Terminal:** The agent might default to raw `kubectl` commands. If you want the structured benefits of MCP, explicitly ask it to use the specific MCP tool (e.g., `use the 'list_pods' MCP tool`). See [`docs/mcp-tools-overview.md`](docs/mcp-tools-overview.md).

## Utility Scripts

This repository includes utility scripts to help with common tasks. For more details, see the [Utility Scripts Documentation](docs/utility-scripts.md).

*   `scripts/update_instructions.sh`: Updates AI instruction files from a central source.

## Further Reading & Resources

*   [Detailed Setup Guide](docs/setup-guide.md)
*   [Usage Examples & Workflows](docs/usage-examples.md)
*   [Prompting Best Practices](docs/prompting-guide.md)
*   [MCP Tools Overview](docs/mcp-tools-overview.md)
*   [Model Context Protocol (MCP) Documentation](https://modelcontextprotocol.io/)
*   [MCP Debugging Guide](https://modelcontextprotocol.io/docs/tools/debugging)
*   [`envctl` Repository](https://github.com/giantswarm/envctl)
*   [`mcp-server-kubernetes` Repository](https://github.com/Flux159/mcp-server-kubernetes)
*   [`prometheus-mcp-server` Repository](https://github.com/pab1it0/prometheus-mcp-server)

## Contributing

Contributions are welcome! Please see the [Contribution Guidelines](CONTRIBUTING.md) and open an issue or Pull Request.

*Discuss setup issues or share experiences in the `#sig-architecture` Slack channel (or other relevant channels).*

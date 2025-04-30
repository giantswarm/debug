# MCP Tools Overview

This document provides an overview of the MCP servers configured by default in this repository's `mcp.json` and the key tools they provide.

## Default MCP Servers

1.  **`mcp-server-kubernetes`** ([GitHub](https://github.com/Flux159/mcp-server-kubernetes))
    *   **Purpose:** Interacts with Kubernetes clusters using `kubectl` commands translated into structured tools.
    *   **Key Enabled Tools (Examples - refer to MCP server docs for full list):**
        *   `list_namespaces`: List namespaces in the current context.
        *   `list_pods`: List pods, filterable by namespace, labels.
        *   `list_deployments`: List deployments.
        *   `list_services`: List services.
        *   `list_jobs`, `list_cronjobs`: List jobs and cronjobs.
        *   `list_nodes`: List cluster nodes.
        *   `describe_pod`, `describe_deployment`, `describe_service`, `describe_node`, etc.: Get detailed YAML-like descriptions of resources.
        *   `get_logs`: Fetch logs from pods, deployments, jobs.
        *   `get_events`: Get Kubernetes events.
        *   `explain_resource`: Get documentation for Kubernetes resource types (like `kubectl explain`).
        *   `get_current_context`, `list_contexts`: Manage `kubectl` contexts (useful for debugging context issues).
    *   **Key *Disabled* Tools (by Default - for Safety):**
        *   Tools that modify state: `create_deployment`, `delete_deployment`, `create_pod`, `delete_pod`, `scale_deployment`, `update_service`, `install_helm_chart`, `uninstall_helm_chart`, etc.
        *   *Rationale:* Modifying cluster state via LLM requires extreme caution. It's generally safer to have the agent *suggest* changes (e.g., generate YAML) for manual review and application.

2.  **`prometheus-mcp-server`** ([GitHub](https://github.com/pab1it0/prometheus-mcp-server))
    *   **Purpose:** Queries Prometheus-compatible endpoints (like Mimir).
    *   **Connection:** Relies on the port-forward established by `envctl` to `http://localhost:8080/prometheus`.
    *   **Key Tools:**
        *   `query`: Execute an instant PromQL query.
        *   `query_range`: Execute a range PromQL query over a time period.
        *   `series`: Find time series matching label selectors.
        *   `labels`: List label names.
        *   `label_values`: List values for a given label name.

## Optional MCP Servers (Commented out in `mcp.json`)

1.  **`mcp-server-brave-search`** (Requires separate install & API key)
    *   **Purpose:** Allows the agent to perform web searches using the Brave Search API.
    *   **Key Tools:**
        *   `brave_web_search`: Perform a general web search.
        *   *(Potentially others like `brave_local_search`)*
    *   **Use Case:** Useful for fetching up-to-date documentation, troubleshooting unfamiliar errors, or getting current information beyond the LLM's training data.

## Adding More MCP Servers

You can extend the agent's capabilities by adding more MCP servers (e.g., for Loki, specific cloud providers, databases) to your `mcp.json` configuration. Follow the documentation for the specific MCP server you want to add. 
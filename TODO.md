1. Configuration Files & Standardization:
Refine mcp.json (Placeholder Emphasis): The current mcp.json is a good start. Ensure the README.md strongly emphasizes that the /path/to/your/prometheus-mcp-server is a placeholder that must be replaced by the user after cloning the Prometheus server repository.
Add Web Search MCPs (Commented Out/Optional): Timo mentioned using Brave Search, Google Search, and Perplexity MCPs but removed the keys. We could add the configuration blocks for these to mcp.json but comment them out, including instructions in the README.md on how users can obtain API keys and uncomment the sections if they want web search capabilities. This acknowledges their utility while managing the secret key aspect.
Apply
(Optional) VS Code Specific Settings (.vscode/): Since VS Code was the primary client demonstrated and discussed:
.vscode/extensions.json: Recommend the essential extensions, primarily GitHub.copilot-chat.
.vscode/settings.json: Potentially suggest settings that optimize the Copilot Chat experience or point to the global mcp.json location if not using a workspace-local one (though a local one might be better for repo-specific configs).
(Advanced) Dev Container (.devcontainer/devcontainer.json): To address Zach's point about the effort Timo put into local setup, a Dev Container definition could significantly simplify onboarding. It could pre-install kubectl, tsh, go, node/npm/npx, python/uv, clone the necessary MCP server repos (like prometheus-mcp-server), and potentially even place a template mcp.json within the container, drastically reducing manual setup steps.
2. Documentation & Guides:
Expand README.md - Troubleshooting & Nuances: Add a section covering common issues Timo encountered:
The need to potentially restart MCP servers (especially Kubernetes) after envctl connect.
The agent sometimes getting confused about which context to use (especially with newer MCP server versions) and how to guide it.
The agent sometimes confusing kubectl terminal commands with MCP tools and how to prompt it to use the MCP tool ("please use the list_pods tool" instead of "run kubectl get pods").
Detailed Setup Guide(s): Create separate files (e.g., in a docs/ directory) or expand the README with more detailed setup steps for:
Different operating systems (macOS, Linux, Windows).
Installing prerequisites (tsh, kubectl, node, python/uv).
Cloning and setting up the prometheus-mcp-server (mentioning virtual environments).
Usage Examples & Workflows (Hands-on Labs): Turn Timo's debugging stories into concrete examples/guides, aligning with Zach's "PE onboarding exercises" idea:
Example 1: Analyzing Resource Usage: Start with an alert or scenario (e.g., high memory usage on a deployment), walk through connecting with envctl, and show sample prompts/interactions to check usage (list_deployments, describe_deployment, Prometheus queries via MCP), check the GitOps repo context, and get suggestions.
Example 2: Troubleshooting Autoscaler: Use the scenario Timo described (cluster full, autoscaler not adding nodes) and show the prompts to investigate node status, check Cluster Autoscaler logs/config, and identify the max node limit configuration in the MC GitOps repo.
Prompt Engineering Best Practices: A dedicated guide (docs/prompting-guide.md) explaining:
How to provide good context (e.g., mentioning the cluster connected via envctl, adding specific files/folders to the agent's context like Timo did with declarations).
How to explicitly ask the agent to use specific MCP tools.
How to handle situations where the agent hallucinates or uses outdated information (potentially leveraging search MCPs if enabled).
Example prompts for common on-call tasks (checking pod status, analyzing logs via Prometheus/Loki if added later, checking Helm release status, validating network policies).
MCP Server Capabilities Overview: Explain which specific tools within the configured MCP servers (Kubernetes, Prometheus) are enabled/recommended in the default mcp.json and why (e.g., disabling delete_* or create_* tools by default for safety).
3. Tooling & Automation:
Setup/Validation Script: A simple shell script (scripts/validate-setup.sh?) that checks if prerequisites (tsh, kubectl, npx, uv, go) are installed and in the $PATH, and checks if the user has logged into Teleport. This could lower the barrier to entry.
Conversation Logging/Sharing Mechanism (Future): Formalize Matías's idea.
Simple Start: Define a markdown template (docs/templates/session-log-template.md) and a directory (sessions/) where engineers can manually copy/paste and save interesting or successful debugging sessions.
Advanced: Explore simple CLI tools or scripts that could help capture terminal interactions or integrate with potential future CLI-based agents (like aider-chat mentioned by Puja) to automate saving sessions.
4. Community & Collaboration:
Contribution Guide (CONTRIBUTING.md): Standard guidelines for suggesting changes, adding new MCP server configs, or improving documentation.
Link to Internal Communication: Add links in the README.md to relevant Slack channels (e.g., #sig-architecture, #on-call) for discussion and support.
These additions aim to make the repository a comprehensive resource for leveraging AI agents in the Giant Swarm debugging workflow, addressing the setup hurdles, training needs, and collaboration ideas discussed in the meeting.
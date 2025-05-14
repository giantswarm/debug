# Prompt Engineering Best Practices

Before diving into specific prompting techniques, it's important to understand that the AI assistant you are interacting with in this environment has already been pre-configured with a set of "system prompts" or custom instructions. These instructions define its persona as an experienced Giant Swarm SRE, provide it with core knowledge about Giant Swarm's platform, and set guidelines for its behavior. This initial configuration is managed by the `scripts/update_instructions.sh` script, which ensures consistency across different tools (like Cursor and VS Code with GitHub Copilot). For more details on what these system prompts contain and how they are managed, please refer to the [Utility Scripts Documentation](utility-scripts.md).

The best practices below will help you leverage this pre-configured AI more effectively for your debugging and operational tasks.

Effective interaction with the AI agent relies on providing clear context and guidance. Here are some best practices when using this debugging environment:

1.  **Establish Context Clearly:**
    *   **Cluster:** Always start by stating which cluster you are connected to via `envctl` (e.g., "I am connected to the 'wallaby' MC" or "I am focused on the 'enigma-ve5v6' WC"). This helps the agent select the correct Kubernetes context if multiple are available or if the MCP server supports context switching.
    *   **Goal:** Briefly explain the problem you're trying to solve or the information you need (e.g., "Investigating high latency on service X," "Trying to understand why pod Y is crashing," "Need to find the configuration for feature Z").
    *   **Relevant Files/Folders:** Use the agent's context features (`@`-mentions in Cursor/VS Code) to point it towards relevant GitOps repository folders or specific configuration files. This is crucial for tasks involving configuration checks or modifications.

2.  **Be Specific About Tools:**
    *   The agent has access to both MCP tools and potentially a general terminal. It might sometimes default to `kubectl` commands via the terminal.
    *   If you want it to use the structured capabilities and safety features of MCP, explicitly ask it to use the MCP tool: `Please use the 'list_pods' MCP tool...` instead of `Can you run kubectl get pods?`
    *   Refer to the `mcp-tools-overview.md` guide for the list of available MCP tools.

3.  **Guide the Agent Step-by-Step:**
    *   For complex tasks, break down the request into smaller, logical steps. This makes it easier for the agent to follow and reduces the chance of errors or hallucinations.
    *   Use numbered lists in your prompts to outline the sequence of actions you want the agent to take (as shown in the `usage-examples.md`).

4.  **Iterate and Refine:**
    *   Don't expect the perfect answer on the first try. Review the agent's response and provide corrective feedback.
    *   If the agent misunderstands or uses the wrong tool, gently correct it: `That wasn't quite right, please try using the 'describe_deployment' MCP tool instead.`
    *   If the agent gets stuck on outdated information, and you have a search MCP enabled, ask it to verify: `Can you search the web for the latest documentation on {specific component/error}?`

5.  **Leverage Different Tools Synergistically:**
    *   Combine information from multiple sources. Ask the agent to correlate Kubernetes resource status (`list_pods`, `describe_deployment`) with metrics from Prometheus (`query_range`) and configuration from Git (`@`-mentioned files).

6.  **Safety First (Especially with Modifications):**
    *   While the default `mcp.json` might disable dangerous tools, always be cautious when asking the agent to *modify* configurations or resources.
    *   Review any suggested changes (e.g., YAML modifications, `kubectl apply` commands) carefully before applying them.
    *   Prefer asking the agent to *generate* the configuration change for you to review and apply manually, rather than asking it to apply the change directly (unless you explicitly enable and trust modification tools).

7.  **Handle Context Ambiguity:**
    *   As Timo noted, newer MCP servers might explicitly ask for the context if multiple are loaded. If `envctl` sets the desired context, you can usually tell the agent: `Please use the current default kubectl context.` or `Use the '{cluster-context-name}' context.`

By following these practices, you can make your interactions with the AI agent more efficient, accurate, and safe. 
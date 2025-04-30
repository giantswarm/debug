# Usage Examples & Workflows

These examples illustrate how to use the AI agent with the configured MCP tools for common debugging scenarios, based on real experiences.

## Scenario 1: Investigating Workload Resource Usage

**Context:** You receive an alert for high memory usage in a specific workload cluster, or you want to proactively check resource utilization.

1.  **Connect:** Use `envctl` to connect to the relevant Management Cluster (MC) and Workload Cluster (WC).
    ```bash
    envctl connect <management-cluster> <workload-cluster-shortname>
    # e.g., envctl connect wallaby plant-lille-prod 
    ```
2.  **Set Agent Context:** In your MCP client (e.g., Cursor chat), ensure the agent knows which cluster you're targeting. You might also add the relevant GitOps repository folder (e.g., `management-clusters/wallaby/organizations/customer-a/`) to the chat context (`@`-mention the folder).
3.  **Initial Investigation Prompt:**
    ```
    I am connected to the '{workload-cluster-shortname}' workload cluster (context should be set). An alert mentioned high memory usage for the 'billing-service' deployment in the 'production' namespace. 

    1. Please verify the current status and resource usage (CPU/Memory requests, limits, and current usage) of the 'billing-service' deployment and its pods in the 'production' namespace using the available Kubernetes MCP tools.
    2. Check the Prometheus MCP tool for memory usage trends over the past 6 hours for these pods.
    3. Examine the HelmRelease/Application configuration for this deployment in the '@customer-a-org' folder context to see the declared requests/limits.
    4. Based on the findings, suggest potential causes and next steps (e.g., are limits too low? is there a memory leak? are more replicas needed?).
    ```
4.  **Follow-up Prompts (Example):**
    *   If usage is high: `The memory usage is consistently hitting the limit. Can you check the logs for the 'billing-service' pods in 'production' for any OutOfMemory errors or suspicious activity over the last hour?` (Note: Assumes a Logs MCP server is added later, or guides the agent to use `kubectl logs` via terminal access if allowed).
    *   If requests/limits seem misaligned: `The current usage is well below the limits, but the request is very low. Suggest more appropriate request/limit values based on the 6-hour trend data.`
    *   Applying changes: `Based on the analysis, please generate the updated 'requests' and 'limits' section for the 'billing-service' container within the relevant HelmRelease/Application manifest found in the '@customer-a-org' context.`

## Scenario 2: Troubleshooting Cluster Autoscaler

**Context:** The cluster is under high load, pods are pending due to insufficient resources, but the Cluster Autoscaler doesn't seem to be adding new nodes.

1.  **Connect:** Use `envctl` to connect to the *Management Cluster* where the Cluster Autoscaler for the affected Workload Cluster is managed.
    ```bash
    envctl connect <management-cluster>
    # e.g., envctl connect enigma
    ```
2.  **Set Agent Context:** Add the MC's GitOps repository (e.g., `@management-clusters`) to the chat context.
3.  **Initial Investigation Prompt:**
    ```
    I am connected to the '{management-cluster}' management cluster context. Pods are pending in the '{workload-cluster-full-name}' workload cluster due to insufficient resources, but new nodes are not being added.

    1. Use the Kubernetes MCP tools to check the status and recent events for the Cluster Autoscaler deployment (usually in the 'kube-system' namespace of the MC, check common names like 'cluster-autoscaler').
    2. Examine the Cluster Autoscaler logs for errors related to the '{workload-cluster-full-name}' MachinePools or scaling decisions in the last 30 minutes. (Again, assumes Logs MCP or terminal access).
    3. Check the current node count and conditions for the relevant MachinePools associated with '{workload-cluster-full-name}'.
    4. Investigate the configuration of the MachinePools for '{workload-cluster-full-name}' within the '@management-clusters' GitOps context, specifically looking for `minReplicas` and `maxReplicas` (or similar) settings. Are we already at the maximum allowed nodes?
    5. Report the findings and explain why the autoscaler might not be adding nodes.
    ```
4.  **Follow-up Prompts (Example):**
    *   If max nodes reached: `We've hit the maximum node limit of {N}. Please locate the MachinePool definition for '{workload-cluster-full-name}' in the '@management-clusters' context and show me the line where the maximum size is defined. Suggest increasing it.`
    *   If errors in logs: `The logs mention '{specific-error-message}'. Can you search the web (if search MCP enabled) or provide information about what this error means for the Cluster Autoscaler?`
    *   Applying changes: `Please modify the MachinePool definition in the '@management-clusters' context to increase the maximum size from {N} to {N+2}.`

These examples demonstrate how combining `envctl` for connection setup with targeted prompts leveraging MCP tools and GitOps context can significantly speed up debugging. 
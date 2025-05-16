# Utility Scripts

This document describes various utility scripts available in this repository to help with development and maintenance tasks.

## `scripts/update_instructions.sh`

**Purpose:**

This script updates the AI assistant instruction files used by different environments (Cursor, GitHub Copilot) from a central source file. This ensures consistency in the instructions provided to the AI.

Specifically, it copies the content from `system-prompt-gs-sre.md` (located in the repository root) to:

*   `.cursor/rules/giantswarm-sre-guidelines.mdc`
*   `.github/copilot-instructions.md`

**Usage:**

1.  Navigate to the root directory of this repository.
2.  Make the script executable (if you haven't already):
    ```bash
    chmod +x scripts/update_instructions.sh
    ```
3.  Run the script:
    ```bash
    bash scripts/update_instructions.sh
    ```

## Understanding System Prompts and AI Customization

This script manages files that act as "system prompts" or custom instructions for AI assistants integrated into code editors like Cursor and VS Code (with GitHub Copilot).

### What is a System Prompt?

A system prompt is a set of instructions, guidelines, or context provided to an AI model *before* it begins interacting with a user or processing a specific query. It's like giving the AI a role, a personality, background information, and rules to follow. This helps the AI generate responses that are more relevant, accurate, and aligned with the user's specific needs or the task at hand.

Key functions of a system prompt include:

*   **Defining Persona:** Instructing the AI on how it should behave (e.g., "You are an expert SRE for Giant Swarm").
*   **Setting Context:** Providing essential background information (e.g., details about a specific platform or technology stack).
*   **Specifying Style/Tone:** Guiding the AI's communication style (e.g., concise, formal, detailed).
*   **Outlining Constraints:** Setting boundaries on what the AI should or shouldn't do or say.
*   **Imparting Knowledge:** Embedding specific information, like coding standards or best practices, that the AI should use.

By using a system prompt, developers can tailor the AI's behavior to be more effective for specialized tasks, such as software development within a particular company or project.

### How This Works with Cursor

Cursor is an AI-first code editor designed for close collaboration with AI.

*   **Custom Rules:** Cursor allows users to define "Rules" which are essentially custom instructions or system prompts. The `.cursor/rules/giantswarm-sre-guidelines.mdc` file, managed by this script, is one such rule.
*   **`.mdc` Files:** Cursor loads these Markdown with Context (`.mdc`) files to provide persistent instructions to its AI. When you use Cursor's AI features (like code generation, editing with `Cmd+K`/`Ctrl+K`, or chat), it considers these rules to guide its responses and actions.
*   **Benefit:** This allows the AI in Cursor to be deeply customized with specific domain knowledge, project requirements, or coding conventions relevant to your work, such as the Giant Swarm SRE guidelines.

### How This Works with VS Code and GitHub Copilot

GitHub Copilot, a popular AI pair programmer extension for VS Code, also supports mechanisms for custom instructions to tailor its assistance.

*   **Custom Instructions for Copilot Chat:** VS Code enables users to provide "custom instructions" for GitHub Copilot Chat. These instructions help align Copilot's responses with your project's specifics, team workflows, coding styles, or preferred tools and libraries.
*   **`copilot-instructions.md`:** The `.github/copilot-instructions.md` file, also managed by this script, is a convention for storing these repository-specific instructions. GitHub Copilot can be configured to read this file (or similar configurations) to understand the desired context for a particular project.
*   **Impact:** By providing these instructions, GitHub Copilot can offer more relevant code suggestions, explanations, and general assistance that is better suited to the project's unique requirements and established coding standards.

**The `update_instructions.sh` script ensures that both Cursor and GitHub Copilot (via VS Code) receive the same consistent set of guiding principles from the `system-prompt-gs-sre.md` source file, leading to a more harmonized and effective AI-assisted development experience across these tools within this project.** 
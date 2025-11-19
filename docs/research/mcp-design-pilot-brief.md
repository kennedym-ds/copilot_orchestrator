# Research Brief: MCP Design Pilot & Subagent Modernization

**Date:** 2025-11-18
**Status:** Draft
**Related Plans:** `copilot-custom-agents-mcp-modernization.md`, `ds-star-routing-alignment-plan.md`

## Executive Summary
This research confirms that the **Model Context Protocol (MCP)** is the optimal path for equipping our subagents (Researcher, Data Analytics, Visualizer) with specialized, deterministic capabilities. By deploying a custom MCP server, we can bridge the gap between our agents and external systems (Design Systems, Databases) while maintaining strict security and context isolation.

## 1. Architecture: The "Unified Agent" Model
Recent updates to GitHub Copilot have unified the control plane, meaning a single MCP server configuration works across both:
*   **GitHub.com (Cloud):** The "Coding Agent" can access tools during issue/PR workflows.
*   **VS Code (Local):** The "Agent Mode" and "Chat" can access the same tools for interactive loops.

### Context Isolation Strategy
We will leverage the `#runSubagent` primitive to ensure safety and focus:
*   **Visualizer Agent:** Runs in a dedicated context with access to the **Design MCP**. It can query brand colors and components without polluting the global context.
*   **Implementer Agent:** Receives only the *output* (e.g., "Use hex code #FF5733") from the Visualizer, keeping its context window clean for coding.

## 2. Pilot Proposal: "Design System" MCP
We propose building a lightweight **Python-based MCP server** (`scripts/mcp/design-server.py`) using the `FastMCP` library. This pilot will demonstrate the end-to-end flow without requiring external API keys initially.

### Proposed Tools
| Tool Name | Description | Input Schema | Output |
| :--- | :--- | :--- | :--- |
| `get_brand_palette` | Returns the official color palette. | `None` | JSON list of colors (name, hex, usage). |
| `check_contrast` | Validates accessibility contrast. | `fg_hex` (str), `bg_hex` (str) | JSON `{ ratio: float, pass_AA: bool }`. |
| `search_components` | Finds approved UI components. | `query` (str) | List of component names and docs URLs. |

### Technical Stack
*   **Language:** Python 3.10+ (Aligns with Data Analytics stack).
*   **Library:** `mcp[cli]` (FastMCP).
*   **Transport:** Stdio (Standard Input/Output) for zero-config local integration.

## 3. Security & Governance
*   **Secrets:** Any future API keys (e.g., for Figma) will be stored in Repository Secrets (`COPILOT_MCP_FIGMA_KEY`) and injected via the environment.
*   **Read-Only:** The pilot server will be strictly read-only.
*   **Logging:** All debug logs will be directed to `stderr` to prevent protocol corruption on `stdout`.

## 4. Implementation Plan (Phase 4 Execution)

### Step 1: Scaffolding
*   Create `scripts/mcp/design-server.py` with the `FastMCP` boilerplate.
*   Implement the three pilot tools (`get_brand_palette`, `check_contrast`, `search_components`) using hardcoded "mock" data for the proof-of-concept.

### Step 2: Configuration
*   Create `mcp.json` in the workspace root to register the server.
    ```json
    {
      "mcpServers": {
        "design-system": {
          "command": "python",
          "args": ["scripts/mcp/design-server.py"]
        }
      }
    }
    ```

### Step 3: Agent Integration
*   Update `.github/agents/visualizer.agent.md` to include the new tools.
    ```yaml
    mcpServers: ['design-system']
    ```

### Step 4: Validation
*   Run a test session: "Visualizer, check if white text on our brand blue passes WCAG AA."
*   Verify the agent calls `get_brand_palette` then `check_contrast`.

## 5. Future Expansion (DS-STAR)
Once the Design Pilot is proven, we will replicate this pattern for the **Data Analytics** agent:
*   **Database MCP:** A read-only server using `asynccontextmanager` for connection pooling (as found in research).
*   **Capabilities:** Schema inspection, SQL generation validation, and safe read-only queries.

---
**Recommendation:** Proceed immediately with **Step 1 (Scaffolding)** of the Implementation Plan.

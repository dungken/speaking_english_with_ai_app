
**AI Task: Feature Implementation / Code Modification Protocol**

**Objective:** Safely and effectively implement the feature or modification described **in the User Request above**. Prioritize understanding the goal, planning thoroughly, leveraging existing code, obtaining explicit user confirmation before action, and outlining verification steps. Adhere strictly to all `core.md` principles.

**Phase 1: Understand Request & Validate Context (Mandatory First Steps)**

1.  **Clarify Goal:** Re-state your interpretation of the primary objective of **the User Request**. If there's *any* ambiguity about the requirements or scope, **STOP and ask clarifying questions** immediately.
2.  **Identify Target(s):** Determine the specific project(s), module(s), or file(s) likely affected by the request. State these targets clearly.
3.  **Verify Environment & Structure:**
    *   Execute `pwd` to confirm the current working directory.
    *   Execute `tree -L 4 --gitignore | cat` focused on the target area(s) identified in step 2 to understand the relevant file structure.
4.  **Examine Existing Code (If Modifying):** If the request involves changing existing code, use `cat -n <workspace-relative-path>` or `read_file` to thoroughly review the current implementation of the relevant sections. Confirm your understanding before proceeding. **If target files are not found, STOP and report.**

**Phase 2: Analysis, Design & Planning (Mandatory Pre-computation)**

5.  **Impact Assessment:** Identify *all* potentially affected files (components, services, types, tests, etc.) and system aspects (state management, APIs, UI layout, data persistence). Consider potential side effects.
6.  **Reusability Check:** **Actively search** using `codebase_search` and `grep_search` for existing functions, components, utilities, types, or patterns within the workspace that could be reused or adapted. **Prioritize leveraging existing code.** Only propose creating new entities if reuse is clearly impractical; justify why.
7.  **Consider Alternatives & Enhancements:** Briefly evaluate if there are alternative implementation strategies that might offer benefits (e.g., better performance, maintainability, adherence to architectural patterns). Note any potential enhancements related to the request (e.g., adding error handling, improving type safety).

**Phase 3: Propose Implementation Plan (User Confirmation Required)**

8.  **Outline Execution Steps:** List the sequence of actions required, including which files will be created or modified (using full workspace-relative paths).
9.  **Propose Code Changes / Creation:**
    *   Detail the specific `edit_file` operations needed. For modifications, provide clear code snippets showing the intended changes using the `// ... existing code ...` convention. For new files, provide the complete initial content.
    *   Ensure `target_file` paths are **workspace-relative**.
10. **Present Alternatives (If Applicable):** If step 7 identified viable alternatives or significant enhancements, present them clearly as distinct options alongside the direct implementation. Explain the trade-offs. Example:
    *   "Option 1: Direct implementation as requested in `ComponentA.js`."
    *   "Option 2: Extract logic into a reusable hook `useFeatureX` and use it in `ComponentA.js`. (Adds reusability)."
11. **State Dependencies & Risks:** Mention any prerequisites, external dependencies (e.g., new libraries needed), or potential risks associated with the proposed changes.
12. **🚨 CRITICAL: Request Explicit Confirmation:** Clearly ask the user:
    *   To choose an implementation option (if alternatives were presented).
    *   To grant explicit permission to proceed with the proposed `edit_file` operation(s).
    *   Example: "Should I proceed with Option 1 and apply the `edit_file` changes to `ComponentA.js`?"
    *   **Do NOT execute `edit_file` without the user's explicit confirmation.**

**Phase 4: Implementation (Requires User Confirmation from Phase 3)**

13. **Execute Confirmed Changes:** If the user confirms, perform the agreed-upon `edit_file` operations exactly as proposed. Report success or any errors immediately.

**Phase 5: Propose Verification (Mandatory After Successful Implementation)**

14. **Standard Checks:** Propose running relevant quality checks for the affected project(s) via `run_terminal_cmd` (e.g., linting, formatting, building, running specific test suites). Remind the user that these commands require confirmation if they alter state or are not covered by auto-approval rules.
15. **Functional Verification Guidance:** Suggest specific steps or scenarios the user should manually test to confirm the feature/modification works correctly and meets the original request's goal. Include checks for potential regressions identified during impact assessment (step 5).

---

**Goal:** Implement **the user's request** accurately, safely, and efficiently, incorporating best practices, proactive suggestions, and rigorous validation checkpoints, all while strictly following `core.md` protocols.
Beta

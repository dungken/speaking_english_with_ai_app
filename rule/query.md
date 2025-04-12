**User Query:** 

{my query}

---

**AI Task: Rigorous Diagnosis and Resolution Protocol**

**Objective:** Address the persistent issue described **in the User Query above**. Execute a thorough investigation to identify the root cause, propose a verified solution, suggest relevant enhancements, and ensure the problem is resolved robustly. Adhere strictly to all `core.md` principles, especially validation and safety.

**Phase 1: Re-establish Context & Verify Environment (Mandatory First Steps)**

1.  **Confirm Workspace State:**
    *   Execute `pwd` to establish the current working directory.
    *   Execute `tree -L 4 --gitignore | cat` focused on the directory/module most relevant to **the user's stated issue** to understand the current file structure.
2.  **Gather Precise Evidence:**
    *   Request or recall the *exact* error message(s), stack trace(s), or specific user-observed behavior related to **the user's stated issue** *as it occurs now*.
    *   Use `cat -n <workspace-relative-path>` or `read_file` on the primary file(s) implicated by the current error/behavior to confirm their existence and get initial content. **If files are not found, STOP and report the pathing issue.**

**Phase 2: Deep Analysis & Root Cause Identification**

3.  **Examine Relevant Code:**
    *   Use `read_file` (potentially multiple times for different sections) to thoroughly analyze the code sections directly involved in the error or the logic related to **the user's stated issue**. Pay close attention to recent changes if known.
    *   Mentally trace the execution flow leading to the failure point. Identify key function calls, state changes, data handling, and asynchronous operations.
4.  **Formulate & Validate Hypotheses:**
    *   Based on the evidence from steps 2 & 3, generate 2-3 specific, plausible hypotheses for the root cause (e.g., "State not updating correctly due to dependency array", "API response parsing fails on edge case", "Race condition between async calls").
    *   Use targeted `read_file`, `grep_search`, or `codebase_search` to find *concrete evidence* in the code that supports or refutes *each* hypothesis. **Do not proceed based on guesses.**
5.  **Identify and State Root Cause:** Clearly articulate the single most likely root cause, supported by the evidence gathered.

**Phase 3: Solution Design & Proactive Enhancement**

6.  **Check for Existing Solutions/Patterns:**
    *   Before crafting a new fix, use `codebase_search` or `grep_search` to determine if existing utilities, error handlers, types, or patterns within the codebase should be used for consistency and reusability.
7.  **Assess Impact & Systemic Considerations:**
    *   Evaluate if the root cause might affect other parts of the application.
    *   Consider if the issue highlights a need for broader improvement (e.g., better error handling strategy, refactoring complex logic).
8.  **Propose Solution(s) & Enhancements (User Confirmation Required):**
    *   **a. Propose Minimal Verified Fix:** Detail the precise, minimal `edit_file` change(s) needed to address the *identified root cause*. Ensure `target_file` uses the correct workspace-relative path. Explain *why* this specific change resolves the issue based on your analysis.
    *   **b. Propose Proactive Enhancements (Mandatory Consideration):** Based on steps 6 & 7, *proactively suggest* 1-2 relevant improvements alongside the fix. Examples:
        *   "To prevent this class of error, we could add specific type guards here."
        *   "Refactoring this to use the central `apiClient` would align with project standards."
        *   "Adding logging around this state transition could help debug future issues."
        *   Briefly explain the benefit of each suggested enhancement.
    *   **c. State Risks:** Mention any potential side effects or considerations for the proposed changes.
    *   **d. 🚨 CRITICAL: Request Explicit Confirmation:** Ask the user clearly which option they want:
        *   "Option 1: Apply only the minimal fix."
        *   "Option 2: Apply the fix AND the suggested enhancement(s) [briefly name them]."
        *   **Do NOT proceed with `edit_file` until the user explicitly selects an option.**

**Phase 4: Validation Strategy**

9.  **Outline Verification Plan:** Describe concrete steps the user (or you, if possible via commands) should take to confirm the fix is successful and hasn't caused regressions. Include specific inputs, expected outputs, or states to check.
10. **Recommend Validation Method:** Suggest *how* to perform the validation (e.g., "Run the `test:auth` script", "Manually attempt login with credentials X and Y", "Check the network tab for response Z").

---

**Goal:** Deliver a confirmed, robust resolution for **the user's stated issue** by rigorously diagnosing the root cause, proposing evidence-based fixes and relevant enhancements, and ensuring verification, all while strictly adhering to `core.md` protocols.

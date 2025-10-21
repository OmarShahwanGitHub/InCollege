# Epic 6 Testing Guide

This folder contains curated input/output pairs for validating the Week 6 job posting features in `InCollege.cob`. Each test follows the project mandate of driving the program entirely from an input file while mirroring the console output in an output artifact.

## Pre-test setup

1. **Reset job storage** – Before running any Epic 6 test case, copy `setup/jobs-empty.doc` to the project root as `jobs.doc` (replace any existing file). This ensures deterministic job IDs and avoids bleed-over between scenarios.
2. **Account prerequisites** – All scenarios assume the baseline `accounts.doc` shipped with the repository (users `test`, `aibek`, `tomato`, etc.). Restore it if your local copy differs.
3. **Execution harness** – Run `InCollege.cob` with the desired `InCollege-Input.txt` contents replaced by the selected test input file. Capture the generated `InCollege-Output.txt` and compare it against the matching expected output.

> ℹ️ For persistence validation, keep the same `jobs.doc` created during Session 1 and run Session 2 immediately afterward without resetting the file.

## Test matrix

| File pair | Focus | Notes |
| --- | --- | --- |
| `Epic6-Story1-Post-Job-With-Salary-Test-Input/Output` | Happy-path posting with salary populated | Verifies the new menu flow, all required prompts, and success message.
| `Epic6-Story2-Required-Field-Reprompt-Test-Input/Output` | Required-field validation | Supplies blank Title, Description, and Location entries to confirm the COBOL loop re-prompts with "This is a required field...".
| `Epic6-Story3-Optional-Salary-Blank-Test-Input/Output` | Optional salary entry & developer audit | Posts without salary and immediately enters developer mode (`0`) to confirm the record is written with an empty salary field.
| `Epic6-Story4-Browse-Under-Construction-Test-Input/Output` | Browse option placeholder | Ensures selecting option 2 echoes the "under construction" message before returning to the menu.
| `Epic6-Story5-Persistence-Session1-Test-Input/Output` | Persistence run – Session 1 | Creates a job as `tomato`, leaving the job table populated for the follow-up session.
| `Epic6-Story5-Persistence-Session2-Test-Input/Output` | Persistence run – Session 2 | Launches developer mode only to verify the job persisted across executions.

## Execution tips

- After copying the appropriate test input into place, run the program once per file. No manual keyboard input should be required.
- Always reset `InCollege-Output.txt` (or delete it) between runs to avoid trailing output from previous executions.
- When comparing outputs, a direct diff (`fc` on Windows, `diff` elsewhere) should show no differences if the program is correct.
- If a scenario fails, inspect both the console and file outputs—they must match byte-for-byte per project requirements.

Happy testing!

# Week 10 Test Input Suite (Epic 10)

This folder contains the scripted input files requested for the Week 10 "System Enhancements & Bug Fixing" deliverable. Each file can be copied into `InCollege-Input.txt` to drive an end-to-end COBOL run that exercises a targeted slice of functionality. Use the matching output file produced during execution (`InCollege-Output.txt`) when assembling the `Epic10-Storyx-Test-Output.zip` artifact.

## How to Use

1. **Reset data files as needed** – for deterministic results, start from a clean snapshot of the `.doc` data files (accounts, profiles, jobs, applications, connections, etc.). The registration test assumes fewer than five accounts exist so the limit can be reached inside the scenario.
2. Copy the desired `Epic10-StoryX-*Test-Input.txt` file to `InCollege-Input.txt`.
3. Compile and run `InCollege.cob` (per the repository README). All screen output is mirrored to `InCollege-Output.txt`.
4. Save the resulting output file alongside the input to build the Week 10 evidence bundle.

## Scenario Coverage

| File | Focus | Highlights |
| --- | --- | --- |
| `Epic10-Story1-Comprehensive-Smoke-Test-Input.txt` | Happy-path regression | Log in as `test`, rebuild profile, search for the new profile, exercise the entire job menu (post → browse → apply → view applications), verify messages, and exit cleanly. |
| `Epic10-Story2-Registration-and-Login-Validation-Test-Input.txt` | Account creation, password rules, login handling, account limit | Drives multiple invalid password attempts before success, negative/positive login retries, then creates additional accounts until the five-account ceiling rejects a sixth registration. |
| `Epic10-Story3-Profile-Validation-and-Viewing-Test-Input.txt` | Profile editing quality-of-life fixes | Forces graduation-year validation (out-of-range and non-numeric), adds experience & education entries (with blank optional fields), views the saved profile, and confirms search formatting. |
| `Epic10-Story4-Connections-and-Network-Flow-Test-Input.txt` | Connections, duplicate prevention, pending queue, accept flow | Creates a target profile, sends a connection request, attempts a duplicate send, then accepts the pending request and verifies the network listing. |
| `Epic10-Story5-Job-Board-Edge-Cases-Test-Input.txt` | Job posting validation, browsing edge cases, duplicate application guarding | Exercises required-field validation with blank inputs, posts a job, applies once successfully, triggers the "job not found" path, re-attempts the same application to hit the duplicate guard, and reviews the application summary. |
| `Epic10-Story6-Messaging-and-Navigation-Test-Input.txt` | Messaging menu, connection validation, back-navigation | Sends a message to a valid connection, attempts to message a non-connection (negative case), views inbox contents, and confirms another user can read the new message. |

## Packaging Guidance

- Zip the six input files as `Epic10-Storyx-Test-Input.zip` (alphabetical order is fine) once validated.
- Capture the corresponding outputs after each run to assemble `Epic10-Storyx-Test-Output.zip`.
- Reference this README (or copy its contents) within your final Week 10 documentation so testers understand prerequisites and coverage.

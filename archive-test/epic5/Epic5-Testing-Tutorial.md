# Epic 5 Test Execution & Validation Tutorial

This tutorial walks every team member through re-running the Epic 5 regression suite, validating the behaviour against the acceptance criteria, and packaging the deliverables. Everything referenced below lives under `archive-test/epic5/` unless noted.

Use this one liner to run all the tests for Epic 5 at once. This will run all test and create new output files for every test in Epic 5:
`& { $setupRoot='archive-test/epic5/setup'; $testRoot='archive-test/epic5'; $tests=@(@{Name='Story1';Conn='connections-empty.doc';Req='connection_requests-accept.doc';Input='Epic5-Story1-Accept-Request-Test-Input.txt';Output='Epic5-Story1-Accept-Request-Test-Output.txt';ResetConn=$true},@{Name='Story2';Conn='connections-empty.doc';Req='connection_requests-reject.doc';Input='Epic5-Story2-Reject-Request-Test-Input.txt';Output='Epic5-Story2-Reject-Request-Test-Output.txt';ResetConn=$true},@{Name='Story3';Conn='connections-empty.doc';Req='connection_requests-mixed.doc';Input='Epic5-Story3-Mixed-Sequencing-Test-Input.txt';Output='Epic5-Story3-Mixed-Sequencing-Test-Output.txt';ResetConn=$true},@{Name='Story4';Conn='connections-multi.doc';Req='connection_requests-empty.doc';Input='Epic5-Story4-View-Network-Multiple-Test-Input.txt';Output='Epic5-Story4-View-Network-Multiple-Test-Output.txt';ResetConn=$true},@{Name='Story5';Conn='connections-empty.doc';Req='connection_requests-empty.doc';Input='Epic5-Story5-View-Network-Empty-Test-Input.txt';Output='Epic5-Story5-View-Network-Empty-Test-Output.txt';ResetConn=$true},@{Name='Story6a';Conn='connections-empty.doc';Req='connection_requests-accept.doc';Input='Epic5-Story6-Persistence-Session1-Test-Input.txt';Output='Epic5-Story6-Persistence-Session1-Test-Output.txt';ResetConn=$true},@{Name='Story6b';Conn=$null;Req='connection_requests-empty.doc';Input='Epic5-Story6-Persistence-Session2-Test-Input.txt';Output='Epic5-Story6-Persistence-Session2-Test-Output.txt';ResetConn=$false}); cobc -x -free InCollege.cob | Out-Null; foreach($t in $tests){ Write-Host "`n=== Running $($t.Name) ===" -ForegroundColor Cyan; Copy-Item -Force (Join-Path $setupRoot 'accounts-baseline.doc') 'accounts.doc'; Copy-Item -Force (Join-Path $setupRoot 'profiles-baseline.doc') 'profiles.doc'; if($t.ResetConn -and $t.Conn){ Copy-Item -Force (Join-Path $setupRoot $t.Conn) 'connections.doc'; } elseif(-not (Test-Path 'connections.doc')){ Copy-Item -Force (Join-Path $setupRoot 'connections-empty.doc') 'connections.doc'; } if($t.Req){ Copy-Item -Force (Join-Path $setupRoot $t.Req) 'connection_requests.doc'; } else { Copy-Item -Force (Join-Path $setupRoot 'connection_requests-empty.doc') 'connection_requests.doc'; } Copy-Item -Force (Join-Path $testRoot $t.Input) 'InCollege-Input.txt'; if(Test-Path 'InCollege-Output.txt'){ Remove-Item 'InCollege-Output.txt'; } ./InCollege.exe | Out-Null; Copy-Item -Force 'InCollege-Output.txt' (Join-Path $testRoot $t.Output); Write-Host "Saved output to $(Join-Path $testRoot $t.Output)" -ForegroundColor Green }; Compress-Archive -Force -Path (Join-Path $testRoot 'Epic5-Story*-Test-Input.txt') -DestinationPath (Join-Path $testRoot 'Epic5-Storyx-Test-Input.zip'); Compress-Archive -Force -Path (Join-Path $testRoot 'Epic5-Story*-Test-Output.txt') -DestinationPath (Join-Path $testRoot 'Epic5-Storyx-Test-Output.zip'); Write-Host "`nAll Epic 5 regression artifacts refreshed." -ForegroundColor Yellow }`

---

## 1. Quick checklist

1. **Refresh data files** with the scenario-specific seeds in `archive-test/epic5/setup`.
2. **Compile** (`cobc -x -free InCollege.cob`) if you have changed source code.
3. **Copy** the target input file to `InCollege-Input.txt` and clear `InCollege-Output.txt`.
4. **Run** the program (`./InCollege.exe`).
5. **Capture & review** the output, comparing it to the expected Epic 5 behaviour below.
6. **Archive** the verified output back into `archive-test/epic5` (and rebuild the zip when all scenarios pass).

Treat the steps above as a shared Definition of Done for QA sign off.

---

## 2. Resetting the environment

Each scenario starts with a known dataset. Copy these files from `archive-test/epic5/setup` to the project root (`InCollege/`):

- `accounts-baseline.doc` → `accounts.doc`
- `profiles-baseline.doc` → `profiles.doc`
- One of the provided `connections-*.doc` seeds → `connections.doc`
- One of the provided `connection_requests-*.doc` seeds → `connection_requests.doc`

> **Tip:** Keep a second PowerShell window open in the project root and run the copy commands there so you can reset quickly between scenarios.

Compile the COBOL program once per session (or whenever `InCollege.cob` changes):

```powershell
cobc -x -free InCollege.cob
```

---

## 3. Scenario-by-scenario playbook

| # | Story & requirement focus | Input file | Seed files to copy before run | Output file name |
| --- | --- | --- | --- | --- |
| 1 | Accept a pending request → connection should appear in the user’s network | `Epic5-Story1-Accept-Request-Test-Input.txt` | `connections-empty.doc`, `connection_requests-accept.doc` | `Epic5-Story1-Accept-Request-Test-Output.txt` |
| 2 | Reject a pending request → no new connection created | `Epic5-Story2-Reject-Request-Test-Input.txt` | `connections-empty.doc`, `connection_requests-reject.doc` | `Epic5-Story2-Reject-Request-Test-Output.txt` |
| 3 | Mixed accept/reject flow while processing two requests | `Epic5-Story3-Mixed-Sequencing-Test-Input.txt` | `connections-empty.doc`, `connection_requests-mixed.doc` | `Epic5-Story3-Mixed-Sequencing-Test-Output.txt` |
| 4 | Display a populated network (multiple connections) | `Epic5-Story4-View-Network-Multiple-Test-Input.txt` | `connections-multi.doc`, `connection_requests-empty.doc` | `Epic5-Story4-View-Network-Multiple-Test-Output.txt` |
| 5 | Display an empty network message | `Epic5-Story5-View-Network-Empty-Test-Input.txt` | `connections-empty.doc`, `connection_requests-empty.doc` | `Epic5-Story5-View-Network-Empty-Test-Output.txt` |
| 6a | Persistence session 1: accept request, exit | `Epic5-Story6-Persistence-Session1-Test-Input.txt` | `connections-empty.doc`, `connection_requests-accept.doc` | `Epic5-Story6-Persistence-Session1-Test-Output.txt` |
| 6b | Persistence session 2: restart and confirm connection is preserved | `Epic5-Story6-Persistence-Session2-Test-Input.txt` | *Reuse files produced by 6a (do **not** reset connections)* | `Epic5-Story6-Persistence-Session2-Test-Output.txt` |

### Running a scenario

1. Copy the seed files (table above) into the project root.
2. Copy the scenario input file to `InCollege-Input.txt`.
3. Delete any existing `InCollege-Output.txt` so the run produces a fresh file.
4. Execute:
   ```powershell
   ./InCollege.exe
   ```
5. When the program exits, copy the resulting `InCollege-Output.txt` back into `archive-test/epic5` using the output file name shown in the table.

---

## 4. Verification guide

After each run, validate that the behaviour matches the Epic 5 acceptance criteria:

- **Story 1 (Accept request)**
  - Look for `Connection request from tomato accepted!`.
  - Immediately afterwards the network view must contain `Connected with: Tomato User (University: Farm, Major: Veg)`.
  - Check `connections.doc` to verify the pair `test                tomato` exists.
- **Story 2 (Reject request)**
  - Confirm `Connection request from potato rejected.` is displayed once and that the subsequent `View My Network` menu shows `You have no connections at this time.`
  - Inspect `connections.doc`; no new rows should have been added, and `connection_requests.doc` should now be empty.
- **Story 3 (Mixed flow)**
  - First request accepted, second rejected, and when you revisit pending requests within the same session you should see only the remaining entry. After rejecting it, the file should report `You have no pending connection requests at this time.`
  - The network section should list Tomato only once, confirming we did not add Potato to the established network.
- **Story 4 (Populated network)**
  - Network must list Tomato, Potato, and Full User with their associated university/major info.
- **Story 5 (Empty network)**
  - Network section displays `You have no connections at this time.` with no other connections listed.
- **Story 6 (Persistence)**
  - Session 1: verify acceptance message and the new connection in `connections.doc`.
  - Session 2: without reseeding files, run again and confirm the network still lists Tomato without re-running the accept flow.

> **Recording results:** Update the shared QA log or Jira test case with run date, git commit hash, and any deviations. Attach the relevant output file or reference the zip bundle described below.

---

## 5. Packaging & hand-off

Two archives accompany our Week 5 deliverables and should be rebuilt whenever results change:

- `Epic5-Storyx-Test-Input.zip` → bundle of all seven input files.
- `Epic5-Storyx-Test-Output.zip` → bundle of the freshly validated outputs.

Regenerate them from `archive-test/epic5/` whenever files change:

```powershell
Compress-Archive -Force -Path Epic5-Story*-Test-Input.txt -DestinationPath Epic5-Storyx-Test-Input.zip
Compress-Archive -Force -Path Epic5-Story*-Test-Output.txt -DestinationPath Epic5-Storyx-Test-Output.zip
```

Store both zips alongside the individual files so future teammates (or graders) can download a single artifact.

---

## 6. Notes & troubleshooting

- Processing a pending request creates a temporary helper file (`connection_requests.tmp`). The test harness clears it after each update; delete the file when you finish testing so it doesn’t linger as an untracked artifact.
- If a run crashes midway, re-copy the seed files from `archive-test/epic5/setup` before attempting to rerun; partial writes can leave the data files in an inconsistent state.

Document any additional quirks you discover during testing so that developers can reproduce and patch them before the final submission.

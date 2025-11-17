# InCollege
COBOL program for a LinkedIn-like app for college students.

## How to Run

### Compile the program (GnuCOBOL)
PowerShell (Windows):
```powershell
cobc -x -free InCollege.cob -o InCollege.exe
```

macOS/Linux:
```bash
cobc -x -free InCollege.cob -o InCollege
```

### Execute the program
PowerShell (Windows):
```powershell
./InCollege.exe
```

macOS/Linux:
```bash
./InCollege
```

### Testing with Input/Output Files
- Input: The program reads all user inputs from `InCollege-Input.txt`.
- Output: Everything displayed on screen is also written to `InCollege-Output.txt`.

To run a sample flow, ensure `InCollege-Input.txt` contains the sequence you want to test, then run the binary. After execution, compare console output with `InCollege-Output.txt` (they should be identical).

## Features
- User registration with password validation
- User login with personalized welcome message
- Post-login menu with profile, search, jobs, connections, and skills
- Account limit enforcement (maximum 5 accounts)
- Find classmates, view their profiles, and send/accept/reject connection requests with
   duplicate-request and self-request validation
- Persistent storage of pending requests and established connections

### Week 10: Stability & I/O Improvements
- Centralized output mirroring via `PRINT-LINE` helper in `InCollege.cob` ensures every message shown on screen is also written to `InCollege-Output.txt`.
- Menus refactored to use the helper (Main, Post-login, Learn Skill, Jobs, Messages) reducing duplication and ensuring consistent formatting.
- File handling remains robust: missing data files are created on first run.

### Week 8: Messaging (New)
- New post-login menu option: `8. Messages`
- Messages submenu:
   1. Send a New Message
   2. View My Messages (under construction)
   3. Back to Main Menu
- Send Message flow:
   - Prompt for recipient username (must be an established connection in `connections.doc`).
   - Prompt for free-form message content (up to 200 chars).
   - Persist the message to `messages.doc` with fields: Sender, Recipient, Content, Timestamp.
   - Confirmation is displayed and written to `InCollege-Output.txt`.

Message file format (`messages.doc`, line sequential):
```
MS-SENDER(20) | MS-RECIPIENT(20) | MS-CONTENT(200) | MS-TIMESTAMP(20)
```
Timestamp uses `CURRENT-DATE` (e.g., YYYYMMDDHHMMSS subset).

Sample files updated for Week 8:
- `InCollege-Input.txt`: Demonstrates login → Messages → Send → View (under construction) → Back → Logout.
- `InCollege-Output.txt`: Mirrors the exact console output for the above flow.

Notes:
- Messaging is only allowed between established connections (stored in `connections.doc`). Pending/non-existent users are rejected with a friendly error.
- "View My Messages" is intentionally under construction for Week 8.

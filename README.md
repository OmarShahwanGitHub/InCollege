# InCollege
COBOL program for a LinkedIn-like professional networking application designed for college students.

## Table of Contents
- [Quick Start](#quick-start)
- [System Requirements](#system-requirements)
- [Installation & Compilation](#installation--compilation)
- [Running the Application](#running-the-application)
- [Testing with Input/Output Files](#testing-with-inputoutput-files)
- [Data Files](#data-files)
- [Features Overview](#features-overview)
- [Input File Format Guide](#input-file-format-guide)
- [Output File Interpretation](#output-file-interpretation)
- [Complete Usage Examples](#complete-usage-examples)
- [Troubleshooting](#troubleshooting)

## Quick Start

```bash
# Compile
cobc -x InCollege.cob -o InCollege

# Run with test input
./InCollege < InCollege-Input.txt > InCollege-Output.txt

# View output
cat InCollege-Output.txt
```

## System Requirements

- **GnuCOBOL Compiler**: Version 3.0 or higher
- **Operating System**: Windows (PowerShell), macOS, or Linux
- **Disk Space**: Minimal (< 5 MB for program + data files)

## Installation & Compilation

### Installing GnuCOBOL

**macOS** (using Homebrew):
```bash
brew install gnucobol
```

**Linux** (Ubuntu/Debian):
```bash
sudo apt-get install gnucobol
```

**Windows**:
Download and install from [GnuCOBOL SourceForge](https://sourceforge.net/projects/gnucobol/)

### Compiling InCollege

**PowerShell (Windows)**:
```powershell
cobc -x InCollege.cob -o InCollege.exe
```

**macOS/Linux**:
```bash
cobc -x InCollege.cob -o InCollege
```

Successful compilation will produce:
- Executable: `InCollege` (or `InCollege.exe` on Windows)
- Note: Free-format COBOL is automatically detected by the compiler

## Running the Application

### Interactive Mode

**Windows**:
```powershell
./InCollege.exe
```

**macOS/Linux**:
```bash
./InCollege
```

Enter all inputs manually when prompted. The program will display menus and messages on the console.

### Automated Testing Mode (Recommended)

Run with pre-prepared input file and capture output:

**Windows**:
```powershell
Get-Content InCollege-Input.txt | ./InCollege.exe > InCollege-Output.txt
```

**macOS/Linux**:
```bash
./InCollege < InCollege-Input.txt > InCollege-Output.txt 2>&1
```

This mode is ideal for:
- Automated testing
- Reproducible test scenarios
- Batch processing
- Continuous integration

## Testing with Input/Output Files

### Input File: `InCollege-Input.txt`
- Contains all user inputs in sequence (one per line)
- Each line corresponds to a menu choice, username, password, or data field
- Must match the exact order prompted by the application
- Empty lines are treated as empty input (may cause validation errors)

### Output File: `InCollege-Output.txt`
- Mirrors **exactly** what appears on the console
- Generated automatically via centralized I/O (`PRINT-LINE` helper)
- Contains all menus, prompts, validation messages, and data displays
- Use for verification, debugging, and acceptance testing

**Key Feature**: Console output and file output are **identical** thanks to the `PRINT-LINE` helper introduced in Week 10, ensuring consistent I/O for all program functions.

## Data Files

The application uses persistent data files in the working directory:

| File | Type | Purpose | Format |
|------|------|---------|--------|
| `accounts.doc` | Line Sequential | User credentials | `USERNAME(20) PASSWORD(12)` |
| `profiles.doc` | Indexed | User profiles | Indexed by username; contains name, major, university, about, graduation year, experience (3x), education (3x) |
| `jobs.doc` | Line Sequential | Job postings | `JOB-ID(4) TITLE(50) DESC(200) EMPLOYER(50) LOCATION(50) SALARY(30)` |
| `applications.doc` | Line Sequential | Job applications | `APPLICANT(20) JOB-ID(4) JOB-TITLE(50) EMPLOYER(50) LOCATION(50)` |
| `messages.doc` | Line Sequential | User messages | `SENDER(20) RECIPIENT(20) CONTENT(200) TIMESTAMP(20)` |
| `connections.doc` | Line Sequential | Established connections | `USER1(20) USER2(20)` |
| `connection-requests.doc` | Line Sequential | Pending connection requests | `SENDER(20) RECEIVER(20)` |
| `roles.txt` | Text | User-role associations | `USERNAME: ROLE` (one per line) |

**Notes**:
- All files are created automatically on first use if they don't exist
- Line sequential files append new records at the end
- `profiles.doc` uses indexed access for fast username lookups
- Clear `applications.doc` before testing job application flows to avoid "already applied" messages

## Features Overview

### Core Functionality
✅ **User Registration** (Menu Option 2)
- Create new account with username and password
- Password validation: 8-12 chars, ≥1 uppercase, ≥1 digit, ≥1 special char
- Maximum 5 accounts enforced
- Credentials stored in `accounts.doc`

✅ **User Login** (Menu Option 1)
- Authenticate with username/password
- Personalized welcome message
- Access to full post-login menu

### Post-Login Features

**1. Create/Edit My Profile**
- Required fields: First name, Last name, Major, University
- Optional: About section, Graduation year (1925-2035)
- Up to 3 work experiences (title, employer, dates, location, description)
- Up to 3 education entries (school, degree, years attended)
- Field-specific validation messages
- Stored in `profiles.doc` (indexed by username)

**2. View My Profile**
- Display all profile information
- Shows "N/A" for missing optional fields

**3. Search for User**
- Search by first name and last name
- Displays matching user profile
- Option to send connection request if not already connected

**4. Learn a New Skill**
- Five skill training options
- Informational feature (no data persistence)

**5. View My Pending Connection Requests**
- Lists all incoming connection requests
- Accept or reject each request individually
- Updates `connections.doc` and removes from `connection-requests.doc`

**6. View My Network**
- Displays all established connections
- Shows first name and last name of each connection

**7. Job Search/Internship**
- **Post a Job**: Create job listings with title, description, employer, location, salary
- **Browse Jobs**: View all available jobs, select by number to see details
- **Apply for Job**: Submit application (one per job), automatically returns to job list
- **View My Applications**: See all submitted applications with job details

**8. Messages**
- **Send a New Message**: Send to any established connection (max 200 chars)
- **View My Messages**: Display all received messages with sender and content
- Connection validation: Can only message users in your network

**9. Exit**
- Gracefully terminates program
- Outputs `--- END_OF_PROGRAM_EXECUTION ---` sentinel

### Week 10 Enhancements
- **Complete I/O Centralization**: All output uses `PRINT-LINE` helper ensuring console/file mirroring
- **Field-Specific Validation**: Error messages indicate exactly which field failed and why
- **Job Menu Loop**: Browse → Apply → Auto-relist flow for seamless navigation
- **Message Display Refinement**: Proper separator formatting between messages
- **Modular Structure**: Clean PERFORM interactions between all modules

## Input File Format Guide

### Structure
Each line in `InCollege-Input.txt` corresponds to one user input in the exact order prompted by the application.

### Sample Input Sequences

#### Example 1: Login → Browse Jobs → Apply → Exit
```
1
AdminUser
Adminpass1+
7
2
1
1
0
3
4
9
```

**Explanation**:
1. `1` - Choose Login
2. `AdminUser` - Username
3. `Adminpass1+` - Password
4. `7` - Job Search/Internship menu
5. `2` - Browse Jobs
6. `1` - Select job #1
7. `1` - Apply for this job
8. `0` - Back to job list (from job details)
9. `3` - View My Applications
10. `4` - Back to Main Menu
11. `9` - Exit

#### Example 2: Register New Account → Create Profile
```
2
NewUser
SecurePass1!
1
NewUser
SecurePass1!
1
John
Doe
Computer Science
University of Florida
Hello, I'm a CS student!
2024
SoftwareEngineerIntern
TechCorp
06/2023-08/2023
RemoteLocation
Developed web applications
N
N
9
```

**Explanation**:
1. `2` - Create New Account
2. `NewUser` - New username
3. `SecurePass1!` - New password (meets validation)
4. `1` - Login
5. `NewUser` - Username
6. `SecurePass1!` - Password
7. `1` - Create/Edit My Profile
8. `John` - First name
9. `Doe` - Last name
10. `Computer Science` - Major
11. `University of Florida` - University
12. `Hello, I'm a CS student!` - About section
13. `2024` - Graduation year
14. `SoftwareEngineerIntern` - Experience title
15. `TechCorp` - Employer
16. `06/2023-08/2023` - Dates worked
17. `RemoteLocation` - Location
18. `Developed web applications` - Description
19. `N` - No more experience
20. `N` - No education to add
21. `9` - Exit

#### Example 3: Send Message to Connection
```
1
User1
Password1!
8
1
User2
Hey, did you see the new job posting?
3
9
```

**Explanation**:
1. `1` - Login
2. `User1` - Username
3. `Password1!` - Password
4. `8` - Messages menu
5. `1` - Send a New Message
6. `User2` - Recipient (must be a connection)
7. `Hey, did you see the new job posting?` - Message content
8. `3` - Back to Main Menu
9. `9` - Exit

### Tips for Creating Input Files
- One input per line (no extra blank lines unless intentionally testing empty input)
- Match exact menu option numbers
- For text fields: ensure proper formatting (no leading/trailing spaces unless intended)
- For multi-step flows: map out the menu path first, then write inputs in order
- Test with empty `applications.doc` for job application scenarios: `rm applications.doc && touch applications.doc`

## Output File Interpretation

### Output Structure

The `InCollege-Output.txt` file contains the complete execution trace with:
- All menu headers and options
- All prompts for user input
- All validation messages (success/error)
- All data displays (profiles, jobs, messages, applications)
- Navigation confirmations
- Exit sentinel

### Sample Output Sections

#### Login Success
```
Welcome to InCollege!
1. Log In
2. Create New Account
Enter your choice:
Please enter your username:
Please enter your password:
You have successfully logged in.
Welcome, AdminUser!
```

#### Validation Error (Password)
```
Error: Password must contain at least one uppercase letter.
Please enter your password:
```

#### Job Application Submission
```
Your application for Senior Developer at InnovateTech has been submitted.
--- Available Job Listings ---
1. Senior Developer at InnovateTech (Remote)
2. UX Designer at CreativeSolutions (San Francisco, CA)
```

#### Message Display
```
--- Your Messages ---
From: ProfSmith
Message: Great work on the project!
---
From: FriendA
Message: Did you see the new internship posting?
---------------------
1. Send a New Message
2. View My Messages
3. Back to Main Menu
Enter your choice:
```

### Key Indicators

- `--- END_OF_PROGRAM_EXECUTION ---`: Successful program termination
- `Error:` prefix: Validation failure or constraint violation
- `---` separators: Menu headers and message delimiters
- Menu redisplay: User returned from submenu or invalid input was entered

### Verification Checklist

When reviewing output files:
- ✅ All prompts appear before corresponding data
- ✅ Validation errors show field-specific messages
- ✅ Navigation flows logically through menus
- ✅ Data displays are formatted correctly
- ✅ End sentinel appears at program conclusion
- ✅ No unexpected error messages or program crashes

## Complete Usage Examples

### Scenario 1: Full Job Application Flow

**Objective**: Create account, create profile, browse jobs, apply, view applications

**Input File** (`InCollege-Input.txt`):
```
2
TestUser
TestPass1!
1
TestUser
TestPass1!
1
Jane
Smith
Business Administration
State University
N/A
2025
N
N
7
2
1
1
0
3
4
9
```

**Expected Output Highlights**:
- Account creation confirmation
- Login success message
- Profile creation with all fields
- Job listings displayed
- Application submission confirmation
- Application summary showing applied job
- Clean exit

**Data Files Updated**:
- `accounts.doc`: New entry for TestUser
- `profiles.doc`: Profile record for TestUser
- `applications.doc`: New application record

### Scenario 2: Networking Flow

**Objective**: Login, search for user, send connection request

**Preparation**: Ensure target user profile exists in `profiles.doc`

**Input File**:
```
1
User1
Password1!
3
John
Doe
1
9
```

**Expected Output**:
- Profile of John Doe displayed
- Option to send connection request
- Confirmation: "Connection request sent to John Doe."
- Request added to `connection-requests.doc`

### Scenario 3: Message Exchange

**Objective**: Login, view messages, send reply

**Preparation**: 
- Ensure `User1` and `User2` are connected in `connections.doc`
- Add test message in `messages.doc`: `User2 User1 "Test message" 20241117120000`

**Input File**:
```
1
User1
Password1!
8
2
1
User2
Thanks for the message!
3
9
```

**Expected Output**:
- Incoming message from User2 displayed
- Message sent confirmation
- New message added to `messages.doc`

## Troubleshooting

### Compilation Errors

**Error**: `command not found: cobc`
- **Solution**: Install GnuCOBOL (see Installation section)

**Error**: `syntax error at line X`
- **Solution**: Ensure you're using GnuCOBOL 3.0+ which supports free-format COBOL
- Verify file encoding is UTF-8

### Runtime Errors

**Error**: `File status 35` (File not found)
- **Solution**: This is normal for first run; the program creates missing data files automatically

**Error**: Program hangs waiting for input
- **Solution**: Ensure input file has enough entries for the complete flow
- Check that input file doesn't have extra blank lines

**Error**: `Invalid choice, please try again`
- **Solution**: Input file contains invalid menu option; verify input sequence matches menu options exactly

### Data Issues

**Issue**: "You have already applied for this job"
- **Solution**: Clear `applications.doc` before testing: `rm applications.doc && touch applications.doc`

**Issue**: "You can only message users you are connected with"
- **Solution**: Add connection to `connections.doc`: `User1                User2` (20 chars each, padded with spaces)

**Issue**: Profile not found during search
- **Solution**: Ensure profile exists in `profiles.doc` with matching first/last name

### Output Validation

**Issue**: Output file is empty
- **Solution**: Use `2>&1` redirection on macOS/Linux: `./InCollege < input.txt > output.txt 2>&1`

**Issue**: Output file contains extra characters or padding
- **Solution**: This is normal; OUTPUT-RECORD is defined as PIC X(210), causing trailing spaces. First 110 lines contain functional output.

**Issue**: Input echoes don't appear in output file
- **Solution**: This is expected with file redirection; input echoes appear in interactive mode only

### Need More Help?

- Check that all data files are in the working directory
- Verify file permissions (read/write access)
- Review commit history for recent changes
- Test with provided sample input files first

## Additional Resources

- **Sample Files**: `InCollege-Input.txt` and `InCollege-Output.txt` demonstrate complete flows
- **Test Data**: See `jobs.doc`, `messages.doc`, and `accounts.doc` for example formats
- **Source Code**: `InCollege.cob` contains detailed comments explaining each module

---

**Version**: Week 10 (EPIC10)  
**Last Updated**: November 17, 2025  
**Contributors**: Software Engineering Team

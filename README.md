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
- **Input**: The program reads all user inputs from `InCollege-Input.txt`.
- **Output Display**: All program output is displayed on the screen (standard output).
- **Output Preservation**: The exact same output displayed on the screen is also written to `InCollege-Output.txt`.

**Important**: To run a test flow:
1. Prepare `InCollege-Input.txt` with the sequence of inputs you want to test (one input per line).
2. Run the compiled program.
3. Compare the console output with `InCollege-Output.txt` - they should be identical.

**Example Input File Format:**
```
1
username
password
2
9
```
Each line represents one user input (menu choice, username, password, etc.).

## Complete Feature List

### User Authentication (Epic 1)
- **User Registration**: Create new accounts with username and password
  - Password validation: 8-12 characters, at least 1 uppercase letter, 1 digit, and 1 special character
  - Account limit: Maximum 5 accounts enforced
  - Account persistence: Saved to `accounts.doc`
- **User Login**: Authenticate with username and password
  - Success message: "You have successfully logged in."
  - Personalized welcome: "Welcome, [Username]!"
  - Unlimited login attempts allowed

### Profile Management (Epic 2)
- **Create/Edit Profile**: Comprehensive profile creation and editing
  - Required fields: First Name, Last Name, University, Major, Graduation Year (1925-2035)
  - Optional fields: About Me (up to 200 characters)
  - Experience entries: Up to 3 entries with Title, Company, Dates, and Description
  - Education entries: Up to 3 entries with Degree, University, and Years Attended
  - Profile persistence: Saved to `profiles.doc` (indexed file)
- **View Profile**: Display complete profile information
  - Shows all profile fields including experience and education
  - Formatted for easy reading

### User Search & Connections (Epic 3, 4, 5)
- **Search for Users**: Find other users by full name (exact match)
  - Displays found user's complete profile
  - Option to send connection request after viewing profile
- **Connection Requests**: Send and manage connection requests
  - Send connection requests to other users
  - Validation: Prevents self-requests, duplicate requests, and requests to already-connected users
  - View pending connection requests
  - Accept or reject incoming connection requests
  - Request persistence: Saved to `connection_requests.doc`
- **Network Management**: View established connections
  - Display all connected users with their profile information
  - Connection persistence: Saved to `connections.doc`

### Job Board (Epic 6, 7)
- **Post Jobs/Internships**: Create job listings
  - Required fields: Job Title, Description, Employer, Location
  - Optional field: Salary
  - Job persistence: Saved to `jobs.doc` with unique job IDs
- **Browse Jobs**: View all available job listings
  - List view showing: Job number, Title, Employer, Location
  - Detailed view: Full job information including description and salary
  - Navigate back to job list or main menu
- **Apply for Jobs**: Submit job applications
  - Apply to specific job postings
  - Prevents duplicate applications to the same job
  - Application persistence: Saved to `applications.doc`
- **View Applications**: Generate application summary report
  - Lists all jobs the user has applied for
  - Shows: Job Title, Employer, Location for each application
  - Displays total application count

### Messaging System (Epic 8, 9)
- **Send Messages**: Send private messages to connections
  - Recipient must be an established connection (validated)
  - Message content: Up to 200 characters
  - Message persistence: Saved to `messages.doc` with timestamp
  - Confirmation message displayed
- **View Messages**: Display received messages
  - Shows all messages sent to the logged-in user
  - Displays sender username and message content
  - Shows "You have no messages" if none exist

### Skills Learning (Epic 1)
- **Learn a New Skill**: Browse available skills
  - 5 skills available: Programming, Data Analysis, Digital Marketing, Project Management, Communication
  - Currently shows "under construction" message for each skill
  - "Go Back" option to return to main menu

## File Structure

### Data Files (Created Automatically)
- `accounts.doc`: User account credentials (username + password)
- `profiles.doc`: User profile information (indexed by username)
- `connection_requests.doc`: Pending connection requests (sender + receiver)
- `connections.doc`: Established connections (user pairs)
- `jobs.doc`: Job/internship postings (with unique IDs)
- `applications.doc`: Job applications (username + job ID)
- `messages.doc`: Messages (sender + recipient + content + timestamp)

### Input/Output Files
- `InCollege-Input.txt`: All user inputs (one per line)
- `InCollege-Output.txt`: Complete program output (mirrors console)

## Input File Format Examples

### Login Flow
```
1
username
password
```

### Registration Flow
```
2
newusername
NewPass123!
```

### Complete User Journey Example
```
1
test
testpasS1+
2
3
John Doe
2
7
2
0
3
8
2
9
```

## Output Format

All output follows consistent formatting:
- Menu headers use "---" format (e.g., "--- Job Search/Internship Menu ---")
- Main menu displays as "Main Menu:"
- Profile views show as "--- Your Profile ---"
- Error messages prefixed with "Error:"
- End of program execution: "--- END_OF_PROGRAM_EXECUTION ---"

## Error Handling

The program includes comprehensive error handling:
- Invalid menu choices display appropriate error messages
- Missing required fields prompt for re-entry
- Invalid input (e.g., non-numeric graduation year) shows descriptive errors
- File I/O errors handled gracefully (creates files if missing)
- Connection validation prevents invalid operations
- Application validation prevents duplicates

## Week 10 Enhancements

### Bug Fixes
- Fixed login success message display
- Fixed menu formatting and ordering
- Fixed job browsing and application display formatting
- Fixed message viewing formatting
- Improved error message clarity

### Quality of Life Improvements
- Enhanced input validation error messages
- Consistent "Go Back" and "Exit" options in all submenus
- Improved display formatting for lists and tables
- Better error handling for file operations

### Code Quality
- Improved code readability and comments
- Consistent naming conventions
- Removed redundant code
- Standardized file I/O structures

## Notes

- All user input must come from `InCollege-Input.txt` - the program does not accept interactive console input
- All output is simultaneously displayed on screen and written to `InCollege-Output.txt`
- Console output and file output are identical for testing verification
- Maximum 5 user accounts can be created
- Messages can only be sent to established connections
- Job applications are tracked per user to prevent duplicates

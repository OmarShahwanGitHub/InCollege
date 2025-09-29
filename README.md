# InCollege
Cobol Program for a LinkedIn-like app for college students

## How to Run

### Compile the program:
```bash
cobc -x -free InCollege-Epic3.cob -o InCollege
```

### Execute the program:
```bash
./InCollege
```

### Testing with Input Files:
The program reads all user inputs from `InCollege-Input.txt`. For testing, you can:
1. Modify `InCollege-Input.txt` with your test inputs
2. Use the provided `InCollege-Test.txt` as a comprehensive test suite
3. Copy `InCollege-Test.txt` to `InCollege-Input.txt` to run the test suite:
   ```bash
   cp InCollege-Test.txt InCollege-Input.txt
   ./InCollege
   ```

## Features
- User registration with password validation
- User login with personalized welcome message
- Post-login menu with job search, find someone, and learn skills options
- Account limit enforcement (maximum 5 accounts)
- Under construction notices for undeveloped features
- Search for classmates, view their profiles, and send connection requests with
   duplicate-request and self-request validation
- Persistent storage of pending connection requests plus a menu to review
   incoming requests

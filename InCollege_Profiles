IDENTIFICATION DIVISION.
       PROGRAM-ID. INCOLLEGE.
       
       ENVIRONMENT DIVISION.
       INPUT-OUTPUT SECTION.
       FILE-CONTROL.
           SELECT INPUT-FILE ASSIGN TO "InCollege-Input.txt"
               ORGANIZATION IS LINE SEQUENTIAL.
           SELECT OUTPUT-FILE ASSIGN TO "InCollege-Output.txt"
               ORGANIZATION IS LINE SEQUENTIAL.
           SELECT ACCOUNTS-FILE ASSIGN TO "accounts.doc"
               ORGANIZATION IS LINE SEQUENTIAL
               FILE STATUS IS WS-FILE-STATUS.
           SELECT PROFILES-FILE ASSIGN TO "profiles.doc"
               ORGANIZATION IS LINE SEQUENTIAL
               FILE STATUS IS WS-PROF-STATUS.
       
       DATA DIVISION.
       FILE SECTION.
       FD INPUT-FILE.
       01 INPUT-RECORD PIC X(80).
       
       FD OUTPUT-FILE.
       01 OUTPUT-RECORD PIC X(80).
       
       FD ACCOUNTS-FILE.
       01 ACCOUNT-RECORD.
           05 ACCOUNT-USERNAME PIC X(20).
           05 ACCOUNT-PASSWORD PIC X(12).
       
       FD PROFILES-FILE.
       01 PROFILE-RECORD.
           05 PROFILE-USERNAME PIC X(20).
           05 PROFILE-DATA.
              10 FIRST-NAME PIC X(20).
              10 LAST-NAME PIC X(20).
              10 UNIVERSITY PIC X(30).
              10 MAJOR PIC X(20).
              10 GRAD-YEAR PIC 9(4).
              10 ABOUT-ME PIC X(200).
              10 EXP-COUNT PIC 9.
              10 EXPERIENCES OCCURS 3 TIMES
                 INDEXED BY EXP-IDX.
                 15 EXP-TITLE PIC X(30).
                 15 EXP-COMPANY PIC X(30).
                 15 EXP-DATES PIC X(20).
                 15 EXP-DESC PIC X(100).
              10 EDU-COUNT PIC 9.
              10 EDUCATION OCCURS 3 TIMES
                 INDEXED BY EDU-IDX.
                 15 EDU-DEGREE PIC X(30).
                 15 EDU-SCHOOL PIC X(30).
                 15 EDU-YEARS PIC X(20).
       
       WORKING-STORAGE SECTION.
       01 WS-EOF-FLAG PIC X VALUE 'N'.
       01 WS-ACCOUNTS-EOF PIC X VALUE 'N'.
       01 WS-PROFILES-EOF PIC X VALUE 'N'.
       01 WS-USER-CHOICE PIC 9.
       01 WS-USERNAME PIC X(20).
       01 WS-USER-TRIM PIC X(20).
       01 WS-PASSWORD PIC X(12).
       01 WS-LOGIN-SUCCESS PIC X VALUE 'N'.
       01 WS-TEMP-INPUT PIC X(80).
       01 WS-STORED-USERNAME PIC X(20).
       01 WS-STORED-PASSWORD PIC X(12).
       01 WS-MESSAGE PIC X(90).
       01 WS-CURRENT-PROFILE.
          05 CP-FIRST-NAME PIC X(20).
          05 CP-LAST-NAME PIC X(20).
          05 CP-UNIVERSITY PIC X(30).
          05 CP-MAJOR PIC X(20).
          05 CP-GRAD-YEAR PIC 9(4).
          05 CP-ABOUT-ME PIC X(200).
          05 CP-EXP-COUNT PIC 9.
          05 CP-EXPERIENCES OCCURS 3 TIMES
            INDEXED BY CP-EXP-IDX.
            10 CP-EXP-TITLE PIC X(30).
            10 CP-EXP-COMPANY PIC X(30).
            10 CP-EXP-DATES PIC X(20).
            10 CP-EXP-DESC PIC X(100).
          05 CP-EDU-COUNT PIC 9.
          05 CP-EDUCATION OCCURS 3 TIMES
            INDEXED BY CP-EDU-IDX.
            10 CP-EDU-DEGREE PIC X(30).
            10 CP-EDU-SCHOOL PIC X(30).
            10 CP-EDU-YEARS PIC X(20).
       
       77  WS-Choice        PIC 9 VALUE 0.
       77  WS-Account-Count PIC 9 VALUE 0.
       77  WS-COUNTER       PIC 9 VALUE 0.
       77  WS-FILE-STATUS   PIC XX.
       77  WS-PROF-STATUS   PIC XX.
       77  WS-EOF           PIC X VALUE "N".
       77  WS-Valid-Pass    PIC X VALUE "N".
       77  WS-Has-Upper     PIC X VALUE "N".
       77  WS-Has-Digit     PIC X VALUE "N".
       77  WS-Has-Special   PIC X VALUE "N".
       77  WS-Len           PIC 99.
       77  WS-Trail-Sp      PIC 99.
       77  WS-Lead-Sp       PIC 99.
       77  IDX              PIC 99.
       77  WS-Temp-Count    PIC 9.
       77  WS-Temp-Input2   PIC X(80).
       77  WS-Temp-Year     PIC 9(4).
       77  WS-Profile-Found PIC X VALUE "N".

       01  WS-Existing-Record.
           05 EX-Username   PIC X(20).
           05 EX-Password   PIC X(12).

       PROCEDURE DIVISION.
       MAIN-LOGIC.
           PERFORM INITIALIZE-PROGRAM
           PERFORM MAIN-MENU UNTIL WS-EOF-FLAG = "Y"
           PERFORM CLEANUP
           STOP RUN.
       
       INITIALIZE-PROGRAM.
           OPEN INPUT INPUT-FILE
           OPEN OUTPUT OUTPUT-FILE
           OPEN INPUT ACCOUNTS-FILE
           IF WS-FILE-STATUS NOT = "00"
              OPEN OUTPUT ACCOUNTS-FILE
              CLOSE ACCOUNTS-FILE
              OPEN INPUT ACCOUNTS-FILE
           END-IF

           MOVE 0 TO WS-Account-Count
           MOVE "N" TO WS-EOF
           PERFORM UNTIL WS-EOF = "Y"
              READ ACCOUNTS-FILE INTO WS-Existing-Record
                 AT END MOVE "Y" TO WS-EOF
                 NOT AT END ADD 1 TO WS-Account-Count
              END-READ
           END-PERFORM
           CLOSE ACCOUNTS-FILE
           .
       
       MAIN-MENU.
           DISPLAY "Welcome to InCollege!"
           MOVE "Welcome to InCollege!" TO OUTPUT-RECORD
           WRITE OUTPUT-RECORD

           DISPLAY "1. Log In"
           MOVE "1. Log In" TO OUTPUT-RECORD
           WRITE OUTPUT-RECORD

           DISPLAY "2. Create New Account"
           MOVE "2. Create New Account" TO OUTPUT-RECORD
           WRITE OUTPUT-RECORD

           DISPLAY "Enter your choice:"
           MOVE "Enter your choice:" TO OUTPUT-RECORD
           WRITE OUTPUT-RECORD
           
           READ INPUT-FILE INTO WS-TEMP-INPUT
               AT END MOVE "Y" TO WS-EOF-FLAG
               NOT AT END
                   MOVE WS-TEMP-INPUT(1:1) TO WS-USER-CHOICE
                   EVALUATE WS-USER-CHOICE
                       WHEN 1
                           PERFORM LOGIN-PROCESS
                       WHEN 2
                           PERFORM REGISTRATION
                       WHEN OTHER
                           DISPLAY "Invalid choice, please try again"
                           MOVE "Invalid choice, please try again" TO OUTPUT-RECORD
                           WRITE OUTPUT-RECORD
                   END-EVALUATE
           END-READ.
       
       REGISTRATION.
           OPEN EXTEND ACCOUNTS-FILE

           IF WS-Account-Count >= 5
              DISPLAY "All permitted accounts have been created, Max 5 accounts."
              MOVE "All permitted accounts have been created, Max 5 accounts." TO OUTPUT-RECORD
              WRITE OUTPUT-RECORD
              EXIT PARAGRAPH
           END-IF

           DISPLAY "Enter Username:"
           MOVE "Enter Username:" TO OUTPUT-RECORD
           WRITE OUTPUT-RECORD
           IF WS-EOF-FLAG NOT = "Y"
             READ INPUT-FILE INTO WS-USERNAME
                 AT END MOVE "Y" TO WS-EOF-FLAG
             END-READ
           END-IF
     
           MOVE "N" TO WS-Valid-Pass
           PERFORM UNTIL WS-Valid-Pass = "Y"
               DISPLAY "Enter Password:"
               MOVE "Enter Password:" TO OUTPUT-RECORD
               WRITE OUTPUT-RECORD
               IF WS-EOF-FLAG NOT = "Y"
                 READ INPUT-FILE INTO WS-PASSWORD
                    AT END MOVE "Y" TO WS-EOF-FLAG
                 END-READ
               END-IF
               PERFORM VALIDATE-PASSWORD
           END-PERFORM
           
           MOVE WS-USERNAME TO ACCOUNT-USERNAME
           MOVE WS-PASSWORD TO ACCOUNT-PASSWORD
           WRITE ACCOUNT-RECORD

           ADD 1 TO WS-Account-Count
           DISPLAY "Account successfully created!"
           MOVE "Account successfully created!" TO OUTPUT-RECORD
           WRITE OUTPUT-RECORD

           CLOSE ACCOUNTS-FILE
           .

       VALIDATE-PASSWORD.
           MOVE "N" TO WS-Valid-Pass
           MOVE "N" TO WS-Has-Upper
           MOVE "N" TO WS-Has-Digit
           MOVE "N" TO WS-Has-Special
           MOVE 0 TO WS-Len
           MOVE 0 TO WS-Trail-Sp
           MOVE 0 TO WS-Lead-Sp

           INSPECT WS-PASSWORD TALLYING WS-Trail-Sp FOR TRAILING SPACES
           INSPECT WS-PASSWORD TALLYING WS-Lead-Sp FOR LEADING SPACES
           INSPECT WS-PASSWORD TALLYING WS-Len FOR CHARACTERS

           SUBTRACT WS-Trail-Sp FROM WS-Len GIVING WS-Len
           SUBTRACT WS-Lead-Sp FROM WS-Len GIVING WS-Len
           IF WS-Len < 8 OR WS-Len > 12
              DISPLAY "Error: Password must be 8-12 characters long."
              MOVE "Error: Password must be 8-12 characters long." TO OUTPUT-RECORD
              WRITE OUTPUT-RECORD
              EXIT PARAGRAPH
           END-IF

           PERFORM VARYING IDX FROM 1 BY 1 UNTIL IDX > WS-Len
              EVALUATE TRUE
                 WHEN WS-PASSWORD(IDX:1) >= "A" AND WS-PASSWORD(IDX:1) <= "Z"
                    MOVE "Y" TO WS-Has-Upper
                 WHEN WS-PASSWORD(IDX:1) >= "0" AND WS-PASSWORD(IDX:1) <= "9"
                    MOVE "Y" TO WS-Has-Digit
                 WHEN WS-PASSWORD(IDX:1) < "0" OR
                      WS-PASSWORD(IDX:1) > "9" AND
                      WS-PASSWORD(IDX:1) < "A" OR
                      WS-PASSWORD(IDX:1) > "Z" AND
                      WS-PASSWORD(IDX:1) < "a" OR
                      WS-PASSWORD(IDX:1) > "z"
                    MOVE "Y" TO WS-Has-Special
              END-EVALUATE
           END-PERFORM

           IF WS-Has-Upper = "Y"
               AND WS-Has-Digit = "Y"
               AND WS-Has-Special = "Y"
               MOVE "Y" TO WS-Valid-Pass
           ELSE
               DISPLAY "Error: Password must include at least 1 uppercase, 1 digit, and 1 special character."
               MOVE "Error: Password must include at least 1 uppercase, 1 digit, and 1 special character." TO OUTPUT-RECORD
               WRITE OUTPUT-RECORD
           END-IF
           .

       LOGIN-PROCESS.
           MOVE "N" TO WS-LOGIN-SUCCESS
           
           DISPLAY "Please enter your username:"
           MOVE "Please enter your username:" TO OUTPUT-RECORD
           WRITE OUTPUT-RECORD

           IF WS-EOF-FLAG NOT = "Y"
             READ INPUT-FILE INTO WS-USERNAME
                 AT END MOVE "Y" TO WS-EOF-FLAG
             END-READ
           END-IF

           DISPLAY "Please enter your password:"
           MOVE "Please enter your password:" TO OUTPUT-RECORD
           WRITE OUTPUT-RECORD

           IF WS-EOF-FLAG NOT = "Y"
               READ INPUT-FILE INTO WS-PASSWORD
                   AT END MOVE "Y" TO WS-EOF-FLAG
               END-READ
           END-IF
           
           IF WS-EOF-FLAG NOT = "Y"
               PERFORM VALIDATE-LOGIN
               
               IF WS-LOGIN-SUCCESS = "Y"
                   STRING "Welcome " DELIMITED BY SIZE
                       WS-USERNAME DELIMITED BY SPACE
                       "!" DELIMITED BY SIZE
                       INTO WS-MESSAGE
                   END-STRING

                   DISPLAY WS-MESSAGE
                   MOVE WS-MESSAGE TO OUTPUT-RECORD
                   WRITE OUTPUT-RECORD

                   MOVE SPACES TO WS-MESSAGE

                   PERFORM POST-LOGIN-MENU
               ELSE
                   DISPLAY "Incorrect username/password, try again."
                   MOVE "Incorrect username/password, try again." TO OUTPUT-RECORD
                   WRITE OUTPUT-RECORD
               END-IF
           END-IF
           .
		
       POST-LOGIN-MENU.
           DISPLAY "1. Create/Edit My Profile"
           MOVE "1. Create/Edit My Profile" TO OUTPUT-RECORD
           WRITE OUTPUT-RECORD

           DISPLAY "2. View My Profile"
           MOVE "2. View My Profile" TO OUTPUT-RECORD
           WRITE OUTPUT-RECORD

           DISPLAY "3. Search for User"
           MOVE "3. Search for User" TO OUTPUT-RECORD
           WRITE OUTPUT-RECORD

           DISPLAY "4. Learn a New Skill"
           MOVE "4. Learn a New Skill" TO OUTPUT-RECORD
           WRITE OUTPUT-RECORD

           DISPLAY "Enter your choice:"
           MOVE "Enter your choice:" TO OUTPUT-RECORD
           WRITE OUTPUT-RECORD
           

           IF WS-EOF-FLAG NOT = "Y"
           READ INPUT-FILE INTO WS-TEMP-INPUT
               AT END MOVE "Y" TO WS-EOF-FLAG
               NOT AT END
                   MOVE WS-TEMP-INPUT(1:1) TO WS-USER-CHOICE
                   EVALUATE WS-USER-CHOICE
                       WHEN 1
                           PERFORM PROFILE-CREATE-EDIT
                       WHEN 2
                           PERFORM PROFILE-VIEW
                       WHEN 3
                           DISPLAY "Search for User is under construction."
                           MOVE "Search for User is under construction." TO OUTPUT-RECORD
                           WRITE OUTPUT-RECORD
                       WHEN 4
                           PERFORM LEARN-SKILL-MENU
                       WHEN OTHER
                           DISPLAY "Invalid choice, please try again"
                           MOVE "Invalid choice, please try again" TO OUTPUT-RECORD
                           WRITE OUTPUT-RECORD
                   END-EVALUATE
           END-READ
           END-IF.
       
       PROFILE-CREATE-EDIT.
           PERFORM LOAD-PROFILE
           
           DISPLAY "--- Create/Edit Profile ---"
           MOVE "--- Create/Edit Profile ---" TO OUTPUT-RECORD
           WRITE OUTPUT-RECORD
           
           DISPLAY "Enter First Name:"
           MOVE "Enter First Name:" TO OUTPUT-RECORD
           WRITE OUTPUT-RECORD
           IF WS-EOF-FLAG NOT = "Y"
               READ INPUT-FILE INTO CP-FIRST-NAME
                   AT END MOVE "Y" TO WS-EOF-FLAG
               END-READ
           END-IF
           
           DISPLAY "Enter Last Name:"
           MOVE "Enter Last Name:" TO OUTPUT-RECORD
           WRITE OUTPUT-RECORD
           IF WS-EOF-FLAG NOT = "Y"
               READ INPUT-FILE INTO CP-LAST-NAME
                   AT END MOVE "Y" TO WS-EOF-FLAG
               END-READ
           END-IF
           
           DISPLAY "Enter University/College Attended:"
           MOVE "Enter University/College Attended:" TO OUTPUT-RECORD
           WRITE OUTPUT-RECORD
           IF WS-EOF-FLAG NOT = "Y"
               READ INPUT-FILE INTO CP-UNIVERSITY
                   AT END MOVE "Y" TO WS-EOF-FLAG
               END-READ
           END-IF
           
           DISPLAY "Enter Major:"
           MOVE "Enter Major:" TO OUTPUT-RECORD
           WRITE OUTPUT-RECORD
           IF WS-EOF-FLAG NOT = "Y"
               READ INPUT-FILE INTO CP-MAJOR
                   AT END MOVE "Y" TO WS-EOF-FLAG
               END-READ
           END-IF
           
           PERFORM UNTIL CP-GRAD-YEAR > 1900 AND CP-GRAD-YEAR < 2100
               DISPLAY "Enter Graduation Year (YYYY):"
               MOVE "Enter Graduation Year (YYYY):" TO OUTPUT-RECORD
               WRITE OUTPUT-RECORD
               IF WS-EOF-FLAG NOT = "Y"
                   READ INPUT-FILE INTO WS-TEMP-INPUT
                       AT END MOVE "Y" TO WS-EOF-FLAG
                   END-READ
                   IF WS-TEMP-INPUT(1:4) NUMERIC
                       MOVE WS-TEMP-INPUT(1:4) TO CP-GRAD-YEAR
                   ELSE
                       MOVE 0 TO CP-GRAD-YEAR
                   END-IF
               END-IF
           END-PERFORM
           
           DISPLAY "Enter About Me (optional, max 200 chars, enter blank line to skip):"
           MOVE "Enter About Me (optional, max 200 chars, enter blank line to skip):" TO OUTPUT-RECORD
           WRITE OUTPUT-RECORD
           IF WS-EOF-FLAG NOT = "Y"
               READ INPUT-FILE INTO CP-ABOUT-ME
                   AT END MOVE "Y" TO WS-EOF-FLAG
               END-READ
           END-IF
           
           MOVE 0 TO CP-EXP-COUNT
           DISPLAY "Add Experience (optional, max 3 entries. Enter 'DONE' to finish):"
           MOVE "Add Experience (optional, max 3 entries. Enter 'DONE' to finish):" TO OUTPUT-RECORD
           WRITE OUTPUT-RECORD
           
           PERFORM UNTIL CP-EXP-COUNT >= 3 OR WS-EOF-FLAG = "Y"
               ADD 1 TO CP-EXP-COUNT
               
               DISPLAY "Experience #" CP-EXP-COUNT " - Title:"
               STRING "Experience #" CP-EXP-COUNT " - Title:" 
                   DELIMITED BY SIZE INTO OUTPUT-RECORD
               WRITE OUTPUT-RECORD
               IF WS-EOF-FLAG NOT = "Y"
                   READ INPUT-FILE INTO CP-EXP-TITLE(CP-EXP-COUNT)
                       AT END MOVE "Y" TO WS-EOF-FLAG
                   END-READ
                   IF FUNCTION UPPER-CASE(CP-EXP-TITLE(CP-EXP-COUNT)) = "DONE"
                       SUBTRACT 1 FROM CP-EXP-COUNT
                       EXIT PERFORM
                   END-IF
               END-IF
               
               DISPLAY "Experience #" CP-EXP-COUNT " - Company/Organization:"
               STRING "Experience #" CP-EXP-COUNT " - Company/Organization:" 
                   DELIMITED BY SIZE INTO OUTPUT-RECORD
               WRITE OUTPUT-RECORD
               IF WS-EOF-FLAG NOT = "Y"
                   READ INPUT-FILE INTO CP-EXP-COMPANY(CP-EXP-COUNT)
                       AT END MOVE "Y" TO WS-EOF-FLAG
                   END-READ
               END-IF
               
               DISPLAY "Experience #" CP-EXP-COUNT " - Dates (e.g., Summer 2024):"
               STRING "Experience #" CP-EXP-COUNT " - Dates (e.g., Summer 2024):" 
                   DELIMITED BY SIZE INTO OUTPUT-RECORD
               WRITE OUTPUT-RECORD
               IF WS-EOF-FLAG NOT = "Y"
                   READ INPUT-FILE INTO CP-EXP-DATES(CP-EXP-COUNT)
                       AT END MOVE "Y" TO WS-EOF-FLAG
                   END-READ
               END-IF
               
               DISPLAY "Experience #" CP-EXP-COUNT " - Description (optional, max 100 chars, blank to skip):"
               STRING "Experience #" CP-EXP-COUNT " - Description (optional, max 100 chars, blank to skip):" 
                   DELIMITED BY SIZE INTO OUTPUT-RECORD
               WRITE OUTPUT-RECORD
               IF WS-EOF-FLAG NOT = "Y"
                   READ INPUT-FILE INTO CP-EXP-DESC(CP-EXP-COUNT)
                       AT END MOVE "Y" TO WS-EOF-FLAG
                   END-READ
               END-IF
               
               DISPLAY "Add Experience (optional, max 3 entries. Enter 'DONE' to finish):"
               MOVE "Add Experience (optional, max 3 entries. Enter 'DONE' to finish):" TO OUTPUT-RECORD
               WRITE OUTPUT-RECORD
           END-PERFORM
           
           MOVE 0 TO CP-EDU-COUNT
           DISPLAY "Add Education (optional, max 3 entries. Enter 'DONE' to finish):"
           MOVE "Add Education (optional, max 3 entries. Enter 'DONE' to finish):" TO OUTPUT-RECORD
           WRITE OUTPUT-RECORD
           
           PERFORM UNTIL CP-EDU-COUNT >= 3 OR WS-EOF-FLAG = "Y"
               ADD 1 TO CP-EDU-COUNT
               
               DISPLAY "Education #" CP-EDU-COUNT " - Degree:"
               STRING "Education #" CP-EDU-COUNT " - Degree:" 
                   DELIMITED BY SIZE INTO OUTPUT-RECORD
               WRITE OUTPUT-RECORD
               IF WS-EOF-FLAG NOT = "Y"
                   READ INPUT-FILE INTO CP-EDU-DEGREE(CP-EDU-COUNT)
                       AT END MOVE "Y" TO WS-EOF-FLAG
                   END-READ
                   IF FUNCTION UPPER-CASE(CP-EDU-DEGREE(CP-EDU-COUNT)) = "DONE"
                       SUBTRACT 1 FROM CP-EDU-COUNT
                       EXIT PERFORM
                   END-IF
               END-IF
               
               DISPLAY "Education #" CP-EDU-COUNT " - University/College:"
               STRING "Education #" CP-EDU-COUNT " - University/College:" 
                   DELIMITED BY SIZE INTO OUTPUT-RECORD
               WRITE OUTPUT-RECORD
               IF WS-EOF-FLAG NOT = "Y"
                   READ INPUT-FILE INTO CP-EDU-SCHOOL(CP-EDU-COUNT)
                       AT END MOVE "Y" TO WS-EOF-FLAG
                   END-READ
               END-IF
               
               DISPLAY "Education #" CP-EDU-COUNT " - Years Attended (e.g., 2023-2025):"
               STRING "Education #" CP-EDU-COUNT " - Years Attended (e.g., 2023-2025):" 
                   DELIMITED BY SIZE INTO OUTPUT-RECORD
               WRITE OUTPUT-RECORD
               IF WS-EOF-FLAG NOT = "Y"
                   READ INPUT-FILE INTO CP-EDU-YEARS(CP-EDU-COUNT)
                       AT END MOVE "Y" TO WS-EOF-FLAG
                   END-READ
               END-IF
               
               DISPLAY "Add Education (optional, max 3 entries. Enter 'DONE' to finish):"
               MOVE "Add Education (optional, max 3 entries. Enter 'DONE' to finish):" TO OUTPUT-RECORD
               WRITE OUTPUT-RECORD
           END-PERFORM
           
           PERFORM SAVE-PROFILE
           DISPLAY "Profile saved successfully!"
           MOVE "Profile saved successfully!" TO OUTPUT-RECORD
           WRITE OUTPUT-RECORD
           .
       
       PROFILE-VIEW.
           PERFORM LOAD-PROFILE
           
           DISPLAY "--- Your Profile ---"
           MOVE "--- Your Profile ---" TO OUTPUT-RECORD
           WRITE OUTPUT-RECORD
           
           DISPLAY "Name: " CP-FIRST-NAME " " CP-LAST-NAME
           STRING "Name: " CP-FIRST-NAME " " CP-LAST-NAME
               DELIMITED BY SIZE INTO OUTPUT-RECORD
           WRITE OUTPUT-RECORD
           
           DISPLAY "University: " CP-UNIVERSITY
           STRING "University: " CP-UNIVERSITY
               DELIMITED BY SIZE INTO OUTPUT-RECORD
           WRITE OUTPUT-RECORD
           
           DISPLAY "Major: " CP-MAJOR
           STRING "Major: " CP-MAJOR
               DELIMITED BY SIZE INTO OUTPUT-RECORD
           WRITE OUTPUT-RECORD
           
           DISPLAY "Graduation Year: " CP-GRAD-YEAR
           STRING "Graduation Year: " CP-GRAD-YEAR
               DELIMITED BY SIZE INTO OUTPUT-RECORD
           WRITE OUTPUT-RECORD
           
           IF CP-ABOUT-ME NOT = SPACES
               DISPLAY "About Me: " CP-ABOUT-ME
               STRING "About Me: " CP-ABOUT-ME
                   DELIMITED BY SIZE INTO OUTPUT-RECORD
               WRITE OUTPUT-RECORD
           END-IF
           
           IF CP-EXP-COUNT > 0
               DISPLAY "Experience:"
               MOVE "Experience:" TO OUTPUT-RECORD
               WRITE OUTPUT-RECORD
               
               PERFORM VARYING IDX FROM 1 BY 1 
                 UNTIL IDX > CP-EXP-COUNT
                   DISPLAY " Title: " CP-EXP-TITLE(IDX)
                   STRING " Title: " CP-EXP-TITLE(IDX)
                       DELIMITED BY SIZE INTO OUTPUT-RECORD
                   WRITE OUTPUT-RECORD
                   
                   DISPLAY " Company: " CP-EXP-COMPANY(IDX)
                   STRING " Company: " CP-EXP-COMPANY(IDX)
                       DELIMITED BY SIZE INTO OUTPUT-RECORD
                   WRITE OUTPUT-RECORD
                   
                   DISPLAY " Dates: " CP-EXP-DATES(IDX)
                   STRING " Dates: " CP-EXP-DATES(IDX)
                       DELIMITED BY SIZE INTO OUTPUT-RECORD
                   WRITE OUTPUT-RECORD
                   
                   IF CP-EXP-DESC(IDX) NOT = SPACES
                       DISPLAY " Description: " CP-EXP-DESC(IDX)
                       STRING " Description: " CP-EXP-DESC(IDX)
                           DELIMITED BY SIZE INTO OUTPUT-RECORD
                       WRITE OUTPUT-RECORD
                   END-IF
                   DISPLAY " "
                   MOVE " " TO OUTPUT-RECORD
                   WRITE OUTPUT-RECORD
               END-PERFORM
           END-IF
           
           IF CP-EDU-COUNT > 0
               DISPLAY "Education:"
               MOVE "Education:" TO OUTPUT-RECORD
               WRITE OUTPUT-RECORD
               
               PERFORM VARYING IDX FROM 1 BY 1 
                 UNTIL IDX > CP-EDU-COUNT
                   DISPLAY " Degree: " CP-EDU-DEGREE(IDX)
                   STRING " Degree: " CP-EDU-DEGREE(IDX)
                       DELIMITED BY SIZE INTO OUTPUT-RECORD
                   WRITE OUTPUT-RECORD
                   
                   DISPLAY " University: " CP-EDU-SCHOOL(IDX)
                   STRING " University: " CP-EDU-SCHOOL(IDX)
                       DELIMITED BY SIZE INTO OUTPUT-RECORD
                   WRITE OUTPUT-RECORD
                   
                   DISPLAY " Years: " CP-EDU-YEARS(IDX)
                   STRING " Years: " CP-EDU-YEARS(IDX)
                       DELIMITED BY SIZE INTO OUTPUT-RECORD
                   WRITE OUTPUT-RECORD
                   DISPLAY " "
                   MOVE " " TO OUTPUT-RECORD
                   WRITE OUTPUT-RECORD
               END-PERFORM
           END-IF
           
           DISPLAY "---"
           MOVE "---" TO OUTPUT-RECORD
           WRITE OUTPUT-RECORD
           .
       
       LOAD-PROFILE.
           MOVE "N" TO WS-Profile-Found
           MOVE SPACES TO WS-CURRENT-PROFILE
           MOVE 0 TO CP-EXP-COUNT
           MOVE 0 TO CP-EDU-COUNT
           
           OPEN INPUT PROFILES-FILE
           IF WS-PROF-STATUS NOT = "00"
               OPEN OUTPUT PROFILES-FILE
               CLOSE PROFILES-FILE
               OPEN INPUT PROFILES-FILE
           END-IF
           
           MOVE "N" TO WS-PROFILES-EOF
           PERFORM UNTIL WS-PROFILES-EOF = "Y"
               READ PROFILES-FILE INTO PROFILE-RECORD
                   AT END MOVE "Y" TO WS-PROFILES-EOF
                   NOT AT END
                       IF PROFILE-USERNAME = WS-USERNAME
                           MOVE PROFILE-DATA TO WS-CURRENT-PROFILE
                           MOVE "Y" TO WS-Profile-Found
                       END-IF
               END-READ
           END-PERFORM
           
           CLOSE PROFILES-FILE
           .
       
       SAVE-PROFILE.
           OPEN I-O PROFILES-FILE
           IF WS-PROF-STATUS NOT = "00"
               OPEN OUTPUT PROFILES-FILE
               CLOSE PROFILES-FILE
               OPEN I-O PROFILES-FILE
           END-IF
           
           MOVE "N" TO WS-PROFILES-EOF
           MOVE "N" TO WS-Profile-Found
           MOVE 0 TO WS-Temp-Count
           
           PERFORM UNTIL WS-PROFILES-EOF = "Y"
               READ PROFILES-FILE INTO PROFILE-RECORD
                   AT END MOVE "Y" TO WS-PROFILES-EOF
                   NOT AT END
                       ADD 1 TO WS-Temp-Count
                       IF PROFILE-USERNAME = WS-USERNAME
                           MOVE "Y" TO WS-Profile-Found
                           EXIT PERFORM
                       END-IF
               END-READ
           END-PERFORM
           
           IF WS-Profile-Found = "Y"
               MOVE WS-USERNAME TO PROFILE-USERNAME
               MOVE WS-CURRENT-PROFILE TO PROFILE-DATA
               REWRITE PROFILE-RECORD
           ELSE
               MOVE WS-USERNAME TO PROFILE-USERNAME
               MOVE WS-CURRENT-PROFILE TO PROFILE-DATA
               WRITE PROFILE-RECORD
           END-IF
           
           CLOSE PROFILES-FILE
           .
       
       LEARN-SKILL-MENU.
           DISPLAY "Learn a New Skill"
           MOVE "Learn a New Skill" TO OUTPUT-RECORD
           WRITE OUTPUT-RECORD

           DISPLAY "1. Programming"
           MOVE "1. Programming" TO OUTPUT-RECORD
           WRITE OUTPUT-RECORD

           DISPLAY "2. Data Analysis"
           MOVE "2. Data Analysis" TO OUTPUT-RECORD
           WRITE OUTPUT-RECORD

           DISPLAY "3. Digital Marketing"
           MOVE "3. Digital Marketing" TO OUTPUT-RECORD
           WRITE OUTPUT-RECORD

           DISPLAY "4. Project Management"
           MOVE "4. Project Management" TO OUTPUT-RECORD
           WRITE OUTPUT-RECORD

           DISPLAY "5. Communication"
           MOVE "5. Communication" TO OUTPUT-RECORD
           WRITE OUTPUT-RECORD

           DISPLAY "6. Go Back"
           MOVE "6. Go Back" TO OUTPUT-RECORD
           WRITE OUTPUT-RECORD

           DISPLAY "Enter your choice:"
           MOVE "Enter your choice:" TO OUTPUT-RECORD
           WRITE OUTPUT-RECORD
           
           IF WS-EOF-FLAG NOT = "Y"
           READ INPUT-FILE INTO WS-TEMP-INPUT
               AT END MOVE "Y" TO WS-EOF-FLAG
               NOT AT END
                   MOVE WS-TEMP-INPUT(1:1) TO WS-USER-CHOICE
                   EVALUATE WS-USER-CHOICE
                       WHEN 1
                           DISPLAY "Programming is under construction."
                           MOVE "Programming is under construction." TO OUTPUT-RECORD
                           WRITE OUTPUT-RECORD
                       WHEN 2
                           DISPLAY "Data Analysis under construction."
                           MOVE "Data Analysis under construction." TO OUTPUT-RECORD
                           WRITE OUTPUT-RECORD
                       WHEN 3
                           DISPLAY "Digital Marketing "
                           MOVE "Digital Marketing " TO OUTPUT-RECORD
                           WRITE OUTPUT-RECORD

                           DISPLAY "under construction."
                           MOVE "under construction." TO OUTPUT-RECORD
                           WRITE OUTPUT-RECORD
                       WHEN 4
                           DISPLAY "Project Management "
                           MOVE "Project Management " TO OUTPUT-RECORD
                           WRITE OUTPUT-RECORD

                           DISPLAY "under construction."
                           MOVE "under construction." TO OUTPUT-RECORD
                           WRITE OUTPUT-RECORD
                       WHEN 5
                           DISPLAY "Communication under construction."
                           MOVE "Communication under construction." TO OUTPUT-RECORD
                           WRITE OUTPUT-RECORD
                       WHEN 6
                           DISPLAY "Returning to main menu..."
                           MOVE "Returning to main menu..." TO OUTPUT-RECORD
                           WRITE OUTPUT-RECORD
                       WHEN OTHER
                           DISPLAY "Invalid choice, please try again"
                           MOVE "Invalid choice, please try again" TO OUTPUT-RECORD
                           WRITE OUTPUT-RECORD
                   END-EVALUATE
           END-READ
           END-IF.
       
       VALIDATE-LOGIN.
           MOVE "N" TO WS-LOGIN-SUCCESS
           MOVE "N" TO WS-ACCOUNTS-EOF
           MOVE 0 TO WS-COUNTER
           
           OPEN INPUT ACCOUNTS-FILE
           CLOSE ACCOUNTS-FILE
           OPEN INPUT ACCOUNTS-FILE
           
           PERFORM UNTIL WS-ACCOUNTS-EOF = "Y" OR WS-LOGIN-SUCCESS = "Y"
             OR WS-COUNTER > 5
               ADD 1 TO WS-COUNTER
               READ ACCOUNTS-FILE INTO ACCOUNT-RECORD
                   AT END MOVE "Y" TO WS-ACCOUNTS-EOF
               END-READ
               MOVE ACCOUNT-USERNAME TO WS-STORED-USERNAME
               MOVE ACCOUNT-PASSWORD TO WS-STORED-PASSWORD
                       
               IF WS-ACCOUNTS-EOF = 'N' AND 
                  WS-USERNAME = WS-STORED-USERNAME AND
                  WS-PASSWORD = WS-STORED-PASSWORD
                  MOVE "Y" TO WS-LOGIN-SUCCESS
               END-IF
           END-PERFORM
           
           CLOSE ACCOUNTS-FILE.
       
       WRITE-TO-OUTPUT.
           MOVE FUNCTION TRIM(FUNCTION REVERSE(
               FUNCTION TRIM(FUNCTION REVERSE(
               WS-TEMP-INPUT)))) TO OUTPUT-RECORD
           WRITE OUTPUT-RECORD.
       
       CLEANUP.
           CLOSE INPUT-FILE
           CLOSE OUTPUT-FILE
           CLOSE ACCOUNTS-FILE
           CLOSE PROFILES-FILE.

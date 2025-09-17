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
           SELECT PROFILE-FILE ASSIGN TO "profiles.doc"
               ORGANIZATION IS INDEXED
               ACCESS MODE IS DYNAMIC
               RECORD KEY IS PR-USERNAME
               FILE STATUS IS WS-FILE-STATUS.
       
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
       
       FD  PROFILE-FILE.
       01  PROFILE-RECORD.
           05  PR-USERNAME        PIC X(20).
           05  PR-FIRST-NAME      PIC X(20).
           05  PR-LAST-NAME       PIC X(20).
           05  PR-UNIVERSITY      PIC X(30).
           05  PR-MAJOR           PIC X(30).
           05  PR-GRAD-YEAR       PIC 9(4).
           05  PR-ABOUT-ME        PIC X(200).
           05  PR-EXP OCCURS 3 TIMES.
               10 PR-EXP-DESC     PIC X(100).
           05  PR-EDU OCCURS 3 TIMES.
               10 PR-EDU-DESC     PIC X(100).

       WORKING-STORAGE SECTION.
       01 WS-EOF-FLAG PIC X VALUE 'N'.
       01 WS-ACCOUNTS-EOF PIC X VALUE 'N'.
       01 WS-USER-CHOICE PIC 9.
       01 WS-USERNAME PIC X(20).
       01 WS-USER-TRIM PIC X(20).
       01 WS-PASSWORD PIC X(12).
       01 WS-LOGIN-SUCCESS PIC X VALUE 'N'.
       01 WS-TEMP-INPUT PIC X(80).
       01 WS-STORED-USERNAME PIC X(20).
       01 WS-STORED-PASSWORD PIC X(12).
       01 WS-MESSAGE PIC X(90).
       
       77  WS-Choice        PIC 9 VALUE 0.
       77  WS-Account-Count PIC 9 VALUE 0.
       77  WS-COUNTER       PIC 9 VALUE 0.
       77  WS-FILE-STATUS   PIC XX.
       77  WS-EOF           PIC X VALUE "N".
       77  WS-Valid-Pass    PIC X VALUE "N".
       77  WS-Has-Upper     PIC X VALUE "N".
       77  WS-Has-Digit     PIC X VALUE "N".
       77  WS-Has-Special   PIC X VALUE "N".
       77  WS-Len           PIC 99.
       77  WS-Trail-Sp      PIC 99.
       77  WS-Lead-Sp       PIC 99.
       77  IDX              PIC 99.

       01  WS-Existing-Record.
           05 EX-Username   PIC X(20).
           05 EX-Password   PIC X(12).

       01  TEMP-FIRST-NAME    PIC X(20).
       01  TEMP-LAST-NAME     PIC X(20).
       01  TEMP-UNIVERSITY    PIC X(30).
       01  TEMP-MAJOR         PIC X(30).
       01  TEMP-GRAD-YEAR     PIC X(4).
       01  TEMP-ABOUT-ME      PIC X(200).
       01  TEMP-EXP OCCURS 3 TIMES.
           05  TEMP-EXP-DESC   PIC X(100).
       01  TEMP-EDU OCCURS 3 TIMES.
           05  TEMP-EDU-DESC   PIC X(100).

       01  CURRENT-USERNAME   PIC X(20).
       01  FOUND-PROFILE-FLAG PIC X VALUE "N".
       01  END-PROFILE-FILE   PIC X VALUE "N".
       77  WS-VALID-GRAD-YEAR PIC X VALUE "N".
       77  WS-VALID-REQUIRED  PIC X VALUE "N".

       PROCEDURE DIVISION.
       MAIN-LOGIC.
           PERFORM INITIALIZE-PROGRAM
      *> ADD UNTIL MENU-OPTION = "9" (EXIT)
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

           OPEN I-O PROFILE-FILE
           IF WS-FILE-STATUS NOT = "00"
              OPEN OUTPUT PROFILE-FILE
              CLOSE PROFILE-FILE
              OPEN I-O PROFILE-FILE
           END-IF
           CLOSE PROFILE-FILE
           .
       
       MAIN-MENU.
           DISPLAY "==== INCOLLEGE MAIN MENU ===="
           MOVE "==== INCOLLEGE MAIN MENU ====" TO OUTPUT-RECORD
           WRITE OUTPUT-RECORD

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
               
               MOVE WS-USERNAME TO CURRENT-USERNAME
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

                   PERFORM POST-LOGIN-MENU UNTIL WS-USER-CHOICE = 9 OR WS-EOF-FLAG = "Y"
               ELSE
                   DISPLAY "Incorrect username/password, try again."
                   MOVE "Incorrect username/password, try again." TO OUTPUT-RECORD
                   WRITE OUTPUT-RECORD
               END-IF
           END-IF
           .

       POST-LOGIN-MENU.
           DISPLAY "==== PROFILE MENU ===="
           MOVE "==== PROFILE MENU ====" TO OUTPUT-RECORD
           WRITE OUTPUT-RECORD

           DISPLAY "1. Create/Edit My Profile"
           MOVE "1. Create/Edit My Profile" TO OUTPUT-RECORD
           WRITE OUTPUT-RECORD

           DISPLAY "2. View My Profile"
           MOVE "2. View My Profile" TO OUTPUT-RECORD
           WRITE OUTPUT-RECORD

           DISPLAY "3. Search for a job"
           MOVE "3. Search for a job" TO OUTPUT-RECORD
           WRITE OUTPUT-RECORD

           DISPLAY "4. Find someone you know"
           MOVE "4. Find someone you know" TO OUTPUT-RECORD
           WRITE OUTPUT-RECORD

           DISPLAY "5. Learn a new skill"
           MOVE "5. Learn a new skill" TO OUTPUT-RECORD
           WRITE OUTPUT-RECORD

           DISPLAY "9. Logout"
           MOVE "9. Logout" TO OUTPUT-RECORD
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
                           PERFORM CREATE-EDIT-PROFILE
                       WHEN 2
                           PERFORM PROFILE-VIEW
                       WHEN 3
                           DISPLAY "Job search is under construction."
                           MOVE "Job search is under construction." TO OUTPUT-RECORD
                           WRITE OUTPUT-RECORD
                       WHEN 4
                           DISPLAY "Find someone is under construction."
                           MOVE "Find someone is under construction." TO OUTPUT-RECORD
                           WRITE OUTPUT-RECORD
                       WHEN 5
                           PERFORM LEARN-SKILL-MENU
                       WHEN 9
                           DISPLAY "Logging out."
                           MOVE "Logging out." TO OUTPUT-RECORD
                           WRITE OUTPUT-RECORD
                           EXIT PARAGRAPH
                       WHEN OTHER
                           DISPLAY "Invalid choice, please try again"
                           MOVE "Invalid choice, please try again" TO OUTPUT-RECORD
                           WRITE OUTPUT-RECORD
                   END-EVALUATE
           END-READ
           END-IF.

       PROFILE-VIEW.
           PERFORM LOAD-PROFILE
           IF FOUND-PROFILE-FLAG = "N"
               DISPLAY "Profile not found. Create a new profile."
               MOVE "Profile not found. Create a new profile." TO OUTPUT-RECORD
               WRITE OUTPUT-RECORD
               DISPLAY "Redirecting to Create Profile page."
               MOVE "Redirecting to Create Profile page." TO OUTPUT-RECORD
               WRITE OUTPUT-RECORD
               PERFORM CREATE-EDIT-PROFILE
      *>SINCE USER DOESN'T HAVE A PROFILE, THERE IS NOTHING TO SHOW
      *>SO WE REDIRECT THEM TO MAKE THEM CREATE A NEW ONE
               EXIT PARAGRAPH
           END-IF
           DISPLAY "==== YOUR PROFILE ===="
           MOVE "==== YOUR PROFILE ====" TO OUTPUT-RECORD
           WRITE OUTPUT-RECORD
           CLOSE PROFILE-FILE

           STRING "First Name: " PR-FIRST-NAME
               DELIMITED BY SIZE INTO OUTPUT-RECORD
           DISPLAY OUTPUT-RECORD
           WRITE OUTPUT-RECORD

           STRING "Last Name: " PR-LAST-NAME
               DELIMITED BY SIZE INTO OUTPUT-RECORD
           DISPLAY OUTPUT-RECORD
           WRITE OUTPUT-RECORD

           STRING "University: " PR-UNIVERSITY
               DELIMITED BY SIZE INTO OUTPUT-RECORD
           DISPLAY OUTPUT-RECORD
           WRITE OUTPUT-RECORD

           STRING "Major: " PR-MAJOR
               DELIMITED BY SIZE INTO OUTPUT-RECORD
           DISPLAY OUTPUT-RECORD
           WRITE OUTPUT-RECORD

           STRING "Graduation Year: " PR-GRAD-YEAR
               DELIMITED BY SIZE INTO OUTPUT-RECORD
           DISPLAY OUTPUT-RECORD
           WRITE OUTPUT-RECORD

           IF PR-ABOUT-ME NOT = SPACES
               STRING "About Me: " PR-ABOUT-ME
                   DELIMITED BY SIZE INTO OUTPUT-RECORD
               DISPLAY OUTPUT-RECORD
               WRITE OUTPUT-RECORD
           END-IF

           IF PR-EXP(1) NOT = SPACES
               STRING "Experience 1: " PR-EXP(1)
                   DELIMITED BY SIZE INTO OUTPUT-RECORD
               DISPLAY OUTPUT-RECORD
               WRITE OUTPUT-RECORD
           END-IF
           IF PR-EXP(2) NOT = SPACES
               STRING "Experience 2: " PR-EXP(2)
                   DELIMITED BY SIZE INTO OUTPUT-RECORD
               DISPLAY OUTPUT-RECORD
               WRITE OUTPUT-RECORD
           END-IF
           IF PR-EXP(3) NOT = SPACES
               STRING "Experience 3: " PR-EXP(3)
                   DELIMITED BY SIZE INTO OUTPUT-RECORD
               DISPLAY OUTPUT-RECORD
               WRITE OUTPUT-RECORD
           END-IF

           IF PR-EDU(1) NOT = SPACES
               STRING "Education 1: " PR-EDU(1)
                   DELIMITED BY SIZE INTO OUTPUT-RECORD
               DISPLAY OUTPUT-RECORD
               WRITE OUTPUT-RECORD
           END-IF
           IF PR-EDU(2) NOT = SPACES
               STRING "Education 2: " PR-EDU(2)
                   DELIMITED BY SIZE INTO OUTPUT-RECORD
               DISPLAY OUTPUT-RECORD
               WRITE OUTPUT-RECORD
           END-IF
           IF PR-EDU(3) NOT = SPACES
               STRING "Education 3: " PR-EDU(3)
                   DELIMITED BY SIZE INTO OUTPUT-RECORD
               DISPLAY OUTPUT-RECORD
               WRITE OUTPUT-RECORD
           END-IF

           MOVE "--- END OF PROFILE VIEW ---" TO OUTPUT-RECORD
           DISPLAY OUTPUT-RECORD
           WRITE OUTPUT-RECORD
           .

       LOAD-PROFILE.
           MOVE "Y" TO FOUND-PROFILE-FLAG
           MOVE "N" TO END-PROFILE-FILE
           CLOSE PROFILE-FILE
           OPEN I-O PROFILE-FILE
           MOVE CURRENT-USERNAME TO PR-USERNAME
           READ PROFILE-FILE KEY IS PR-USERNAME
               INVALID KEY MOVE "N" TO FOUND-PROFILE-FLAG
               NOT INVALID KEY MOVE "Y" TO FOUND-PROFILE-FLAG
           END-READ
      *>     PERFORM UNTIL END-PROFILE-FILE = "Y" OR
      *>       FOUND-PROFILE-FLAG= "Y"
      *>         READ PROFILE-FILE
      *>             AT END MOVE "Y" TO END-PROFILE-FILE
      *>             NOT AT END
      *>                 DISPLAY PR-USERNAME CURRENT-USERNAME
      *>                 IF PR-USERNAME = CURRENT-USERNAME
      *>                     MOVE "Y" TO FOUND-PROFILE-FLAG
      *>                 END-IF
      *>         END-READ
      *>     END-PERFORM
           .
       CREATE-EDIT-PROFILE.
           PERFORM LOAD-PROFILE
           IF FOUND-PROFILE-FLAG = "Y"
               DISPLAY "Profile found. Editing existing records"
               MOVE "Profile found. Editing existing records" TO OUTPUT-RECORD
               WRITE OUTPUT-RECORD
           END-IF
      *> If we didn't file user's profile and we wanted to create an
      *>accout (choice = 1) then output this
      *>without this if when redirected from profile-view paragraph it
      *>would duplicate Profile not found. Create a new profile. in the
      *>output
           IF FOUND-PROFILE-FLAG = "N" AND WS-USER-CHOICE = 1
               DISPLAY "Profile not found. Create a new profile."
               MOVE "Profile not found. Create a new profile." TO OUTPUT-RECORD
               WRITE OUTPUT-RECORD
           END-IF
      *> FILLED WITH SPACES JUST IN CASE
           MOVE SPACES TO TEMP-FIRST-NAME
           MOVE SPACES TO TEMP-LAST-NAME
           MOVE SPACES TO TEMP-UNIVERSITY
           MOVE SPACES TO TEMP-MAJOR
           MOVE SPACES TO TEMP-GRAD-YEAR
           MOVE SPACES TO TEMP-ABOUT-ME
           MOVE SPACES TO TEMP-EXP (1)
           MOVE SPACES TO TEMP-EXP (2)
           MOVE SPACES TO TEMP-EXP (3)
      *>    MOVE SPACES TO TEMP-EXP-DESC
           MOVE SPACES TO TEMP-EDU (1)
           MOVE SPACES TO TEMP-EDU (2)
           MOVE SPACES TO TEMP-EDU (3)
      *>    MOVE SPACES TO TEMP-EDU-DESC

      *>REQUIRED
           DISPLAY "Enter First Name: "
           MOVE "Enter First Name: " TO OUTPUT-RECORD
           WRITE OUTPUT-RECORD
      *>added IF BLOCK to add skip functionality if required field is
      *>nonempty
           IF FOUND-PROFILE-FLAG = "Y" AND
             PR-FIRST-NAME NOT = SPACES AND
             PR-FIRST-NAME NOT = LOW-VALUE
               DISPLAY "(Leave empty to keep the old record)"
               MOVE "(Leave empty to keep the old record)" TO OUTPUT-RECORD
               WRITE OUTPUT-RECORD
           END-IF
           MOVE "N" TO WS-VALID-REQUIRED
      *>CHECKING IF THE VALUE ENTERED NON-EMPTY
           PERFORM UNTIL WS-VALID-REQUIRED = "Y"
               IF WS-EOF-FLAG = "Y"
                   EXIT PARAGRAPH
               END-IF
               IF WS-EOF-FLAG NOT = "Y"
                   READ INPUT-FILE INTO TEMP-FIRST-NAME
                       AT END MOVE "Y" TO WS-EOF-FLAG
                   END-READ
               END-IF
               IF TEMP-FIRST-NAME NOT = SPACES
                   MOVE "Y" TO WS-VALID-REQUIRED 
               ELSE
                   DISPLAY "This is a required field. Please enter non-empty value"
                   MOVE "This is a required field. Please enter non-empty value" TO OUTPUT-RECORD
                   WRITE OUTPUT-RECORD
               END-IF
           END-PERFORM
           MOVE TEMP-FIRST-NAME TO PR-FIRST-NAME

      *>REQUIRED
           DISPLAY "Enter Last Name: "
           MOVE "Enter Last Name: " TO OUTPUT-RECORD
           WRITE OUTPUT-RECORD
           IF FOUND-PROFILE-FLAG = "Y" AND
             PR-LAST-NAME NOT EQUAL SPACES AND
             PR-LAST-NAME NOT = LOW-VALUE
               DISPLAY "(Leave empty to keep the old record)"
               MOVE "(Leave empty to keep the old record)" TO OUTPUT-RECORD
               WRITE OUTPUT-RECORD
           END-IF
           MOVE "N" TO WS-VALID-REQUIRED
           PERFORM UNTIL WS-VALID-REQUIRED = "Y"
               IF WS-EOF-FLAG = "Y"
                   EXIT PARAGRAPH
               END-IF
               IF WS-EOF-FLAG NOT = "Y"
                 READ INPUT-FILE INTO TEMP-LAST-NAME
                     AT END MOVE "Y" TO WS-EOF-FLAG
                 END-READ
               END-IF

               IF TEMP-LAST-NAME NOT = SPACES
                   MOVE "Y" TO WS-VALID-REQUIRED 
               ELSE
                   DISPLAY "This is a required field. Please enter non-empty value"
                   MOVE "This is a required field. Please enter non-empty value" TO OUTPUT-RECORD
                   WRITE OUTPUT-RECORD
               END-IF
           END-PERFORM
           MOVE TEMP-LAST-NAME TO PR-LAST-NAME

      *>REQUIRED
           DISPLAY "Enter University: "
           MOVE "Enter University: " TO OUTPUT-RECORD
           WRITE OUTPUT-RECORD
           IF FOUND-PROFILE-FLAG = "Y" AND
             PR-UNIVERSITY NOT EQUAL SPACES AND
             PR-UNIVERSITY NOT = LOW-VALUE
               DISPLAY "(Leave empty to keep the old record)"
               MOVE "(Leave empty to keep the old record)" TO OUTPUT-RECORD
               WRITE OUTPUT-RECORD
           END-IF
           MOVE "N" TO WS-VALID-REQUIRED
           PERFORM UNTIL WS-VALID-REQUIRED = "Y"
               IF WS-EOF-FLAG = "Y"
                   EXIT PARAGRAPH
               END-IF
               IF WS-EOF-FLAG NOT = "Y"
                 READ INPUT-FILE INTO TEMP-UNIVERSITY
                     AT END MOVE "Y" TO WS-EOF-FLAG
                 END-READ
               END-IF

               IF TEMP-UNIVERSITY NOT = SPACES
                   MOVE "Y" TO WS-VALID-REQUIRED 
               ELSE
                   DISPLAY "This is a required field. Please enter non-empty value"
                   MOVE "This is a required field. Please enter non-empty value" TO OUTPUT-RECORD
                   WRITE OUTPUT-RECORD
               END-IF
           END-PERFORM
           MOVE TEMP-UNIVERSITY TO PR-UNIVERSITY

      *>REQUIRED
           DISPLAY "Enter Major: "
           MOVE "Enter Major: " TO OUTPUT-RECORD
           WRITE OUTPUT-RECORD
           IF FOUND-PROFILE-FLAG = "Y" AND
             PR-MAJOR NOT EQUAL SPACES AND
             PR-MAJOR NOT = LOW-VALUE
               DISPLAY "(Leave empty to keep the old record)"
               MOVE "(Leave empty to keep the old record)" TO OUTPUT-RECORD
               WRITE OUTPUT-RECORD
           END-IF
           MOVE "N" TO WS-VALID-REQUIRED
           PERFORM UNTIL WS-VALID-REQUIRED = "Y"
               IF WS-EOF-FLAG = "Y"
                   EXIT PARAGRAPH
               END-IF
               IF WS-EOF-FLAG NOT = "Y"
                 READ INPUT-FILE INTO TEMP-MAJOR
                     AT END MOVE "Y" TO WS-EOF-FLAG
                 END-READ
               END-IF
               IF TEMP-MAJOR NOT = SPACES
                   MOVE "Y" TO WS-VALID-REQUIRED 
               ELSE
                   DISPLAY "This is a required field. Please enter non-empty value"
                   MOVE "This is a required field. Please enter non-empty value" TO OUTPUT-RECORD
                   WRITE OUTPUT-RECORD
               END-IF
           END-PERFORM
           MOVE TEMP-MAJOR TO PR-MAJOR

      *>REQUIRED
           DISPLAY "Enter Graduation Year: "
           MOVE "Enter Graduation Year: " TO OUTPUT-RECORD
           WRITE OUTPUT-RECORD
           IF FOUND-PROFILE-FLAG = "Y" AND
             PR-GRAD-YEAR NOT EQUAL SPACES AND
             PR-GRAD-YEAR NOT = LOW-VALUE
               DISPLAY "(Leave empty to keep the old record)"
               MOVE "(Leave empty to keep the old record)" TO OUTPUT-RECORD
               WRITE OUTPUT-RECORD
           END-IF
      *>Graduation year validation
           MOVE "N" TO WS-VALID-GRAD-YEAR
           PERFORM UNTIL WS-VALID-GRAD-YEAR = "Y"
               IF WS-EOF-FLAG = "Y"
                   EXIT PARAGRAPH
               END-IF
               IF WS-EOF-FLAG NOT = "Y"
                   READ INPUT-FILE INTO TEMP-GRAD-YEAR
                       AT END MOVE "Y" TO WS-EOF-FLAG
                   END-READ
               END-IF
               IF TEMP-GRAD-YEAR IS NUMERIC AND
                   FUNCTION NUMVAL(TEMP-GRAD-YEAR) >= 1925 AND
                   FUNCTION NUMVAL(TEMP-GRAD-YEAR) <= 2035
                   MOVE "Y" TO WS-VALID-GRAD-YEAR
               ELSE
                   DISPLAY "Please enter a valid graduation year. (1925-2035)"
                   MOVE "Please enter a valid graduation year. (1925-2035)" TO OUTPUT-RECORD
                   WRITE OUTPUT-RECORD
               END-IF
           END-PERFORM

           MOVE FUNCTION NUMVAL(TEMP-GRAD-YEAR) TO PR-GRAD-YEAR

           DISPLAY "About Me (optional, blank = skip/keep): "
           MOVE "About Me (optional, blank = skip/keep): " TO OUTPUT-RECORD
           WRITE OUTPUT-RECORD
           IF WS-EOF-FLAG NOT = "Y"
               READ INPUT-FILE INTO TEMP-ABOUT-ME
                   AT END MOVE "Y" TO WS-EOF-FLAG
               END-READ
           END-IF
           IF TEMP-ABOUT-ME NOT = SPACES
               MOVE TEMP-ABOUT-ME TO PR-ABOUT-ME
           END-IF

           DISPLAY "Experience 1 (optional, blank = skip/keep): "
           MOVE "Experience 1 (optional, blank = skip/keep): " TO OUTPUT-RECORD
           WRITE OUTPUT-RECORD
           IF WS-EOF-FLAG NOT = "Y"
               READ INPUT-FILE INTO TEMP-EXP (1)
                   AT END MOVE "Y" TO WS-EOF-FLAG
               END-READ
           END-IF
           IF TEMP-EXP (1) NOT = SPACES
               MOVE TEMP-EXP (1) TO PR-EXP (1)
           END-IF

           DISPLAY "Experience 2 (optional, blank = skip/keep): "
           MOVE "Experience 2 (optional, blank = skip/keep): " TO OUTPUT-RECORD
           WRITE OUTPUT-RECORD
           IF WS-EOF-FLAG NOT = "Y"
               READ INPUT-FILE INTO TEMP-EXP (2)
                   AT END MOVE "Y" TO WS-EOF-FLAG
               END-READ
           END-IF
           IF TEMP-EXP (2) NOT = SPACES
               MOVE TEMP-EXP (2) TO PR-EXP (2)
           END-IF

           DISPLAY "Experience 3 (optional, blank = skip/keep): "
           MOVE "Experience 3 (optional, blank = skip/keep): " TO OUTPUT-RECORD
           WRITE OUTPUT-RECORD
           IF WS-EOF-FLAG NOT = "Y"
               READ INPUT-FILE INTO TEMP-EXP (3)
                   AT END MOVE "Y" TO WS-EOF-FLAG
               END-READ
           END-IF
           IF TEMP-EXP (3) NOT = SPACES
               MOVE TEMP-EXP (3) TO PR-EXP (3)
           END-IF

           DISPLAY "Education 1 (optional, blank = skip/keep): "
           MOVE "Education 1 (optional, blank = skip/keep): " TO OUTPUT-RECORD
           WRITE OUTPUT-RECORD
           IF WS-EOF-FLAG NOT = "Y"
               READ INPUT-FILE INTO TEMP-EDU (1)
                   AT END MOVE "Y" TO WS-EOF-FLAG
               END-READ
           END-IF
           IF TEMP-EDU (1) NOT = SPACES
               MOVE TEMP-EDU (1) TO PR-EDU (1)
           END-IF

           DISPLAY "Education 2 (optional, blank = skip/keep): "
           MOVE "Education 2 (optional, blank = skip/keep): " TO OUTPUT-RECORD
           WRITE OUTPUT-RECORD
           IF WS-EOF-FLAG NOT = "Y"
               READ INPUT-FILE INTO TEMP-EDU (2)
                   AT END MOVE "Y" TO WS-EOF-FLAG
               END-READ
           END-IF
           IF TEMP-EDU (2) NOT = SPACES
               MOVE TEMP-EDU (2) TO PR-EDU (2)
           END-IF

           DISPLAY "Education 3 (optional, blank = skip/keep): "
           MOVE "Education 3 (optional, blank = skip/keep): " TO OUTPUT-RECORD
           WRITE OUTPUT-RECORD
           IF WS-EOF-FLAG NOT = "Y"
               READ INPUT-FILE INTO TEMP-EDU (3)
                   AT END MOVE "Y" TO WS-EOF-FLAG
               END-READ
           END-IF
           IF TEMP-EDU (3) NOT = SPACES
               MOVE TEMP-EDU (3) TO PR-EDU (3)
           END-IF

      *> MOVE USERNAME HERE BECAUSE IT MEANS THAT EVERYOTHER FIELD WAS
      *>ENTERED CORRECTLTY
           MOVE CURRENT-USERNAME TO PR-USERNAME
           IF FOUND-PROFILE-FLAG = "Y"
               REWRITE PROFILE-RECORD
               DISPLAY "Profile updated successfully."
               MOVE "Profile updated successfully." TO OUTPUT-RECORD
               WRITE OUTPUT-RECORD
           ELSE
               WRITE PROFILE-RECORD
               DISPLAY "Profile created successfully."
               MOVE "Profile created successfully." TO OUTPUT-RECORD
               WRITE OUTPUT-RECORD
           END-IF
           DISPLAY "Profile saved successfully."
           MOVE "Profile saved successfully." TO OUTPUT-RECORD
           WRITE OUTPUT-RECORD
           CLOSE PROFILE-FILE
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
           CLOSE PROFILE-FILE
           .

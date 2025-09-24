       IDENTIFICATION DIVISION.
       PROGRAM-ID. INCOLLEGE.
       
       ENVIRONMENT DIVISION.
       INPUT-OUTPUT SECTION.
      *> Creating file variables
       FILE-CONTROL.
           SELECT INPUT-FILE ASSIGN TO "InCollege-Input.txt"
      *> This one is my folder of test files
      *>     SELECT INPUT-FILE ASSIGN TO "Tests/epic3-1.in"
      *>     SELECT INPUT-FILE ASSIGN TO "create-acc-profile.in"
      *>     SELECT INPUT-FILE ASSIGN TO "search-people.in"
               ORGANIZATION IS LINE SEQUENTIAL.
           SELECT OUTPUT-FILE ASSIGN TO "InCollege-Output.txt"
               ORGANIZATION IS LINE SEQUENTIAL.
           SELECT ACCOUNTS-FILE ASSIGN TO "accounts.doc"
               ORGANIZATION IS LINE SEQUENTIAL
               FILE STATUS IS WS-FILE-STATUS.
           SELECT PROFILE-FILE ASSIGN TO "profiles.doc"
      *> NEEDS TO BE INDEXED, RELATIVE ORG IS TOO COMPLEX FOR THAT
      *>SIMPLE TASK (KEEPING PROFILE RECORDS)
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
           05  PR-EXP-COUNT       PIC 9.
      *> ARRAY OF PROFILE-EXPERIENCE OF SIZE 3
      *> ARRAYS START FROM 1 IN COBOL
           05  PR-EXP OCCURS 3 TIMES
               INDEXED BY PR-EXP-IDX.
               10 PR-EXP-TITLE    PIC X(30).
               10 PR-EXP-COMPANY  PIC X(30).
               10 PR-EXP-DATES    PIC X(20).
               10 PR-EXP-DESC     PIC X(100).
           05  PR-EDU-COUNT          PIC 9.
           05  PR-EDU OCCURS 3 TIMES
               INDEXED BY PR-EDU-IDX.
               10 PR-EDU-DEGREE PIC X(30).
               10 PR-EDU-SCHOOL PIC X(30).
               10 PR-EDU-YEARS PIC X(10).

       WORKING-STORAGE SECTION.
      *> FLAG FOR THE INPUT-FILE END OF FILE
       01 WS-EOF-FLAG PIC X VALUE 'N'.
       01 WS-ACCOUNTS-EOF PIC X VALUE 'N'.
      *> MENU OPTION USER CHOICE
       01 WS-USER-CHOICE PIC 9.
       01 WS-USERNAME PIC X(20).
       01 WS-PASSWORD PIC X(12).
       01 WS-LOGIN-SUCCESS PIC X VALUE 'N'.
       01 WS-TEMP-INPUT PIC X(80).
       01 WS-STORED-USERNAME PIC X(20).
       01 WS-STORED-PASSWORD PIC X(12).
       01 WS-MESSAGE PIC X(90).
       
       77  WS-ACCOUNT-COUNT PIC 9 VALUE 0.
       77  WS-COUNTER       PIC 9 VALUE 0.
       77  WS-FILE-STATUS   PIC XX.
       77  WS-VALID-PASS    PIC X VALUE "N".
       77  WS-HAS-UPPER     PIC X VALUE "N".
       77  WS-HAS-DIGIT     PIC X VALUE "N".
       77  WS-HAS-SPECIAL   PIC X VALUE "N".
       77  WS-LEN           PIC 99.
       77  WS-TRAIL-SP      PIC 99.
       77  WS-LEAD-SP       PIC 99.
       77  PASS-IDX         PIC 99.

       01  WS-EXISTING-RECORD.
           05 EX-USERNAME   PIC X(20).
           05 EX-PASSWORD   PIC X(12).

       01  TEMP-FIRST-NAME    PIC X(20).
       01  TEMP-LAST-NAME     PIC X(20).
       01  TEMP-UNIVERSITY    PIC X(30).
       01  TEMP-MAJOR         PIC X(30).
       01  TEMP-GRAD-YEAR     PIC X(4).
       01  TEMP-ABOUT-ME      PIC X(200).
       01  TEMP-EXP-COUNT PIC 9.
       01  TEMP-EXP OCCURS 3 TIMES
           INDEXED BY TEMP-EXP-IDX.
           10  TEMP-EXP-TITLE PIC X(30).
           10  TEMP-EXP-COMPANY PIC X(30).
           10  TEMP-EXP-DATES PIC X(20).
           10  TEMP-EXP-DESC   PIC X(100).
       01  TEMP-EDU-COUNT          PIC 9.
       01  TEMP-EDU OCCURS 3 TIMES
           INDEXED BY TEMP-EDU-IDX.
           10  TEMP-EDU-DEGREE PIC X(30).
           10  TEMP-EDU-SCHOOL PIC X(30).
           10  TEMP-EDU-YEARS  PIC X(10).

       01  CURRENT-USERNAME   PIC X(20).
       01  FOUND-PROFILE-FLAG PIC X VALUE "N".
       77  WS-VALID-GRAD-YEAR PIC X VALUE "N".
       77  WS-VALID-REQUIRED  PIC X VALUE "N".

       PROCEDURE DIVISION.
       MAIN-LOGIC.
           PERFORM INITIALIZE-PROGRAM
      *> MAYBE ADD UNTIL MENU-OPTION = "9" (EXIT)
           PERFORM MAIN-MENU UNTIL WS-EOF-FLAG = "Y"
           PERFORM CLEANUP
           STOP RUN.
       
       INITIALIZE-PROGRAM.
           OPEN INPUT INPUT-FILE
           OPEN OUTPUT OUTPUT-FILE
           OPEN INPUT ACCOUNTS-FILE
      *> "00" FILE STATUS CODE MEANS OPENED SUCCESSFULY
      *> IF IT'S NOT "00" CHANCES ARE THAT FILE DOESN'T EXIST
      *> SO WE OPEN IT AS OUTPUT WHICH WILL CREATE A
      *> DESIRED FILE EVEN IF IT DOESN'T EXIST
      *> (WE DON'T HAVE TO CLOSE IT BEFORE OPENING IT AGAIN
      *> SINCE WE COULDN'T OPEN IT IN THE FIRST PLACE)
      *> THEN WE CAN OPEN IT AGAIN AS INPUT TO READ FROM IT
           IF WS-FILE-STATUS NOT = "00"
              OPEN OUTPUT ACCOUNTS-FILE
              CLOSE ACCOUNTS-FILE
              OPEN INPUT ACCOUNTS-FILE
           END-IF

      *> COUNTING HOW MANY ACCOUNTS ALREADY SAVED IN THE
      *> ACCOUNTS.DOC FILE TO ENFORCE MAX 5 ACCOUNTS RULE
           MOVE 0 TO WS-ACCOUNT-COUNT
           MOVE "N" TO WS-ACCOUNTS-EOF
           PERFORM UNTIL WS-ACCOUNTS-EOF = "Y"
              READ ACCOUNTS-FILE INTO WS-EXISTING-RECORD
                 AT END MOVE "Y" TO WS-ACCOUNTS-EOF
                 NOT AT END ADD 1 TO WS-ACCOUNT-COUNT
              END-READ
           END-PERFORM
           CLOSE ACCOUNTS-FILE

      *> IF THE FILE DOESN'T EXIST, CREATE ONE
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
      *> (1:1) = (start:length) = SUBSTRING
      *> means (1'st index:take one character starting from that index)
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
      *> OPENED AS EXTEND TO APPEND TO THE END OF THE FILE INSTEAD OF
      *> OVERWRITING EXISTING RECORDS
           OPEN EXTEND ACCOUNTS-FILE

           IF WS-ACCOUNT-COUNT >= 5
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
     
      *> PASS VALIDATION
           MOVE "N" TO WS-VALID-PASS
           PERFORM UNTIL WS-VALID-PASS = "Y"
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
           
      *> ADD A NEWLY CREATED ACCOUNT INTO ACCOUNT FILE
      *> ACCOUNT-RECORD is LINKED WITH ACCOUNTS.DOC
      *> SO, WRITE ACCOUNT-RECORD JUST APPENDS NEW ACCCOUNT TO THE END
      *> OF THE ACCOUNTS.DOC
           MOVE WS-USERNAME TO ACCOUNT-USERNAME
           MOVE WS-PASSWORD TO ACCOUNT-PASSWORD
           WRITE ACCOUNT-RECORD

      *> KEEP TRACK OF THE NUMBER ACCOUNTS TO ENFORE 5 MAX RULE
           ADD 1 TO WS-ACCOUNT-COUNT
           DISPLAY "Account successfully created!"
           MOVE "Account successfully created!" TO OUTPUT-RECORD
           WRITE OUTPUT-RECORD

           CLOSE ACCOUNTS-FILE
           .

       VALIDATE-PASSWORD.
      *> RESETING WORKING VARIABLES
           MOVE "N" TO WS-VALID-PASS
           MOVE "N" TO WS-HAS-UPPER
           MOVE "N" TO WS-HAS-DIGIT
           MOVE "N" TO WS-HAS-SPECIAL
           MOVE 0 TO WS-LEN
           MOVE 0 TO WS-TRAIL-SP
           MOVE 0 TO WS-LEAD-SP

      *> COUNT THE NUMBER OF TRAILING, LEADING SPACES AND
      *> WS-LEN = NUMBER OF CHARACTERS IN WS-PASSWORD
           INSPECT WS-PASSWORD TALLYING WS-TRAIL-SP FOR TRAILING SPACES
           INSPECT WS-PASSWORD TALLYING WS-LEAD-SP FOR LEADING SPACES
           INSPECT WS-PASSWORD TALLYING WS-LEN FOR CHARACTERS

      *> WS-LEN = WS-LEN - WS-TRAIL-SP
      *> WS-LEN = WS-LEN - WS-LEAD-SP
           SUBTRACT WS-TRAIL-SP FROM WS-LEN GIVING WS-LEN
           SUBTRACT WS-LEAD-SP FROM WS-LEN GIVING WS-LEN
      *> IF THE LENGTH REQUIREMENT NOT MET, PASSWORD IS NOT OK
           IF WS-LEN < 8 OR WS-LEN > 12
              DISPLAY "Error: Password must be 8-12 characters long."
              MOVE "Error: Password must be 8-12 characters long." TO OUTPUT-RECORD
              WRITE OUTPUT-RECORD
              EXIT PARAGRAPH
           END-IF

      *> RUN LOOP ON EVERY CHARACTER OF THE WS-PASSWORD TO FIND IF
      *> CHARACTERS REQ. IS MET
           PERFORM VARYING PASS-IDX FROM 1 BY 1 UNTIL PASS-IDX > WS-LEN
              EVALUATE TRUE
                 WHEN WS-PASSWORD(PASS-IDX:1) >= "A" AND WS-PASSWORD(PASS-IDX:1) <= "Z"
                    MOVE "Y" TO WS-HAS-UPPER
                 WHEN WS-PASSWORD(PASS-IDX:1) >= "0" AND WS-PASSWORD(PASS-IDX:1) <= "9"
                    MOVE "Y" TO WS-HAS-DIGIT
                 WHEN WS-PASSWORD(PASS-IDX:1) < "0" OR
                      WS-PASSWORD(PASS-IDX:1) > "9" AND
                      WS-PASSWORD(PASS-IDX:1) < "A" OR
                      WS-PASSWORD(PASS-IDX:1) > "Z" AND
                      WS-PASSWORD(PASS-IDX:1) < "a" OR
                      WS-PASSWORD(PASS-IDX:1) > "z"
                    MOVE "Y" TO WS-HAS-SPECIAL
              END-EVALUATE
           END-PERFORM

      *> IF CHARACTER REQ. MET THE PASS IS GOOD
           IF WS-HAS-UPPER = "Y"
               AND WS-HAS-DIGIT = "Y"
               AND WS-HAS-SPECIAL = "Y"
               MOVE "Y" TO WS-VALID-PASS
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
      *> EMPTYING THE VARIALBE
                   MOVE SPACES TO WS-MESSAGE
      *> CONCATINATING STRINGS TO DISPLAY AND WRITE WELCOME MESSAGE INTO
      *> A FILE
                   STRING "Welcome " DELIMITED BY SIZE
                       WS-USERNAME DELIMITED BY SPACE
                       "!" DELIMITED BY SIZE
                       INTO WS-MESSAGE
                   END-STRING

                   DISPLAY WS-MESSAGE
                   MOVE WS-MESSAGE TO OUTPUT-RECORD
                   WRITE OUTPUT-RECORD

      *> 9 = Log Out in POST-LOGIN-MENU 
                   PERFORM POST-LOGIN-MENU UNTIL WS-USER-CHOICE = 9 OR WS-EOF-FLAG = "Y"
               ELSE
                   DISPLAY "Incorrect username/password, try again."
                   MOVE "Incorrect username/password, try again." TO OUTPUT-RECORD
                   WRITE OUTPUT-RECORD
               END-IF
           END-IF
           .

       POST-LOGIN-MENU.
           MOVE "==== PROFILE MENU ====" TO OUTPUT-RECORD
           DISPLAY OUTPUT-RECORD
           WRITE OUTPUT-RECORD

           MOVE "1. Create/Edit My Profile" TO OUTPUT-RECORD
           DISPLAY OUTPUT-RECORD
           WRITE OUTPUT-RECORD

           MOVE "2. View My Profile" TO OUTPUT-RECORD
           DISPLAY OUTPUT-RECORD
           WRITE OUTPUT-RECORD

           MOVE "3. Search for a job" TO OUTPUT-RECORD
           DISPLAY OUTPUT-RECORD
           WRITE OUTPUT-RECORD

           MOVE "4. Find someone you know" TO OUTPUT-RECORD
           DISPLAY OUTPUT-RECORD
           WRITE OUTPUT-RECORD

           MOVE "5. Learn a new skill" TO OUTPUT-RECORD
           DISPLAY OUTPUT-RECORD
           WRITE OUTPUT-RECORD

           MOVE "9. Logout" TO OUTPUT-RECORD
           DISPLAY OUTPUT-RECORD
           WRITE OUTPUT-RECORD

           MOVE "Enter your choice:" TO OUTPUT-RECORD
           DISPLAY OUTPUT-RECORD
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
                           MOVE "Job search is under construction." TO OUTPUT-RECORD
                           DISPLAY OUTPUT-RECORD
                           WRITE OUTPUT-RECORD
                       WHEN 4
                           PERFORM SEARCH-USER
                       WHEN 5
                           PERFORM LEARN-SKILL-MENU
                       WHEN 9
                           MOVE "Logging out." TO OUTPUT-RECORD
                           DISPLAY OUTPUT-RECORD
                           WRITE OUTPUT-RECORD
                           EXIT PARAGRAPH
                       WHEN OTHER
                           MOVE "Invalid choice, please try again" TO OUTPUT-RECORD
                           DISPLAY OUTPUT-RECORD
                           WRITE OUTPUT-RECORD
                   END-EVALUATE
           END-READ
           END-IF.

       PROFILE-VIEW.
           PERFORM LOAD-PROFILE
      *> WE DON'T NEED PROFILE-FILE OPEN HERE SO WE CLOSE IT
      *> PROFILE INFO IS GOING TO BE STORED IN PROFILE-RECORD (EX: PR-FIRST-NAME) AFTER LOAD-PROFILE
           CLOSE PROFILE-FILE

           IF FOUND-PROFILE-FLAG = "N"
               MOVE "Profile not found. Create a new profile." TO OUTPUT-RECORD
               DISPLAY OUTPUT-RECORD
               WRITE OUTPUT-RECORD

               MOVE "Redirecting to Create Profile page." TO OUTPUT-RECORD
               DISPLAY OUTPUT-RECORD
               WRITE OUTPUT-RECORD
               PERFORM CREATE-EDIT-PROFILE
      *>SINCE USER DOESN'T HAVE A PROFILE, THERE IS NOTHING TO SHOW
      *>SO WE REDIRECT THEM TO MAKE THEM CREATE A NEW ONE
      *>AFTER REDIRECTED PAGE IS COMPLETE THE POINTER RETURNS HERE
      *>AND WE EXIT FROM PROFILE-VIEW
               EXIT PARAGRAPH
           END-IF

           MOVE "==== YOUR PROFILE ====" TO OUTPUT-RECORD
           DISPLAY OUTPUT-RECORD
           WRITE OUTPUT-RECORD

      *> WHEN CONCATINATING IF THE STRING WE CONCATINATING IS SHORTER
      *> THE LEFTOVER SPACE WILL NOT BE FILLED WITH SPACES
      *> IT WILL HAVE THE VALUES THAT OUTPUT-RECORD HAD PREVIOUSLY
      *> EX: MOVE "************" TO OUTPUT-RECORD
      *> EX: STRING "HI" DELIMITED BY SIZE INTO OUTPUT-RECORD
      *> EX: OUTPUT-RECORD VALUE = "HI**********" NOT "HI          " (OR "HI")
      *> SO WE NEED TO FILL OUTPUT-RECORD WITH SPACES FOR NICE OUTPUT
           MOVE SPACES TO OUTPUT-RECORD
           STRING "Name: " DELIMITED BY SIZE
                   PR-FIRST-NAME DELIMITED BY SPACE
                   " " DELIMITED BY SIZE
                   PR-LAST-NAME DELIMITED BY SPACE
                   INTO OUTPUT-RECORD
           END-STRING
           DISPLAY OUTPUT-RECORD
           WRITE OUTPUT-RECORD

           MOVE SPACES TO OUTPUT-RECORD
           STRING "University: " PR-UNIVERSITY
               DELIMITED BY SIZE INTO OUTPUT-RECORD
           DISPLAY OUTPUT-RECORD
           WRITE OUTPUT-RECORD

           MOVE SPACES TO OUTPUT-RECORD
           STRING "Major: " PR-MAJOR
               DELIMITED BY SIZE INTO OUTPUT-RECORD
           DISPLAY OUTPUT-RECORD
           WRITE OUTPUT-RECORD

           MOVE SPACES TO OUTPUT-RECORD
           STRING "Graduation Year: " PR-GRAD-YEAR
               DELIMITED BY SIZE INTO OUTPUT-RECORD
           DISPLAY OUTPUT-RECORD
           WRITE OUTPUT-RECORD

      *> IF THE USER SKIPPED (LEFT ABOUT-ME BLANK) WE DON'T SHOW IT
           IF PR-ABOUT-ME NOT = SPACES
               MOVE SPACES TO OUTPUT-RECORD
                   STRING "About Me: " PR-ABOUT-ME
                       DELIMITED BY SIZE INTO OUTPUT-RECORD
                   DISPLAY OUTPUT-RECORD
                   WRITE OUTPUT-RECORD
           END-IF

           IF PR-EXP-COUNT > 0
               MOVE "Experience:" TO OUTPUT-RECORD
               DISPLAY OUTPUT-RECORD
               WRITE OUTPUT-RECORD
               MOVE 1 TO TEMP-EXP-COUNT
               PERFORM UNTIL TEMP-EXP-COUNT > PR-EXP-COUNT
                   MOVE SPACES TO OUTPUT-RECORD
                   STRING "  Title: " PR-EXP-TITLE(TEMP-EXP-COUNT)
                       DELIMITED BY SIZE INTO OUTPUT-RECORD
                   DISPLAY OUTPUT-RECORD
                   WRITE OUTPUT-RECORD

                   MOVE SPACES TO OUTPUT-RECORD
                   STRING "  Company: " PR-EXP-COMPANY(TEMP-EXP-COUNT)
                       DELIMITED BY SIZE INTO OUTPUT-RECORD
                   DISPLAY OUTPUT-RECORD
                   WRITE OUTPUT-RECORD

                   MOVE SPACES TO OUTPUT-RECORD
                   STRING "  Dates: " PR-EXP-DATES(TEMP-EXP-COUNT)
                       DELIMITED BY SIZE INTO OUTPUT-RECORD
                   DISPLAY OUTPUT-RECORD
                   WRITE OUTPUT-RECORD

                   IF PR-EXP-DESC(TEMP-EXP-COUNT) NOT = SPACES
                       MOVE SPACES TO OUTPUT-RECORD
                       STRING "  Description: " PR-EXP-DESC(TEMP-EXP-COUNT)
                           DELIMITED BY SIZE INTO OUTPUT-RECORD
                       DISPLAY OUTPUT-RECORD
                       WRITE OUTPUT-RECORD
                   END-IF
                   ADD 1 TO TEMP-EXP-COUNT
               END-PERFORM
           END-IF

           IF PR-EDU-COUNT > 0
               MOVE "Education:" TO OUTPUT-RECORD
               DISPLAY OUTPUT-RECORD
               WRITE OUTPUT-RECORD
               
               MOVE 1 TO TEMP-EDU-COUNT
               PERFORM UNTIL TEMP-EDU-COUNT > PR-EDU-COUNT
                   MOVE SPACES TO OUTPUT-RECORD
                   STRING "  Degree: " PR-EDU-DEGREE(TEMP-EDU-COUNT)
                       DELIMITED BY SIZE INTO OUTPUT-RECORD
                   DISPLAY OUTPUT-RECORD
                   WRITE OUTPUT-RECORD

                   MOVE SPACES TO OUTPUT-RECORD
                   STRING "  University: " PR-EDU-SCHOOL(TEMP-EDU-COUNT)
                       DELIMITED BY SIZE INTO OUTPUT-RECORD
                   DISPLAY OUTPUT-RECORD
                   WRITE OUTPUT-RECORD

                   MOVE SPACES TO OUTPUT-RECORD
                   STRING "  Years: " PR-EDU-YEARS(TEMP-EDU-COUNT)
                       DELIMITED BY SIZE INTO OUTPUT-RECORD
                   DISPLAY OUTPUT-RECORD
                   WRITE OUTPUT-RECORD
                   ADD 1 TO TEMP-EDU-COUNT
               END-PERFORM
           END-IF

           MOVE "--- END OF PROFILE VIEW ---" TO OUTPUT-RECORD
           DISPLAY OUTPUT-RECORD
           WRITE OUTPUT-RECORD
           .

       LOAD-PROFILE.
      *> PROFILE INFO IS GOING TO BE STORED IN PROFILE-RECORD (EX: PR-FIRST-NAME) AFTER LOAD-PROFILE
           MOVE "Y" TO FOUND-PROFILE-FLAG
           CLOSE PROFILE-FILE
           OPEN I-O PROFILE-FILE
           MOVE CURRENT-USERNAME TO PR-USERNAME
      *> FINDING THE DESIRED USERNAME IN THE PROFILE-FILE
           READ PROFILE-FILE KEY IS PR-USERNAME
               INVALID KEY MOVE "N" TO FOUND-PROFILE-FLAG
               NOT INVALID KEY MOVE "Y" TO FOUND-PROFILE-FLAG
           END-READ
      *> WE DON'T CLOSE PROFILE FILE HERE SO WE NEED TO CLOSE IT FROM
      *> THE PARAGRAPH FROM WHICH WE CALLED LOAD-PROFILE
           .
       CREATE-EDIT-PROFILE.
           PERFORM LOAD-PROFILE
      *> LOAD PROFILE FOUND DESIRED USERNAME IN DATA FILE
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
           IF FOUND-PROFILE-FLAG = "N"
               IF WS-USER-CHOICE = 2
                   DISPLAY "You don't have a profile. Create a profile."
                   MOVE "You don't have a profile. Create a profile." TO OUTPUT-RECORD
                   WRITE OUTPUT-RECORD
               ELSE
                   DISPLAY "Welcome to Create a Profile Page."
                   MOVE "Welcome to Create a Profile Page." TO OUTPUT-RECORD
                   WRITE OUTPUT-RECORD
               END-IF
           END-IF
      *> FILLED WITH SPACES JUST IN CASE
           MOVE SPACES TO TEMP-FIRST-NAME
           MOVE SPACES TO TEMP-LAST-NAME
           MOVE SPACES TO TEMP-UNIVERSITY
           MOVE SPACES TO TEMP-MAJOR
           MOVE SPACES TO TEMP-GRAD-YEAR
           MOVE SPACES TO TEMP-ABOUT-ME
      *> THIS WILL FILL SPACES TO ANY ELEMENTS INSIDE TEMP-EXP ARRAY, EX: TEMP-EXP-TITLE, etc.
           MOVE SPACES TO TEMP-EXP (1)
           MOVE SPACES TO TEMP-EXP (2)
           MOVE SPACES TO TEMP-EXP (3)
      *> THIS WILL FILL SPACES TO ANY ELEMENTS INSIDE TEMP-EDU ARRAY, EX: TEMP-EDU-DEGREE, etc.
           MOVE SPACES TO TEMP-EDU (1)
           MOVE SPACES TO TEMP-EDU (2)
           MOVE SPACES TO TEMP-EDU (3)

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
               IF TEMP-FIRST-NAME = SPACES AND FOUND-PROFILE-FLAG = "Y"
                   MOVE "Y" TO WS-VALID-REQUIRED 
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

               IF TEMP-LAST-NAME = SPACES AND FOUND-PROFILE-FLAG = "Y"
                   MOVE "Y" TO WS-VALID-REQUIRED 
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

               IF TEMP-UNIVERSITY = SPACES AND FOUND-PROFILE-FLAG = "Y"
                   MOVE "Y" TO WS-VALID-REQUIRED 
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
               IF TEMP-MAJOR = SPACES AND FOUND-PROFILE-FLAG = "Y"
                   MOVE "Y" TO WS-VALID-REQUIRED 
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
               IF TEMP-GRAD-YEAR = SPACES AND FOUND-PROFILE-FLAG = "Y"
                   MOVE "Y" TO WS-VALID-GRAD-YEAR
               END-IF
      *> AS I UNDERSTOOD NUMVAL RETURNS INTEGER FROM A STRING THAT
      *> CONTAINS NUMERIC CHARACTERS, NEEDED TO COMPARE STRING TO
      *> INTEGER
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

      *> AS I UNDERSTOOD NUMVAL RETURNS INTEGER FROM A STRING THAT
      *> CONTAINS NUMERIC CHARACTERS, NEEDED TO COMPARE STRING TO
      *> INTIGERS OR TO MOVE STRING INTO INTEGER VARIABLE, LIKE HERE
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

           MOVE 0 TO TEMP-EXP-COUNT
           PERFORM UNTIL TEMP-EXP-COUNT >= 3 OR WS-EOF-FLAG = "Y"
               MOVE "=== Add Experience (optional, max 3 entries. Enter 'DONE' to finish) ===" TO OUTPUT-RECORD
               DISPLAY OUTPUT-RECORD
               WRITE OUTPUT-RECORD

               ADD 1 TO TEMP-EXP-COUNT
               MOVE SPACES TO OUTPUT-RECORD
               STRING "Experience #" TEMP-EXP-COUNT " - Title:" 
                   DELIMITED BY SIZE INTO OUTPUT-RECORD
               DISPLAY OUTPUT-RECORD
               WRITE OUTPUT-RECORD
               IF WS-EOF-FLAG NOT = "Y"
                   READ INPUT-FILE INTO TEMP-EXP-TITLE (TEMP-EXP-COUNT)
                       AT END MOVE "Y" TO WS-EOF-FLAG
                   END-READ
                   IF FUNCTION UPPER-CASE(TEMP-EXP-TITLE(TEMP-EXP-COUNT)) = "DONE"
                       SUBTRACT 1 FROM TEMP-EXP-COUNT
                       EXIT PERFORM
                   END-IF
               END-IF

               MOVE SPACES TO OUTPUT-RECORD
               STRING "Experience #" TEMP-EXP-COUNT " - Company/Organization:" 
                   DELIMITED BY SIZE INTO OUTPUT-RECORD
               DISPLAY OUTPUT-RECORD
               WRITE OUTPUT-RECORD
               IF WS-EOF-FLAG NOT = "Y"
                   READ INPUT-FILE INTO TEMP-EXP-COMPANY (TEMP-EXP-COUNT)
                       AT END MOVE "Y" TO WS-EOF-FLAG
                   END-READ
               END-IF

               MOVE SPACES TO OUTPUT-RECORD
               STRING "Experience #" TEMP-EXP-COUNT " - Dates (e.g., Summer 2024):" 
                   DELIMITED BY SIZE INTO OUTPUT-RECORD
               DISPLAY OUTPUT-RECORD
               WRITE OUTPUT-RECORD
               IF WS-EOF-FLAG NOT = "Y"
                   READ INPUT-FILE INTO TEMP-EXP-DATES (TEMP-EXP-COUNT)
                       AT END MOVE "Y" TO WS-EOF-FLAG
                   END-READ
               END-IF

               MOVE SPACES TO OUTPUT-RECORD
               STRING "Experience #" TEMP-EXP-COUNT " - Description (optional, max 100 chars, blank to skip):" 
                   DELIMITED BY SIZE INTO OUTPUT-RECORD
               DISPLAY OUTPUT-RECORD
               WRITE OUTPUT-RECORD
               IF WS-EOF-FLAG NOT = "Y"
                   READ INPUT-FILE INTO TEMP-EXP-DESC (TEMP-EXP-COUNT)
                       AT END MOVE "Y" TO WS-EOF-FLAG
                   END-READ
               END-IF
               MOVE TEMP-EXP(TEMP-EXP-COUNT) TO PR-EXP(TEMP-EXP-COUNT)
               MOVE TEMP-EXP-COUNT TO PR-EXP-COUNT
           END-PERFORM

           MOVE 0 TO TEMP-EDU-COUNT
           PERFORM UNTIL TEMP-EDU-COUNT >= 3 OR WS-EOF-FLAG = "Y"
               MOVE "Add Education (optional, max 3 entries. Enter 'DONE' to finish):" TO OUTPUT-RECORD
               DISPLAY OUTPUT-RECORD
               WRITE OUTPUT-RECORD

               ADD 1 TO TEMP-EDU-COUNT
               MOVE SPACES TO OUTPUT-RECORD
               STRING "Education #" TEMP-EDU-COUNT " - Degree:" 
                   DELIMITED BY SIZE INTO OUTPUT-RECORD
               DISPLAY OUTPUT-RECORD
               WRITE OUTPUT-RECORD
               IF WS-EOF-FLAG NOT = "Y"
                   READ INPUT-FILE INTO TEMP-EDU-DEGREE(TEMP-EDU-COUNT)
                       AT END MOVE "Y" TO WS-EOF-FLAG
                   END-READ
                   IF FUNCTION UPPER-CASE(TEMP-EDU-DEGREE(TEMP-EDU-COUNT)) = "DONE"
                       SUBTRACT 1 FROM TEMP-EDU-COUNT
                       EXIT PERFORM
                   END-IF
               END-IF

               MOVE SPACES TO OUTPUT-RECORD
               STRING "Education #" TEMP-EDU-COUNT " - University/College:" 
                   DELIMITED BY SIZE INTO OUTPUT-RECORD
               DISPLAY OUTPUT-RECORD
               WRITE OUTPUT-RECORD
               IF WS-EOF-FLAG NOT = "Y"
                   READ INPUT-FILE INTO TEMP-EDU-SCHOOL(TEMP-EDU-COUNT)
                       AT END MOVE "Y" TO WS-EOF-FLAG
                   END-READ
               END-IF

               MOVE SPACES TO OUTPUT-RECORD
               STRING "Education #" TEMP-EDU-COUNT " - Years Attended (e.g., 2023-2025):" 
                   DELIMITED BY SIZE INTO OUTPUT-RECORD
               DISPLAY OUTPUT-RECORD
               WRITE OUTPUT-RECORD
               IF WS-EOF-FLAG NOT = "Y"
                   READ INPUT-FILE INTO TEMP-EDU-YEARS(TEMP-EDU-COUNT)
                       AT END MOVE "Y" TO WS-EOF-FLAG
                   END-READ
               END-IF
               MOVE TEMP-EDU(TEMP-EDU-COUNT) TO PR-EDU(TEMP-EDU-COUNT)
               MOVE TEMP-EDU-COUNT TO PR-EDU-COUNT
           END-PERFORM

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

       SEARCH-USER.
           DISPLAY "Enter the full name of the person you are looking for:"
           MOVE "Enter the full name of the person you are looking for:" TO OUTPUT-RECORD
           WRITE OUTPUT-RECORD

           IF WS-EOF-FLAG NOT = "Y"
               READ INPUT-FILE INTO WS-TEMP-INPUT
                   AT END MOVE "Y" TO WS-EOF-FLAG
               END-READ
           END-IF

           UNSTRING WS-TEMP-INPUT DELIMITED BY SPACE
               INTO TEMP-FIRST-NAME TEMP-LAST-NAME
           END-UNSTRING

      *> DISPLAY "DEBUG******************"TEMP-FIRST-NAME"*"TEMP-LAST-NAME"*"
           MOVE "N" TO FOUND-PROFILE-FLAG
           OPEN INPUT PROFILE-FILE
           PERFORM UNTIL WS-EOF-FLAG = "Y" OR FOUND-PROFILE-FLAG = "Y"
               READ PROFILE-FILE NEXT RECORD
                   AT END EXIT PERFORM
                   NOT AT END
                       IF PR-FIRST-NAME = TEMP-FIRST-NAME
                          AND PR-LAST-NAME = TEMP-LAST-NAME
                          MOVE "Y" TO FOUND-PROFILE-FLAG
                       END-IF
               END-READ
           END-PERFORM
           CLOSE PROFILE-FILE

           IF FOUND-PROFILE-FLAG = "Y"
               MOVE "--- Found User Profile ---" TO OUTPUT-RECORD
               DISPLAY OUTPUT-RECORD
               WRITE OUTPUT-RECORD

               MOVE SPACES TO OUTPUT-RECORD
               STRING "Name: " DELIMITED BY SIZE
                       PR-FIRST-NAME DELIMITED BY SPACE
                       " " DELIMITED BY SIZE
                       PR-LAST-NAME DELIMITED BY SPACE
                       INTO OUTPUT-RECORD
               END-STRING
               DISPLAY OUTPUT-RECORD
               WRITE OUTPUT-RECORD

               MOVE SPACES TO OUTPUT-RECORD
               STRING "University: " PR-UNIVERSITY
                   DELIMITED BY SIZE INTO OUTPUT-RECORD
               DISPLAY OUTPUT-RECORD
               WRITE OUTPUT-RECORD

               MOVE SPACES TO OUTPUT-RECORD
               STRING "Major: " PR-MAJOR
                   DELIMITED BY SIZE INTO OUTPUT-RECORD
               DISPLAY OUTPUT-RECORD
               WRITE OUTPUT-RECORD

               MOVE SPACES TO OUTPUT-RECORD
               STRING "Graduation Year: " PR-GRAD-YEAR
                   DELIMITED BY SIZE INTO OUTPUT-RECORD
               DISPLAY OUTPUT-RECORD
               WRITE OUTPUT-RECORD

               IF PR-ABOUT-ME NOT = SPACES
                   MOVE SPACES TO OUTPUT-RECORD
                   STRING "About Me: " PR-ABOUT-ME
                       DELIMITED BY SIZE INTO OUTPUT-RECORD
                   DISPLAY OUTPUT-RECORD
                   WRITE OUTPUT-RECORD
               END-IF

               IF PR-EXP-COUNT > 0
                   MOVE "Experience:" TO OUTPUT-RECORD
                   DISPLAY OUTPUT-RECORD
                   WRITE OUTPUT-RECORD
                   MOVE 1 TO TEMP-EXP-COUNT
                   PERFORM UNTIL TEMP-EXP-COUNT > PR-EXP-COUNT
                       MOVE SPACES TO OUTPUT-RECORD
                       STRING "  Title: " PR-EXP-TITLE(TEMP-EXP-COUNT)
                           DELIMITED BY SIZE INTO OUTPUT-RECORD
                       DISPLAY OUTPUT-RECORD
                       WRITE OUTPUT-RECORD

                       MOVE SPACES TO OUTPUT-RECORD
                       STRING "  Company: " PR-EXP-COMPANY(TEMP-EXP-COUNT)
                           DELIMITED BY SIZE INTO OUTPUT-RECORD
                       DISPLAY OUTPUT-RECORD
                       WRITE OUTPUT-RECORD

                       MOVE SPACES TO OUTPUT-RECORD
                       STRING "  Dates: " PR-EXP-DATES(TEMP-EXP-COUNT)
                           DELIMITED BY SIZE INTO OUTPUT-RECORD
                       DISPLAY OUTPUT-RECORD
                       WRITE OUTPUT-RECORD

                       IF PR-EXP-DESC(TEMP-EXP-COUNT) NOT = SPACES
                           MOVE SPACES TO OUTPUT-RECORD
                           STRING "  Description: " PR-EXP-DESC(TEMP-EXP-COUNT)
                               DELIMITED BY SIZE INTO OUTPUT-RECORD
                           DISPLAY OUTPUT-RECORD
                           WRITE OUTPUT-RECORD
                       END-IF
                       ADD 1 TO TEMP-EXP-COUNT
                   END-PERFORM
               ELSE
                   MOVE "Experience: None" TO OUTPUT-RECORD
                   DISPLAY OUTPUT-RECORD
                   WRITE OUTPUT-RECORD
               END-IF

               IF PR-EDU-COUNT > 0
                   MOVE "Education:" TO OUTPUT-RECORD
                   DISPLAY OUTPUT-RECORD
                   WRITE OUTPUT-RECORD

                   MOVE 1 TO TEMP-EDU-COUNT
                   PERFORM UNTIL TEMP-EDU-COUNT > PR-EDU-COUNT
                       MOVE SPACES TO OUTPUT-RECORD
                       STRING "  Degree: " PR-EDU-DEGREE(TEMP-EDU-COUNT)
                           DELIMITED BY SIZE INTO OUTPUT-RECORD
                       DISPLAY OUTPUT-RECORD
                       WRITE OUTPUT-RECORD

                       MOVE SPACES TO OUTPUT-RECORD
                       STRING "  University: " PR-EDU-SCHOOL(TEMP-EDU-COUNT)
                           DELIMITED BY SIZE INTO OUTPUT-RECORD
                       DISPLAY OUTPUT-RECORD
                       WRITE OUTPUT-RECORD

                       MOVE SPACES TO OUTPUT-RECORD
                       STRING "  Years: " PR-EDU-YEARS(TEMP-EDU-COUNT)
                           DELIMITED BY SIZE INTO OUTPUT-RECORD
                       DISPLAY OUTPUT-RECORD
                       WRITE OUTPUT-RECORD

                       ADD 1 TO TEMP-EDU-COUNT
                   END-PERFORM
               ELSE
                   MOVE "Education: None" TO OUTPUT-RECORD
                   DISPLAY OUTPUT-RECORD
                   WRITE OUTPUT-RECORD
               END-IF
           ELSE
               MOVE "No one by that name could be found." TO OUTPUT-RECORD
               DISPLAY OUTPUT-RECORD
               WRITE OUTPUT-RECORD
           END-IF.

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

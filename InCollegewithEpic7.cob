IDENTIFICATION DIVISION.
       PROGRAM-ID. INCOLLEGE.
       
       ENVIRONMENT DIVISION.
       INPUT-OUTPUT SECTION.
      *> Creating file variables
       FILE-CONTROL.
           SELECT INPUT-FILE ASSIGN TO "InCollege-Input.txt"
      *> This one is Aibek's folder of test files
      *>     SELECT INPUT-FILE ASSIGN TO "create-acc-profile.in"
      *>     SELECT INPUT-FILE ASSIGN TO "search-people.in"
      *> SELECT INPUT-FILE ASSIGN TO "debug.txt"
      *> SELECT INPUT-FILE ASSIGN TO "job-listing.in"
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
           SELECT CONNECTION-REQUESTS-FILE ASSIGN TO "connection_requests.doc"
               ORGANIZATION IS LINE SEQUENTIAL
               FILE STATUS IS WS-CONN-REQ-STATUS.
           SELECT CONNECTION-REQUESTS-TEMP-FILE ASSIGN TO "connection_requests.tmp"
               ORGANIZATION IS LINE SEQUENTIAL
               FILE STATUS IS WS-CONN-REQ-TEMP-STATUS.
           SELECT CONNECTIONS-FILE ASSIGN TO "connections.doc"
               ORGANIZATION IS LINE SEQUENTIAL
               FILE STATUS IS WS-CONNECTION-STATUS.
           SELECT JOBS-FILE ASSIGN TO "jobs.doc"
               ORGANIZATION IS LINE SEQUENTIAL
               FILE STATUS IS WS-JOBS-FILE-STATUS.
      *> === EPIC 7 NEW FILE ===
      *> For saving job applications (username + job ID)
           SELECT APPLICATIONS-FILE ASSIGN TO "applications.doc"
               ORGANIZATION IS LINE SEQUENTIAL
               FILE STATUS IS WS-APPLICATIONS-STATUS.
      *> === EPIC 8 NEW FILE ===
      *> For saving messages (sender, recipient, content, timestamp)
           SELECT MESSAGES-FILE ASSIGN TO "messages.doc"
               ORGANIZATION IS LINE SEQUENTIAL
               FILE STATUS IS WS-MESSAGES-STATUS.

       DATA DIVISION.
       FILE SECTION.
       FD INPUT-FILE.
       01 INPUT-RECORD PIC X(80).
       
       FD OUTPUT-FILE.
       01 OUTPUT-RECORD PIC X(100).
       
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

       FD CONNECTION-REQUESTS-FILE.
       01 CONNECTION-REQUEST-RECORD.
           05 CR-SENDER   PIC X(20).
           05 CR-RECEIVER PIC X(20).

       FD CONNECTION-REQUESTS-TEMP-FILE.
       01 CONNECTION-REQUEST-TEMP-RECORD.
           05 CRT-SENDER   PIC X(20).
           05 CRT-RECEIVER PIC X(20).

       FD CONNECTIONS-FILE.
       01 CONNECTION-RECORD.
           05 CN-USER-ONE PIC X(20).
           05 CN-USER-TWO PIC X(20).

       FD JOBS-FILE.
       01 JOBS-FILE-RECORD.
           05 JR-ID              PIC 9(4) VALUE 0.
           05 JR-TITLE           PIC X(20).
           05 JR-DESC            PIC X(200).
           05 JR-EMPLOYER        PIC X(20).
           05 JR-LOCATION        PIC X(20).
           05 JR-SALARY          PIC X(20).
           05 JR-AUTHOR-USERNAME PIC X(20).
      *> === EPIC 7 NEW FILE SECTION ===
       FD APPLICATIONS-FILE.
       01 APPLICATION-RECORD.
           05 APP-USERNAME   PIC X(20).
           05 APP-JOB-ID     PIC 9(4).
      *> === EPIC 8 NEW FILE SECTION ===
       FD MESSAGES-FILE.
       01 MESSAGE-RECORD.
           05 MS-SENDER      PIC X(20).
           05 MS-RECIPIENT   PIC X(20).
           05 MS-CONTENT     PIC X(200).
           05 MS-TIMESTAMP   PIC X(20).

       WORKING-STORAGE SECTION.
      *> FLAG FOR THE INPUT-FILE END OF FILE
       01 TEMP-LAST-JOB-ID           PIC 9(4) VALUE 0.
       01 WS-JOBS-FILE-EOF           PIC X VALUE 'N'.
       01 WS-JOBS-FILE-STATUS        PIC XX.
       01 WS-APPLICATIONS-STATUS     PIC XX.
       01 WS-APPLICATIONS-EOF        PIC X VALUE "N".
       01 WS-TARGET-JOB-ID           PIC 9(4) VALUE 0.
       01 WS-TARGET-JOB-ID-FOUND     PIC X VALUE 'N'.
       01 WS-TARGET-JOB-ID-APPLIED   PIC X VALUE 'N'.

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
       77  WS-CONN-REQ-STATUS PIC XX.
       77  WS-CONN-REQ-TEMP-STATUS PIC XX.
       77  WS-CONNECTION-STATUS PIC XX.
       77  WS-VALID-PASS    PIC X VALUE "N".
       77  WS-HAS-UPPER     PIC X VALUE "N".
       77  WS-HAS-DIGIT     PIC X VALUE "N".
       77  WS-HAS-SPECIAL   PIC X VALUE "N".
       77  WS-LEN           PIC 99.
       77  WS-TRAIL-SP      PIC 99.
       77  WS-LEAD-SP       PIC 99.
       77  PASS-IDX         PIC 99.
       77  WS-PENDING-EOF     PIC X VALUE "N".
       77  WS-CONNECTIONS-EOF PIC X VALUE "N".
       77  WS-OUTGOING-PENDING PIC X VALUE "N".
       77  WS-INCOMING-PENDING PIC X VALUE "N".
       77  WS-ALREADY-CONNECTED PIC X VALUE "N".
       77  WS-PENDING-FOUND   PIC X VALUE "N".
       77  WS-REQUEST-CHOICE  PIC 9 VALUE 0.
       77  WS-CONN-REQ-OPEN   PIC X VALUE "N".

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
             01  WS-TARGET-USERNAME PIC X(20).
           01  WS-CURRENT-REQUEST.
               05 WS-CURRENT-REQUEST-SENDER   PIC X(20).
               05 WS-CURRENT-REQUEST-RECEIVER PIC X(20).
           01  WS-REMOVE-REQUEST.
               05 WS-REMOVE-SENDER   PIC X(20).
               05 WS-REMOVE-RECEIVER PIC X(20).
       01  FOUND-PROFILE-FLAG PIC X VALUE "N".
       77  WS-VALID-GRAD-YEAR PIC X VALUE "N".
       77  WS-VALID-REQUIRED  PIC X VALUE "N".
           77  WS-TEMP-EOF        PIC X VALUE "N".
      *> === EPIC 8 NEW WORKING STORAGE ===
       77  WS-MESSAGES-STATUS     PIC XX.
       77  WS-MSG-CHOICE          PIC 9.
       77  WS-MSG-RECIPIENT      PIC X(20).
       77  WS-MSG-CONTENT        PIC X(200).
       77  WS-CONNECTED-FLAG      PIC X VALUE "N".
       77  WS-TIMESTAMP          PIC X(20).

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

           OPEN INPUT CONNECTION-REQUESTS-FILE
           IF WS-CONN-REQ-STATUS NOT = "00"
             OPEN OUTPUT CONNECTION-REQUESTS-FILE
             CLOSE CONNECTION-REQUESTS-FILE
             OPEN INPUT CONNECTION-REQUESTS-FILE
           END-IF
           CLOSE CONNECTION-REQUESTS-FILE

           OPEN INPUT CONNECTIONS-FILE
           IF WS-CONNECTION-STATUS NOT = "00"
             OPEN OUTPUT CONNECTIONS-FILE
             CLOSE CONNECTIONS-FILE
             OPEN INPUT CONNECTIONS-FILE
           END-IF
           CLOSE CONNECTIONS-FILE

           OPEN INPUT JOBS-FILE
           IF WS-JOBS-FILE-STATUS NOT = "00"
             OPEN OUTPUT JOBS-FILE 
             CLOSE JOBS-FILE
             OPEN INPUT JOBS-FILE
           END-IF
           CLOSE JOBS-FILE

           OPEN INPUT APPLICATIONS-FILE
           IF WS-APPLICATIONS-STATUS NOT = "00"
             OPEN OUTPUT APPLICATIONS-FILE
             CLOSE APPLICATIONS-FILE
             OPEN INPUT APPLICATIONS-FILE
           END-IF
           CLOSE APPLICATIONS-FILE

      *> === EPIC 8 INITIALIZE MESSAGES-FILE ===
           OPEN INPUT MESSAGES-FILE
           IF WS-MESSAGES-STATUS NOT = "00"
             OPEN OUTPUT MESSAGES-FILE
             CLOSE MESSAGES-FILE
             OPEN INPUT MESSAGES-FILE
           END-IF
           CLOSE MESSAGES-FILE

       .
       
       MAIN-MENU.
           MOVE "==== INCOLLEGE MAIN MENU ====" TO OUTPUT-RECORD
           DISPLAY OUTPUT-RECORD
           WRITE OUTPUT-RECORD

           MOVE "Welcome to InCollege!" TO OUTPUT-RECORD
           DISPLAY OUTPUT-RECORD
           WRITE OUTPUT-RECORD

           MOVE "1. Log In" TO OUTPUT-RECORD
           DISPLAY OUTPUT-RECORD
           WRITE OUTPUT-RECORD

           MOVE "2. Create New Account" TO OUTPUT-RECORD
           DISPLAY OUTPUT-RECORD
           WRITE OUTPUT-RECORD

      *> COMMENT THIS BEFORE DEPLOYMENT!
      *> MOVE "0. DEVELOPER MODE FOR DEGUBBING" TO OUTPUT-RECORD
      *> DISPLAY OUTPUT-RECORD
      *> WRITE OUTPUT-RECORD

           MOVE "Enter your choice:" TO OUTPUT-RECORD
           DISPLAY OUTPUT-RECORD
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
      *> COMMENT THIS BEFORE DEPLOYMENT!
      *> WHEN 0
      *> PERFORM DEBUG-JOBS
                       WHEN OTHER
                           MOVE "Invalid choice, please try again" TO OUTPUT-RECORD
                           DISPLAY OUTPUT-RECORD
                           WRITE OUTPUT-RECORD
                   END-EVALUATE
           END-READ.
       
       REGISTRATION.
      *> OPENED AS EXTEND TO APPEND TO THE END OF THE FILE INSTEAD OF
      *> OVERWRITING EXISTING RECORDS
           OPEN EXTEND ACCOUNTS-FILE

           IF WS-ACCOUNT-COUNT >= 5
              MOVE "All permitted accounts have been created, Max 5 accounts." TO OUTPUT-RECORD
              DISPLAY OUTPUT-RECORD
              WRITE OUTPUT-RECORD
              EXIT PARAGRAPH
           END-IF

           MOVE "Enter Username:" TO OUTPUT-RECORD
           DISPLAY OUTPUT-RECORD
           WRITE OUTPUT-RECORD
           IF WS-EOF-FLAG NOT = "Y"
             READ INPUT-FILE INTO WS-USERNAME
                 AT END MOVE "Y" TO WS-EOF-FLAG
             END-READ
           END-IF
     
      *> PASS VALIDATION
           MOVE "N" TO WS-VALID-PASS
           PERFORM UNTIL WS-VALID-PASS = "Y" OR WS-EOF-FLAG = "Y"
               MOVE "Enter Password:" TO OUTPUT-RECORD
               DISPLAY OUTPUT-RECORD
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
           IF WS-VALID-PASS = "N"
             MOVE "Failed to create an account." TO OUTPUT-RECORD
             DISPLAY OUTPUT-RECORD
             WRITE OUTPUT-RECORD
     
             CLOSE ACCOUNTS-FILE
             EXIT PARAGRAPH
           END-IF
           MOVE WS-USERNAME TO ACCOUNT-USERNAME
           MOVE WS-PASSWORD TO ACCOUNT-PASSWORD
           WRITE ACCOUNT-RECORD

      *> KEEP TRACK OF THE NUMBER ACCOUNTS TO ENFORE 5 MAX RULE
           ADD 1 TO WS-ACCOUNT-COUNT
           MOVE "Account successfully created!" TO OUTPUT-RECORD
           DISPLAY OUTPUT-RECORD
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
              MOVE "Error: Password must be 8-12 characters long." TO OUTPUT-RECORD
              DISPLAY OUTPUT-RECORD
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
               MOVE "Error: Password must include at least 1 uppercase, 1 digit, and 1 special character." TO OUTPUT-RECORD
               DISPLAY OUTPUT-RECORD
               WRITE OUTPUT-RECORD
           END-IF
           .

       LOGIN-PROCESS.
           MOVE "N" TO WS-LOGIN-SUCCESS
           
           MOVE "Please enter your username:" TO OUTPUT-RECORD
           DISPLAY OUTPUT-RECORD
           WRITE OUTPUT-RECORD

           IF WS-EOF-FLAG NOT = "Y"
             READ INPUT-FILE INTO WS-USERNAME
                 AT END MOVE "Y" TO WS-EOF-FLAG
             END-READ
           END-IF

           MOVE "Please enter your password:" TO OUTPUT-RECORD
           DISPLAY OUTPUT-RECORD
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
                   MOVE "Incorrect username/password, try again." TO OUTPUT-RECORD
                   DISPLAY OUTPUT-RECORD
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

           MOVE "6. View My Pending Connection Requests" TO OUTPUT-RECORD
           DISPLAY OUTPUT-RECORD
           WRITE OUTPUT-RECORD

           MOVE "7. View My Network" TO OUTPUT-RECORD
           DISPLAY OUTPUT-RECORD
           WRITE OUTPUT-RECORD

      *> === EPIC 8 NEW MENU OPTION ===
           MOVE "8. Messages" TO OUTPUT-RECORD
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
                           PERFORM JOB-MENU UNTIL WS-EOF-FLAG = "Y" OR WS-USER-CHOICE = 9
                       WHEN 4
                           PERFORM SEARCH-USER
                       WHEN 5
                           PERFORM LEARN-SKILL-MENU
                       WHEN 6
                           PERFORM VIEW-PENDING-REQUESTS
                       WHEN 7
                           PERFORM VIEW-MY-NETWORK
      *> === EPIC 8 NEW MENU OPTION ===
                       WHEN 8
                           PERFORM MESSAGES-MENU UNTIL WS-MSG-CHOICE = 3 OR WS-EOF-FLAG = "Y"
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
               MOVE "Profile found. Editing existing records" TO OUTPUT-RECORD
               DISPLAY OUTPUT-RECORD
               WRITE OUTPUT-RECORD
           END-IF
      *> If we didn't file user's profile and we wanted to create an
      *>accout (choice = 1) then output this
      *>without this if when redirected from profile-view paragraph it
      *>would duplicate Profile not found. Create a new profile. in the
      *>output
           IF FOUND-PROFILE-FLAG = "N"
               IF WS-USER-CHOICE = 2
                   MOVE "You don't have a profile. Create a profile." TO OUTPUT-RECORD
                   DISPLAY OUTPUT-RECORD
                   WRITE OUTPUT-RECORD
               ELSE
                   MOVE "Welcome to Create a Profile Page." TO OUTPUT-RECORD
                   DISPLAY OUTPUT-RECORD
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
           MOVE "Enter First Name: " TO OUTPUT-RECORD
           DISPLAY OUTPUT-RECORD
           WRITE OUTPUT-RECORD
      *>added IF BLOCK to add skip functionality if required field is
      *>nonempty
           IF FOUND-PROFILE-FLAG = "Y" AND
             PR-FIRST-NAME NOT = SPACES AND
             PR-FIRST-NAME NOT = LOW-VALUE
               MOVE "(Leave empty to keep the old record)" TO OUTPUT-RECORD
               DISPLAY OUTPUT-RECORD
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
                   MOVE "This is a required field. Please enter non-empty value" TO OUTPUT-RECORD
                   DISPLAY OUTPUT-RECORD
                   WRITE OUTPUT-RECORD
               END-IF
           END-PERFORM
           MOVE TEMP-FIRST-NAME TO PR-FIRST-NAME

      *>REQUIRED
           MOVE "Enter Last Name: " TO OUTPUT-RECORD
           DISPLAY OUTPUT-RECORD
           WRITE OUTPUT-RECORD
           IF FOUND-PROFILE-FLAG = "Y" AND
             PR-LAST-NAME NOT EQUAL SPACES AND
             PR-LAST-NAME NOT = LOW-VALUE
               MOVE "(Leave empty to keep the old record)" TO OUTPUT-RECORD
               DISPLAY OUTPUT-RECORD
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
                   MOVE "This is a required field. Please enter non-empty value" TO OUTPUT-RECORD
                   DISPLAY OUTPUT-RECORD
                   WRITE OUTPUT-RECORD
               END-IF
           END-PERFORM
           MOVE TEMP-LAST-NAME TO PR-LAST-NAME

      *>REQUIRED
           MOVE "Enter University: " TO OUTPUT-RECORD
           DISPLAY OUTPUT-RECORD
           WRITE OUTPUT-RECORD
           IF FOUND-PROFILE-FLAG = "Y" AND
             PR-UNIVERSITY NOT EQUAL SPACES AND
             PR-UNIVERSITY NOT = LOW-VALUE
               MOVE "(Leave empty to keep the old record)" TO OUTPUT-RECORD
               DISPLAY OUTPUT-RECORD
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
                   MOVE "This is a required field. Please enter non-empty value" TO OUTPUT-RECORD
                   DISPLAY OUTPUT-RECORD
                   WRITE OUTPUT-RECORD
               END-IF
           END-PERFORM
           MOVE TEMP-UNIVERSITY TO PR-UNIVERSITY

      *>REQUIRED
           MOVE "Enter Major: " TO OUTPUT-RECORD
           DISPLAY OUTPUT-RECORD
           WRITE OUTPUT-RECORD
           IF FOUND-PROFILE-FLAG = "Y" AND
             PR-MAJOR NOT EQUAL SPACES AND
             PR-MAJOR NOT = LOW-VALUE
               MOVE "(Leave empty to keep the old record)" TO OUTPUT-RECORD
               DISPLAY OUTPUT-RECORD
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
                   MOVE "This is a required field. Please enter non-empty value" TO OUTPUT-RECORD
                   DISPLAY OUTPUT-RECORD
                   WRITE OUTPUT-RECORD
               END-IF
           END-PERFORM
           MOVE TEMP-MAJOR TO PR-MAJOR

      *>REQUIRED
           MOVE "Enter Graduation Year: " TO OUTPUT-RECORD
           DISPLAY OUTPUT-RECORD
           WRITE OUTPUT-RECORD
           IF FOUND-PROFILE-FLAG = "Y" AND
             PR-GRAD-YEAR NOT EQUAL SPACES AND
             PR-GRAD-YEAR NOT = LOW-VALUE
               MOVE "(Leave empty to keep the old record)" TO OUTPUT-RECORD
               DISPLAY OUTPUT-RECORD
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
                   MOVE "Please enter a valid graduation year. (1925-2035)" TO OUTPUT-RECORD
                   DISPLAY OUTPUT-RECORD
                   WRITE OUTPUT-RECORD
               END-IF
           END-PERFORM

      *> AS I UNDERSTOOD NUMVAL RETURNS INTEGER FROM A STRING THAT
      *> CONTAINS NUMERIC CHARACTERS, NEEDED TO COMPARE STRING TO
      *> INTIGERS OR TO MOVE STRING INTO INTEGER VARIABLE, LIKE HERE
           MOVE FUNCTION NUMVAL(TEMP-GRAD-YEAR) TO PR-GRAD-YEAR

           MOVE "About Me (optional, blank = skip/keep): " TO OUTPUT-RECORD
           DISPLAY OUTPUT-RECORD
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
               MOVE "Profile updated successfully." TO OUTPUT-RECORD
               DISPLAY OUTPUT-RECORD
               WRITE OUTPUT-RECORD
           ELSE
               WRITE PROFILE-RECORD
               MOVE "Profile created successfully." TO OUTPUT-RECORD
               DISPLAY OUTPUT-RECORD
               WRITE OUTPUT-RECORD
           END-IF
           MOVE "Profile saved successfully." TO OUTPUT-RECORD
           DISPLAY OUTPUT-RECORD
           WRITE OUTPUT-RECORD

           CLOSE PROFILE-FILE
           .

       SEARCH-USER.
           MOVE "Enter the full name of the person you are looking for:" TO OUTPUT-RECORD
           DISPLAY OUTPUT-RECORD
           WRITE OUTPUT-RECORD

           IF WS-EOF-FLAG NOT = "Y"
               READ INPUT-FILE INTO WS-TEMP-INPUT
                   AT END MOVE "Y" TO WS-EOF-FLAG
               END-READ
           END-IF

           UNSTRING WS-TEMP-INPUT DELIMITED BY SPACE
               INTO TEMP-FIRST-NAME TEMP-LAST-NAME
           END-UNSTRING

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

               MOVE "1. Send Connection Request" TO OUTPUT-RECORD
               DISPLAY OUTPUT-RECORD
               WRITE OUTPUT-RECORD

               MOVE "2. Back to Main Menu" TO OUTPUT-RECORD
               DISPLAY OUTPUT-RECORD
               WRITE OUTPUT-RECORD

               MOVE "Enter your choice:" TO OUTPUT-RECORD
               DISPLAY OUTPUT-RECORD
               WRITE OUTPUT-RECORD

               MOVE 0 TO WS-REQUEST-CHOICE
               IF WS-EOF-FLAG NOT = "Y"
                   READ INPUT-FILE INTO WS-TEMP-INPUT
                       AT END MOVE "Y" TO WS-EOF-FLAG
                       NOT AT END
                           MOVE WS-TEMP-INPUT(1:1) TO WS-REQUEST-CHOICE
                           EVALUATE WS-REQUEST-CHOICE
                               WHEN 1
                                   PERFORM SEND-CONNECTION-REQUEST
                               WHEN 2
                                   CONTINUE
                               WHEN OTHER
                                   MOVE "Invalid choice, returning to main menu." TO OUTPUT-RECORD
                                   DISPLAY OUTPUT-RECORD
                                   WRITE OUTPUT-RECORD
                           END-EVALUATE
                   END-READ
               END-IF
           ELSE
               MOVE "No one by that name could be found." TO OUTPUT-RECORD
               DISPLAY OUTPUT-RECORD
               WRITE OUTPUT-RECORD
           END-IF.

       SEND-CONNECTION-REQUEST.
           MOVE PR-USERNAME TO WS-TARGET-USERNAME
           IF WS-TARGET-USERNAME = CURRENT-USERNAME
               MOVE "You cannot send a connection request to yourself." TO OUTPUT-RECORD
               DISPLAY OUTPUT-RECORD
               WRITE OUTPUT-RECORD

               EXIT PARAGRAPH
           END-IF

           MOVE "N" TO WS-ALREADY-CONNECTED
           MOVE "N" TO WS-CONNECTIONS-EOF
           OPEN INPUT CONNECTIONS-FILE
           IF WS-CONNECTION-STATUS = "35"
               MOVE "Y" TO WS-CONNECTIONS-EOF
           END-IF
           PERFORM UNTIL WS-CONNECTIONS-EOF = "Y" OR WS-ALREADY-CONNECTED = "Y"
               READ CONNECTIONS-FILE INTO CONNECTION-RECORD
                   AT END MOVE "Y" TO WS-CONNECTIONS-EOF
                   NOT AT END
                       IF (CN-USER-ONE = CURRENT-USERNAME AND CN-USER-TWO = WS-TARGET-USERNAME)
                           OR (CN-USER-ONE = WS-TARGET-USERNAME AND CN-USER-TWO = CURRENT-USERNAME)
                           MOVE "Y" TO WS-ALREADY-CONNECTED
                       END-IF
               END-READ
           END-PERFORM
           CLOSE CONNECTIONS-FILE

           IF WS-ALREADY-CONNECTED = "Y"
               MOVE "You are already connected with this user." TO OUTPUT-RECORD
               DISPLAY OUTPUT-RECORD
               WRITE OUTPUT-RECORD
               EXIT PARAGRAPH
           END-IF

           MOVE "N" TO WS-OUTGOING-PENDING
           MOVE "N" TO WS-INCOMING-PENDING
           MOVE "N" TO WS-PENDING-EOF
           OPEN INPUT CONNECTION-REQUESTS-FILE
           IF WS-CONN-REQ-STATUS = "35"
               MOVE "Y" TO WS-PENDING-EOF
           END-IF
           PERFORM UNTIL WS-PENDING-EOF = "Y"
               READ CONNECTION-REQUESTS-FILE INTO CONNECTION-REQUEST-RECORD
                   AT END MOVE "Y" TO WS-PENDING-EOF
                   NOT AT END
                       IF CR-SENDER = CURRENT-USERNAME AND CR-RECEIVER = WS-TARGET-USERNAME
                           MOVE "Y" TO WS-OUTGOING-PENDING
                       END-IF
                       IF CR-SENDER = WS-TARGET-USERNAME AND CR-RECEIVER = CURRENT-USERNAME
                           MOVE "Y" TO WS-INCOMING-PENDING
                       END-IF
                       IF WS-OUTGOING-PENDING = "Y" AND WS-INCOMING-PENDING = "Y"
                           MOVE "Y" TO WS-PENDING-EOF
                       END-IF
               END-READ
           END-PERFORM
           CLOSE CONNECTION-REQUESTS-FILE

           IF WS-OUTGOING-PENDING = "Y"
               MOVE "You already sent a connection request to this user." TO OUTPUT-RECORD
               DISPLAY OUTPUT-RECORD
               WRITE OUTPUT-RECORD
               EXIT PARAGRAPH
           END-IF

           IF WS-INCOMING-PENDING = "Y"
               MOVE "This user has already sent you a connection request." TO OUTPUT-RECORD
               DISPLAY OUTPUT-RECORD
               WRITE OUTPUT-RECORD
               EXIT PARAGRAPH
           END-IF

           OPEN EXTEND CONNECTION-REQUESTS-FILE
           MOVE CURRENT-USERNAME TO CR-SENDER
           MOVE WS-TARGET-USERNAME TO CR-RECEIVER
           WRITE CONNECTION-REQUEST-RECORD
           CLOSE CONNECTION-REQUESTS-FILE

           MOVE SPACES TO WS-MESSAGE
           STRING "Connection request sent to " DELIMITED BY SIZE
                  PR-FIRST-NAME DELIMITED BY SPACE
                  " " DELIMITED BY SIZE
                  PR-LAST-NAME DELIMITED BY SPACE
                  "." DELIMITED BY SIZE
                  INTO WS-MESSAGE
           END-STRING
           DISPLAY WS-MESSAGE
           MOVE WS-MESSAGE TO OUTPUT-RECORD
           WRITE OUTPUT-RECORD
           .

       VIEW-PENDING-REQUESTS.
           MOVE "--- Pending Connection Requests ---" TO OUTPUT-RECORD
           DISPLAY OUTPUT-RECORD
           WRITE OUTPUT-RECORD

           MOVE "N" TO WS-PENDING-FOUND
           MOVE "N" TO WS-PENDING-EOF
           OPEN INPUT CONNECTION-REQUESTS-FILE
           IF WS-CONN-REQ-STATUS = "35"
               MOVE "Y" TO WS-PENDING-EOF
               MOVE "N" TO WS-CONN-REQ-OPEN
           ELSE
               MOVE "Y" TO WS-CONN-REQ-OPEN
           END-IF
           PERFORM UNTIL WS-PENDING-EOF = "Y"
               READ CONNECTION-REQUESTS-FILE INTO CONNECTION-REQUEST-RECORD
                   AT END MOVE "Y" TO WS-PENDING-EOF
                   NOT AT END
                       IF CR-RECEIVER = CURRENT-USERNAME
                           MOVE "Y" TO WS-PENDING-FOUND
                           MOVE CR-SENDER TO WS-CURRENT-REQUEST-SENDER
                           MOVE CR-RECEIVER TO WS-CURRENT-REQUEST-RECEIVER
                           MOVE SPACES TO OUTPUT-RECORD
                           STRING "Request from: " DELIMITED BY SIZE
                                  CR-SENDER DELIMITED BY SPACE
                                  INTO OUTPUT-RECORD
                           END-STRING
                           DISPLAY OUTPUT-RECORD
                           WRITE OUTPUT-RECORD
                           
                           MOVE "1. Accept" TO OUTPUT-RECORD
                           DISPLAY OUTPUT-RECORD
                           WRITE OUTPUT-RECORD
                           
                           MOVE "2. Reject" TO OUTPUT-RECORD
                           DISPLAY OUTPUT-RECORD
                           WRITE OUTPUT-RECORD
                           
                           MOVE SPACES TO OUTPUT-RECORD
                           STRING "Enter your choice for " DELIMITED BY SIZE
                                  CR-SENDER DELIMITED BY SPACE
                                  ":" DELIMITED BY SIZE
                                  INTO OUTPUT-RECORD
                           END-STRING
                           DISPLAY OUTPUT-RECORD
                           WRITE OUTPUT-RECORD
                           
                           IF WS-EOF-FLAG NOT = "Y"
                               READ INPUT-FILE INTO WS-TEMP-INPUT
                                   AT END MOVE "Y" TO WS-EOF-FLAG
                                   NOT AT END
                                       MOVE WS-TEMP-INPUT(1:1) TO WS-REQUEST-CHOICE
                                       EVALUATE WS-REQUEST-CHOICE
                                           WHEN 1
                                               PERFORM CLOSE-PENDING-REQUEST-FILE
                                               PERFORM ACCEPT-CONNECTION-REQUEST
                                           WHEN 2
                                               PERFORM CLOSE-PENDING-REQUEST-FILE
                                               PERFORM REJECT-CONNECTION-REQUEST
                                           WHEN OTHER
                                               MOVE "Invalid choice, skipping this request." TO OUTPUT-RECORD
                                               DISPLAY OUTPUT-RECORD
                                               WRITE OUTPUT-RECORD
                                       END-EVALUATE
                               END-READ
                           END-IF
      *> Exit after processing one request
                           MOVE "Y" TO WS-PENDING-EOF
                       END-IF
               END-READ
           END-PERFORM
           PERFORM CLOSE-PENDING-REQUEST-FILE

           IF WS-PENDING-FOUND = "N"
               MOVE "You have no pending connection requests at this time." TO OUTPUT-RECORD
               DISPLAY OUTPUT-RECORD
               WRITE OUTPUT-RECORD
           END-IF

           MOVE "-----------------------------------" TO OUTPUT-RECORD
           DISPLAY OUTPUT-RECORD
           WRITE OUTPUT-RECORD
           .

       CLOSE-PENDING-REQUEST-FILE.
           IF WS-CONN-REQ-OPEN = "Y"
               CLOSE CONNECTION-REQUESTS-FILE
               MOVE "N" TO WS-CONN-REQ-OPEN
           END-IF
           .

       VIEW-MY-NETWORK.
           MOVE "--- Your Network ---" TO OUTPUT-RECORD
           DISPLAY OUTPUT-RECORD
           WRITE OUTPUT-RECORD

           MOVE "N" TO WS-PENDING-FOUND
           MOVE "N" TO WS-CONNECTIONS-EOF
           OPEN INPUT CONNECTIONS-FILE
           IF WS-CONNECTION-STATUS = "35"
               MOVE "Y" TO WS-CONNECTIONS-EOF
           END-IF
           PERFORM UNTIL WS-CONNECTIONS-EOF = "Y"
               READ CONNECTIONS-FILE INTO CONNECTION-RECORD
                   AT END MOVE "Y" TO WS-CONNECTIONS-EOF
                   NOT AT END
                       IF CN-USER-ONE = CURRENT-USERNAME OR CN-USER-TWO = CURRENT-USERNAME
                           MOVE "Y" TO WS-PENDING-FOUND
                           MOVE SPACES TO OUTPUT-RECORD
                           IF CN-USER-ONE = CURRENT-USERNAME
                               MOVE CN-USER-TWO TO WS-TARGET-USERNAME
                           ELSE
                               MOVE CN-USER-ONE TO WS-TARGET-USERNAME
                           END-IF
                           
      *> Look up the connected user's profile information
                           PERFORM LOAD-CONNECTED-USER-PROFILE
                           
                           IF FOUND-PROFILE-FLAG = "Y"
                               MOVE SPACES TO OUTPUT-RECORD
                               STRING "Connected with: " DELIMITED BY SIZE
                                      PR-FIRST-NAME DELIMITED BY SPACE
                                      " " DELIMITED BY SIZE
                                      PR-LAST-NAME DELIMITED BY SPACE
                                      " (University: " DELIMITED BY SIZE
                                      PR-UNIVERSITY DELIMITED BY SPACE
                                      ", Major: " DELIMITED BY SIZE
                                      PR-MAJOR DELIMITED BY SPACE
                                      ")" DELIMITED BY SIZE
                                      INTO OUTPUT-RECORD
                               END-STRING
                           ELSE
                               MOVE SPACES TO OUTPUT-RECORD
                               STRING "Connected with: " DELIMITED BY SIZE
                                      WS-TARGET-USERNAME DELIMITED BY SPACE
                                      INTO OUTPUT-RECORD
                               END-STRING
                           END-IF
                           DISPLAY OUTPUT-RECORD
                           WRITE OUTPUT-RECORD
                       END-IF
               END-READ
           END-PERFORM
           CLOSE CONNECTIONS-FILE

           IF WS-PENDING-FOUND = "N"
               MOVE "You have no connections at this time." TO OUTPUT-RECORD
               DISPLAY OUTPUT-RECORD
               WRITE OUTPUT-RECORD
           END-IF

           MOVE "--------------------" TO OUTPUT-RECORD
           DISPLAY OUTPUT-RECORD
           WRITE OUTPUT-RECORD
           .

       LOAD-CONNECTED-USER-PROFILE.
      *> Load profile information for a connected user
           MOVE "Y" TO FOUND-PROFILE-FLAG
           CLOSE PROFILE-FILE
           OPEN I-O PROFILE-FILE
           MOVE WS-TARGET-USERNAME TO PR-USERNAME
      *> FINDING THE DESIRED USERNAME IN THE PROFILE-FILE
           READ PROFILE-FILE KEY IS PR-USERNAME
               INVALID KEY MOVE "N" TO FOUND-PROFILE-FLAG
               NOT INVALID KEY MOVE "Y" TO FOUND-PROFILE-FLAG
           END-READ
      *> WE DON'T CLOSE PROFILE FILE HERE SO WE NEED TO CLOSE IT FROM
      *> THE PARAGRAPH FROM WHICH WE CALLED LOAD-CONNECTED-USER-PROFILE
           .

       ACCEPT-CONNECTION-REQUEST.
      *> Add connection to established connections file
           OPEN EXTEND CONNECTIONS-FILE
           MOVE CURRENT-USERNAME TO CN-USER-ONE
           MOVE WS-CURRENT-REQUEST-SENDER TO CN-USER-TWO
           WRITE CONNECTION-RECORD
           CLOSE CONNECTIONS-FILE
           
      *> Remove the request from pending requests file
           PERFORM REMOVE-CONNECTION-REQUEST
           
      *> Display confirmation message
           MOVE SPACES TO WS-MESSAGE
           STRING "Connection request from " DELIMITED BY SIZE
                  WS-CURRENT-REQUEST-SENDER DELIMITED BY SPACE
                  " accepted!" DELIMITED BY SIZE
                  INTO WS-MESSAGE
           END-STRING
           DISPLAY WS-MESSAGE
           MOVE WS-MESSAGE TO OUTPUT-RECORD
           WRITE OUTPUT-RECORD
           .

       REJECT-CONNECTION-REQUEST.
      *> Remove the request from pending requests file
           PERFORM REMOVE-CONNECTION-REQUEST
           
      *> Display confirmation message
           MOVE SPACES TO WS-MESSAGE
           STRING "Connection request from " DELIMITED BY SIZE
                  WS-CURRENT-REQUEST-SENDER DELIMITED BY SPACE
                  " rejected." DELIMITED BY SIZE
                  INTO WS-MESSAGE
           END-STRING
           DISPLAY WS-MESSAGE
           MOVE WS-MESSAGE TO OUTPUT-RECORD
           WRITE OUTPUT-RECORD
           .

       REMOVE-CONNECTION-REQUEST.
           MOVE WS-CURRENT-REQUEST-SENDER TO WS-REMOVE-SENDER
           MOVE WS-CURRENT-REQUEST-RECEIVER TO WS-REMOVE-RECEIVER

      *> Copy all requests except the processed one into a temp file
           OPEN INPUT CONNECTION-REQUESTS-FILE
           IF WS-CONN-REQ-STATUS = "35"
               CLOSE CONNECTION-REQUESTS-FILE
               EXIT PARAGRAPH
           END-IF

           OPEN OUTPUT CONNECTION-REQUESTS-TEMP-FILE
           MOVE "N" TO WS-TEMP-EOF
           PERFORM UNTIL WS-TEMP-EOF = "Y"
               READ CONNECTION-REQUESTS-FILE INTO CONNECTION-REQUEST-RECORD
                   AT END MOVE "Y" TO WS-TEMP-EOF
                   NOT AT END
                       IF CR-SENDER = WS-REMOVE-SENDER AND CR-RECEIVER = WS-REMOVE-RECEIVER
                           CONTINUE
                       ELSE
                           MOVE CONNECTION-REQUEST-RECORD TO CONNECTION-REQUEST-TEMP-RECORD
                           WRITE CONNECTION-REQUEST-TEMP-RECORD
                       END-IF
               END-READ
           END-PERFORM
           CLOSE CONNECTION-REQUESTS-FILE
           CLOSE CONNECTION-REQUESTS-TEMP-FILE

      *> Rewrite the original file with the filtered contents
           OPEN OUTPUT CONNECTION-REQUESTS-FILE
           OPEN INPUT CONNECTION-REQUESTS-TEMP-FILE
           MOVE "N" TO WS-TEMP-EOF
           PERFORM UNTIL WS-TEMP-EOF = "Y"
               READ CONNECTION-REQUESTS-TEMP-FILE INTO CONNECTION-REQUEST-TEMP-RECORD
                   AT END MOVE "Y" TO WS-TEMP-EOF
                   NOT AT END
                       MOVE CONNECTION-REQUEST-TEMP-RECORD TO CONNECTION-REQUEST-RECORD
                       WRITE CONNECTION-REQUEST-RECORD
               END-READ
           END-PERFORM
           CLOSE CONNECTION-REQUESTS-FILE
           CLOSE CONNECTION-REQUESTS-TEMP-FILE

      *> Clear the temporary file so it does not retain stale data
           OPEN OUTPUT CONNECTION-REQUESTS-TEMP-FILE
           CLOSE CONNECTION-REQUESTS-TEMP-FILE
           .

       LEARN-SKILL-MENU.
           MOVE "Learn a New Skill" TO OUTPUT-RECORD
           DISPLAY OUTPUT-RECORD
           WRITE OUTPUT-RECORD

           MOVE "1. Programming" TO OUTPUT-RECORD
           DISPLAY OUTPUT-RECORD
           WRITE OUTPUT-RECORD

           MOVE "2. Data Analysis" TO OUTPUT-RECORD
           DISPLAY OUTPUT-RECORD
           WRITE OUTPUT-RECORD

           MOVE "3. Digital Marketing" TO OUTPUT-RECORD
           DISPLAY OUTPUT-RECORD
           WRITE OUTPUT-RECORD

           MOVE "4. Project Management" TO OUTPUT-RECORD
           DISPLAY OUTPUT-RECORD
           WRITE OUTPUT-RECORD

           MOVE "5. Communication" TO OUTPUT-RECORD
           DISPLAY OUTPUT-RECORD
           WRITE OUTPUT-RECORD

           MOVE "6. Go Back" TO OUTPUT-RECORD
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
                           MOVE "Programming is under construction." TO OUTPUT-RECORD
                           DISPLAY OUTPUT-RECORD
                           WRITE OUTPUT-RECORD
                       WHEN 2
                           MOVE "Data Analysis is under construction." TO OUTPUT-RECORD
                           DISPLAY OUTPUT-RECORD
                           WRITE OUTPUT-RECORD
                       WHEN 3
                           MOVE "Digital Marketing is under construction." TO OUTPUT-RECORD
                           DISPLAY OUTPUT-RECORD
                           WRITE OUTPUT-RECORD
                       WHEN 4
                           MOVE "Project Management under construction." TO OUTPUT-RECORD
                           DISPLAY OUTPUT-RECORD
                           WRITE OUTPUT-RECORD
                       WHEN 5
                           MOVE "Communication is under construction." TO OUTPUT-RECORD
                           DISPLAY OUTPUT-RECORD
                           WRITE OUTPUT-RECORD
                       WHEN 6
                           MOVE "Returning to main menu..." TO OUTPUT-RECORD
                           DISPLAY OUTPUT-RECORD
                           WRITE OUTPUT-RECORD
                       WHEN OTHER
                           MOVE "Invalid choice, please try again." TO OUTPUT-RECORD
                           DISPLAY OUTPUT-RECORD
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
       
       JOB-MENU.
           MOVE "==== Job Search/Internship Menu ====" TO OUTPUT-RECORD
           DISPLAY OUTPUT-RECORD
           WRITE OUTPUT-RECORD

           MOVE "1. Post a Job/Internship" TO OUTPUT-RECORD
           DISPLAY OUTPUT-RECORD
           WRITE OUTPUT-RECORD

           MOVE "2. Browse Jobs/Internships" TO OUTPUT-RECORD
           DISPLAY OUTPUT-RECORD
           WRITE OUTPUT-RECORD

      *> === EPIC 7 NEW MENU OPTION ===
           MOVE "3. View My Applications" TO OUTPUT-RECORD
           DISPLAY OUTPUT-RECORD
           WRITE OUTPUT-RECORD

           MOVE "4. Back to Main Menu" TO OUTPUT-RECORD
           DISPLAY OUTPUT-RECORD
           WRITE OUTPUT-RECORD

           READ INPUT-FILE INTO WS-USER-CHOICE
             AT END MOVE "Y" TO WS-EOF-FLAG
             NOT AT END
               EVALUATE WS-USER-CHOICE
                 WHEN 1
                   MOVE "Posting a job..." TO OUTPUT-RECORD
                   DISPLAY OUTPUT-RECORD
                   WRITE OUTPUT-RECORD

                   PERFORM POST-A-JOB
                 WHEN 2
                   PERFORM BROWSE-JOBS
      *> PERFORM BROWSE-JOBS (FUTURE FEATURE)
                 WHEN 3
                   PERFORM VIEW-MY-APPLICATIONS
                 WHEN 4
                   MOVE "Returning back to MAIN MENU..." TO OUTPUT-RECORD
                   DISPLAY OUTPUT-RECORD
                   WRITE OUTPUT-RECORD

      *> NEED TO ASSIGN USER CHOICE TO 9 TO EXIT THE LOOP TOWARDS MAIN
      *> MENU
      *> WHEN 3 should return back to main menu (1. login, 2. register)
      *> it returns to main menu for me, pls report if it doesn't for u
                   MOVE 9 TO WS-USER-CHOICE
                   EXIT PARAGRAPH
                 WHEN OTHER
                   MOVE "Invalid choice, please try again" TO OUTPUT-RECORD
                   DISPLAY OUTPUT-RECORD
                   WRITE OUTPUT-RECORD
               END-EVALUATE
           END-READ
       .
       
       POST-A-JOB.
      *> MAKE SURE JOBS-FILE IS CLOSED BEFORE JOBS-FILE OPENS AS INPUT
      *> CLOSE JOBS-FILE
           OPEN INPUT JOBS-FILE
           MOVE 'N' TO WS-JOBS-FILE-EOF
           PERFORM UNTIL WS-JOBS-FILE-EOF = 'Y'
             READ JOBS-FILE
               AT END 
                 MOVE 'Y' TO WS-JOBS-FILE-EOF
               NOT AT END
                 MOVE JR-ID OF JOBS-FILE-RECORD TO TEMP-LAST-JOB-ID
             END-READ
           END-PERFORM
           CLOSE JOBS-FILE

           OPEN EXTEND JOBS-FILE
           ADD 1 TO TEMP-LAST-JOB-ID
           MOVE TEMP-LAST-JOB-ID TO JR-ID

           MOVE "Job Titile: " TO OUTPUT-RECORD
           DISPLAY OUTPUT-RECORD
           WRITE OUTPUT-RECORD

           MOVE "N" TO WS-VALID-REQUIRED
      *>CHECKING IF THE VALUE ENTERED NON-EMPTY
           PERFORM UNTIL WS-VALID-REQUIRED = "Y"
               IF WS-EOF-FLAG NOT = "Y"
                   READ INPUT-FILE INTO JR-TITLE
                       AT END MOVE "Y" TO WS-EOF-FLAG
                   END-READ
               END-IF
               IF WS-EOF-FLAG = "Y"
                   MOVE "Failed to post a job. EOF during Title" TO OUTPUT-RECORD
                   DISPLAY OUTPUT-RECORD
                   WRITE OUTPUT-RECORD
                   EXIT PARAGRAPH
               END-IF
               IF JR-TITLE NOT = SPACES
                   MOVE "Y" TO WS-VALID-REQUIRED 
               ELSE
                   MOVE "This is a required field. Please enter non-empty value" TO OUTPUT-RECORD
                   DISPLAY OUTPUT-RECORD
                   WRITE OUTPUT-RECORD
               END-IF
           END-PERFORM

           MOVE "Description: " TO OUTPUT-RECORD
           DISPLAY OUTPUT-RECORD
           WRITE OUTPUT-RECORD

           MOVE "N" TO WS-VALID-REQUIRED
      *>CHECKING IF THE VALUE ENTERED NON-EMPTY
           PERFORM UNTIL WS-VALID-REQUIRED = "Y"
               IF WS-EOF-FLAG NOT = "Y"
                   READ INPUT-FILE INTO JR-DESC
                       AT END MOVE "Y" TO WS-EOF-FLAG
                   END-READ
               END-IF
               IF WS-EOF-FLAG = "Y"
                   MOVE "Failed to post a job. EOF during Description" TO OUTPUT-RECORD
                   DISPLAY OUTPUT-RECORD
                   WRITE OUTPUT-RECORD
                   EXIT PARAGRAPH
               END-IF
               IF JR-DESC NOT = SPACES
                   MOVE "Y" TO WS-VALID-REQUIRED 
               ELSE
                   MOVE "This is a required field. Please enter non-empty value" TO OUTPUT-RECORD
                   DISPLAY OUTPUT-RECORD
                   WRITE OUTPUT-RECORD
               END-IF
           END-PERFORM

           MOVE "Employer: " TO OUTPUT-RECORD
           DISPLAY OUTPUT-RECORD
           WRITE OUTPUT-RECORD

           MOVE "N" TO WS-VALID-REQUIRED
      *>CHECKING IF THE VALUE ENTERED NON-EMPTY
           PERFORM UNTIL WS-VALID-REQUIRED = "Y"
               IF WS-EOF-FLAG NOT = "Y"
                   READ INPUT-FILE INTO JR-EMPLOYER
                       AT END MOVE "Y" TO WS-EOF-FLAG
                   END-READ
               END-IF
               IF WS-EOF-FLAG = "Y"
                   MOVE "Failed to post a job. EOF during Employer" TO OUTPUT-RECORD
                   DISPLAY OUTPUT-RECORD
                   WRITE OUTPUT-RECORD
                   EXIT PARAGRAPH
               END-IF
               IF JR-EMPLOYER NOT = SPACES
                   MOVE "Y" TO WS-VALID-REQUIRED 
               ELSE
                   MOVE "This is a required field. Please enter non-empty value" TO OUTPUT-RECORD
                   DISPLAY OUTPUT-RECORD
                   WRITE OUTPUT-RECORD
               END-IF
           END-PERFORM

           MOVE "Location: " TO OUTPUT-RECORD
           DISPLAY OUTPUT-RECORD
           WRITE OUTPUT-RECORD

           MOVE "N" TO WS-VALID-REQUIRED
      *>CHECKING IF THE VALUE ENTERED NON-EMPTY
           PERFORM UNTIL WS-VALID-REQUIRED = "Y"
               IF WS-EOF-FLAG NOT = "Y"
                   READ INPUT-FILE INTO JR-LOCATION
                       AT END MOVE "Y" TO WS-EOF-FLAG
                   END-READ
               END-IF
               IF WS-EOF-FLAG = "Y"
                   MOVE "Failed to post a job. EOF during Location" TO OUTPUT-RECORD
                   DISPLAY OUTPUT-RECORD
                   WRITE OUTPUT-RECORD
                   EXIT PARAGRAPH
               END-IF
               IF JR-LOCATION NOT = SPACES
                   MOVE "Y" TO WS-VALID-REQUIRED 
               ELSE
                   MOVE "This is a required field. Please enter non-empty value" TO OUTPUT-RECORD
                   DISPLAY OUTPUT-RECORD
                   WRITE OUTPUT-RECORD
               END-IF
           END-PERFORM

           MOVE "Salary (optional): " TO OUTPUT-RECORD
           DISPLAY OUTPUT-RECORD
           WRITE OUTPUT-RECORD
           IF WS-EOF-FLAG NOT = "Y"
             READ INPUT-FILE INTO JR-SALARY
                 AT END MOVE "Y" TO WS-EOF-FLAG
             END-READ
           END-IF

      *> IF WS-USERNAME CHANGES DURING EXECUTION
      *> TRY USING CURRENT-USERNAME
           MOVE WS-USERNAME TO JR-AUTHOR-USERNAME

           WRITE JOBS-FILE-RECORD

           MOVE "Job posted successfully!" TO OUTPUT-RECORD
           DISPLAY OUTPUT-RECORD
           WRITE OUTPUT-RECORD

           CLOSE JOBS-FILE
       .
       BROWSE-JOBS.
           MOVE "--- Available Job Listings ---" TO OUTPUT-RECORD
           DISPLAY OUTPUT-RECORD
           WRITE OUTPUT-RECORD

           OPEN INPUT JOBS-FILE
           MOVE 1 TO TEMP-LAST-JOB-ID
           MOVE 'N' TO WS-JOBS-FILE-EOF
           PERFORM UNTIL WS-JOBS-FILE-EOF = 'Y'
               READ JOBS-FILE INTO JOBS-FILE-RECORD
                   AT END MOVE 'Y' TO WS-JOBS-FILE-EOF
                   NOT AT END
                       MOVE SPACES TO OUTPUT-RECORD
      *>FUNCTION TRIM(JR-TITLE TRAILING) rightmost whitespaces
                       STRING TEMP-LAST-JOB-ID ". " FUNCTION TRIM(JR-TITLE TRAILING)
                       " at " FUNCTION TRIM(JR-EMPLOYER TRAILING)
                       " (" FUNCTION TRIM(JR-LOCATION TRAILING) ")" INTO OUTPUT-RECORD
                       END-STRING
                       DISPLAY OUTPUT-RECORD
                       WRITE OUTPUT-RECORD
                       ADD 1 TO TEMP-LAST-JOB-ID
               END-READ
           END-PERFORM
           CLOSE JOBS-FILE

           MOVE "Enter job number to view details, or 0 to go back:" TO OUTPUT-RECORD
           DISPLAY OUTPUT-RECORD
           WRITE OUTPUT-RECORD

           READ INPUT-FILE INTO WS-TEMP-INPUT
               AT END MOVE "Y" TO WS-EOF-FLAG
               NOT AT END
                   IF FUNCTION NUMVAL(WS-TEMP-INPUT) > 0
                       MOVE FUNCTION NUMVAL(WS-TEMP-INPUT) TO WS-TARGET-JOB-ID
                       PERFORM VIEW-JOB-DETAILS
                   END-IF
           END-READ
           .

       VIEW-JOB-DETAILS.
           OPEN INPUT JOBS-FILE
           MOVE 1 TO TEMP-LAST-JOB-ID
           MOVE 'N' TO WS-JOBS-FILE-EOF
           MOVE 'N' TO WS-TARGET-JOB-ID-FOUND
      *> added OR TEMP-LAST-JOB-ID = WS-TARGET-JOB-ID
           PERFORM UNTIL WS-JOBS-FILE-EOF = 'Y' OR TEMP-LAST-JOB-ID > WS-TARGET-JOB-ID
               READ JOBS-FILE INTO JOBS-FILE-RECORD
                   AT END MOVE 'Y' TO WS-JOBS-FILE-EOF
                   NOT AT END
                       IF TEMP-LAST-JOB-ID = WS-TARGET-JOB-ID
                           MOVE 'Y' TO WS-TARGET-JOB-ID-FOUND

                           MOVE "=== Job Details ===" TO OUTPUT-RECORD
                           DISPLAY OUTPUT-RECORD
                           WRITE OUTPUT-RECORD

                           MOVE SPACES TO OUTPUT-RECORD
                           STRING "Title: " JR-TITLE INTO OUTPUT-RECORD
                           DISPLAY OUTPUT-RECORD
                           WRITE OUTPUT-RECORD

                           MOVE SPACES TO OUTPUT-RECORD
                           STRING "Description: " JR-DESC INTO OUTPUT-RECORD
                           DISPLAY OUTPUT-RECORD
                           WRITE OUTPUT-RECORD

                           MOVE SPACES TO OUTPUT-RECORD
                           STRING "Employer: " JR-EMPLOYER INTO OUTPUT-RECORD
                           DISPLAY OUTPUT-RECORD
                           WRITE OUTPUT-RECORD

                           MOVE SPACES TO OUTPUT-RECORD
                           STRING "Location: " JR-LOCATION INTO OUTPUT-RECORD
                           DISPLAY OUTPUT-RECORD
                           WRITE OUTPUT-RECORD

                           IF JR-SALARY NOT = SPACES
                               MOVE SPACES TO OUTPUT-RECORD
                               STRING "Salary: " JR-SALARY INTO OUTPUT-RECORD
                               DISPLAY OUTPUT-RECORD
                               WRITE OUTPUT-RECORD
                           END-IF

                           MOVE "1. Apply for this Job" TO OUTPUT-RECORD
                           DISPLAY OUTPUT-RECORD
                           WRITE OUTPUT-RECORD
                           MOVE "2. Back to Job List" TO OUTPUT-RECORD
                           DISPLAY OUTPUT-RECORD
                           WRITE OUTPUT-RECORD

                           READ INPUT-FILE INTO WS-TEMP-INPUT
                               AT END MOVE "Y" TO WS-EOF-FLAG
                               NOT AT END
                                   IF WS-TEMP-INPUT(1:1) = "1"
                                       PERFORM APPLY-FOR-JOB
                                   END-IF
                           END-READ
                       END-IF
                       ADD 1 TO TEMP-LAST-JOB-ID
               END-READ
           END-PERFORM
           IF WS-TARGET-JOB-ID-FOUND = 'N'
             MOVE "Error. No job by provided number found! (see below)" TO OUTPUT-RECORD
             DISPLAY OUTPUT-RECORD
             WRITE OUTPUT-RECORD
             MOVE WS-TARGET-JOB-ID TO OUTPUT-RECORD
             DISPLAY OUTPUT-RECORD
             WRITE OUTPUT-RECORD
           END-IF
           CLOSE JOBS-FILE
           .

       APPLY-FOR-JOB.
           OPEN INPUT APPLICATIONS-FILE
           MOVE 'N' TO WS-TARGET-JOB-ID-APPLIED
           MOVE 'N' TO WS-APPLICATIONS-EOF
           PERFORM UNTIL WS-APPLICATIONS-EOF = 'Y' OR WS-TARGET-JOB-ID-APPLIED = 'Y'
               READ APPLICATIONS-FILE INTO APPLICATION-RECORD
                   AT END MOVE 'Y' TO WS-APPLICATIONS-EOF
                   NOT AT END
                       IF APP-USERNAME = CURRENT-USERNAME
                           IF APP-JOB-ID = WS-TARGET-JOB-ID
                               MOVE 'Y' TO WS-TARGET-JOB-ID-APPLIED
                           END-IF
                       END-IF
               END-READ
           END-PERFORM
           CLOSE APPLICATIONS-FILE

           IF WS-TARGET-JOB-ID-APPLIED = 'N'
             OPEN EXTEND APPLICATIONS-FILE
             MOVE CURRENT-USERNAME TO APP-USERNAME
             MOVE WS-TARGET-JOB-ID TO APP-JOB-ID
             WRITE APPLICATION-RECORD
             CLOSE APPLICATIONS-FILE

      *> this can be changed to MOVE SPACES TO OUTPUT-RECORD
             MOVE SPACES TO WS-MESSAGE
             STRING "Application submitted for " FUNCTION TRIM(JR-TITLE TRAILING)
                    " at " FUNCTION TRIM(JR-EMPLOYER TRAILING) INTO WS-MESSAGE
             END-STRING
             DISPLAY WS-MESSAGE
             MOVE WS-MESSAGE TO OUTPUT-RECORD
             WRITE OUTPUT-RECORD
           ELSE
             MOVE "Sorry, you've already applied for this job" TO OUTPUT-RECORD
             DISPLAY OUTPUT-RECORD
             WRITE OUTPUT-RECORD
           END-IF
           .

       VIEW-MY-APPLICATIONS.
           MOVE "--- Your Job Applications ---" TO OUTPUT-RECORD
           DISPLAY OUTPUT-RECORD
           WRITE OUTPUT-RECORD
           MOVE 0 TO WS-COUNTER

           OPEN INPUT APPLICATIONS-FILE
           MOVE 'N' TO WS-APPLICATIONS-EOF
           PERFORM UNTIL WS-APPLICATIONS-EOF = 'Y'
               READ APPLICATIONS-FILE INTO APPLICATION-RECORD
                   AT END MOVE 'Y' TO WS-APPLICATIONS-EOF
                   NOT AT END
                       IF APP-USERNAME = CURRENT-USERNAME
                           ADD 1 TO WS-COUNTER
                           PERFORM SHOW-APPLICATION-DETAIL
                       END-IF
               END-READ
           END-PERFORM
           CLOSE APPLICATIONS-FILE

           MOVE SPACES TO OUTPUT-RECORD
           STRING "Total Applications: " WS-COUNTER INTO OUTPUT-RECORD
           DISPLAY OUTPUT-RECORD
           WRITE OUTPUT-RECORD
           .

       SHOW-APPLICATION-DETAIL.
           OPEN INPUT JOBS-FILE
           MOVE 'N' TO WS-JOBS-FILE-EOF
           PERFORM UNTIL WS-JOBS-FILE-EOF = 'Y'
               READ JOBS-FILE INTO JOBS-FILE-RECORD
                   AT END MOVE 'Y' TO WS-JOBS-FILE-EOF
                   NOT AT END
                       IF JR-ID = APP-JOB-ID
                           MOVE SPACES TO OUTPUT-RECORD
                           STRING "Job Title: " FUNCTION TRIM(JR-TITLE TRAILING) INTO OUTPUT-RECORD
                           DISPLAY OUTPUT-RECORD
                           WRITE OUTPUT-RECORD

                           MOVE SPACES TO OUTPUT-RECORD
                           STRING "Employer: " FUNCTION TRIM(JR-EMPLOYER TRAILING) INTO OUTPUT-RECORD
                           DISPLAY OUTPUT-RECORD
                           WRITE OUTPUT-RECORD

                           MOVE SPACES TO OUTPUT-RECORD
                           STRING "Location: " FUNCTION TRIM(JR-LOCATION TRAILING) INTO OUTPUT-RECORD
                           DISPLAY OUTPUT-RECORD
                           WRITE OUTPUT-RECORD

                           MOVE "---" TO OUTPUT-RECORD
                           DISPLAY OUTPUT-RECORD
                           WRITE OUTPUT-RECORD
                       END-IF
               END-READ
           END-PERFORM
           CLOSE JOBS-FILE
           .

       DEBUG-JOBS.
      *> THIS PARAGRAPH CAN LATER BE USED AS A BLUEPRINT FOR JOB LISTINGS DISPLAY
           MOVE "JOBS DEBUG OUTPUT BEGIN" TO OUTPUT-RECORD
           DISPLAY OUTPUT-RECORD
           WRITE OUTPUT-RECORD

           OPEN INPUT JOBS-FILE
           MOVE 'N' TO WS-JOBS-FILE-EOF
           PERFORM UNTIL WS-JOBS-FILE-EOF = 'Y'
             READ JOBS-FILE
               AT END 
                 MOVE 'Y' TO WS-JOBS-FILE-EOF
               NOT AT END
                 MOVE "======" TO OUTPUT-RECORD
                 DISPLAY OUTPUT-RECORD
                 WRITE OUTPUT-RECORD

                 MOVE "JOB ID: " TO OUTPUT-RECORD
                 DISPLAY OUTPUT-RECORD
                 WRITE OUTPUT-RECORD

                 MOVE JR-ID TO OUTPUT-RECORD
                 DISPLAY OUTPUT-RECORD
                 WRITE OUTPUT-RECORD

                 MOVE "Titie: " TO OUTPUT-RECORD
                 DISPLAY OUTPUT-RECORD
                 WRITE OUTPUT-RECORD

                 MOVE JR-TITLE TO OUTPUT-RECORD
                 DISPLAY OUTPUT-RECORD
                 WRITE OUTPUT-RECORD

                 MOVE "Description: " TO OUTPUT-RECORD
                 DISPLAY OUTPUT-RECORD
                 WRITE OUTPUT-RECORD

                 MOVE JR-DESC TO OUTPUT-RECORD
                 DISPLAY OUTPUT-RECORD
                 WRITE OUTPUT-RECORD

                 MOVE "Employer: " TO OUTPUT-RECORD
                 DISPLAY OUTPUT-RECORD
                 WRITE OUTPUT-RECORD

                 MOVE JR-EMPLOYER TO OUTPUT-RECORD
                 DISPLAY OUTPUT-RECORD
                 WRITE OUTPUT-RECORD

                 MOVE "Location: " TO OUTPUT-RECORD
                 DISPLAY OUTPUT-RECORD
                 WRITE OUTPUT-RECORD

                 MOVE JR-LOCATION TO OUTPUT-RECORD
                 DISPLAY OUTPUT-RECORD
                 WRITE OUTPUT-RECORD

                 MOVE "Salary: " TO OUTPUT-RECORD
                 DISPLAY OUTPUT-RECORD
                 WRITE OUTPUT-RECORD

                 MOVE JR-SALARY TO OUTPUT-RECORD
                 DISPLAY OUTPUT-RECORD
                 WRITE OUTPUT-RECORD

                 MOVE "AUTHOR: " TO OUTPUT-RECORD
                 DISPLAY OUTPUT-RECORD
                 WRITE OUTPUT-RECORD

                 MOVE JR-AUTHOR-USERNAME TO OUTPUT-RECORD
                 DISPLAY OUTPUT-RECORD
                 WRITE OUTPUT-RECORD
             END-READ
           END-PERFORM
           CLOSE JOBS-FILE

           MOVE "JOBS DEBUG OUTPUT ENDED" TO OUTPUT-RECORD
           DISPLAY OUTPUT-RECORD
           WRITE OUTPUT-RECORD
       .

       WRITE-TO-OUTPUT.
           MOVE FUNCTION TRIM(FUNCTION REVERSE(
               FUNCTION TRIM(FUNCTION REVERSE(
               WS-TEMP-INPUT)))) TO OUTPUT-RECORD
               WRITE OUTPUT-RECORD
       .
       
      *> === EPIC 8 MESSAGING FUNCTIONS ===
       MESSAGES-MENU.
           MOVE "--- Messages Menu ---" TO OUTPUT-RECORD
           DISPLAY OUTPUT-RECORD
           WRITE OUTPUT-RECORD

           MOVE "1. Send a New Message" TO OUTPUT-RECORD
           DISPLAY OUTPUT-RECORD
           WRITE OUTPUT-RECORD

           MOVE "2. View My Messages" TO OUTPUT-RECORD
           DISPLAY OUTPUT-RECORD
           WRITE OUTPUT-RECORD

           MOVE "3. Back to Main Menu" TO OUTPUT-RECORD
           DISPLAY OUTPUT-RECORD
           WRITE OUTPUT-RECORD

           MOVE "Enter your choice:" TO OUTPUT-RECORD
           DISPLAY OUTPUT-RECORD
           WRITE OUTPUT-RECORD

           IF WS-EOF-FLAG NOT = "Y"
               READ INPUT-FILE INTO WS-TEMP-INPUT
                   AT END MOVE "Y" TO WS-EOF-FLAG
                   NOT AT END
                       MOVE WS-TEMP-INPUT(1:1) TO WS-MSG-CHOICE
                       EVALUATE WS-MSG-CHOICE
                           WHEN 1
                               PERFORM SEND-MESSAGE
                           WHEN 2
                               PERFORM VIEW-MY-MESSAGES
                           WHEN 3
                               CONTINUE
                           WHEN OTHER
                               MOVE "Invalid choice, please try again" TO OUTPUT-RECORD
                               DISPLAY OUTPUT-RECORD
                               WRITE OUTPUT-RECORD
                       END-EVALUATE
               END-READ
           END-IF
           .

       SEND-MESSAGE.
           MOVE "Enter recipient's username (must be a connection):" TO OUTPUT-RECORD
           DISPLAY OUTPUT-RECORD
           WRITE OUTPUT-RECORD

           IF WS-EOF-FLAG NOT = "Y"
               READ INPUT-FILE INTO WS-MSG-RECIPIENT
                   AT END MOVE "Y" TO WS-EOF-FLAG
               END-READ
           END-IF

           IF WS-EOF-FLAG = "Y"
               EXIT PARAGRAPH
           END-IF

      *> Validate that recipient is a connection
           PERFORM CHECK-IF-CONNECTED

           IF WS-CONNECTED-FLAG = "N"
               MOVE "You can only message users you are connected with." TO OUTPUT-RECORD
               DISPLAY OUTPUT-RECORD
               WRITE OUTPUT-RECORD
               EXIT PARAGRAPH
           END-IF

           MOVE "Enter your message (max 200 chars):" TO OUTPUT-RECORD
           DISPLAY OUTPUT-RECORD
           WRITE OUTPUT-RECORD

           IF WS-EOF-FLAG NOT = "Y"
               READ INPUT-FILE INTO WS-MSG-CONTENT
                   AT END MOVE "Y" TO WS-EOF-FLAG
               END-READ
           END-IF

           IF WS-EOF-FLAG = "Y"
               EXIT PARAGRAPH
           END-IF

      *> Generate timestamp from CURRENT-DATE (format: YYYYMMDDHHMMSS)
           MOVE FUNCTION CURRENT-DATE(1:14) TO WS-TIMESTAMP

      *> Save message to file
           OPEN EXTEND MESSAGES-FILE
           MOVE CURRENT-USERNAME TO MS-SENDER
           MOVE WS-MSG-RECIPIENT TO MS-RECIPIENT
           MOVE WS-MSG-CONTENT TO MS-CONTENT
           MOVE WS-TIMESTAMP TO MS-TIMESTAMP
           WRITE MESSAGE-RECORD
           CLOSE MESSAGES-FILE

      *> Display success message
           MOVE SPACES TO WS-MESSAGE
           STRING "Message sent to " DELIMITED BY SIZE
                  WS-MSG-RECIPIENT DELIMITED BY SPACE
                  " successfully!" DELIMITED BY SIZE
                  INTO WS-MESSAGE
           END-STRING
           DISPLAY WS-MESSAGE
           MOVE WS-MESSAGE TO OUTPUT-RECORD
           WRITE OUTPUT-RECORD
           .

       VIEW-MY-MESSAGES.
           MOVE "View My Messages is under construction." TO OUTPUT-RECORD
           DISPLAY OUTPUT-RECORD
           WRITE OUTPUT-RECORD
           .

       CHECK-IF-CONNECTED.
           MOVE "N" TO WS-CONNECTED-FLAG
           MOVE "N" TO WS-CONNECTIONS-EOF

           OPEN INPUT CONNECTIONS-FILE
           IF WS-CONNECTION-STATUS = "35"
               MOVE "Y" TO WS-CONNECTIONS-EOF
           END-IF

           PERFORM UNTIL WS-CONNECTIONS-EOF = "Y" OR WS-CONNECTED-FLAG = "Y"
               READ CONNECTIONS-FILE INTO CONNECTION-RECORD
                   AT END MOVE "Y" TO WS-CONNECTIONS-EOF
                   NOT AT END
                       IF (CN-USER-ONE = CURRENT-USERNAME AND CN-USER-TWO = WS-MSG-RECIPIENT)
                           OR (CN-USER-TWO = CURRENT-USERNAME AND CN-USER-ONE = WS-MSG-RECIPIENT)
                           MOVE "Y" TO WS-CONNECTED-FLAG
                       END-IF
               END-READ
           END-PERFORM

           CLOSE CONNECTIONS-FILE
           .

       CLEANUP.
           CLOSE INPUT-FILE
           CLOSE OUTPUT-FILE
           CLOSE ACCOUNTS-FILE
           CLOSE PROFILE-FILE
           CLOSE JOBS-FILE
           CLOSE CONNECTION-REQUESTS-FILE 
           CLOSE CONNECTION-REQUESTS-TEMP-FILE 
           CLOSE CONNECTIONS-FILE 
      *> === EPIC 8 CLEANUP ===
           CLOSE MESSAGES-FILE
       .

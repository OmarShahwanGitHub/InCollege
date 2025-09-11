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
           DISPLAY "Search for a job"
           MOVE "Search for a job" TO OUTPUT-RECORD
           WRITE OUTPUT-RECORD

           DISPLAY "Find someone you know"
           MOVE "Find someone you know" TO OUTPUT-RECORD
           WRITE OUTPUT-RECORD

           DISPLAY "Learn a new skill"
           MOVE "Learn a new skill" TO OUTPUT-RECORD
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
                           DISPLAY "Job search is under construction."
                           MOVE "Job search is under construction." TO OUTPUT-RECORD
                           WRITE OUTPUT-RECORD
                       WHEN 2
                           DISPLAY "Find someone is under construction."
                           MOVE "Find someone is under construction." TO OUTPUT-RECORD
                           WRITE OUTPUT-RECORD
                       WHEN 3
                           PERFORM LEARN-SKILL-MENU
                       WHEN OTHER
                           DISPLAY "Invalid choice, please try again"
                           MOVE "Invalid choice, please try again" TO OUTPUT-RECORD
                           WRITE OUTPUT-RECORD
                   END-EVALUATE
           END-READ
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
           CLOSE ACCOUNTS-FILE.
		  

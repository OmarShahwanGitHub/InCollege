       IDENTIFICATION DIVISION.
       PROGRAM-ID. INCOLLEGE.
       
       ENVIRONMENT DIVISION.
       INPUT-OUTPUT SECTION.
       FILE-CONTROL.
           SELECT INPUT-FILE ASSIGN TO "InCollege-Input.txt"
               ORGANIZATION IS LINE SEQUENTIAL.
           SELECT OUTPUT-FILE ASSIGN TO "InCollege-Output.txt"
               ORGANIZATION IS LINE SEQUENTIAL.
           SELECT ACCOUNTS-FILE ASSIGN TO "accounts.dat"
               ORGANIZATION IS LINE SEQUENTIAL.
       
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
       01 WS-ACCOUNT-COUNT PIC 9(2) VALUE 0.
       01 WS-LOGIN-SUCCESS PIC X VALUE 'N'.
       01 WS-TEMP-INPUT PIC X(80).
       01 WS-STORED-USERNAME PIC X(20).
       01 WS-STORED-PASSWORD PIC X(12).
       01 WS-MESSAGE PIC X(90).
       01 WS-VALID PIC X VALUE 'N'.
       01 WS-HAS-UPPER PIC X VALUE 'N'.
       01 WS-HAS-DIGIT PIC X VALUE 'N'.
       01 WS-HAS-SPECIAL PIC X VALUE 'N'.
       01 WS-LEN PIC 99.
       01 WS-TRAIL-SP PIC 99.
       01 WS-LEAD-SP PIC 99.
       01 IDX PIC 99.
       01 WS-LAST-DISPLAY PIC X(80).
       
       PROCEDURE DIVISION.
       MAIN-LOGIC.
           PERFORM INITIALIZE-PROGRAM
           PERFORM MAIN-MENU UNTIL WS-EOF-FLAG = 'Y'
           PERFORM CLEANUP
           STOP RUN.
       
       INITIALIZE-PROGRAM.
           OPEN INPUT INPUT-FILE
           OPEN OUTPUT OUTPUT-FILE
           PERFORM COUNT-EXISTING-ACCOUNTS.
       
       MAIN-MENU.
           MOVE "Welcome to InCollege!" TO WS-LAST-DISPLAY
           PERFORM DISPLAY-AND-WRITE

           MOVE "Log In" TO WS-LAST-DISPLAY
           PERFORM DISPLAY-AND-WRITE

           MOVE "Create New Account" TO WS-LAST-DISPLAY
           PERFORM DISPLAY-AND-WRITE

           MOVE "Enter your choice:" TO WS-LAST-DISPLAY
           PERFORM DISPLAY-AND-WRITE
           
           READ INPUT-FILE INTO WS-TEMP-INPUT
               AT END MOVE 'Y' TO WS-EOF-FLAG
               NOT AT END
                   MOVE WS-TEMP-INPUT(1:1) TO WS-USER-CHOICE
                   EVALUATE WS-USER-CHOICE
                       WHEN 1
                           PERFORM LOGIN-PROCESS
                       WHEN 2
                           PERFORM CREATE-ACCOUNT
                       WHEN OTHER
                           MOVE "Invalid choice, please try again" TO WS-LAST-DISPLAY
                           PERFORM DISPLAY-AND-WRITE
                   END-EVALUATE
           END-READ.
       
       LOGIN-PROCESS.
           MOVE 'N' TO WS-LOGIN-SUCCESS
           
           MOVE "Please enter your username:" TO WS-LAST-DISPLAY
           PERFORM DISPLAY-AND-WRITE

           READ INPUT-FILE INTO WS-USERNAME
               AT END MOVE 'Y' TO WS-EOF-FLAG
           END-READ
           
           IF WS-EOF-FLAG NOT = 'Y'
               MOVE "Please enter your password:" TO WS-LAST-DISPLAY
               PERFORM DISPLAY-AND-WRITE

               READ INPUT-FILE INTO WS-PASSWORD
                   AT END MOVE 'Y' TO WS-EOF-FLAG
               END-READ
           END-IF
           
           IF WS-EOF-FLAG NOT = 'Y'
               PERFORM VALIDATE-LOGIN
               
               IF WS-LOGIN-SUCCESS = 'Y'
                   STRING "Welcome, " DELIMITED BY SIZE
                       WS-USERNAME DELIMITED BY SPACE
                       "!" DELIMITED BY SIZE
                       INTO WS-MESSAGE
                   END-STRING

                   MOVE WS-MESSAGE TO WS-LAST-DISPLAY
                   PERFORM DISPLAY-AND-WRITE
                   MOVE SPACES TO WS-MESSAGE

                   PERFORM POST-LOGIN-MENU
               ELSE
                   MOVE "Incorrect username/password, try again." TO WS-LAST-DISPLAY
                   PERFORM DISPLAY-AND-WRITE
               END-IF
           END-IF.
		
       POST-LOGIN-MENU.
           MOVE "Search for a job" TO WS-LAST-DISPLAY
           PERFORM DISPLAY-AND-WRITE

           MOVE "Find someone you know" TO WS-LAST-DISPLAY
           PERFORM DISPLAY-AND-WRITE

           MOVE "Learn a new skill" TO WS-LAST-DISPLAY
           PERFORM DISPLAY-AND-WRITE

           MOVE "Enter your choice:" TO WS-LAST-DISPLAY
           PERFORM DISPLAY-AND-WRITE
           
           READ INPUT-FILE INTO WS-TEMP-INPUT
               AT END MOVE 'Y' TO WS-EOF-FLAG
               NOT AT END
                   MOVE WS-TEMP-INPUT(1:1) TO WS-USER-CHOICE
                   EVALUATE WS-USER-CHOICE
                       WHEN 1
                           MOVE "Job search under construction." TO WS-LAST-DISPLAY
                           PERFORM DISPLAY-AND-WRITE
                       WHEN 2
                           MOVE "Find someone under construction." TO WS-LAST-DISPLAY
                           PERFORM DISPLAY-AND-WRITE
                       WHEN 3
                           PERFORM LEARN-SKILL-MENU
                       WHEN OTHER
                           MOVE "Invalid choice, please try again" TO WS-LAST-DISPLAY
                           PERFORM DISPLAY-AND-WRITE
                   END-EVALUATE
           END-READ.
       
       LEARN-SKILL-MENU.
           MOVE "Learn a New Skill" TO WS-LAST-DISPLAY
           PERFORM DISPLAY-AND-WRITE

           MOVE "Skill 1" TO WS-LAST-DISPLAY
           PERFORM DISPLAY-AND-WRITE

           MOVE "Skill 2" TO WS-LAST-DISPLAY
           PERFORM DISPLAY-AND-WRITE

           MOVE "Skill 3" TO WS-LAST-DISPLAY
           PERFORM DISPLAY-AND-WRITE

           MOVE "Skill 4" TO WS-LAST-DISPLAY
           PERFORM DISPLAY-AND-WRITE

           MOVE "Skill 5" TO WS-LAST-DISPLAY
           PERFORM DISPLAY-AND-WRITE

           MOVE "Go Back" TO WS-LAST-DISPLAY
           PERFORM DISPLAY-AND-WRITE

           MOVE "Enter your choice:" TO WS-LAST-DISPLAY
           PERFORM DISPLAY-AND-WRITE
           
           READ INPUT-FILE INTO WS-TEMP-INPUT
               AT END MOVE 'Y' TO WS-EOF-FLAG
               NOT AT END
                   MOVE WS-TEMP-INPUT(1:1) TO WS-USER-CHOICE
                   EVALUATE WS-USER-CHOICE
                       WHEN 1
                           MOVE "This skill is under construction." TO WS-LAST-DISPLAY
                           PERFORM DISPLAY-AND-WRITE
                       WHEN 2
                           MOVE "This skill is under construction." TO WS-LAST-DISPLAY
                           PERFORM DISPLAY-AND-WRITE
                       WHEN 3
                           MOVE "This skill is under construction." TO WS-LAST-DISPLAY
                           PERFORM DISPLAY-AND-WRITE
                       WHEN 4
                           MOVE "This skill is under construction." TO WS-LAST-DISPLAY
                           PERFORM DISPLAY-AND-WRITE
                       WHEN 5
                           MOVE "This skill is under construction." TO WS-LAST-DISPLAY
                           PERFORM DISPLAY-AND-WRITE
                       WHEN 6
                           MOVE "Returning to main menu..." TO WS-LAST-DISPLAY
                           PERFORM DISPLAY-AND-WRITE
                       WHEN OTHER
                           MOVE "Invalid choice, please try again" TO WS-LAST-DISPLAY
                           PERFORM DISPLAY-AND-WRITE
                   END-EVALUATE
           END-READ.
       
       COUNT-EXISTING-ACCOUNTS.
           MOVE 0 TO WS-ACCOUNT-COUNT
           MOVE 'N' TO WS-ACCOUNTS-EOF
           
           OPEN INPUT ACCOUNTS-FILE
           
           PERFORM UNTIL WS-ACCOUNTS-EOF = 'Y'
               READ ACCOUNTS-FILE INTO ACCOUNT-RECORD
                   AT END 
                       MOVE 'Y' TO WS-ACCOUNTS-EOF
                   NOT AT END
                       ADD 1 TO WS-ACCOUNT-COUNT
               END-READ
           END-PERFORM
           
           CLOSE ACCOUNTS-FILE.
       
       CREATE-ACCOUNT.
           IF WS-ACCOUNT-COUNT >= 5
              MOVE "All permitted accounts have been created, please come back later." TO WS-LAST-DISPLAY
              PERFORM DISPLAY-AND-WRITE
              EXIT PARAGRAPH
           END-IF

           MOVE "Enter Username:" TO WS-LAST-DISPLAY
           PERFORM DISPLAY-AND-WRITE
           READ INPUT-FILE INTO WS-USERNAME
               AT END MOVE 'Y' TO WS-EOF-FLAG
           END-READ

           IF WS-EOF-FLAG NOT = 'Y'
               MOVE "N" TO WS-VALID
               PERFORM UNTIL WS-VALID = "Y" OR WS-EOF-FLAG = 'Y'
                  MOVE "Enter Password:" TO WS-LAST-DISPLAY
                  PERFORM DISPLAY-AND-WRITE
                  MOVE "(Password must be 8-12 characters long.)" TO WS-LAST-DISPLAY
                  PERFORM DISPLAY-AND-WRITE
                  MOVE "(Password must include at least 1 uppercase, 1 digit, and 1 special character.)" TO WS-LAST-DISPLAY
                  PERFORM DISPLAY-AND-WRITE
                  MOVE "(Leading and trailing spaces will be ignored.)" TO WS-LAST-DISPLAY
                  PERFORM DISPLAY-AND-WRITE
                  READ INPUT-FILE INTO WS-PASSWORD
                      AT END MOVE 'Y' TO WS-EOF-FLAG
                  END-READ
                  IF WS-EOF-FLAG NOT = 'Y'
                      PERFORM VALIDATE-PASSWORD
                  END-IF
               END-PERFORM

               IF WS-EOF-FLAG NOT = 'Y' AND WS-VALID = 'Y'
                   OPEN EXTEND ACCOUNTS-FILE
                   MOVE WS-USERNAME TO ACCOUNT-USERNAME
                   MOVE WS-PASSWORD TO ACCOUNT-PASSWORD
                   WRITE ACCOUNT-RECORD
                   CLOSE ACCOUNTS-FILE

                   ADD 1 TO WS-ACCOUNT-COUNT
                   MOVE "Account successfully created!" TO WS-LAST-DISPLAY
                   PERFORM DISPLAY-AND-WRITE
               END-IF
           END-IF.
       
       VALIDATE-PASSWORD.
           MOVE "N" TO WS-VALID
           MOVE "N" TO WS-HAS-UPPER
           MOVE "N" TO WS-HAS-DIGIT
           MOVE "N" TO WS-HAS-SPECIAL
           MOVE 0 TO WS-LEN
           MOVE 0 TO WS-TRAIL-SP
           MOVE 0 TO WS-LEAD-SP

           INSPECT WS-PASSWORD TALLYING WS-TRAIL-SP FOR TRAILING SPACES
           INSPECT WS-PASSWORD TALLYING WS-LEAD-SP FOR LEADING SPACES
           INSPECT WS-PASSWORD TALLYING WS-LEN FOR CHARACTERS

           SUBTRACT WS-TRAIL-SP FROM WS-LEN GIVING WS-LEN
           SUBTRACT WS-LEAD-SP FROM WS-LEN GIVING WS-LEN
           IF WS-LEN < 8 OR WS-LEN > 12
              MOVE "Error: Password must be 8-12 characters long." TO WS-LAST-DISPLAY
              PERFORM DISPLAY-AND-WRITE
              EXIT PARAGRAPH
           END-IF

           PERFORM VARYING IDX FROM 1 BY 1 UNTIL IDX > WS-LEN
              EVALUATE TRUE
                 WHEN WS-PASSWORD(IDX:1) >= "A" AND WS-PASSWORD(IDX:1) <= "Z"
                    MOVE "Y" TO WS-HAS-UPPER
                 WHEN WS-PASSWORD(IDX:1) >= "0" AND WS-PASSWORD(IDX:1) <= "9"
                    MOVE "Y" TO WS-HAS-DIGIT
                 WHEN WS-PASSWORD(IDX:1) < "0" OR
                      WS-PASSWORD(IDX:1) > "9" AND
                      WS-PASSWORD(IDX:1) < "A" OR
                      WS-PASSWORD(IDX:1) > "Z" AND
                      WS-PASSWORD(IDX:1) < "a" OR
                      WS-PASSWORD(IDX:1) > "z"
                    MOVE "Y" TO WS-HAS-SPECIAL
              END-EVALUATE
           END-PERFORM

           IF WS-HAS-UPPER = "Y"
              AND WS-HAS-DIGIT = "Y"
              AND WS-HAS-SPECIAL = "Y"
              MOVE "Y" TO WS-VALID
           ELSE
             MOVE "Error: Password must include at least 1 uppercase, 1 digit, and 1 special character." TO WS-LAST-DISPLAY
             PERFORM DISPLAY-AND-WRITE
           END-IF.
       
       VALIDATE-LOGIN.
           MOVE 'N' TO WS-LOGIN-SUCCESS
           MOVE 'N' TO WS-ACCOUNTS-EOF
           
           OPEN INPUT ACCOUNTS-FILE
           
           PERFORM UNTIL WS-ACCOUNTS-EOF = 'Y' OR WS-LOGIN-SUCCESS = 'Y'
               READ ACCOUNTS-FILE INTO ACCOUNT-RECORD
                   AT END 
                       MOVE 'Y' TO WS-ACCOUNTS-EOF
                   NOT AT END
                       MOVE ACCOUNT-USERNAME TO WS-STORED-USERNAME
                       MOVE ACCOUNT-PASSWORD TO WS-STORED-PASSWORD
                       
                       IF WS-USERNAME = WS-STORED-USERNAME AND
                          WS-PASSWORD = WS-STORED-PASSWORD
                           MOVE 'Y' TO WS-LOGIN-SUCCESS
                       END-IF
               END-READ
           END-PERFORM
           
           CLOSE ACCOUNTS-FILE.
       
       DISPLAY-AND-WRITE.
           DISPLAY WS-LAST-DISPLAY
           MOVE WS-LAST-DISPLAY TO OUTPUT-RECORD
           WRITE OUTPUT-RECORD.
       
       WRITE-TO-OUTPUT.
           MOVE WS-LAST-DISPLAY TO OUTPUT-RECORD
           WRITE OUTPUT-RECORD.
       
       CLEANUP.
           CLOSE INPUT-FILE
           CLOSE OUTPUT-FILE.
		  

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
           DISPLAY "Welcome to InCollege!"
           PERFORM WRITE-TO-OUTPUT

           DISPLAY "Log In"
           PERFORM WRITE-TO-OUTPUT

           DISPLAY "Create New Account"
           PERFORM WRITE-TO-OUTPUT

           DISPLAY "Enter your choice:"
           PERFORM WRITE-TO-OUTPUT
           
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
                           DISPLAY "Invalid choice, please try again"
                           PERFORM WRITE-TO-OUTPUT
                   END-EVALUATE
           END-READ.
       
       LOGIN-PROCESS.
           MOVE 'N' TO WS-LOGIN-SUCCESS
           
           DISPLAY "Please enter your username:"
           PERFORM WRITE-TO-OUTPUT

           READ INPUT-FILE INTO WS-USERNAME
               AT END MOVE 'Y' TO WS-EOF-FLAG
           END-READ
           
           IF WS-EOF-FLAG NOT = 'Y'
               DISPLAY "Please enter your password:"
               PERFORM WRITE-TO-OUTPUT

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

                   DISPLAY WS-MESSAGE
                   MOVE WS-MESSAGE TO OUTPUT-RECORD
                   WRITE OUTPUT-RECORD
                   MOVE SPACES TO WS-MESSAGE

                   PERFORM POST-LOGIN-MENU
               ELSE
                   DISPLAY "Incorrect username/password, try again."
                   PERFORM WRITE-TO-OUTPUT
               END-IF
           END-IF.
		
       POST-LOGIN-MENU.
           DISPLAY "Search for a job"
           PERFORM WRITE-TO-OUTPUT

           DISPLAY "Find someone you know"
           PERFORM WRITE-TO-OUTPUT

           DISPLAY "Learn a new skill"
           PERFORM WRITE-TO-OUTPUT

           DISPLAY "Enter your choice:"
           PERFORM WRITE-TO-OUTPUT
           
           READ INPUT-FILE INTO WS-TEMP-INPUT
               AT END MOVE 'Y' TO WS-EOF-FLAG
               NOT AT END
                   MOVE WS-TEMP-INPUT(1:1) TO WS-USER-CHOICE
                   EVALUATE WS-USER-CHOICE
                       WHEN 1
                           DISPLAY "Job search under construction."
                           PERFORM WRITE-TO-OUTPUT
                       WHEN 2
                           DISPLAY "Find someone under construction."
                           PERFORM WRITE-TO-OUTPUT
                       WHEN 3
                           PERFORM LEARN-SKILL-MENU
                       WHEN OTHER
                           DISPLAY "Invalid choice, please try again"
                           PERFORM WRITE-TO-OUTPUT
                   END-EVALUATE
           END-READ.
       
       LEARN-SKILL-MENU.
           DISPLAY "Learn a New Skill"
           PERFORM WRITE-TO-OUTPUT

           DISPLAY "Skill 1"
           PERFORM WRITE-TO-OUTPUT

           DISPLAY "Skill 2"
           PERFORM WRITE-TO-OUTPUT

           DISPLAY "Skill 3"
           PERFORM WRITE-TO-OUTPUT

           DISPLAY "Skill 4"
           PERFORM WRITE-TO-OUTPUT

           DISPLAY "Skill 5"
           PERFORM WRITE-TO-OUTPUT

           DISPLAY "Go Back"
           PERFORM WRITE-TO-OUTPUT

           DISPLAY "Enter your choice:"
           PERFORM WRITE-TO-OUTPUT
           
           READ INPUT-FILE INTO WS-TEMP-INPUT
               AT END MOVE 'Y' TO WS-EOF-FLAG
               NOT AT END
                   MOVE WS-TEMP-INPUT(1:1) TO WS-USER-CHOICE
                   EVALUATE WS-USER-CHOICE
                       WHEN 1
                           DISPLAY "This skill is under construction."
                           PERFORM WRITE-TO-OUTPUT
                       WHEN 2
                           DISPLAY "This skill is under construction."
                           PERFORM WRITE-TO-OUTPUT
                       WHEN 3
                           DISPLAY "This skill is under construction."
                           PERFORM WRITE-TO-OUTPUT
                       WHEN 4
                           DISPLAY "This skill is under construction."
                           PERFORM WRITE-TO-OUTPUT
                       WHEN 5
                           DISPLAY "This skill is under construction."
                           PERFORM WRITE-TO-OUTPUT
                       WHEN 6
                           DISPLAY "Returning to main menu..."
                           PERFORM WRITE-TO-OUTPUT
                       WHEN OTHER
                           DISPLAY "Invalid choice, please try again"
                           PERFORM WRITE-TO-OUTPUT
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
              DISPLAY "All permitted accounts have been created, please come back later."
              PERFORM WRITE-TO-OUTPUT
              EXIT PARAGRAPH
           END-IF

           DISPLAY "Enter Username:"
           PERFORM WRITE-TO-OUTPUT
           READ INPUT-FILE INTO WS-USERNAME
               AT END MOVE 'Y' TO WS-EOF-FLAG
           END-READ

           IF WS-EOF-FLAG NOT = 'Y'
               MOVE "N" TO WS-VALID
               PERFORM UNTIL WS-VALID = "Y" OR WS-EOF-FLAG = 'Y'
                  DISPLAY "Enter Password:"
                  PERFORM WRITE-TO-OUTPUT
                  DISPLAY "(Password must be 8-12 characters long.)"
                  PERFORM WRITE-TO-OUTPUT
                  DISPLAY "(Password must include at least 1 uppercase, 1 digit, and 1 special character.)"
                  PERFORM WRITE-TO-OUTPUT
                  DISPLAY "(Leading and trailing spaces will be ignored.)"
                  PERFORM WRITE-TO-OUTPUT
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
                   DISPLAY "Account successfully created!"
                   PERFORM WRITE-TO-OUTPUT
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
              DISPLAY "Error: Password must be 8-12 characters long."
              PERFORM WRITE-TO-OUTPUT
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
             DISPLAY "Error: Password must include at least 1 uppercase, 1 digit, and 1 special character."
             PERFORM WRITE-TO-OUTPUT
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
       
       WRITE-TO-OUTPUT.
           MOVE SPACES TO OUTPUT-RECORD
           WRITE OUTPUT-RECORD.
       
       CLEANUP.
           CLOSE INPUT-FILE
           CLOSE OUTPUT-FILE.
		  

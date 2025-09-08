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
       01 WS-PASSWORD PIC X(12).
       01 WS-ACCOUNT-COUNT PIC 9(2) VALUE 0.
       01 WS-LOGIN-SUCCESS PIC X VALUE 'N'.
       01 WS-TEMP-INPUT PIC X(80).
       01 WS-STORED-USERNAME PIC X(20).
       01 WS-STORED-PASSWORD PIC X(12).
       
       PROCEDURE DIVISION.
       MAIN-LOGIC.
           PERFORM INITIALIZE-PROGRAM
           PERFORM MAIN-MENU UNTIL WS-EOF-FLAG = 'Y'
           PERFORM CLEANUP
           STOP RUN.
       
       INITIALIZE-PROGRAM.
           OPEN INPUT INPUT-FILE
           OPEN OUTPUT OUTPUT-FILE.
       
       MAIN-MENU.
           DISPLAY "Welcome to InCollege!"
           PERFORM WRITE-TO-OUTPUT
           DISPLAY "1. Log In"
           PERFORM WRITE-TO-OUTPUT
           DISPLAY "2. Create New Account"
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
                           DISPLAY "Create account feature coming soon"
                           PERFORM WRITE-TO-OUTPUT
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
                   DISPLAY "You have successfully logged in."
                   PERFORM WRITE-TO-OUTPUT
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
                           DISPLAY "Job search is under construction."
                           PERFORM WRITE-TO-OUTPUT
                       WHEN 2
                           DISPLAY "Find someone is under construction."
                           PERFORM WRITE-TO-OUTPUT
                       WHEN 3
                           DISPLAY "Learn skill is under construction."
                           PERFORM WRITE-TO-OUTPUT
                       WHEN OTHER
                           DISPLAY "Invalid choice, please try again"
                           PERFORM WRITE-TO-OUTPUT
                   END-EVALUATE
           END-READ.
       
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
           MOVE FUNCTION TRIM(FUNCTION REVERSE(
               FUNCTION TRIM(FUNCTION REVERSE(
               WS-TEMP-INPUT)))) TO OUTPUT-RECORD
           WRITE OUTPUT-RECORD.
       
       CLEANUP.
           CLOSE INPUT-FILE
           CLOSE OUTPUT-FILE.
		   
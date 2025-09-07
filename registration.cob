>>SOURCE FORMAT FREE
       IDENTIFICATION DIVISION.
       PROGRAM-ID. Registration.

       ENVIRONMENT DIVISION.
       INPUT-OUTPUT SECTION.
       FILE-CONTROL.
           SELECT AccountFile ASSIGN TO "accounts.dat"
               ORGANIZATION IS LINE SEQUENTIAL
               FILE STATUS IS WS-FILE-STATUS.

       DATA DIVISION.
       FILE SECTION.
       FD  AccountFile.
       01  Account-Record.
           05 Username   PIC X(20).
           05 Password   PIC X(12).

       WORKING-STORAGE SECTION.
       77  WS-Choice        PIC 9 VALUE 0.
       77  WS-Account-Count PIC 9 VALUE 0.
       77  WS-FILE-STATUS   PIC XX.
       77  WS-EOF           PIC X VALUE "N".
       77  WS-Valid         PIC X VALUE "N".
       77  WS-Has-Upper     PIC X VALUE "N".
       77  WS-Has-Digit     PIC X VALUE "N".
       77  WS-Has-Special   PIC X VALUE "N".
       77  WS-Len           PIC 99.
       77  WS-Trail-Sp      PIC 99.
       77  WS-Lead-Sp       PIC 99.
       77  IDX              PIC 99.

       01  WS-Username      PIC X(20).
       01  WS-Password      PIC X(12).

       01  WS-Existing-Record.
           05 EX-Username   PIC X(20).
           05 EX-Password   PIC X(12).

       PROCEDURE DIVISION.
       MAIN-PROCEDURE.
           PERFORM INIT-FILE

           PERFORM UNTIL WS-Choice = 9
              DISPLAY "1. Create Account"
              DISPLAY "9. Exit"
              ACCEPT WS-Choice
              EVALUATE WS-Choice
                 WHEN 1
                    PERFORM CREATE-ACCOUNT
                 WHEN 9
                    DISPLAY "Exiting..."
                 WHEN OTHER
                    DISPLAY "Invalid choice."
              END-EVALUATE
           END-PERFORM

           CLOSE AccountFile
           STOP RUN.

       INIT-FILE.
           OPEN INPUT AccountFile
           IF WS-FILE-STATUS NOT = "00"
              OPEN OUTPUT AccountFile
              CLOSE AccountFile
              OPEN INPUT AccountFile
           END-IF

           MOVE 0 TO WS-Account-Count
           MOVE "N" TO WS-EOF
           PERFORM UNTIL WS-EOF = "Y"
              READ AccountFile INTO WS-Existing-Record
                 AT END MOVE "Y" TO WS-EOF
                 NOT AT END ADD 1 TO WS-Account-Count
              END-READ
           END-PERFORM
           CLOSE AccountFile
           OPEN EXTEND AccountFile
           .

       CREATE-ACCOUNT.
           IF WS-Account-Count >= 5
              DISPLAY "All permitted accounts have been created, please come back later."
              EXIT PARAGRAPH
           END-IF

           DISPLAY "Enter Username:"
           ACCEPT WS-Username

           MOVE "N" TO WS-Valid
           PERFORM UNTIL WS-Valid = "Y"
              DISPLAY "Enter Password:"
              DISPLAY "(Password must be 8-12 characters long.)"
              DISPLAY "(Password must include at least 1 uppercase, 1 digit, and 1 special character.)"
              DISPLAY "(Leading and trailing spaces will be ignored.)"
              ACCEPT WS-Password
              PERFORM VALIDATE-PASSWORD
           END-PERFORM

           MOVE WS-Username TO Username
           MOVE WS-Password TO Password
           WRITE Account-Record

           ADD 1 TO WS-Account-Count
           DISPLAY "Account successfully created!"
           .

       VALIDATE-PASSWORD.
           MOVE "N" TO WS-Valid
           MOVE "N" TO WS-Has-Upper
           MOVE "N" TO WS-Has-Digit
           MOVE "N" TO WS-Has-Special
           MOVE 0 TO WS-Len
           MOVE 0 TO WS-Trail-Sp
           MOVE 0 TO WS-Lead-Sp

           INSPECT WS-Password TALLYING WS-Trail-Sp FOR TRAILING SPACES
           INSPECT WS-Password TALLYING WS-Lead-Sp FOR LEADING SPACES
           INSPECT WS-Password TALLYING WS-Len FOR CHARACTERS

           SUBTRACT WS-Trail-Sp FROM WS-Len GIVING WS-Len
           SUBTRACT WS-Lead-Sp FROM WS-Len GIVING WS-Len
           IF WS-Len < 8 OR WS-Len > 12
              DISPLAY "Error: Password must be 8-12 characters long."
              EXIT PARAGRAPH
           END-IF

           PERFORM VARYING IDX FROM 1 BY 1 UNTIL IDX > WS-Len
              EVALUATE TRUE
                 WHEN WS-Password(IDX:1) >= "A" AND WS-Password(IDX:1) <= "Z"
                    MOVE "Y" TO WS-Has-Upper
                 WHEN WS-Password(IDX:1) >= "0" AND WS-Password(IDX:1) <= "9"
                    MOVE "Y" TO WS-Has-Digit
                 WHEN WS-Password(IDX:1) < "0" OR
                      WS-Password(IDX:1) > "9" AND
                      WS-Password(IDX:1) < "A" OR
                      WS-Password(IDX:1) > "Z" AND
                      WS-Password(IDX:1) < "a" OR
                      WS-Password(IDX:1) > "z"
                    MOVE "Y" TO WS-Has-Special
              END-EVALUATE
           END-PERFORM

           IF WS-Has-Upper = "Y"
              AND WS-Has-Digit = "Y"
              AND WS-Has-Special = "Y"
              MOVE "Y" TO WS-Valid
           ELSE
             DISPLAY "Error: Password must include at least 1 uppercase, 1 digit, and 1 special character."
           END-IF
           .


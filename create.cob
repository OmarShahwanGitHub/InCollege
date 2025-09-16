       IDENTIFICATION DIVISION.
       PROGRAM-ID. CREATE_EDIT.

       ENVIRONMENT DIVISION.
       INPUT-OUTPUT SECTION.
       FILE-CONTROL.
           SELECT ACCOUNTS-FILE ASSIGN TO "accounts.doc"
               ORGANIZATION IS LINE SEQUENTIAL
               FILE STATUS IS WS-FILE-STATUS.
           SELECT PROFILE-FILE ASSIGN TO "profiles.doc"
               ORGANIZATION IS RELATIVE
               FILE STATUS IS WS-FILE-STATUS.

       DATA DIVISION.
       FILE SECTION.
       FD ACCOUNTS-FILE.
       01 ACCOUNT-RECORD.
           05 AC-USERNAME PIC X(20).
           05 AC-PASSWORD PIC X(12).

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
       77  WS-FILE-STATUS   PIC XX.

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

       01  MENU-CHOICE        PIC 9.
       01  LOGIN-USERNAME     PIC X(20).
       01  LOGIN-PASSWORD     PIC X(12).
       01  CURRENT-USERNAME   PIC X(20).
       01  ACCOUNT-COUNT      PIC 9 VALUE 0.
       01  FOUND-FLAG         PIC X VALUE "N".
       01  END-FILE           PIC X VALUE "N".

       PROCEDURE DIVISION.
       MAIN-PROCEDURE.
           PERFORM INIT
           PERFORM MAIN-MENU UNTIL MENU-CHOICE = 9.
           STOP RUN.

       INIT.
           OPEN INPUT PROFILE-FILE
           IF WS-FILE-STATUS NOT = "00"
              OPEN OUTPUT PROFILE-FILE
              CLOSE PROFILE-FILE
              OPEN INPUT PROFILE-FILE
           END-IF
           CLOSE PROFILE-FILE
           .

       MAIN-MENU.
           DISPLAY "==== INCOLLEGE MAIN MENU ===="
           DISPLAY "2. Login"
           DISPLAY "9. Exit"
           ACCEPT MENU-CHOICE
           EVALUATE MENU-CHOICE
               WHEN 2 PERFORM LOGIN
               WHEN 9 CONTINUE
               WHEN OTHER DISPLAY "Invalid choice."
           END-EVALUATE.

       LOGIN.
           DISPLAY "Enter Username: "
           ACCEPT LOGIN-USERNAME
           DISPLAY "Enter Password: "
           ACCEPT LOGIN-PASSWORD
           MOVE "N" TO FOUND-FLAG
           MOVE "N" TO END-FILE
           OPEN INPUT ACCOUNTS-FILE
           PERFORM UNTIL FOUND-FLAG = "Y" OR END-FILE = "Y"
               READ ACCOUNTS-FILE
                   AT END MOVE "Y" TO END-FILE
                   NOT AT END
                       DISPLAY AC-USERNAME LOGIN-USERNAME 
                       DISPLAY AC-PASSWORD LOGIN-PASSWORD
                       IF AC-USERNAME = LOGIN-USERNAME AND
                          AC-PASSWORD = LOGIN-PASSWORD
                           MOVE "Y" TO FOUND-FLAG
                           MOVE LOGIN-USERNAME TO CURRENT-USERNAME
                       END-IF
               END-READ
           END-PERFORM
           CLOSE ACCOUNTS-FILE
           IF FOUND-FLAG = "Y"
               DISPLAY "Login successful."
               PERFORM PROFILE-MENU
           ELSE
               DISPLAY "Invalid login."
           END-IF
           .

       PROFILE-MENU.
           DISPLAY "==== PROFILE MENU ===="
           DISPLAY "1. Create/Edit My Profile"
           DISPLAY "9. Logout"
           ACCEPT MENU-CHOICE
           EVALUATE MENU-CHOICE
               WHEN 1 PERFORM CREATE-EDIT-PROFILE
               WHEN 9 CONTINUE
               WHEN OTHER DISPLAY "Invalid choice."
           END-EVALUATE.

       CREATE-EDIT-PROFILE.
      *> DONT FORGET TO ADD GRADYEAR VALIDATION
           MOVE "N" TO FOUND-FLAG
           MOVE "N" TO END-FILE

           OPEN I-O PROFILE-FILE
           PERFORM UNTIL END-FILE = "Y" OR FOUND-FLAG = "Y"
               READ PROFILE-FILE
                   AT END MOVE "Y" TO END-FILE
                   NOT AT END
                       IF PR-USERNAME = CURRENT-USERNAME
                           MOVE "Y" TO FOUND-FLAG
                           DISPLAY "Profile found. Editing"
      *>DISPLAY PROFILE IF FOUND
                       END-IF
               END-READ
           END-PERFORM

           IF FOUND-FLAG = "N"
      *>        If no profile, start a fresh one
               MOVE CURRENT-USERNAME TO PR-USERNAME
               DISPLAY "Profile not found. Create a new account"
           END-IF

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

           DISPLAY "Enter First Name: "
      *>REQUIRED
           IF FOUND-FLAG = "Y" OR
             PR-FIRST-NAME NOT = SPACES AND
             PR-FIRST-NAME NOT = LOW-VALUE
               display FOUND-FLAG "(" PR-FIRST-NAME ")"
               DISPLAY "(blank = keep: " PR-FIRST-NAME ")"
           END-IF
           ACCEPT TEMP-FIRST-NAME
           IF TEMP-FIRST-NAME NOT = SPACES
               MOVE TEMP-FIRST-NAME TO PR-FIRST-NAME
           END-IF

           DISPLAY "Enter Last Name: "
      *>REQUIRED
           IF FOUND-FLAG = "Y" OR
             PR-LAST-NAME NOT EQUAL SPACES AND
             PR-LAST-NAME NOT = LOW-VALUE
               DISPLAY "(blank = keep: " PR-LAST-NAME ")"
           END-IF
           ACCEPT TEMP-LAST-NAME
           IF TEMP-LAST-NAME NOT = SPACES
               MOVE TEMP-LAST-NAME TO PR-LAST-NAME
           END-IF

           DISPLAY "Enter University: "
      *>REQUIRED
           IF FOUND-FLAG = "Y" OR
             PR-UNIVERSITY NOT EQUAL SPACES AND
             PR-UNIVERSITY NOT = LOW-VALUE
               DISPLAY "(blank = keep: " PR-UNIVERSITY ")"
           END-IF
           ACCEPT TEMP-UNIVERSITY
           IF TEMP-UNIVERSITY NOT = SPACES
               MOVE TEMP-UNIVERSITY TO PR-UNIVERSITY
           END-IF

           DISPLAY "Enter Major: "
      *>REQUIRED
           IF FOUND-FLAG = "Y" OR
             PR-MAJOR NOT EQUAL SPACES AND
             PR-MAJOR NOT = LOW-VALUE
               DISPLAY "(blank = keep: " PR-MAJOR ")"
           END-IF
           ACCEPT TEMP-MAJOR
           IF TEMP-MAJOR NOT = SPACES
               MOVE TEMP-MAJOR TO PR-MAJOR
           END-IF

           DISPLAY "Enter Graduation Year: "
      *>REQUIRED
           IF FOUND-FLAG = "Y" OR
             PR-GRAD-YEAR NOT EQUAL SPACES AND
             PR-GRAD-YEAR NOT = LOW-VALUE
               DISPLAY "(blank = keep: " PR-GRAD-YEAR ")"
           END-IF
           ACCEPT TEMP-GRAD-YEAR
           IF TEMP-GRAD-YEAR NOT = SPACES
               MOVE FUNCTION NUMVAL(TEMP-GRAD-YEAR) TO PR-GRAD-YEAR
           END-IF

           DISPLAY "About Me (optional, blank = skip): "
           ACCEPT TEMP-ABOUT-ME
           IF TEMP-ABOUT-ME NOT = SPACES
               MOVE TEMP-ABOUT-ME TO PR-ABOUT-ME
           END-IF

           DISPLAY "Experience 1 (optional, blank = skip): "
           ACCEPT TEMP-EXP (1)
           IF TEMP-EXP (1) NOT = SPACES
               MOVE TEMP-EXP (1) TO PR-EXP (1)
           END-IF

           DISPLAY "Experience 2 (optional, blank = skip): "
           ACCEPT TEMP-EXP (2)
           IF TEMP-EXP (2) NOT = SPACES
               MOVE TEMP-EXP (2) TO PR-EXP (2)
           END-IF

           DISPLAY "Experience 3 (optional, blank = skip): "
           ACCEPT TEMP-EXP (3)
           IF TEMP-EXP (3) NOT = SPACES
               MOVE TEMP-EXP (3) TO PR-EXP (3)
           END-IF

           DISPLAY "Education 1 (optional, blank = skip): "
           ACCEPT TEMP-EDU (1)
           IF TEMP-EDU (1) NOT = SPACES
               MOVE TEMP-EDU (1) TO PR-EDU (1)
           END-IF

           DISPLAY "Education 2 (optional, blank = skip): "
           ACCEPT TEMP-EDU (2)
           IF TEMP-EDU (2) NOT = SPACES
               MOVE TEMP-EDU (2) TO PR-EDU (2)
           END-IF

           DISPLAY "Education 3 (optional, blank = skip): "
           ACCEPT TEMP-EDU (3)
           IF TEMP-EDU (3) NOT = SPACES
               MOVE TEMP-EDU (3) TO PR-EDU (3)
           END-IF

           IF FOUND-FLAG = "Y"
               REWRITE PROFILE-RECORD
               DISPLAY "Profile updated successfully."
           ELSE
               CLOSE PROFILE-FILE
               OPEN EXTEND PROFILE-FILE
               WRITE PROFILE-RECORD
               DISPLAY "Profile created successfully."
           END-IF
           CLOSE PROFILE-FILE
           DISPLAY "Profile saved successfully.".

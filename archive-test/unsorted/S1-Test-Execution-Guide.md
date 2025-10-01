# Story S1: View Complete Saved Profile - Test Execution Guide

## Test Setup
1. Ensure `InCollege-Epic3.cob` is compiled and ready to run
2. Make sure `accounts.doc` contains testuser with password "Password123!"

## Test Cases

### Test Case 1: Complete Profile View
**Input File:** `S1-View-Complete-Profile-Test-Input.txt`
**Expected:** All profile fields displayed with proper formatting

**Steps:**
1. Copy `S1-View-Complete-Profile-Test-Input.txt` to `InCollege-Input.txt`
2. Run the program
3. Compare console output with `InCollege-Output.txt`
4. Verify all acceptance criteria are met

### Test Case 2: Minimal Profile View
**Input File:** `S1-Minimal-Profile-Test-Input.txt`
**Expected:** Only required fields displayed, optional fields skipped or shown as "None"

### Test Case 3: No Experience Profile
**Input File:** `S1-No-Experience-Test-Input.txt`
**Expected:** Experience section shows "None" or is skipped

### Test Case 4: No Education Profile
**Input File:** `S1-No-Education-Test-Input.txt`
**Expected:** Education section shows "None" or is skipped

## Acceptance Criteria Verification

### ✅ All Profile Fields Displayed
- [ ] First Name and Last Name
- [ ] University/College
- [ ] Major
- [ ] Graduation Year
- [ ] About Me (if not empty)
- [ ] Experience entries (if any)
- [ ] Education entries (if any)

### ✅ Proper Formatting
- [ ] "==== YOUR PROFILE ====" header
- [ ] "--- END OF PROFILE VIEW ---" footer
- [ ] Each field on separate line with clear labels
- [ ] Consistent spacing and alignment

### ✅ Empty Sections Handling
- [ ] "None" shown for empty Experience sections
- [ ] "None" shown for empty Education sections
- [ ] About Me section skipped if empty

### ✅ I/O Consistency
- [ ] Console output matches file output exactly
- [ ] No differences in formatting, spacing, or content
- [ ] All prompts and messages captured

### ✅ Menu Integration
- [ ] Option 2 navigates to profile view
- [ ] Returns to main menu after viewing
- [ ] Menu flow works correctly

## Bug Reporting Template
If any test fails, document:
- **Test Case:** [Which test case failed]
- **Expected Result:** [What should have happened]
- **Actual Result:** [What actually happened]
- **Console Output:** [Screenshot or text]
- **File Output:** [Contents of InCollege-Output.txt]
- **Differences:** [Specific differences found]

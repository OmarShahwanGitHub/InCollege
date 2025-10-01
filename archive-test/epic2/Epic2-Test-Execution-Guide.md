# Epic 2: Test Execution Guide

## Prerequisites
1. Ensure `InCollege_Profiles.cob` is the active program
2. Ensure `accounts.doc` exists with test user accounts
3. Clear any existing `profiles.doc` file for clean testing
4. Clear any existing `InCollege-Output.txt` file

## Test Execution Steps

### Test 1: Story 1 - Profile Creation (Positive Test)
1. Copy `Epic2-Story1-Test-Input.txt` to `InCollege-Input.txt`
2. Run the COBOL program
3. Verify output matches `Epic2-Story1-Expected-Output.txt`
4. Check that `profiles.doc` contains the new profile data
5. Verify I/O consistency (screen output = file output)

### Test 2: Story 1 - Profile Creation (Negative Test)
1. Copy `Epic2-Story1-Negative-Test-Input.txt` to `InCollege-Input.txt`
2. Run the COBOL program
3. Verify error handling for missing required fields
4. Check that program prompts for required field again
5. Verify I/O consistency

### Test 3: Story 1 - Profile Creation (Edge Test)
1. Copy `Epic2-Story1-Edge-Test-Input.txt` to `InCollege-Input.txt`
2. Run the COBOL program
3. Verify maximum experience and education entries are handled
4. Check profile data integrity
5. Verify I/O consistency

### Test 4: Story 1 - Profile Creation (Validation Test)
1. Copy `Epic2-Story1-Validation-Test-Input.txt` to `InCollege-Input.txt`
2. Run the COBOL program
3. Verify graduation year validation (1800 should be rejected)
4. Check that program prompts for valid year
5. Verify I/O consistency

### Test 5: Story 2 - Profile Editing
1. Copy `Epic2-Story2-Test-Input.txt` to `InCollege-Input.txt`
2. Run the COBOL program
3. Verify existing profile is found and loaded
4. Check that updated information is saved
5. Verify I/O consistency

### Test 6: Story 3 - Profile Viewing
1. Copy `Epic2-Story3-Test-Input.txt` to `InCollege-Input.txt`
2. Run the COBOL program
3. Verify profile information is displayed correctly
4. Check output format matches expected format
5. Verify I/O consistency

### Test 7: Story 4 - Profile Persistence
1. Copy `Epic2-Story4-Test-Input.txt` to `InCollege-Input.txt`
2. Run the COBOL program
3. Verify profile data is saved to `profiles.doc`
4. Restart program and verify data is retrievable
5. Verify I/O consistency

### Test 8: Boundary Testing
1. Copy `Epic2-Story1-Boundary-Test-Input.txt` to `InCollege-Input.txt`
2. Run the COBOL program
3. Verify minimum field lengths are handled
4. Check boundary year values (1925, 2035)
5. Verify I/O consistency

### Test 9: Maximum Length Testing
1. Copy `Epic2-Story1-MaxLength-Test-Input.txt` to `InCollege-Input.txt`
2. Run the COBOL program
3. Verify maximum field lengths are handled
4. Check for truncation or overflow issues
5. Verify I/O consistency

### Test 10: Special Characters Testing
1. Copy `Epic2-Story1-SpecialChars-Test-Input.txt` to `InCollege-Input.txt`
2. Run the COBOL program
3. Verify special characters are handled properly
4. Check data integrity with special characters
5. Verify I/O consistency

## Verification Checklist

For each test, verify:
- [ ] Program executes without crashes
- [ ] All expected output is generated
- [ ] Screen output matches file output exactly
- [ ] Profile data is saved correctly to `profiles.doc`
- [ ] Input validation works as expected
- [ ] Error messages are appropriate
- [ ] Program handles edge cases gracefully

## Bug Documentation

If any issues are found:
1. Document the bug using the template in `Epic2-Test-Plan.md`
2. Capture the actual output file
3. Note the input file used
4. Describe the expected vs actual behavior
5. Assign appropriate severity level

## Test Results Summary

After completing all tests, create a summary document including:
- Total tests executed
- Tests passed
- Tests failed
- Bugs found
- Overall assessment of profile management functionality

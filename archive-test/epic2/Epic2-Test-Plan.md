# Epic 2: User Profile Management - Test Plan

## Test Overview
This test plan covers comprehensive testing of the InCollege profile management system including profile creation, editing, viewing, and persistence functionality.

## Test Environment Setup
- **Program**: InCollege_Profiles.cob
- **Input File**: InCollege-Input.txt
- **Output File**: InCollege-Output.txt
- **Profile Storage**: profiles.doc
- **Account Storage**: accounts.doc

## Test Cases

### Story 1: Create Profile (IC-38)

#### Test Case 1.1: Positive Test - Complete Profile Creation
**Input File**: Epic2-Story1-Test-Input.txt
**Description**: Test successful profile creation with all required fields and optional fields
**Expected Results**:
- Profile created successfully
- All required fields saved (First Name, Last Name, University, Major, Graduation Year)
- Optional fields saved (About Me, Experience, Education)
- Profile data persisted to profiles.doc
- Output matches screen display

#### Test Case 1.2: Negative Test - Missing Required Fields
**Input File**: Epic2-Story1-Negative-Test-Input.txt
**Description**: Test profile creation with missing required fields
**Expected Results**:
- Error message for missing First Name
- Program prompts for required field again
- Profile creation fails until all required fields provided

#### Test Case 1.3: Edge Test - Maximum Optional Fields
**Input File**: Epic2-Story1-Edge-Test-Input.txt
**Description**: Test profile creation with maximum number of experience and education entries
**Expected Results**:
- Profile created with 3 experience entries
- Profile created with 3 education entries
- All data properly saved and formatted

#### Test Case 1.4: Validation Test - Invalid Graduation Year
**Input File**: Epic2-Story1-Validation-Test-Input.txt
**Description**: Test graduation year validation with invalid year
**Expected Results**:
- Error message for invalid graduation year (1800)
- Program prompts for valid year (1925-2035)
- Profile creation continues after valid year entered

### Story 2: Edit Profile (IC-39)

#### Test Case 2.1: Profile Editing
**Input File**: Epic2-Story2-Test-Input.txt
**Description**: Test editing existing profile with updated information
**Expected Results**:
- Existing profile found and loaded
- Updated information saved correctly
- Profile updated successfully message displayed
- Changes persisted to profiles.doc

### Story 3: View Profile (IC-40)

#### Test Case 3.1: Profile Viewing
**Input File**: Epic2-Story3-Test-Input.txt
**Description**: Test viewing existing profile
**Expected Results**:
- Profile information displayed correctly
- All fields shown in proper format
- Output matches expected format from assignment

### Story 4: Save Profile Permanently (IC-41)

#### Test Case 4.1: Profile Persistence
**Input File**: Epic2-Story4-Test-Input.txt
**Description**: Test profile persistence across program restarts
**Expected Results**:
- Profile data saved to profiles.doc
- Data retrievable after program restart
- No data loss or corruption

## I/O Consistency Tests

### Test Case I/O-1: Input/Output File Consistency
**Description**: Verify that all screen output is identical to output file
**Expected Results**:
- Every line displayed on screen is written to InCollege-Output.txt
- No additional or missing lines in output file
- Character-by-character match between screen and file output

### Test Case I/O-2: File-Based Input Processing
**Description**: Verify all user input is read from input file
**Expected Results**:
- All prompts answered using input file data
- No manual user interaction required
- Program processes complete input sequence

## Data Validation Tests

### Test Case VAL-1: Required Field Validation
**Description**: Test validation of required fields
**Expected Results**:
- First Name: Required, non-empty
- Last Name: Required, non-empty
- University: Required, non-empty
- Major: Required, non-empty
- Graduation Year: Required, numeric, 1925-2035

### Test Case VAL-2: Optional Field Handling
**Description**: Test handling of optional fields
**Expected Results**:
- About Me: Optional, can be blank
- Experience entries: Optional, up to 3, can be blank
- Education entries: Optional, up to 3, can be blank

### Test Case VAL-3: Data Type Validation
**Description**: Test data type validation
**Expected Results**:
- Graduation Year: Must be numeric
- Text fields: Accept alphanumeric characters
- Proper handling of special characters

## Error Handling Tests

### Test Case ERR-1: Invalid Menu Choices
**Description**: Test handling of invalid menu selections
**Expected Results**:
- Invalid choice error message
- Program returns to menu
- No program crash

### Test Case ERR-2: File I/O Errors
**Description**: Test handling of file I/O issues
**Expected Results**:
- Graceful handling of missing files
- Proper file creation if needed
- Error messages for critical failures

## Performance Tests

### Test Case PERF-1: Large Data Handling
**Description**: Test handling of maximum field lengths
**Expected Results**:
- All fields accept maximum allowed characters
- No truncation or overflow issues
- Proper data storage and retrieval

## Test Execution Checklist

- [ ] All test input files created
- [ ] Test environment prepared
- [ ] Each test case executed
- [ ] Output files captured
- [ ] Results compared to expected outcomes
- [ ] I/O consistency verified
- [ ] Bugs documented and reported
- [ ] Test results summarized

## Bug Reporting Template

**Bug ID**: [Unique identifier]
**Severity**: [Critical/High/Medium/Low]
**Component**: [Profile Creation/Editing/Viewing/Persistence]
**Description**: [Brief description of the issue]
**Steps to Reproduce**:
1. [Step 1]
2. [Step 2]
3. [Step 3]
**Expected Result**: [What should happen]
**Actual Result**: [What actually happened]
**Input File Used**: [Test input file name]
**Output File**: [Generated output file name]
**Screenshots/Logs**: [If applicable]

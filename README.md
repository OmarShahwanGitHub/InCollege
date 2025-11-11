# InCollege Week 9 - View Messages

## Setup

Compile:
```
cobc -x -free InCollege.cob
./InCollege
```

Input comes from InCollege-Input.txt, output goes to InCollege-Output.txt

## What We Added This Week

Added message viewing so users can see messages sent to them.

Go to Messages menu (option 8) then pick View My Messages (option 2).

If you have messages it shows:
```
--- Your Messages ---
From: username
Message: message text
---
```

If not: "You have no messages."

## Testing

Need to test:
1. User with messages - should show all their messages
2. User with no messages - should say no messages
3. Messages should persist after restarting the program  
4. Users should only see their own messages
5. Console output and file output should match exactly

## Files

messages.doc format: sender(20) + recipient(20) + message(200) + timestamp(20) = 260 chars per line

accounts.doc format: username(20) + password(12) = 32 chars per line

## Notes

Integrates with everything from previous weeks - login, profiles, connections, jobs, sending messages.

Make sure to check that console and file outputs are identical when testing.

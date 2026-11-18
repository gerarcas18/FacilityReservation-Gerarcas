# Functional Test Results

Run these tests with separate Administrator, Facility Staff, and Requester accounts. Record the actual result and evidence. Do not mark PASS until the test has been performed.

| Test ID | Scenario | Expected Result | Result |
|---|---|---|---|
| TC-B4-01 | Requester submits reservation | Saved as Pending | Not yet tested |
| TC-B4-02 | Submit overlapping schedule | Conflict detected and blocked | Not yet tested |
| TC-B4-03 | Administrator approves | Status changes to Approved | Not yet tested |
| TC-B4-04 | Administrator rejects | Status changes to Rejected | Not yet tested |
| TC-B4-05 | Staff marks reservation In Use | Status changes to In Use | Not yet tested |
| TC-B4-06 | Staff completes reservation | Status changes to Completed | Not yet tested |
| TC-B4-07 | Requester attempts another user's request | Access is blocked | Not yet tested |
| TC-B4-08 | Reserve facility under maintenance | Request is blocked | Not yet tested |
| TC-B4-09 | View audit log after status change | Actor/action/time are recorded | Not yet tested |
| TC-B4-10 | Open protected application without login | Login required / access denied | Not yet tested |

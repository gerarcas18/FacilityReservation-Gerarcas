# Business Rules

| ID | Business Rule | Enforcement |
|---|---|---|
| BR-B4-01 | Only active facilities may be reserved. | UI and database trigger |
| BR-B4-02 | Reservation start must precede its end. | UI and database constraint |
| BR-B4-03 | Overlapping approved, scheduled, or in-use reservations are prohibited for the same facility. | PostgreSQL exclusion constraint |
| BR-B4-04 | Only an Administrator may approve or reject a reservation. | Row-level security and trigger |
| BR-B4-05 | A rejected reservation cannot proceed to Scheduled. | Database workflow validation |
| BR-B4-06 | Approved reservations reserve their time slot. | Exclusion constraint |
| BR-B4-07 | Completed reservations cannot be reopened through ordinary status updates. | Database workflow validation |
| BR-B4-08 | Maintenance and inactive facilities cannot be reserved. | UI and database trigger |
| BR-B4-09 | Requesters may cancel only their own eligible Pending requests. | Row-level security and trigger |
| BR-B4-10 | Critical reservation status changes are recorded in the audit log. | Database audit trigger |

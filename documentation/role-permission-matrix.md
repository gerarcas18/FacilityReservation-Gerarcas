# Role-Permission Matrix

| Function | Administrator | Facility Staff | Requester |
|---|---|---|---|
| View facilities | Yes | Yes | Yes |
| Manage facilities | Yes | No | No |
| View all reservations | Yes | Yes | Own only |
| Submit reservation | No | No | Yes |
| Approve / reject reservations | Yes | No | No |
| Mark In Use / Completed | No | Yes | No |
| Cancel own Pending request | No | No | Yes |
| View audit logs / user directory | Yes | No | No |
| Manage service concerns | View | Create/update (schema provided; UI pending) | No |

## Reservation Workflow

Reservation Submitted → Pending → Administrator Review → Approved or Rejected.

Approved → Scheduled → In Use → Completed.

A requester may cancel their own eligible Pending request. A reservation cannot be scheduled if its facility/time slot conflicts with another active reservation.

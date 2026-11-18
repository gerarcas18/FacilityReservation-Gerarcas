# Use Cases

## Actors and use cases

| Actor | Use Cases |
|---|---|
| Administrator | Login, logout, manage facilities, manage user roles, review reservations, approve, reject, view audit logs, view service concerns |
| Facility Staff | Login, logout, view reservations, confirm facility usage, mark In Use, complete reservation, create service request, update facility condition |
| Requester | Login, logout, view facilities, submit reservation, view status/history, cancel eligible own request |

## Detailed use cases

### UC-B4-01 — Submit Facility Reservation
**Primary actor:** Requester  
**Preconditions:** User is authenticated; selected facility is Active.  
**Main flow:** Requester selects a facility, enters start/end time and purpose, submits the form, and the system validates the input and schedule. A valid request is saved with Pending status.  
**Alternate flow:** Missing fields, invalid time range, inactive facility, or conflicting schedule causes the request to be rejected with an explanatory message.  
**Postcondition:** A Pending reservation is recorded.

### UC-B4-02 — Review Reservation
**Primary actor:** Administrator  
**Preconditions:** Administrator is authenticated; reservation is Pending.  
**Main flow:** Administrator opens the reservation, reviews its details, and approves or rejects it. The system validates the role and workflow, updates the status, and records an audit entry.  
**Alternate flow:** Unauthorized users or invalid status transitions are blocked.  
**Postcondition:** Reservation is Approved or Rejected and the action is auditable.

## Relationships
A Facility can have many Reservations over time. Each Reservation references one Facility and one Requester. Audit Logs record critical actions by an actor.

# FacilityFlow — Laboratory 4, Section B
Role-Based Facility Reservation and Approval System

## Stack
HTML, CSS, JavaScript, Supabase Authentication, PostgreSQL, GitHub Pages.

## Setup
1. Create a **separate Supabase project** for this activity.
2. Open Supabase SQL Editor and run `database/schema.sql`.
3. Copy the project's URL and publishable key into `js/config.js`. Never put a service-role key in browser code.
4. In Supabase Authentication, create test accounts for Administrator, Facility Staff, and Requester.
5. Assign roles in SQL Editor, replacing the sample emails:
   ```sql
   update public.profiles set role = 'administrator' where email = 'admin@example.com';
   update public.profiles set role = 'facility_staff' where email = 'staff@example.com';
   ```
   The default role for new accounts is `requester`.
6. In GitHub, open Settings → Pages and select **GitHub Actions** as the build and deployment source.
7. Wait for the Pages workflow to finish. The live URL will be `https://gerarcas18.github.io/FacilityReservation-Gerarcas/`.

## Included
- Role-specific navigation for Administrator, Facility Staff, and Requester
- Facility management and facility condition checks
- Reservation submission, administrator approval/rejection, staff usage/completion updates
- Schedule overlap protection in the database
- Audit log and user-role directory
- SQL schema, role matrix, ERD, use cases, business rules, and functional test checklist

## Important setup notes
The application cannot connect until `js/config.js` contains your own Supabase project URL and publishable key. The database must be initialized before login. Use separate test accounts to verify each role. Functional test results are intentionally marked **Not yet tested** until you perform them.

The service-concern table is included in the database design; its full management interface is not yet implemented in this version. Do not submit test results as PASS unless you have actually completed each test.

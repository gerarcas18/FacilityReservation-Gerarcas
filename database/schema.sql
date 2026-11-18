create extension if not exists btree_gist;

create table if not exists public.profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  full_name text not null default '',
  email text,
  role text not null default 'requester' check (role in ('administrator','facility_staff','requester')),
  created_at timestamptz default now()
);
create table if not exists public.facilities (
  id uuid primary key default gen_random_uuid(),
  name text not null,
  location text,
  description text,
  condition text not null default 'Active' check (condition in ('Active','Maintenance','Inactive')),
  created_at timestamptz default now()
);
create table if not exists public.reservations (
  id uuid primary key default gen_random_uuid(),
  facility_id uuid not null references public.facilities(id) on delete restrict,
  requester_id uuid not null references public.profiles(id),
  start_time timestamptz not null,
  end_time timestamptz not null,
  purpose text not null,
  status text not null default 'Pending' check (status in ('Pending','Approved','Rejected','Scheduled','In Use','Completed','Cancelled')),
  reviewed_by uuid references public.profiles(id),
  reviewed_at timestamptz,
  created_at timestamptz default now(),
  check (start_time < end_time)
);
create table if not exists public.audit_logs (
  id bigint generated always as identity primary key,
  actor_id uuid references public.profiles(id),
  action text not null,
  entity text,
  entity_id uuid,
  details jsonb default '{}'::jsonb,
  created_at timestamptz default now()
);
create table if not exists public.service_concerns (
  id uuid primary key default gen_random_uuid(),
  facility_id uuid references public.facilities(id),
  reported_by uuid references public.profiles(id),
  description text not null,
  status text not null default 'Open' check (status in ('Open','In Progress','Resolved')),
  created_at timestamptz default now()
);

create or replace function public.current_role()
returns text language sql stable security definer set search_path=public
as $$ select role from public.profiles where id=auth.uid() $$;

create or replace function public.enforce_reservation_rules()
returns trigger language plpgsql security definer set search_path=public
as $$
declare facility_condition text; actor_role text;
begin
  actor_role := public.current_role();
  if tg_op = 'INSERT' then
    select condition into facility_condition from public.facilities where id=new.facility_id;
    if facility_condition is distinct from 'Active' then raise exception 'Only Active facilities may be reserved'; end if;
    if new.requester_id <> auth.uid() or new.status <> 'Pending' then raise exception 'Requester may submit only their own Pending request'; end if;
  else
    if old.status = 'Completed' then raise exception 'Completed reservations cannot be edited'; end if;
    if actor_role = 'requester' and (old.requester_id <> auth.uid() or old.status <> 'Pending') then
      raise exception 'Requesters may edit only their own Pending requests';
    end if;
    if new.facility_id is distinct from old.facility_id or new.requester_id is distinct from old.requester_id then
      if actor_role <> 'administrator' then raise exception 'Only Administrator may change reservation ownership or facility'; end if;
    end if;
    if new.status is distinct from old.status then
      if new.status in ('Approved','Rejected','Scheduled') and actor_role <> 'administrator' then
        raise exception 'Only Administrator may approve, reject, or schedule';
      end if;
      if new.status in ('In Use','Completed') and actor_role <> 'facility_staff' then
        raise exception 'Only Facility Staff may update usage and completion';
      end if;
      if actor_role = 'requester' and not (old.status = 'Pending' and new.status = 'Cancelled') then
        raise exception 'Requester may only cancel own Pending request';
      end if;
      if old.status = 'Rejected' and new.status = 'Scheduled' then raise exception 'Rejected reservations cannot be Scheduled'; end if;
    end if;
  end if;
  select condition into facility_condition from public.facilities where id=new.facility_id;
  if facility_condition is distinct from 'Active' and new.status in ('Pending','Approved','Scheduled','In Use') then
    raise exception 'Facility is not Active';
  end if;
  return new;
end $$;
drop trigger if exists reservation_guard on public.reservations;
create trigger reservation_guard before insert or update on public.reservations
for each row execute function public.enforce_reservation_rules();

alter table public.reservations drop constraint if exists reservations_no_overlap;
alter table public.reservations add constraint reservations_no_overlap
exclude using gist (facility_id with =, tstzrange(start_time,end_time,'[)') with &&)
where (status in ('Approved','Scheduled','In Use'));

create or replace function public.audit_reservation()
returns trigger language plpgsql security definer set search_path=public
as $$
begin
  if tg_op='INSERT' then
    insert into public.audit_logs(actor_id,action,entity,entity_id,details)
    values(auth.uid(),'reservation_submitted','reservations',new.id,jsonb_build_object('status',new.status));
  elsif old.status is distinct from new.status then
    insert into public.audit_logs(actor_id,action,entity,entity_id,details)
    values(auth.uid(),'reservation_status_changed','reservations',new.id,jsonb_build_object('from',old.status,'to',new.status));
  end if;
  return new;
end $$;
drop trigger if exists reservation_audit on public.reservations;
create trigger reservation_audit after insert or update on public.reservations
for each row execute function public.audit_reservation();

create or replace function public.new_profile()
returns trigger language plpgsql security definer set search_path=public
as $$
begin
  insert into public.profiles(id,full_name,email,role)
  values(new.id,coalesce(new.raw_user_meta_data->>'full_name',''),new.email,'requester');
  return new;
end $$;
drop trigger if exists auth_profile_created on auth.users;
create trigger auth_profile_created after insert on auth.users
for each row execute function public.new_profile();

alter table public.profiles enable row level security;
alter table public.facilities enable row level security;
alter table public.reservations enable row level security;
alter table public.audit_logs enable row level security;
alter table public.service_concerns enable row level security;

drop policy if exists "read profiles" on public.profiles;
create policy "read profiles" on public.profiles for select to authenticated using (true);
drop policy if exists "admin profile management" on public.profiles;
create policy "admin profile management" on public.profiles for update to authenticated using (public.current_role()='administrator') with check (public.current_role()='administrator');
drop policy if exists "read facilities" on public.facilities;
create policy "read facilities" on public.facilities for select to authenticated using (true);
drop policy if exists "admin facility insert" on public.facilities;
create policy "admin facility insert" on public.facilities for insert to authenticated with check (public.current_role()='administrator');
drop policy if exists "admin facility update" on public.facilities;
create policy "admin facility update" on public.facilities for update to authenticated using (public.current_role()='administrator') with check (public.current_role()='administrator');
drop policy if exists "admin facility delete" on public.facilities;
create policy "admin facility delete" on public.facilities for delete to authenticated using (public.current_role()='administrator');

drop policy if exists "reservation visibility" on public.reservations;
create policy "reservation visibility" on public.reservations for select to authenticated
using (requester_id=auth.uid() or public.current_role() in ('administrator','facility_staff'));
drop policy if exists "requester insert" on public.reservations;
create policy "requester insert" on public.reservations for insert to authenticated
with check (requester_id=auth.uid() and status='Pending' and public.current_role()='requester');
drop policy if exists "requester update own pending" on public.reservations;
create policy "requester update own pending" on public.reservations for update to authenticated
using (requester_id=auth.uid() and status='Pending' and public.current_role()='requester')
with check (requester_id=auth.uid() and status in ('Pending','Cancelled'));
drop policy if exists "admin update reservations" on public.reservations;
create policy "admin update reservations" on public.reservations for update to authenticated
using (public.current_role()='administrator') with check (public.current_role()='administrator');
drop policy if exists "staff update reservations" on public.reservations;
create policy "staff update reservations" on public.reservations for update to authenticated
using (public.current_role()='facility_staff' and status in ('Approved','Scheduled','In Use'))
with check (public.current_role()='facility_staff' and status in ('In Use','Completed'));

drop policy if exists "admin read audit" on public.audit_logs;
create policy "admin read audit" on public.audit_logs for select to authenticated using (public.current_role()='administrator');
drop policy if exists "staff read concerns" on public.service_concerns;
create policy "staff read concerns" on public.service_concerns for select to authenticated using (public.current_role() in ('administrator','facility_staff'));
drop policy if exists "staff create concerns" on public.service_concerns;
create policy "staff create concerns" on public.service_concerns for insert to authenticated with check (reported_by=auth.uid() and public.current_role()='facility_staff');
drop policy if exists "staff update concerns" on public.service_concerns;
create policy "staff update concerns" on public.service_concerns for update to authenticated using (public.current_role()='facility_staff') with check (public.current_role()='facility_staff');

insert into public.facilities(name,location,description,condition)
select v.name,v.location,v.description,v.condition
from (values
 ('Audio Visual Room','Main Building · 2nd Floor','Presentation and seminar room','Active'),
 ('Computer Laboratory 1','ICT Building · Room 101','Computer laboratory','Active'),
 ('Conference Hall','Administration Building','Meetings and events','Active'),
 ('Science Laboratory','Science Building · Room 203','Laboratory classroom','Maintenance')
) as v(name,location,description,condition)
where not exists (select 1 from public.facilities f where f.name=v.name);

-- Create accounts in Supabase Authentication first, then assign:
-- update public.profiles set role='administrator',full_name='Administrator' where email='admin@example.com';
-- update public.profiles set role='facility_staff',full_name='Facility Staff' where email='staff@example.com';
-- Requester accounts receive the requester role automatically.

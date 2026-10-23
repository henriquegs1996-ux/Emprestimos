-- Controle de Empréstimos — esquema inicial Supabase
-- Execute no SQL Editor do seu projeto. RLS garante que cada usuário veja somente os próprios registros.
create extension if not exists pgcrypto;

create table if not exists public.clients (
 id uuid primary key default gen_random_uuid(),
 owner_id uuid not null default auth.uid() references auth.users(id) on delete cascade,
 name text not null,
 contact text,
 address text,
 cpf text,
 rg text,
 created_at timestamptz not null default now()
);
create table if not exists public.loans (
 id uuid primary key default gen_random_uuid(),
 owner_id uuid not null default auth.uid() references auth.users(id) on delete cascade,
 client_id uuid not null references public.clients(id) on delete cascade,
 principal numeric(12,2) not null check (principal > 0),
 start_date date not null,
 installment_count integer not null check (installment_count between 1 and 240),
 first_due date not null,
 frequency text not null check (frequency in ('monthly','weekly','biweekly','daily')),
 interest_type text not null check (interest_type in ('percent','fixed')),
 daily_interest numeric(10,4) not null default 0 check (daily_interest >= 0),
 notes text,
 created_at timestamptz not null default now()
);
create table if not exists public.installments (
 id uuid primary key default gen_random_uuid(),
 owner_id uuid not null default auth.uid() references auth.users(id) on delete cascade,
 loan_id uuid not null references public.loans(id) on delete cascade,
 sequence integer not null check (sequence > 0),
 due_date date not null,
 amount numeric(12,2) not null check (amount > 0),
 paid_amount numeric(12,2) not null default 0 check (paid_amount >= 0),
 status text not null default 'pending' check (status in ('pending','paid')),
 created_at timestamptz not null default now(),
 unique(loan_id,sequence)
);
create table if not exists public.payments (
 id uuid primary key default gen_random_uuid(),
 owner_id uuid not null default auth.uid() references auth.users(id) on delete cascade,
 installment_id uuid not null references public.installments(id) on delete cascade,
 amount numeric(12,2) not null check (amount > 0),
 paid_at date not null default current_date,
 notes text,
 created_at timestamptz not null default now()
);

-- RLS obrigatório em todas as tabelas com dados pessoais/financeiros
alter table public.clients enable row level security;
alter table public.loans enable row level security;
alter table public.installments enable row level security;
alter table public.payments enable row level security;

drop policy if exists "clients owner all" on public.clients;
create policy "clients owner all" on public.clients for all to authenticated
 using (owner_id = auth.uid()) with check (owner_id = auth.uid());

drop policy if exists "loans owner all" on public.loans;
create policy "loans owner all" on public.loans for all to authenticated
 using (owner_id = auth.uid()) with check (
  owner_id = auth.uid() and exists (
   select 1 from public.clients c where c.id = client_id and c.owner_id = auth.uid()
  )
);

drop policy if exists "installments owner all" on public.installments;
create policy "installments owner all" on public.installments for all to authenticated
 using (owner_id = auth.uid()) with check (
  owner_id = auth.uid() and exists (
   select 1 from public.loans l where l.id = loan_id and l.owner_id = auth.uid()
  )
);

drop policy if exists "payments owner all" on public.payments;
create policy "payments owner all" on public.payments for all to authenticated
 using (owner_id = auth.uid()) with check (
  owner_id = auth.uid() and exists (
   select 1 from public.installments i where i.id = installment_id and i.owner_id = auth.uid()
  )
);

create index if not exists clients_owner_idx on public.clients(owner_id);
create index if not exists loans_owner_idx on public.loans(owner_id);
create index if not exists installments_owner_due_idx on public.installments(owner_id,due_date);
create index if not exists payments_owner_date_idx on public.payments(owner_id,paid_at);

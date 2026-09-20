-- ============================================================
-- Warsztat Współpracy — schemat Supabase
-- Wklej całość w: Supabase Dashboard -> SQL Editor -> New query -> Run
-- ============================================================

create extension if not exists pgcrypto;

-- Pojedynczy wiersz sterujący stanem sesji (aktywny moduł, lista do
-- głosowania, zatwierdzona karta współpracy).
create table if not exists session_state (
  id smallint primary key default 1 check (id = 1),
  active_module text not null default 'lobby',
  vote_module_id text,
  vote_options jsonb not null default '[]'::jsonb,
  charter jsonb not null default '[]'::jsonb,
  timer_module_id text,
  timer_remaining_seconds integer,
  timer_running boolean not null default false,
  timer_started_at timestamptz,
  updated_at timestamptz not null default now()
);
insert into session_state (id) values (1) on conflict (id) do nothing;
-- Jeśli tabela już istniała bez kolumn timera (start od zera), dodaj je bezpiecznie:
alter table session_state add column if not exists timer_module_id text;
alter table session_state add column if not exists timer_remaining_seconds integer;
alter table session_state add column if not exists timer_running boolean not null default false;
alter table session_state add column if not exists timer_started_at timestamptz;

-- Odpowiedzi tekstowe uczestników (jeden wiersz = jedno wysłanie formularza).
create table if not exists responses (
  id uuid primary key default gen_random_uuid(),
  module_id text not null,
  dept text,
  name text,
  values jsonb not null,
  created_at timestamptz not null default now()
);
create index if not exists responses_module_idx on responses (module_id);

-- Głosy uczestników (jeden wiersz na osobę na urządzenie — nadpisywalny).
create table if not exists votes (
  client_id text primary key,
  module_id text not null,
  picks text[] not null default '{}',
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);
create index if not exists votes_module_idx on votes (module_id);

-- Wyniki grupowania AI (wklejane ręcznie przez moderatora z czatu Claude),
-- opcjonalnie edytowane ręcznie przez moderatora + jego własny komentarz.
create table if not exists analysis (
  key text primary key,
  themes jsonb not null default '[]'::jsonb,
  comment text,
  updated_at timestamptz not null default now()
);
alter table analysis add column if not exists comment text;

-- Zarchiwizowane sesje (skompilowane podsumowanie zapisane przed resetem).
create table if not exists sessions (
  id uuid primary key default gen_random_uuid(),
  name text not null,
  archived_at timestamptz not null default now(),
  data jsonb not null default '{}'::jsonb
);

-- ============================================================
-- Row Level Security — dostęp bez logowania (klucz anon), zgodnie
-- z założeniem "uczestnicy bez konta". To narzędzie do jednorazowego,
-- wewnętrznego warsztatu — reguły są celowo otwarte (każdy z linkiem
-- może odczytać/zapisać), a panel moderatora chroniony jest tylko
-- PIN-em w interfejsie (nie na poziomie bazy).
-- ============================================================
alter table session_state enable row level security;
alter table responses     enable row level security;
alter table votes         enable row level security;
alter table analysis      enable row level security;
alter table sessions      enable row level security;

drop policy if exists session_state_all on session_state;
create policy session_state_all on session_state for all using (true) with check (true);

drop policy if exists responses_all on responses;
create policy responses_all on responses for all using (true) with check (true);

drop policy if exists votes_all on votes;
create policy votes_all on votes for all using (true) with check (true);

drop policy if exists analysis_all on analysis;
create policy analysis_all on analysis for all using (true) with check (true);

drop policy if exists sessions_all on sessions;
create policy sessions_all on sessions for all using (true) with check (true);

-- ============================================================
-- Realtime — włącz replikację zmian dla live-aktualizacji ekranu.
-- ============================================================
alter publication supabase_realtime add table session_state;
alter publication supabase_realtime add table responses;
alter publication supabase_realtime add table votes;
alter publication supabase_realtime add table analysis;
alter publication supabase_realtime add table sessions;

create table
  logs (
    id bigint primary key generated always as identity,
    created_at timestamptz default now(),
    uid text,
    closest_place text not null
  );
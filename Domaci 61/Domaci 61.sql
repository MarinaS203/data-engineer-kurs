--Domaci 6.1 od cetvrtka 29. oktobra

CREATE SCHEMA IF NOT EXISTS bootcamp.domaci;
use bootcamp.domaci;

-- 1. Kreiranje dimenzije igrača
-- Na osnovu tabele players napravite tabelu dim_player koja sadrži sledeće kolone: player_
-- id, ime, prezime, poziciju i nacionalnost igrača. Koliko redova ima novokreirana tabela?

create or replace table dim_players as
select distinct player_id, 
        first_name, 
        last_name, 
        position, 
        nationality
from bootcamp.northern_star.players
order by player_id asc;

select * from dim_players; --tabela ima 693 reda, prvih 12 su null vrednosti. 


-- 2. Napravite tabelu dim_date na isti način kao na predavanju. Zatim napravite tabelu fact_player_
-- match na osnovu tabela player_match_stats i matches. Tabela treba da sadrži sledeće kolone: 
-- match_id, date_key, player_id, team_id, minutes_played, shots, passes i rating.

CREATE OR REPLACE TABLE dim_date AS
SELECT CAST(DATE_FORMAT(d, 'yyyyMMdd') AS INT) AS date_key,
       d                                       AS full_date,
       DATE_FORMAT(d, 'EEEE')                  AS weekday_name,
       DAYOFWEEK(d) IN (1, 7)                  AS is_weekend,
       CASE WHEN MONTH(d) >= 7 THEN CONCAT(YEAR(d), '/', SUBSTRING(CAST(YEAR(d) + 1 AS STRING), 3, 2))
            ELSE CONCAT(YEAR(d) - 1, '/', SUBSTRING(CAST(YEAR(d) AS STRING), 3, 2))
       END                                     AS season
FROM (SELECT EXPLODE(SEQUENCE(DATE'2023-07-01', DATE'2025-06-30', INTERVAL 1 DAY)) AS d);

SELECT * FROM dim_date;

-- Zatim napravite tabelu fact_player_match na osnovu tabela player_match_stats i matches. 
--Tabela treba da sadrži sledeće kolone: match_id, date_key, player_id, team_id, minutes_played, shots, passes i rating.
-- U tabelu uključite samo podatke koji se odnose na odigrane utakmice. Kolika je granularnost tabele fact_player_match, 
  --odnosno šta predstavlja jedan njen red? Koliko redova ima ova tabela?

create or replace table fact_player_match as
select distinct m.match_id,
CAST(DATE_FORMAT(m.kickoff_ts, 'yyyyMMdd') AS INT) AS date_key,
ps.player_id,
ps.team_id, 
ps.minutes_played,
ps.shots,
ps.passes, 
ps.rating 
from bootcamp.northern_star.player_match_stats ps
join bootcamp.northern_star.matches m on m.match_id=ps.match_id where m.status='played'
order by m.match_id asc, ps.player_id asc;

select * from fact_player_match limit 100;
--Jedan red ove tabele predstavlja statistiku za pojedinacnog igraca, na odredjenom mecu. 

select count(*) from fact_player_match;
--Tabela ima 30400 redova, jer za svaki match_id, posmatram statistiku za svakog igraca pojedinacno. 
--Dakle, 760 odigranih utakmica * 40 igraca po utakmici, 304000 redova.

-- 3. Prosečna ocena igrača po poziciji
-- Koristeći napravljene dimenzije i činjeničnu tabelu, izračunajte
-- prosečnu ocenu (rating) igrača za svaku poziciju tokom
-- sezone 2024/25.
-- Prikažite poziciju i odgovarajuću prosečnu ocenu.

select rating from fact_player_match; --i u player_match_stats i u ovoj tabeli imam nan vrednosti 
--prvo cu da sredim nan vrednosti, stavicu NULL
UPDATE fact_player_match SET rating = 'Null' WHERE rating='nan';

select kickoff_ts from bootcamp.northern_star.matches where season='2024/25' order by kickoff_ts asc;
--od 2024-08-17 do 2025-05-18 traje sezona 2024/25.
select date_key from fact_player_match; --datumi su u formatu YYYYmmDD

select 
dp.position,
round(avg(rating),2) as avg_rating
from fact_player_match fpm
join bootcamp.domaci.dim_players dp on dp.player_id=fpm.player_id
where fpm.rating<>'Null' and (date_key>20240816 and date_key<20250519)
group by dp.position;

-- 4. Dodavanje broja golova u činjeničnu tabelu
-- Proširite tabelu fact_player_match dodavanjem kolone koja
-- predstavlja broj golova koje je svaki igrač postigao na
-- određenoj utakmici.
-- Koliki je ukupan zbir golova svih igrača u tabeli
-- fact_player_match?

alter table fact_player_match add column goals int;
--Napravicu novu tabelu koja sabira sve golove za jednog igraca na jednom mecu

create or replace table pomoc as
select
player_id, 
match_id,
sum(case when event_type in('goal', 'own_goal', 'penalty_goal') then 1 
                else 0
                end) as goals_per_player
from bootcamp.northern_star.match_events 
where event_type in('goal', 'own_goal', 'penalty_goal')
group by match_id, player_id
order by match_id asc, player_id asc;

select * from pomoc;
--Ovo sam nasla kao najbolju opciju da ubacim podatke iz pomocne tabele u ovu novu tabelu
merge into fact_player_match fc
using pomoc p
on fc.player_id = p.player_id and fc.match_id = p.match_id
when matched then
update set fc.goals = p.goals_per_player;

select count(*) from fact_player_match where goals is not null;--1930 redova, jer su neki dali vise od jednog gola

select 
sum(goals) as total_goals
from fact_player_match; 
--Ukupan broj golova je 2137 (tj suma golova)

select count(*) from bootcamp.northern_star.match_events where event_type in('goal', 'own_goal', 'penalty_goal');--2137 dogadjaja tipa go


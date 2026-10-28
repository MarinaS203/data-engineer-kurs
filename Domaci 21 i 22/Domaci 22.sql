--Domaci zadatak 22 - like, ilike, between

USE bootcamp.northern_star;


--Prvi zadatak 
SELECT
  home_team, away_team, match_report
FROM matches_flat
WHERE
  match_report ILIKE ('%goal%');

--Drugi zadatak
SELECT home_team, away_team,
   coalesce (referee_name, 'Unknown') AS referee_name
FROM matches_flat
LIMIT 20;

--Treci zadatak
SELECT 
    match_id, match_report, length(match_report) AS report_length
    FROM matches_flat
    WHERE length(match_report)>40;

--Cetvrti zadatak
SELECT
    home_team, away_team, kickoff_ts
    FROM matches_flat
    WHERE date(kickoff_ts)>='2025-01-01' AND date(kickoff_ts)<='2025-01-15';

/*Ovo sam proveravala da li će biti isti rezultat, hoće.
SELECT
    home_team, away_team, kickoff_ts
    FROM matches_flat
    WHERE kickoff_ts BETWEEN '2025-01-01 00:00:00' AND '2025-01-15 23:59:59';
*/

--Peti zadatak
SELECT 
    --COUNT(match_id),
    kickoff_ts, date(kickoff_ts) AS date_of_the_game, dayofweek(kickoff_ts) AS day_of_the_game
    FROM matches_flat
    WHERE dayofweek(kickoff_ts)=6;
/*U vezi ovog zadatka, jedini dan kada se nisu igrale utakmice je petak, 
isprobala sam sve dane, igrano je redom:
nedelja: 121
ponedeljak: 23
utorak:15
sreda:18
cetvrtak:10
petak:0
subota:574, 
što u zbiru daje 761, što je ukupan broj utakmica, tako da querry za petak ne vraća ni jedan red.*/

--Sesti zadatak
SELECT 
    COUNT (match_id)
    from matches_flat
    WHERE season = '2024/25' AND attendance BETWEEN 20000 AND 35000;
--188 utakmica

--Sedmi zadatak
SELECT 
    DISTINCT(first_goal_scorer)
    FROM matches_flat
    WHERE first_goal_scorer LIKE 'A%' OR first_goal_scorer LIKE '%-%';

--Osmi zadatak
SELECT
    home_team, away_team, date_format(kickoff_ts, 'HH:mm') AS vreme_pocetka
    FROM matches_flat
    WHERE season = '2024/25' AND time(kickoff_ts) BETWEEN '18:00:00' AND '21:00:00';

--Deveti zadatak
SELECT 
    COUNT(match_id)
    FROM matches_flat
    WHERE season = '2024/25' AND month(kickoff_ts) BETWEEN 3 AND 5 AND match_report ILIKE ('%win%');
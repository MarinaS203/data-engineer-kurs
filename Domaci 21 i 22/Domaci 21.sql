--Domaci zadatak 21

--Prvi zadatak 
SELECT 
    match_id, home_team, away_team, stadium_capacity, attendance, 
    stadium_capacity - attendance AS empty_seats
FROM matches_flat
ORDER BY empty_seats DESC 
LIMIT 5;
--Zajednicka karakteristika za prva tri ispisa u tabeli je Home team - Oakfield Town.

--Drugi zadatak
SELECT 
COUNT (DISTINCT referee_name) AS broj_razlicitih_sudija
FROM matches_flat
WHERE home_team = 'Riverton Athletic';

--Treci zadatak 
SELECT
COUNT (match_id)
FROM matches_flat
WHERE (away_goals_ht > home_goals_ht) AND (home_goals>away_goals);

--Cetvrti zadatak
SELECT 
    home_team, away_team, home_goals_ht, away_goals_ht, home_goals, away_goals,
    (home_goals+away_goals)-(home_goals_ht+away_goals_ht) AS goals_second_ht
FROM matches_flat
ORDER BY goals_second_ht DESC
LIMIT 1;

--Peti zadatak
SELECT 
COUNT (match_id) 
FROM matches_flat
WHERE season = '2023/24' AND (weather = 'snow' OR weather = 'fog');

--Šesti zadatak
/*Ovaj zadatak bi se mnogo lakše radio sa CASE WHEN, ali pošto 
to još nismo radili, uradila sam ga ovako. Sa CASE WHEN, u jednoj 
koloni bi odmah upisivao pobednika, na osnovu gol razlike. */
SELECT 
    home_team, away_team, kickoff_ts, home_goals, away_goals,
    home_goals > away_goals AS home_wins,
    home_goals < away_goals AS away_wins,
    home_goals = away_goals AS draw
FROM matches_flat
WHERE (home_team = 'Northport United' OR home_team = 'Northport City') AND (away_team = 'Northport United' OR away_team = 'Northport City')
ORDER BY kickoff_ts ASC; 

--Sedmi zadatak
/* Ne možemo biti sigurni koja utakmica je prva počela, da postoje
podaci u original_kickoff_ts, mogli bismo njih da uporedimo, 
u slučaju da su kickoff_ts isti. Onda bih uradila sortiranje 
još po koloni original_kickoff_ts , sa ASC*/
SELECT 
    match_id, home_team, away_team, kickoff_ts, original_kickoff_tS
FROM matches_flat
WHERE season = '2024/25'
ORDER BY kickoff_ts ASC
LIMIT 3;

--Osmi zadatak
/*Jedan upit pokazuje utakmice u kojima je Sean O'Neil postigao prvi gol, 
a drugi upit broji koliko takvih utakmica ima.*/

SELECT match_id, home_team, away_team, first_goal_scorer
FROM matches_flat
WHERE first_goal_scorer = "Sean O'Neill";

SELECT 
COUNT (match_id) AS matches_where_Sean_scored_first
FROM matches_flat
WHERE first_goal_scorer = "Sean O'Neill";

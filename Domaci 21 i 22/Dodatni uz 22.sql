USE bootcamp.northern_star; 

--Dodatni zadaci uz domaci 22

--Prvi zadatak
SELECT 
count (match_id)
FROM matches_flat  
WHERE referee_name IS NULL AND attendance IS NULL;

--Drugi zadatak
SELECT 
    home_team, away_team, date(kickoff_ts) as date_of_game
    FROM matches_flat
    where date(kickoff_ts) BETWEEN '2025-03-01' AND '2025-03-31'
    ORDER BY date_of_game ASC;

--Treci zadatak
SELECT      
    count(match_id)
    FROM matches_flat
    where date(kickoff_ts) BETWEEN '2024-12-20' AND '2025-01-10';

--Cetvrti zadatak
SELECT  
    date(kickoff_ts) AS date_of_the_game, home_team, away_team,
    coalesce(cast(attendance as string), 'Unknown') AS attendance_status
    FROM matches_flat;

--Peti zadatak
SELECT  
    date(kickoff_ts) AS date_of_the_game, home_team, away_team, home_goals, away_goals
    FROM matches_flat
    where (date(kickoff_ts) BETWEEN '2025-04-01' AND '2025-04-30') AND (home_goals+away_goals>=2 AND home_goals+away_goals<=4)
    ORDER BY date_of_the_game ASC;

--Sesti zadatak
SELECT 
    date(kickoff_ts) as date_of_the_game, home_team, away_team,
    concat(home_team_code, ' ', home_goals_ht, ' - ', away_goals_ht, ' ', away_team_code) AS ht_result,
    concat(home_team_code, ' ', home_goals, ' - ', away_goals, ' ', away_team_code) AS final_result
    from matches_flat
    where (home_goals_ht = away_goals_ht) AND (home_goals<>away_goals);

    


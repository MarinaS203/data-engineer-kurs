-- Sesije 3,4 
 
-- 1.1. За сваког судију прикажите националност (из referees), број утакмица, просечан број голова и
--проценат победа домаћина. Код ког судије домаћини најчешће побеђују?
--  trebaju mi referee name, nationality iz referees, iz matches match_id u kojem je taj sudija,
--pa prebrojim, u matches home_goals, away_goals pa racunam prosek i gledam procenat pobeda domacina. 

select 
    r.referee_name, r.nationality, 
    count(m.match_id) as total_matches,
    avg(m.home_goals+m.away_goals) as avg_goals,
    sum(case when home_goals>away_goals then 1
        else 0
        end) as home_wins,
    round(home_wins*100.0/total_matches,2) as percentage
from referees r
left join matches m on m.referee_id=r.referee_id 
where m.status='played'
group by r.referee_name, r.nationality
order by home_wins desc;
--Najvise pobeda domacina ima kod sudije Samuel-a Achebea, iz Nigerije (53.85%). 

-- 2. Који клубови су у сезони 2024/25 имали више победа у гостима него код куће?
--u tabeli matches imam season, home_goals, away_goals, home_team_id, u teams team_id, team_name

WITH sides AS (
  SELECT match_id, season, matchday, kickoff_ts,
         home_team_id AS team_id, away_team_id AS opponent_id, 'home' AS venue,
         home_goals AS goals_for, away_goals AS goals_against--ovo su protivnicki golovi
  FROM matches
  WHERE status = 'played'
  UNION ALL
  SELECT match_id, season, matchday, kickoff_ts,
         away_team_id, home_team_id, 'away',
         away_goals, home_goals
  FROM matches
  WHERE status = 'played'
)
-- select * from sides; 
-- select * from matches 
-- where match_id=1239;
select team_id,
    sum(case when (goals_for>goals_against and venue='home') then 1
            else 0
            end) as home_win,
    sum(case when goals_against<goals_for and venue='away' then 1
        else 0
        end) as away_win
     from sides
    where season='2024/25'
    group by team_id
having away_win>home_win
order by away_win-home_win DESC;
--Dobijaju se tri tima, sa id-jevima 12,23,7

-- 3. Колико играча је давало голове у обе сезоне?
select distinct(event_type) from match_events; --goal, penalty_goal
select distinct(season) from matches;
--u sezoni 2023/24 320 igraca, 2024/25 308 igraca
--Ideja mi je bila da u podupitu nadjem igrace koji su dali golove u jednoj sezoni (npr 24/25), 
--a da u glavnom querry-ju pronadjem igrace kod kojih je player_id u tom nizu koji vraca podupit, 
--uz dodatni uslov da je sezona 23/24. Tabelu sam spajala sa dodatnim uslovom za event_type, 
--da bih spojila samo te utakmice koje mi trebaju. I ovaj zadatak je rogobatan, ali mi ništa elegantnije nije palo na pamet. 
--Jedva čekam da možemo da napišemo funkcije i da ih zovemo gotove po potrebi, ovo je baš mučno za složenije zadatke.

select distinct(player_id)
from match_events me    
join matches m on m.match_id=me.match_id and me.event_type in('goal', 'penalty_goal')
where m.season = '2023/24' and me.player_id in (select player_id from match_events me1   
                                                join matches m1 on m1.match_id=me1.match_id and me1.event_type in('goal', 'penalty_goal')
                                                        where m1.season = '2024/25');
--Dobiju se 193 igraca koji su dali golove u obe utakmice.

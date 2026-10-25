--1. Сезона у бројевима: утакмице, победе, нерешене, порази, дати и примљени голови, бодови.
WITH club AS (
SELECT team_id FROM teams WHERE team_name = 'Ashford Rovers'
)
 select 
    c.team_id,
    count(m.match_id) as num_of_matches,
    sum( case when (c.team_id=m.home_team_id and home_goals>away_goals) or (c.team_id=m.away_team_id and home_goals<away_goals) then 1 
            else 0 
            end) as num_of_wins,
    sum( case when (c.team_id=m.home_team_id and home_goals<away_goals) or (c.team_id=m.away_team_id and home_goals>away_goals) then 1 
            else 0 
            end) as num_of_losses,
    sum (case when home_goals=away_goals then 1
            else 0
            end) as num_of_draws,
        sum(home_goals) as goals_scored,
        sum(away_goals) as goals_received,
    sum(case when (c.team_id=m.home_team_id and home_goals>away_goals) or (c.team_id=m.away_team_id and home_goals<away_goals) then 3
            when home_goals=away_goals then 1
            else 0 end) as points
    from matches m 
    join club c on m.home_team_id=c.team_id or m.away_team_id=c.team_id  
    where season='2024/25' 
    group by c.team_id, m.season;

--2. Код куће и у гостима: исти бројеви, одвојено за домаће и гостујуће утакмице.
--Сезона у бројевима: утакмице, победе, нерешене, порази, дати и примљени голови, бодови.
WITH club AS (
SELECT team_id FROM teams WHERE team_name = 'Ashford Rovers'
),
sides AS (
  SELECT match_id, season, 
         home_team_id AS team_id, away_team_id AS opponent_id, 'home' AS venue,
         home_goals AS goals_for, away_goals AS goals_against--ovo su protivnicki golovi
  FROM matches m
  join club c on m.home_team_id=c.team_id
  UNION ALL
  SELECT match_id, season, 
         away_team_id, home_team_id, 'away',
         away_goals, home_goals
  FROM matches m   
  join club b on m.away_team_id=b.team_id
)
   
   select 
   team_id,
   sum (case when venue = 'home' then 1 else 0 end) as num_of_home_matches,
   sum (case when venue = 'away' then 1 else 0 end) as num_of_away_matches,
   sum(case when (goals_for>goals_against and venue='home') then 1
            else 0
            end) as home_win,
   sum(case when (goals_for<goals_against and venue='home') then 1
            else 0
            end) as home_losses,
   sum(case when (goals_for=goals_against and venue='home') then 1
                else 0
                end) as home_draw,
   sum(case when (goals_against<goals_for and venue='away') then 1
                else 0
                 end) as away_win,
   sum(case when (goals_against>goals_for and venue='away') then 1
                 else 0
                 end) as away_losses,
   sum(case when (goals_for=goals_against and venue='away') then 1
                else 0
                end) as away_draw,
         sum(case when venue='home' then goals_for
                else 0
                end) as home_goals,
        sum(case when venue='away' then goals_against
                else 0
                end) as away_goals,
                sum(case when venue='home' then goals_against
                else 0
                end) as home_goals_received,
        sum(case when venue='away' then goals_for
                else 0
                end) as away_goals_received,
                sum(case when venue='home' and goals_for>goals_against then 3 
                         when venue='home' and goals_for=goals_against then 1 
                         else 0 end) as home_points,
                sum(case when venue='away' and goals_for>goals_against then 3 
                         when venue='away' and goals_for=goals_against then 1 
                         else 0 end) as away_points
        from sides
    where season='2024/25'
    group by team_id, venue; 

   -- 3.  Стрелци: три најбоља стрелца клуба и најбољи асистент.
   --select distinct(event_type) from match_events; 'goal', 'penalty_goal'
WITH club AS (
SELECT team_id FROM teams WHERE team_name = 'Ashford Rovers'
)
   select 
   me.player_id, p.first_name, p.last_name,
   sum(case when event_type in ('goal', 'penalty_goal') then 1
        else 0 
        end ) as goals_scored 
   from club c 
   join match_events me on me.team_id=c.team_id
   join matches m on m.match_id=me.match_id and season='2024/25'
   join players p on p.player_id=me.player_id
   group by me.player_id, p.first_name, p.last_name
   order by goals_scored DESC, me.player_id asc
   limit 3; 
   --ovaj upit vraca tri najbolja igraca player_id 85,470,77 Luke Gibbs, Jonas Becker, Jack Cole
  
  -- Provera: select team_id from match_events where player_id=75;
  -- select team_name from teams where team_id=3;
WITH club AS (
SELECT team_id FROM teams WHERE team_name = 'Ashford Rovers'
)
   select 
   me.related_player_id, p.first_name, p.last_name,
   sum(case when (event_type='goal' and related_player_id is not null) then 1
        else 0 
        end ) as goals_assisted 
   from club c 
   join match_events me on me.team_id=c.team_id
   join matches m on m.match_id=me.match_id and season='2024/25'
   join players p on p.player_id=me.related_player_id
   group by me.related_player_id, p.first_name, p.last_name
   order by goals_assisted DESC, me.related_player_id asc
   limit 1; 
--Najbolji asistent je sa related_player_id 75, Kyle Jenkins
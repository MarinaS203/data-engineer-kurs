--Dosije kluba

--select team_name from teams; --Ashford Rovers sam uzela za primer, ali sam koristila CTE koji nam je Cvijan postavio, da bi se u zadacima lako menjalo ime kluba. Verujem da je to dosta zakomplikovalo neke zadatke, verujem i da moze jednostavnije. U nekim zadacima sam koristila i dva odvojena upita jer nisam znala kako da spakujem sve u jedan.

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


--4. Дисциплина: картони клуба по утакмици у поређењу са просеком лиге по тиму по утакмици
select distinct(event_type) from match_events; --yellow_card, second_yellow, red_card

WITH club AS (
    SELECT team_id FROM teams WHERE team_name = 'Ashford Rovers'
)
select 
    round(avg(total_cards),2) as avg_cards_per_match
from (
select 
        m.match_id,
        count(me.event_type) as total_cards 
   from matches m
   join club c on m.home_team_id = c.team_id or m.away_team_id = c.team_id
   left join match_events me on me.match_id = m.match_id and me.team_id = c.team_id and me.event_type in ('yellow_card', 'second_yellow', 'red_card')
   where m.season = '2024/25'
   group by m.match_id
   order by m.match_id asc); --rezultat je 2.05 kartona je njihov prosek po utakmici
   --dalje racunam prosek lige (to je prosek po timu po sezoni )
 select 
    round(count(me.event_type)/(count(distinct m.match_id)*2),2) as league_avg_cards
    from matches m
    left join match_events me on me.match_id = m.match_id and me.event_type in ('yellow_card', 'second_yellow', 'red_card')
    where m.season = '2024/25';
--1.74 kartona je prosek lige po utakmici

--5.Тренери: ко је водио клуб у сезони и са колико бодова по утакмици
WITH club AS (
SELECT team_id FROM teams WHERE team_name = 'Ashford Rovers'
), 
manager as (
        select spell_id, team_id, manager_name, start_date, end_date 
        from manager_spells 
        where team_id in (select team_id from club)
)
 select 
    ms.manager_name,
    count(m.match_id) as num_of_matches,
    sum(case when (c.team_id=m.home_team_id and home_goals>away_goals) or (c.team_id=m.away_team_id and home_goals<away_goals) then 3
            when home_goals=away_goals then 1
            else 0 end) as points,--ovde sam probala da direktno delim, pa sam se zakucala u zid i lomila glavu veoma dugo (points/num_of_matches as avg_points)
        round(sum(case when (c.team_id=m.home_team_id and home_goals>away_goals) or (c.team_id=m.away_team_id and home_goals<away_goals) then 3
            when home_goals=away_goals then 1
            else 0 end) / count(m.match_id),2) as avg_points
    from club c
  --ovde sam provela pola dana dok nisam ukapirala kojim redom sve da povezem da ne bi umnozavalo redove
    join matches m on m.home_team_id = c.team_id or m.away_team_id = c.team_id
    join manager ms on ms.team_id = c.team_id and date(m.kickoff_ts) >= ms.start_date 
    and (date(m.kickoff_ts) <= ms.end_date or ms.end_date is null)
    where m.season = '2024/25'
    group by ms.manager_name;

--select * from matches where (home_team_id = 3 or away_team_id = 3) and season = '2024/25';

--6. Највећа победа и најтежи пораz
--U matches imam sezonu, i imam home_goals, away_goals. Treba mi i kada mi je tim bio domaci i kada je bio gostujuci, da izracunam razliku golova za svaki mec. Mene su ovaj i prethodna dva zadatka bas namucila. 
WITH club AS (
    SELECT team_id FROM teams WHERE team_name = 'Ashford Rovers'
),
sides AS (
    SELECT 
        match_id, season, home_team_id AS team_id, away_team_id AS opponent_id, 'home' AS venue,
        home_goals AS goals_for, away_goals AS goals_against
    FROM matches m
    JOIN club c ON m.home_team_id = c.team_id

    union all

    SELECT 
        match_id, season, away_team_id, home_team_id, 'away',
        away_goals, home_goals
    FROM matches m
    JOIN club c ON m.away_team_id = c.team_id
),
the_biggest as (
    select 
    max(case when goals_for>goals_against then goals_for-goals_against
             end) as biggest_win,
    max(case when goals_for<goals_against then goals_against-goals_for
             end) as biggest_loss
    from sides
    where season = '2024/25'
)
select
    s.match_id, s.venue, s.goals_for, s.goals_against
    from sides s
    join the_biggest b on (s.goals_for-s.goals_against=b.biggest_win) 
    or (s.goals_against-s.goals_for=b.biggest_loss)
    where s.season = '2024/25'; 
    --najvece pobede 2170, 2171,2374 poraz 2077

--7. Публика: просечна посета и попуњеност на домаћим утакмицама, и колико утакмица нема
--податак о посети. 
--u matches imam match id, home_team_id, season, stadium_id, ali u stadiums imam capacity
with club as (
    select team_id from teams where team_name = 'Ashford Rovers'
)
select
   s.capacity,
   s.stadium_name,
    avg(m.attendance) as avg_attendance,
    round(avg(m.attendance * 100.0/s.capacity),2) as avg_percentage,
    sum( case when m.attendance is null then 1
              else 0
              end) as matches_without_attendance
   from matches m
   join club c on m.home_team_id = c.team_id
   join stadiums s on m.stadium_id = s.stadium_id
   where m.season = '2024/25'
   group by  s.stadium_name,s.capacity;
   --28500 24960 87.58	0
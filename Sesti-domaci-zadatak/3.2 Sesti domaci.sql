use bootcamp.northern_star;

--Domaci 3.2. zadat 20. oktobra.

--Osnovni nivo
-- 1.Prikažite naziv svakog kluba i naziv stadiona na kojem igra
-- domaće utakmice. (iz tabele teams uzimam team_name, spajam je po stadium_id sa tabelom stadiums, i iz nje uzimam ime stadiona)
    select
    t.team_name, 
    s.stadium_name
    from teams t
    left join stadiums s on s.stadium_id=t.stadium_id
    group by team_name, stadium_name;

    -- select distinct(team_name) from teams; --24 tima
    -- select distinct(stadium_name) from stadiums; --22 stadiona, dakle 4 tima dele dva stadiona
    -- stavila sam left join, da se ne bi izgubile te vrednosti

-- 2.Prikažite ime i prezime igrača i naziv kluba za koji je igrao u
-- sezoni 2024/25. Uklonite duplikate iz rezultata.
--Iz tabele players uzimam first_name, last_name kolone, povezem players sa match_events (preko player_id), a onda povezem match_events sa matches(u kojoj je sezona, preko match_id)
--ovde je neki problem, koji ne vidim trenutno
-- select
-- p.first_name, p.last_name, 
-- t.team_name
-- from players p
-- join player_contracts pc on pc.player_id=p.player_id
-- join teams t on t.team_id=pc.team_id
-- join matches m on m.referee_id=p.referee_id  
-- where m.season = '2024/25';  

--select * from player_contracts; --odavde sam videla da je team_id null, isto kao i stadium_id, ali player_id nije null .
select *
 from player_contracts; 

-- 3.Prikažite datum odigravanja utakmice, naziv stadiona i broj
-- gledalaca za sve utakmice u sezoni 2024/25. 
--iz tabele matches mogu da uzmem sezonu, stadium_id, attendance, preko stadium_id povezem sa tabelom stadiums i uzmem stadium_name.

select 
date(m.kickoff_ts) as date_of_the_game,
s.stadium_name, m.attendance
from matches m
join stadiums s on s.stadium_id=m.stadium_id
where m.season='2024/25'
group by stadium_name, date_of_the_game, attendance
order by date_of_the_game asc;

--Srednji nivo zadataka
-- 1.Prikažite sve utakmice za koje nije evidentiran broj gledalaca.
-- Prikažite datum, domaći klub i gostujući klub.
--Iz tabele matches uzimam attendance=null, u istoj tabeli je kickoff_ts za datum, home_team_id, away_team_id, to treba da spojim sa tabelom teams da dobijem team name.

-- select home_team_id from matches
-- where home_team_id is null; --nema null vrednosti u ovoj koloni 
-- select away_team_id from matches
-- where away_team_id is null; --ni ovde nema null vrednosti, moze inner join
--select attendance from matches where attendance is null; --vraca 17 redova

select 
m.attendance, date(m.kickoff_ts) as date_of_the_game, h.team_name as home_team, a.team_name as away_team
from matches m
join teams h on m.home_team_id=h.team_id
join teams a on m.away_team_id=a.team_id
where m.attendance is null
order by date_of_the_game asc; --vraca 17 redova

-- 2.Pronađite stadione na kojima nije odigrana ni jedna utakmica
-- u sezoni 2024/25.
-- select distinct(stadium_id) from stadiums
-- order by stadium_id desc;--22 razlicita stadiona
-- select distinct(stadium_id) from matches
-- where season = '2024/25'
-- order by stadium_id desc; --21 razliciti stadion --nedostaje stadion ciji je id 20, ovo je rucna metoda

-- select match_id from matches
-- where stadium_id = 20 and season ='2024/25'; --provera, ne vraca redove, da bismo dobili koji je stadion, moramo da koristimo left join

select
s.stadium_id, s.stadium_name
from stadiums s
left join matches m on s.stadium_id = m.stadium_id and season='2024/25'
where m.stadium_id is null;

-- 3.Za svaki klub izračunajte ukupan broj žutih kartona koje su
-- dobili njegovi igrači u sezoni 2024/25. Rezultat sortirajte
-- opadajuće prema broju kartona.*/
--U tabeli match_events ima event_type yellow_card i second_yellow, i ima team_id (dakle za svaki event_type ima koji tim je u njemu ucestvovao); u tabeli matches je season; mogu da povezem match_events sa teams preko team id, a matches i match_events preko match_id
-- select * from match_events;
-- select distinct(event_type) from match_events;

select 
t.team_name,
sum (case when me.event_type = 'yellow_card' or me.event_type='second_yellow' then 1 
    else 0
    end) as total_yellow
from teams t
join match_events me on me.team_id=t.team_id 
join matches m on m.match_id=me.match_id
where m.season='2024/25'
group by t.team_name
order by total_yellow desc;

-- Napredni nivo:
-- 1.Pronađite pet igrača sa najvećim brojem asistencija u
-- sezoni 2024/25. Prikažite ime igrača i broj asistencija.
-- --treba mi related_player_id iz match_events, event_type treba da bude 'goal' (moze da ima related player a moze i da bude null), season se nalazi u matches; match_events i matches mogu da povezem sa match_id, i jos mi treba ime igraca, firs_name, last_name iz players, povezem match events i players sa player id
-- select distinct(event_type) from match_events;
-- select * from match_events;
select 
p.first_name, p.last_name,
sum (case when me.event_type='goal' and me.related_player_id is not null then 1
         else 0 
    end) as num_of_assist
from match_events me
join matches m on me.match_id=m.match_id
join players p on me.player_id=p.player_id
where m.season = '2024/25'
group by p.first_name, p.last_name
order by num_of_assist desc
limit 5;

-- 2.Pronađite tri igrača sa najvećim ukupnim brojem
-- odigranih minuta u sezoni 2024/25. Prikažite ime igrača,
-- klub i ukupan broj minuta.
--treba mi minutes_played iz player_match_stats, first_name, last_name iz players, season iz matches
-- select * from player_match_stats;
-- select * from player_match_stats where minutes_played is null; --nema null vrednosti

select 
p.player_id,
p.first_name, p.last_name,
sum(ps.minutes_played) as total_minutes_played
from player_match_stats ps
join matches m on ps.match_id=m.match_id
join players p on ps.player_id=p.player_id
where m.season='2024/25'
group by p.player_id, p.first_name, p.last_name
order by total_minutes_played desc
limit 3;

-- 3.Za svaku sezonu prikažite broj isključenja po klubovima.
-- Računajte događaje red_card i second_yellow. Uključite
-- samo klubove koji su imali najmanje jedno isključenje.
-- select distinct(event_type) from match_events; --trebaju mi red_card i second_yellow da izbrojim
-- iz match_events brojim event_type gde je red_card i second_yellow, treba mi season iz tabele matches; 
-- u tabeli match_events uz event_type ide team_id, u tabeli teams se nalazi team_name. match_events mogu preko team_id da povezem sa teams, a preko match_id sa matches

select 
m.season, 
t.team_name,
sum(case when me.event_type='red_card' or me.event_type='second_yellow' then 1
    else 0
    end) as broj_iskljucenja
    from matches m
    join match_events me on m.match_id=me.match_id
    join teams t on t.team_id=me.team_id
    group by m.season, t.team_name
    having broj_iskljucenja>0
    order by m.season asc, broj_iskljucenja desc;



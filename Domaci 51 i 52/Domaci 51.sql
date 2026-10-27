
--Domaci zadatak od 26. oktobra 
-- 1. Za sezonu 2024/25 prikažite igrače i ukupan broj golova
-- koje su postigli. Prikažite samo igrače koji su postigli bar
-- jedan gol. Pomoću DENSE_RANK() rangirajte igrače prema ukupnom broju
-- golova, od najvećeg ka najmanjem. Igrači sa istim brojem golova
-- treba da imaju isti rang.
--U tabeli match_events imam event_type 'goal' i 'penalty_goal', treba da saberem obe vrste golova, 
--da ih podelim u grupe na osnovu player id, uslov treba da bude da su dali bar jedan gol, i da ih rangiram po zbiru golova

with sum_of_goals as(
select player_id, 
sum(case when me.event_type in('goal', 'penalty_goal') then 1 
        else 0
        end) as goals_per_player
from match_events me
join matches m on m.match_id=me.match_id and season='2024/25'
group by player_id
having goals_per_player >=1
order by goals_per_player desc
)--upit vraca 308 igraca, prvi na listi je player_id=678, sa 34 gola
select player_id, goals_per_player,
dense_rank() over (order by goals_per_player desc) as rnk
from sum_of_goals;
--dense_rank() over (partition by player_id order by goals_per_player desc) as rnk, 
--ovde sam najpre uradila ovako, i izbacivalo mi je rnk=1 za svakog igraca. 
--Onda sam ukapirala da rank rangira u okviru svake grupe koju napravim sa partition. 
--Posto je svaki player_id po jedna grupa, svi bi u okviru svoje grupe bili rangirani kao prvi. 
--Vidim da je to korisno npr za sledeci zadatak.


-- 2. Za sezonu 2024/25 prikažite tri igrača sa najviše
-- postignutih golova za svaki klub. Prikažite naziv kluba, ime i prezime igrača i broj postignutih
-- golova. Pomoću ROW_NUMBER() odredite redosled igrača
-- unutar svakog kluba, od najvećeg ka najmanjem broju golova.
with sum_of_goals as(
select me.player_id, me.team_id,
sum(case when me.event_type in('goal', 'penalty_goal') then 1 
        else 0 
        end) as goals_per_player 
from match_events me
join matches m on m.match_id=me.match_id and season='2024/25'
group by me.player_id, me.team_id
--order by goals_per_player desc  -ovo je bilo nepotrebno, suština je da ovaj cte vrati broj ukupnih golova po svakom igraču
) --vraca 506 redova, prvi je igrac 678 sa 34 gola
select  
   t.team_id, t.team_name, p.player_id, p.first_name, p.last_name, s.goals_per_player,
    row_number() over (partition by s.team_id order by goals_per_player desc) as rank
    from sum_of_goals s
    join players p on p.player_id=s.player_id
    join teams t on t.team_id=s.team_id
    qualify rank in (1,2,3) 
    --join sa players da bih dobila ime i prezime igrača, join sa timovima da bih dobila ime tima. uslov za sezonu sam postavila u cte-u.
    --ovde mi je bilo bas zanimljivo da mora da se vodi racuna odakle se vuce team_id za partition by. 
    --prvo sam pomislila da je svejedno, ali kada sam uzela team_id iz players,
    --uporno mi je vracalo kolonu null ova, jer je ta kolona u toj tabeli ustvari kolona null vrednosti. 
    --Druga stvar, u cte-u najpre nisam vadila team_id, a onda sam videla da on na osnovu rezultata iz cte-a 
    --gde su vezani igraci za timove, mora da pravi particije. 
    --Trece, komentare pišem i za Vas i za sebe, da imam kao podsetnik gde sam sve pravila greške dok 
    --mi nije proradilo kako treba. Nadam se da nije problem što su esejskog tipa. :)
    --order by goals_per_player desc, rank desc; --i ovo je nepotrebno


-- 3. Za sezonu 2024/25 prikažite sve utakmice svakog kluba,
-- broj golova koje je klub postigao i broj golova koje je postigao
-- u svojoj prethodnoj utakmici. Pomoću LAG() pronađite broj golova iz prethodne utakmice.
-- Izračunajte i razliku između broja golova na tekućoj i prethodnoj
-- utakmici. Rezultate sortirajte po nazivu kluba i datumu utakmice.

--u tabeli matches mi je sezona, match_id, golovi, kickoff_ts koji mogu da koristim za odredjivanje datuma utakmice

with matches1 as (select 
m.match_id, t.team_id, m.kickoff_ts,
case when t.team_id=m.home_team_id then m.home_goals
        when t.team_id=m.away_team_id then m.away_goals
        else 0 end as goals
from matches m
join teams t on (t.team_id=home_team_id or t.team_id=away_team_id) and m.season='2024/25'
where t.team_id=m.home_team_id or t.team_id=m.away_team_id
group by t.team_id, m.match_id, m.home_goals, m.away_goals, m.home_team_id, m.away_team_id, m.kickoff_ts
order by t.team_id asc, m.kickoff_ts asc, m.match_id asc
) --do ovde mi upit pokazuje meceve, timove i golove za svaku utakmicu, i home i away statusa; 
--select 
--match_id, home_team_id, away_team_id, home_goals, away_goals 
--from matches where match_id in (2133,2155,2216,2062,2165,2019,2222,2243,2279,2057,2302,2203) 
-- ovaj upit sam koristila da proverim da li je dobro slozio golove iz utakmica -jeste :)

select *,
lag(goals) over (partition by team_id order by team_id, kickoff_ts) as previous_match_goals,
goals-previous_match_goals as goal_diff
from matches1
order by team_id, match_id, kickoff_ts; --ovo ne mora jer sam u order by kod lag stavila kickoff_ts. 

--Mnogo mi se dopada ovaj lag() i lead() alat, jer sam se u prethodnim domacim bas pitala da li imaju 
--neke funkcije koje mogu da izvuku vrednosti iz prethodnih/sledecih redova. 



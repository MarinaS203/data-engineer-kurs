--Domaci zadatak 52 od 27.oktobra - prozorske funkcije, rows between


-- 1.За сваки клуб у сезони 2024/25 израчунајте колико је голова дао више или мање него на
-- претходној утакмици. Где је највећи скок?
select 
match_id, 
team_id, 
kickoff_ts,
goals_for, 
lag(goals_for) over (partition by team_id order by kickoff_ts, goals_for) as prethodni_mec,
goals_for-prethodni_mec as gol_razlika,
rank() over (order by abs(goals_for-lag(goals_for) over (partition by team_id order by kickoff_ts, goals_for)) desc) as rang
from team_matches
where season='2024/25'
qualify rang=1
order by team_id, kickoff_ts;

--select team_name from teams where team_id=4; Kingsbridge City

-- 2. Колико пута је клуб после победе победио и у следећој утакмици? Од колико победа после
-- којих постоји следећа утакмица?

select * from team_matches limit 10;
--treba mi da za jedan tim sortiram utakmice po kickoff_ts, i onda da kada je u trenutnom redu W, da brojim koliko puta je i u sledecem redu W

SELECT season, team_id, kickoff_ts,
LAG(kickoff_ts) OVER (PARTITION BY season, team_id ORDER BY kickoff_ts) AS prev_kickoff,
DATEDIFF(kickoff_ts,
LAG(kickoff_ts) OVER (PARTITION BY season, team_id ORDER BY kickoff_ts)) AS rest_days
FROM team_matches
WHERE season = '2024/25'
ORDER BY rest_days, team_id;

SELECT match_id, kickoff_ts, home_goals + away_goals AS goals,
SUM(home_goals + away_goals) OVER (ORDER BY kickoff_ts) AS running_default,
SUM(home_goals + away_goals) OVER (ORDER BY kickoff_ts, match_id
ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS running_rows
FROM matches
WHERE season = '2024/25' AND status = 'played'
ORDER BY kickoff_ts, match_id;

-- 1. Prosek datih golova u poslednjih 5 utakmica, uz izričit
-- okvir prozora. Koja je najveća vrednost? Računajte
-- samo kada prozor zaista ima 5 utakmica.
-- select 
-- match_id, 
-- kickoff_ts,  
-- home_goals+away_goals as total_goals_in_match
-- from matches
-- order by kickoff_ts, match_id; --upit koji sam koristila za proveru broja golova i proseka

select 
match_id, 
kickoff_ts,  
round(avg(home_goals+away_goals) over (order by kickoff_ts rows between 4 preceding and current row),2) as avg_goals 
from matches
where season='2024/25'
qualify (lag(match_id,4) over (order by kickoff_ts is not null))
order by kickoff_ts, match_id;
--Stavila sam ovako, uslov u qualify mu zadaje da proveri da li postoje prethodna ceitiri reda, odnosno za current row,
--da li je match_id u prethodna 4 reda null ili ne. Ako nije, onda pocinje da racuna proseke, zato upit vraca rezultat pocevsi od utakmice match_id=2005.
--Da bih izracunala najvecu vrednost, spakovacu ovaj upit koji mi trazi prosecnu vrednost u cte, a onda cu da pozovem upit za max.
with avg as(
select 
match_id, 
kickoff_ts,  
round(avg(home_goals+away_goals) over (order by kickoff_ts rows between 4 preceding and current row),2) as avg_goals 
from matches
where season='2024/25'
qualify (lag(match_id,4) over (order by kickoff_ts is not null))
order by kickoff_ts, match_id
)
select *, 
row_number() over (order by avg_goals desc) as rank
from avg
qualify rank=1;
--Za utakmicu match_id=2325 postize se maksimum proseka golova u prethodnih pet utakmica i iznosi 4.6.


-- 2. Tekući zbir datih golova svakog kluba u sezoni
-- 2024/25: ko je prvi stigao do 50 golova i kada?
--Ovde cu da koristim view team_matches, jer je lakše raditi sa golovima u okviru nje, zato što moram da grupisem po timu.
with current_table as (select 
match_id, 
kickoff_ts, 
team_id, 
sum(goals_for) over(partition by team_id order by kickoff_ts asc rows between unbounded preceding and current row) as current_goals
from team_matches
where season='2024/25'
) --pravi tabelu tekucih golova za svaki tim 
--Dalje hocu da poredim datume za svaki tim kada je prvi imao current_goals>=50
--opet cu gornji upit da stavim u cte, a onda cu da rangiram vremena za svaki tim, kada je prvi put postigao ovaj uslov.
select *,
row_number() over (partition by team_id order by current_goals asc) as rank
from current_table
where current_goals>=50
qualify rank=1 --sada sam napravila tabelu kada je svaki tim prvi put dostigao 50 golova, bez ovog donjeg order by timovi su sortirani to team_id
order by kickoff_ts asc; 
--kada se doda order by kickoff_ts asc, dobija se bas trazeno pitanje iz zadatka, prvi tim koji je dostigao 51 poen je tim 4, 
--u utakmici 2212, odigranoj 18. januara 2025. godine
select team_name from teams where team_id=4;
--Tim je Kingsbridge City. 

-- 3. Za svaku domaću utakmicu izračunajte promenu
-- posećenosti u odnosu na prethodnu domaću utakmicu
-- istog kluba u istoj sezoni. Gde je najveći pad i zašto?
--U tabeli matches me interesuju samo home_team_id, po njima pravim grupe. Sortiram sve po kickoff_ts, 
--posmatram kolonu attendance. Pošto posmatram u odnosu na prethodnu, treba mi lag funkcija. 
--Dakle, sortiram po vremenu utakmice, grupišem po timovima. 
with att as(
select
match_id, 
home_team_id, 
kickoff_ts, 
attendance,
lag(attendance) over (partition by home_team_id order by kickoff_ts asc) as previous_att 
from matches
where season='2024/25'
)

select *,
attendance-previous_att as att_diff,
row_number() over (order by attendance-previous_att asc) as rank
from att
where attendance-previous_att is not null
--qualify rank=1;

--Najveci pad posecenosti se dogodio u utakmici 2033, home_team_id 11, odigrano u sredu 14.9.2024., 
--jer je promenjen stadion. Na prethodnoj utakmici je bio stadium_id 22, a na ovoj stadium_id 11.
--Prvi stadion ima kapacitet 80000, a naredni 19500 posetilaca, zato takav pad u posecenosti. 
--Ukoliko bi nas zanimala apsolutna posecenost, a ne relativna kao ovde, trebalo bi da poredimo popunjenost kapaciteta stadiona, u procentima. 

select * from stadiums where stadium_id in (11,22);
select *from matches where home_team_id=11
order by kickoff_ts asc; --ove upite sam koristila da vidim sta se desava sa posecenoscu

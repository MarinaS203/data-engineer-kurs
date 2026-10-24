use bootcamp.northern_star;

-- Domaci 4.1 od 22.oktobra

-- 1. Koliko redova ima spoj matches i player_match_stats za sezonu 2024/25? Objasnite.
select * from matches; --761 red
select * from player_match_stats; --30440 redova
select distinct(match_id) from player_match_stats; --761 red 
select * 
from matches m 
join player_match_stats ps on ps.match_id=m.match_id; --30440 redova
--Komentar 1: Razlog zašto ovaj join vraća isti broj redova kao u player_match_stats je zato 
--sto ih povezujemo preko match id, a u ps tabeli za svaku utakmicu(match_id) imamo po vise redova.
--Tako da pri spajanju, redovi iz matches se umnoze (po match_id) da bi istovetni podaci bili za sve utakmice. (primer: ako je match id )
--Komentar 2: Ovde je bas ocigledno umnozavanje redova u smislu 30440/761 = 40 
--(sto je ukupan broj igraca u oba tima); dakle, dopisujemo sve podatke iz matches za svakog igraca u ps tabeli.

-- 2. Koliko puta je igrač u istoj sezoni igrao za dva različita kluba?
--Ovde je uradjen zadatak ispočetka, sa hintovima koje ste mi dali. 

select distinct(ps.player_id)
from player_match_stats ps   
join matches m on m.match_id=ps.match_id
group by player_id, season
having count(distinct(team_id))=2 
order by player_id asc;
--33 igraca su igrala za dva kluba u okviru iste sezone. 

-- Ovaj upit sam koristila da proverim da li je dobro, jer ispisuje igraca, tim i sezonu.
-- select ps.player_id, ps.team_id, m.season 
-- from player_match_stats ps   
-- join matches m on m.match_id=ps.match_id
-- group by player_id, team_id, season
-- --having count(distinct(team_id))=2 
-- order by player_id asc;

--Dole su svi nacini na koje sam pokusala da uradim zadatak. Ostavila sam i to, 
--da vidite alternativne pravce razmišljanja, mada ne znam da li su interesantni.
-- select * from player_match_stats
-- order by player_id asc; --igrac za player_id 11 je igrao i za team_id 1 i za team_id 18
-- select * from player_match_stats
-- where player_id=11;
-- select team_name from teams where team_id=1 or team_id=18; --Northport united i brackley harriers 
-- --zanima me dalje da li je to bilo u istoj sesoni
-- select season 
-- from matches m
-- join player_match_stats s on m.match_id=s.match_id
-- where player_id=11; --sve se desavalo u istoj sezoni
--Druga ideja: posmatram tabelu player_match_stats:
-- select contract_id, player_id, team_id, start_date,end_date from player_contracts
-- order by player_id asc;-717
-- select distinct (player_id) from player_contracts; -681

-- --Ovo je kod za ovaj zadatak. 
-- select contract_id, player_id, team_id, start_date, end_date 
-- from player_contracts pc
-- --join matches m on m.home_team_id=pc.team_id --or m.away_team_id=pc.team_id
-- where player_id in (select distinct(player_id)
--                         from player_contracts
--                         group by player_id
--                         having count(contract_id)=2) --and season = '2024/25'
-- order by player_id; --32 igraca su igrala za dva tima, to vraca podupit, a ovaj veliki upit 
--vraca 64 jer sam trazila contract_id i ostale podatke, pa je sve puta 2

-- 3. Koliko utakmica ima više kartona od prosečne utakmice? Bez kartona računajte sa 0.
 

--Najpre cu da proverim koji event_types su sve vrste kartona. 
select distinct (event_type) from match_events; --Imam 'yellow_card', 'second_yellow' , 'red_card'
--Ovaj zadatak je užasno rogobatan ispao, ali kako god da sam ga radila, nisam uspevala da ga uprostim. Verujem da se može uprostiti sa nekim CT-jevima, ali nisam se snašla na taj način. Ostavila sam ispod zadatke sve nacine na koje sam pokusavala ovo da resim. Ovaj nacin mi se ne dopada baš, ali (valjda) radi ispravno. 

  select match_id
  from match_events
  group by match_id
  having sum(case when event_type in ('red_card', 'yellow_card', 'second_yellow') then 1 
                  else 0
                  end) > (select avg(card_count) from (select sum(case when event_type in ('red_card', 'yellow_card', 'second_yellow') then 1 
                  else 0
                  end) as card_count
                  from match_events
                  group by match_id
                  ) as match_cards 
                  );
--370 utakmica ima vise kartona od prosecne utakmice

--  select 
--   count(distinct(match_id)) as num_of_matches,
--   sum(case when event_type in ('yellow_card', 'second_yellow' , 'red_card') then 1
--            else 0 
--       end) as total_cards,
--       round(total_cards/num_of_matches,2) as avg_cards
--    from match_events;
   --ovim querry-jem sam proverila: ima 760 meceva, 2678 ukupno, prosek je 3.52 kartona po mecu 


-- with tot_cards as(
-- select match_id,
--        sum(case when event_type in ('yellow_card', 'second_yellow' , 'red_card') then 1
--             when event_type is null then 0
--             else 0
--            end) as total_cards
--           from match_events
--           group by match_id), --ovo mi racuna ukupan broj kartona po mecu 
-- avg_card as(
--     select 
--     sum(total_cards)/761 as avg_cards
--     from tot_cards
-- ) 

-- select * from tot_cards, avg_card
-- having tot_cards.total_cards>avg_card.avg_cards;
--group by tot_cards.total_cards;

-- with tot_card as (
--     select 
--         sum(
--             case when event_type in ('yellow_card', 'second_yellow' , 'red_card') then 1
--             else 0
--             end
--         ) as total_cards
--         from match_events
-- );
-- with avg_card as
-- (
--     select avg(tot_cards)
--     from match_events
-- )
-- select count(match_id),
--     sum(
--             case when event_type in ('yellow_card', 'second_yellow' , 'red_card') then 1
--             else 0
--             end
--         ) as total_cards_in_match
-- from match_events 
-- where total_cards_in_match>avg_card;

-- 4. Koliko igrača je odigralo više od 10 utakmica u sezoni 2024/25?

-- select distinct (player_id)
-- from player_match_stats;  --vraca 650 redova, dakle imam 650 igraca ukupno

select distinct(player_id), 
count(s.match_id) as num_of_matches 
from player_match_stats s 
join matches m on m.match_id=s.match_id and m.season = '2024/25'  --mora ovaj dodatni uslov, pa tek onda da broji meceve; 
  --ako se ne stavi uslov, vraca 650 redova, sto je ukupan broj igraca, jer ne filtrira po sezoni kada spaja tabele 
group by player_id
having num_of_matches >10
order by num_of_matches desc;

--483 igraca je odigralo vise od 10 utakmica u sezoni 2024/25


-- 5. Prikažite sve klubove koji su igrali u sezoni 2024/25, bilo kao
-- domaćini ili kao gosti. Koristite UNION, a zatim izmenite upit
-- tako da koristi UNION ALL. Objasnite razliku u broju redova koji
-- dobijate.

with team_matches AS (
select distinct(home_team_id) from matches where season='2024/25'
union all
select distinct(away_team_id) from matches where season ='2024/25'
)
select * from team_matches; --sa union vraca 20 redova, sa union all 40 redova

--Razlika između UNION i UNION ALL je u tome što UNION spoji ove dve tabele, ali obriše duple rezultate,
--dok UNION ALL ujedini obe tabele, bez brisanja duplikata. 


--Sesije 1 i 2.
-- 1. Прикажите утакмице са више од 40.000 гледалаца у марту 2025. Колико их је?
-- 2. Прикажите све различите комбинације резултата (home_goals, away_goals) за одигране
-- утакмице, сортиране по укупном броју голова. Колико различитих резултата постоји?
-- 3. Који стадиони у имену имају реч „Park“?
-- 4. Прикажите утакмице без податка о посети или о времену: датум, тимове, посету и време, а уместо
-- NULL нека пише 'непознато'. Колико их је?

--1. 
select match_id
from matches 
where (month(kickoff_ts)=3 and year(kickoff_ts)=2025) and attendance>40000;

--2.
select distinct (home_goals+ away_goals) as total_goals, home_goals, away_goals 
from matches
where status='played'
order by (total_goals) desc; 

--3. 
select stadium_name 
from stadiums 
where stadium_name ilike ('%park%');
--6 stadiona

--4. Прикажите утакмице без податка о посети или о времену: датум, тимове, посету и време, а уместо
-- NULL нека пише 'непознато'. Колико их је?
select 
    date(kickoff_ts), home_team, away_team,
    coalesce(cast(attendance as string), 'nepoznato'),
    coalesce(cast(weather as string), 'nepoznato')
from matches_flat 
where attendance is null or weather is null;
--89 redova
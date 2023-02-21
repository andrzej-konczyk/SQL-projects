select * from final_group;

-- rules for knock out stage --

-- A1 vs B2
-- C1 vs D2
-- E1 vs F2
-- G1 vs H2
-- B1 vs A2
-- D1 vs C2
-- F1 vs E2
-- H1 vs G2

-- creation of R16 table
create table p_R16 as
WITH team_rank AS (
  SELECT group_name, team, predicted_rank,
         ROW_NUMBER() OVER (PARTITION BY group_name ORDER BY predicted_rank) AS group_rank,
         team AS team_name
  FROM final_group
)
SELECT t1.team_name AS group_winner, 
       t2.team_name AS runner_up
FROM team_rank t1
JOIN team_rank t2
ON t1.group_rank = 1 AND t2.group_rank = 2
AND (
  (t1.group_name = 'A' AND t2.group_name = 'B') OR
  (t1.group_name = 'B' AND t2.group_name = 'A') OR
  (t1.group_name = 'C' AND t2.group_name = 'D') OR
  (t1.group_name = 'D' AND t2.group_name = 'C') OR
  (t1.group_name = 'E' AND t2.group_name = 'F') OR
  (t1.group_name = 'F' AND t2.group_name = 'E') OR
  (t1.group_name = 'G' AND t2.group_name = 'H') OR
  (t1.group_name = 'H' AND t2.group_name = 'G') 
);

select * from p_R16;

-- now we have to estimate number of oals then winner
-- let's use non_penalty_xg_per_90 from opposit_team_results, and fifa_rank from final_league table as hints

-- before that we will change name Unitade States to USA

update opposit_team_results 
set team = 'USA'
where team = 'United States';

update final_league_table 
set team = 'USA'
where team = 'United States';

create table p_r16_fifa as
SELECT 
  p_R16.group_winner, 
  t1.xg_per_90_minutes AS xg_per_90_minuts_1, 
  f1.fifa_rank as fifa_rank_1,
  p_R16.runner_up, 
  t2.xg_per_90_minutes AS xg_per_90_minuts_2,
  f2.fifa_rank as fifa_rank_2
FROM p_R16
LEFT JOIN opposit_team_results t1
ON p_R16.group_winner = t1.team
LEFT JOIN opposit_team_results t2
ON p_R16.runner_up = t2.team
LEFT JOIN final_league_table f1
ON p_R16.group_winner = f1.team
LEFT JOIN final_league_table f2
ON p_R16.runner_up = f2.team;

-- for prediction of number of goals in next phases I will use combination of avg xg_per_90_min and fifa rank, but I will also check how real results took place in such rank teams
-- firstly I will check max fifa rank 

select max(fifa_rank)
from final_league_table flt ;

-- max is 60

-- there will be first assumption - handicap for fifa rank , let's have 6 levels (1-10 / 11-20 / 21 -30 / 31 - 40 / 41-50 / 51 - 60)

-- additionally let's have a look for fifa_ranks results in knock out stage

create table clear_knock_out as
select team_1, goals_1, total_xg_1, team_2, goals_2, total_xg_2 from direct_match
where phase not like 'GR';


create table weight_clear_table as
SELECT
t1.team_1,
t1.goals_1,
t1.total_xg_1,
t2.fifa_rank AS fifa_rank_1,
CASE
WHEN t2.fifa_rank BETWEEN 1 AND 10 THEN 0.6
WHEN t2.fifa_rank BETWEEN 11 AND 20 THEN 0.5
WHEN t2.fifa_rank BETWEEN 21 AND 30 THEN 0.4
WHEN t2.fifa_rank BETWEEN 31 AND 40 THEN 0.3
WHEN t2.fifa_rank BETWEEN 41 AND 50 THEN 0.2
WHEN t2.fifa_rank BETWEEN 51 AND 60 THEN 0.1
ELSE 0.0
END AS weight_1,
t1.total_xg_1 *
CASE
WHEN t2.fifa_rank BETWEEN 1 AND 10 THEN 0.6
WHEN t2.fifa_rank BETWEEN 11 AND 20 THEN 0.5
WHEN t2.fifa_rank BETWEEN 21 AND 30 THEN 0.4
WHEN t2.fifa_rank BETWEEN 31 AND 40 THEN 0.3
WHEN t2.fifa_rank BETWEEN 41 AND 50 THEN 0.2
WHEN t2.fifa_rank BETWEEN 51 AND 60 THEN 0.1
ELSE 0.0
END AS weighted_total_xg_1,
t1.team_2,
t1.goals_2,
t1.total_xg_2,
t3.fifa_rank AS fifa_rank_2,
CASE
WHEN t3.fifa_rank BETWEEN 1 AND 10 THEN 0.6
WHEN t3.fifa_rank BETWEEN 11 AND 20 THEN 0.5
WHEN t3.fifa_rank BETWEEN 21 AND 30 THEN 0.4
WHEN t3.fifa_rank BETWEEN 31 AND 40 THEN 0.3
WHEN t3.fifa_rank BETWEEN 41 AND 50 THEN 0.2
WHEN t3.fifa_rank BETWEEN 51 AND 60 THEN 0.1
ELSE 0.0
END AS weight_2,
t1.total_xg_2 *
CASE
WHEN t3.fifa_rank BETWEEN 1 AND 10 THEN 0.6
WHEN t3.fifa_rank BETWEEN 11 AND 20 THEN 0.5
WHEN t3.fifa_rank BETWEEN 21 AND 30 THEN 0.4
WHEN t3.fifa_rank BETWEEN 31 AND 40 THEN 0.3
WHEN t3.fifa_rank BETWEEN 41 AND 50 THEN 0.2
WHEN t3.fifa_rank BETWEEN 51 AND 60 THEN 0.1
ELSE 0.0
END AS weighted_total_xg_2
FROM
clear_knock_out t1
LEFT JOIN final_league_table t2
ON t1.team_1 = t2.team
LEFT JOIN final_league_table t3
ON t1.team_2 = t3.team;

SELECT 
  team_1, 
  goals_1, 
  weighted_total_xg_1, 
  team_2, 
  goals_2, 
  weighted_total_xg_2, 
  CASE 
    WHEN weighted_total_xg_1 > weighted_total_xg_2 THEN team_1 
    WHEN weighted_total_xg_1 < weighted_total_xg_2 THEN team_2 
    ELSE 'draw' 
  END AS weighted_winner 
from weight_clear_table;

-- only in 3 cases such kind of predidtion did nowrk properly so I will use it to predict all results :)

select * from p_r16_fifa;

create table table_temp_p_r16_fifa as
WITH p_r16_fifa_new AS (
SELECT
group_winner AS team_1,
xg_per_90_minuts_1,
fifa_rank_1,
(CASE
WHEN fifa_rank_1 BETWEEN 1 AND 10 THEN 0.6
WHEN fifa_rank_1 BETWEEN 11 AND 20 THEN 0.5
WHEN fifa_rank_1 BETWEEN 21 AND 30 THEN 0.4
WHEN fifa_rank_1 BETWEEN 31 AND 40 THEN 0.3
WHEN fifa_rank_1 BETWEEN 41 AND 50 THEN 0.3
WHEN fifa_rank_1 BETWEEN 51 AND 60 THEN 0.1
ELSE 0
END) AS weight_1,
runner_up AS team_2,
xg_per_90_minuts_2,
fifa_rank_2,
(CASE
WHEN fifa_rank_2 BETWEEN 1 AND 10 THEN 0.6
WHEN fifa_rank_2 BETWEEN 11 AND 20 THEN 0.5
WHEN fifa_rank_2 BETWEEN 11 AND 20 THEN 0.5
WHEN fifa_rank_2 BETWEEN 21 AND 30 THEN 0.4
WHEN fifa_rank_2 BETWEEN 31 AND 40 THEN 0.3
WHEN fifa_rank_2 BETWEEN 41 AND 50 THEN 0.3
WHEN fifa_rank_2 BETWEEN 51 AND 60 THEN 0.1
ELSE 0
END) AS weight_2
FROM p_r16_fifa
)
SELECT
team_1, xg_per_90_minuts_1, fifa_rank_1, weight_1,
team_2, xg_per_90_minuts_2, fifa_rank_2, weight_2
FROM p_r16_fifa_new;



SELECT team_1, weight_calc_1, team_2, weight_calc_2, 
       CASE 
           WHEN weight_calc_1 = weight_calc_2 THEN 'draw' 
           WHEN weight_calc_1 > weight_calc_2 THEN team_1 
           ELSE team_2 
       END as winner 
FROM (
  SELECT team_1, weight_1 * xg_per_90_minuts_1 as weight_calc_1, 
         team_2, weight_2 * xg_per_90_minuts_2 as weight_calc_2
  FROM table_temp_p_r16_fifa
) subquery;


create table p_r16_final as
WITH results AS (
  SELECT 
    team_1, 
    xg_per_90_minuts_1 * weight_1 AS weight_calc_1, 
    team_2, 
    xg_per_90_minuts_2 * weight_2 AS weight_calc_2
  FROM 
    table_temp_p_r16_fifa
),
SELECT_winners AS (
  SELECT 
    team_1, 
    weight_calc_1, 
    team_2, 
    weight_calc_2, 
    CASE 
      WHEN ABS(weight_calc_1 - weight_calc_2) > 0.2 THEN 
        CASE 
          WHEN weight_calc_1 > weight_calc_2 THEN team_1
          ELSE team_2
        END
      ELSE 
        'extra time' 
    END AS winner, 
    NULL AS extra_time, 
    NULL AS penalties
  FROM 
    results
), 
SELECT_extra_time AS (
  SELECT 
    team_1, 
    weight_calc_1, 
    team_2, 
    weight_calc_2, 
    winner, 
    CASE 
      WHEN winner = 'extra time' AND ABS(weight_calc_1 - weight_calc_2) > 0.1 THEN 
        CASE 
          WHEN weight_calc_1 > weight_calc_2 THEN team_1
          ELSE team_2
        END
      ELSE 
        NULL
    END AS extra_time, 
    NULL AS penalties
  FROM 
    SELECT_winners
), 
SELECT_penalties AS (
  SELECT 
    team_1, 
    weight_calc_1, 
    team_2, 
    weight_calc_2, 
    winner, 
    extra_time, 
    CASE 
      WHEN extra_time IS NULL THEN 
        null
      when extra_time is not null and ABS(weight_calc_1 - weight_calc_2) <= 0.1 then
        CASE 
          WHEN RANDOM() < 0.5 THEN team_1
          ELSE team_2
        END
    END AS penalties
  FROM 
    SELECT_extra_time
)
SELECT 
  team_1, 
  weight_calc_1, 
  team_2, 
  weight_calc_2, 
  winner, 
  extra_time, 
  penalties
FROM 
  SELECT_penalties;


-- I add column with all next round teams
ALTER TABLE p_r16_final
ADD COLUMN next_round varchar(255);

UPDATE p_r16_final
SET next_round = 
    CASE
        WHEN winner != 'extra time' THEN winner
        WHEN extra_time != 'penalties' THEN extra_time
        ELSE penalties
    END;

   
select * from p_r16_final;

ALTER TABLE p_r16_final
ADD COLUMN id serial PRIMARY KEY;


-- create quaters table

CREATE TABLE quaters (
  team_1 varchar(255),
  team_2 varchar(255),
  weight_calc_1 float,
  weight_calc_2 float,
  id serial primary key
  );
 

INSERT INTO quaters (team_1)
select next_round
FROM p_r16_final 
WHERE p_r16_final .id in (1,2,5,6);


update quaters
	set team_2=
		case team_1
			when 'USA' then 'Argentina'
			when 'England' then 'France'
			when 'Germany' then 'Brazil'
			when 'Spain' then 'Switzerland'
		end
	where team_2 is null;

-- now is time to add new wight_cals. I will do that as sum from previous round : it means, that if team A won against team B, then team A new weight calc is sum of weight calc A + bikes B
-- here we have case of real match, so fo that particular case I will do prediction like in group stage

---
select * from direct_match 
where phase = 'QF'
and team_1 = 'England'

---


update quaters 
	set weight_calc_1 =
		case team_1
			when 'USA' then (select weight_calc_1 + weight_calc_2 from p_r16_final where next_round = 'USA')
			when 'Germany' then (select weight_calc_1 + weight_calc_2 from p_r16_final where next_round = 'Germany')
			when 'Spain' then (select weight_calc_1 + weight_calc_2 from p_r16_final where next_round = 'Spain')
			when 'England' then (select weight_calc_1 + weight_calc_2 from p_r16_final where next_round = 'England')
		end
	where weight_calc_1 is null;

update quaters
	set weight_calc_2 =
		case team_2
			when 'Argentina' then (select weight_calc_1 + weight_calc_2 from p_r16_final where next_round = 'Argentina')
			when 'Brazil' then (select weight_calc_1 + weight_calc_2 from p_r16_final where next_round = 'Brazil')
			when 'Switzerland' then (select weight_calc_1 + weight_calc_2 from p_r16_final where next_round = 'Switzerland')
			when 'France' then (select weight_calc_1 + weight_calc_2 from p_r16_final where next_round = 'France')
		end
	where weight_calc_2 is null;

select * from quaters 

-- now let's predict results
-- each next phase is harder than previous one - change rules from 0.2 in 90 min to 0.3 and from 0.1 in extra time to 0.15

create table semi_final as
WITH results AS (
  SELECT 
  	id,
    team_1, 
    weight_calc_1, 
    team_2, 
    weight_calc_2
  FROM 
    quaters
),
SELECT_winners AS (
  select
  	id,
    team_1, 
    weight_calc_1, 
    team_2, 
    weight_calc_2, 
    CASE 
      WHEN ABS(weight_calc_1 - weight_calc_2) > 0.3 THEN 
        CASE 
          WHEN weight_calc_1 > weight_calc_2 THEN team_1
          ELSE team_2
        END
      ELSE 
        'extra time' 
    END AS winner, 
    NULL AS extra_time, 
    NULL AS penalties
  FROM 
    results
), 
SELECT_extra_time AS (
  SELECT 
  	id,
    team_1, 
    weight_calc_1, 
    team_2, 
    weight_calc_2, 
    winner, 
    CASE 
      WHEN winner = 'extra time' AND ABS(weight_calc_1 - weight_calc_2) > 0.15 THEN 
        CASE 
          WHEN weight_calc_1 > weight_calc_2 THEN team_1
          ELSE team_2
        END
      ELSE 
        'penalties'
    END AS extra_time, 
    NULL AS penalties
  FROM 
    SELECT_winners
), 
SELECT_penalties AS (
  SELECT 
  	id,
    team_1, 
    weight_calc_1, 
    team_2, 
    weight_calc_2, 
    winner, 
    extra_time, 
    CASE 
      WHEN extra_time IS NULL THEN 
        null
      when extra_time is not null and ABS(weight_calc_1 - weight_calc_2) <= 0.15 then
        CASE 
          WHEN RANDOM() < 0.5 THEN team_1
          ELSE team_2
        END
    END AS penalties
  FROM 
    SELECT_extra_time
)
SELECT 
  id,
  team_1, 
  weight_calc_1, 
  team_2, 
  weight_calc_2, 
  winner, 
  extra_time, 
  penalties
FROM 
  SELECT_penalties;
 
 -- clean - se null when winner is not extra time
 
update semi_final
set extra_time = null
where winner != 'extra time';

-- I add column with all next round teams
ALTER TABLE semi_final
ADD COLUMN next_round varchar(255);

UPDATE semi_final
SET next_round = 
    CASE
        WHEN winner != 'extra time' THEN winner
        WHEN extra_time != 'penalties' THEN extra_time
        ELSE penalties
    END;

   
select * from semi_final 
order by id ;


-- next step, semi-finals pairs

CREATE TABLE semi_final_pairs
 (team_1 varchar(255),
  team_2 varchar(255),
  weight_calc_1 float,
  weight_calc_2 float,
  id serial primary key
  );
 
  INSERT INTO semi_final_pairs(team_1)
select next_round
FROM semi_final
WHERE semi_final.id in(1,2);


-- base on semi_final table:
update semi_final_pairs 
	set team_2=
		case team_1
			when 'Argentina' then 'Brazil'
			when 'France' then 'Switzerland'
		end
	where team_2 is null;


-- fill in weight calcs

update semi_final_pairs 
	set weight_calc_1 =
		case team_1
			when 'France'then (select weight_calc_1 + weight_calc_2 from semi_final where next_round = 'France')
			when 'Argentina'then (select weight_calc_1 + weight_calc_2 from semi_final where next_round = 'Argentina')
		end
	where weight_calc_1 is null;

update semi_final_pairs
	set weight_calc_2 =
		case team_2
			when 'Brazil' then (select weight_calc_1 + weight_calc_2 from semi_final where next_round = 'Brazil')
			when 'Switzerland' then (select weight_calc_1 + weight_calc_2 from semi_final where next_round = 'Switzerland')
		end
	where weight_calc_2 is null;

-- let's have winners - new rule, win 90 min when 0.4 diff, extra time when 0.2 diff

create table semi_final_results as
WITH results AS (
  SELECT 
  	id,
    team_1, 
    weight_calc_1, 
    team_2, 
    weight_calc_2
  FROM 
    semi_final_pairs
),
SELECT_winners AS (
  select
  	id,
    team_1, 
    weight_calc_1, 
    team_2, 
    weight_calc_2, 
    CASE 
      WHEN ABS(weight_calc_1 - weight_calc_2) > 0.4THEN 
        CASE 
          WHEN weight_calc_1 > weight_calc_2 THEN team_1
          ELSE team_2
        END
      ELSE 
        'extra time' 
    END AS winner, 
    NULL AS extra_time, 
    NULL AS penalties
  FROM 
    results
), 
SELECT_extra_time AS (
  SELECT 
  	id,
    team_1, 
    weight_calc_1, 
    team_2, 
    weight_calc_2, 
    winner, 
    CASE 
      WHEN winner = 'extra time' AND ABS(weight_calc_1 - weight_calc_2) > 0.2 THEN 
        CASE 
          WHEN weight_calc_1 > weight_calc_2 THEN team_1
          ELSE team_2
        END
      ELSE 
        'penalties'
    END AS extra_time, 
    NULL AS penalties
  FROM 
    SELECT_winners
), 
SELECT_penalties AS (
  SELECT 
  	id,
    team_1, 
    weight_calc_1, 
    team_2, 
    weight_calc_2, 
    winner, 
    extra_time, 
    CASE 
      WHEN extra_time IS NULL THEN 
        null
      when extra_time is not null and ABS(weight_calc_1 - weight_calc_2) <= 0.2 then
        CASE 
          WHEN RANDOM() < 0.5 THEN team_1
          ELSE team_2
        END
    END AS penalties
  FROM 
    SELECT_extra_time
)
SELECT 
  id,
  team_1, 
  weight_calc_1, 
  team_2, 
  weight_calc_2, 
  winner, 
  extra_time, 
  penalties
FROM 
  SELECT_penalties;
 
 
  -- clean - see null when winner is not extra time
 
update semi_final_results
set extra_time = null
where winner != 'extra time';

select * from semi_final_results 

-- now is time to create final match and 3rd place match 

--final match 

-- next step, semi-finals pairs

CREATE TABLE final_pair
 (team_1 varchar(255),
  team_2 varchar(255),
  weight_calc_1 float,
  weight_calc_2 float
  );
 
  INSERT INTO final_pair(team_1)
select winner
FROM semi_final_results
WHERE semi_final_results.id ='1'

select * from final_pair


-- base on semi_final table:
update final_pair
	set team_2= 'Brazil'
	where team_2 is null;


-- fill in weight calcs

update final_pair
	set weight_calc_1 =
		case team_1
			when 'France'then (select weight_calc_1 + weight_calc_2 from semi_final_results where winner='France')
		end
	where weight_calc_1 is null;

update final_pair
	set weight_calc_2 =
		case team_2
			when 'Brazil' then (select weight_calc_1 + weight_calc_2 from semi_final_results where winner = 'Brazil')
		end
	where weight_calc_2 is null;


-- let's have winners - new rule, win 90 min when 0.5 diff, extra time when 0.3 diff - final pair

create table final_results as
WITH results AS (
  SELECT 
    team_1, 
    weight_calc_1, 
    team_2, 
    weight_calc_2
  FROM 
    final_pair
),
SELECT_winners AS (
  select
    team_1, 
    weight_calc_1, 
    team_2, 
    weight_calc_2, 
    CASE 
      WHEN ABS(weight_calc_1 - weight_calc_2) > 0.5 THEN 
        CASE 
          WHEN weight_calc_1 > weight_calc_2 THEN team_1
          ELSE team_2
        END
      ELSE 
        'extra time' 
    END AS winner, 
    NULL AS extra_time, 
    NULL AS penalties
  FROM 
    results
), 
SELECT_extra_time AS (
  SELECT 
    team_1, 
    weight_calc_1, 
    team_2, 
    weight_calc_2, 
    winner, 
    CASE 
      WHEN winner = 'extra time' AND ABS(weight_calc_1 - weight_calc_2) > 0.3 THEN 
        CASE 
          WHEN weight_calc_1 > weight_calc_2 THEN team_1
          ELSE team_2
        END
      ELSE 
        'penalties'
    END AS extra_time, 
    NULL AS penalties
  FROM 
    SELECT_winners
), 
SELECT_penalties AS (
  SELECT 
    team_1, 
    weight_calc_1, 
    team_2, 
    weight_calc_2, 
    winner, 
    extra_time, 
    CASE 
      WHEN extra_time IS NULL THEN 
        null
      when extra_time is not null and ABS(weight_calc_1 - weight_calc_2) <= 0.3 then
        CASE 
          WHEN RANDOM() < 0.5 THEN team_1
          ELSE team_2
        END
    END AS penalties
  FROM 
    SELECT_extra_time
)
SELECT 
  team_1, 
  weight_calc_1, 
  team_2, 
  weight_calc_2, 
  winner, 
  extra_time, 
  penalties
FROM 
  SELECT_penalties;
 
 
 select * from final_results
 
 --clean data - remove penalties from extra time section
 
update final_results
set extra_time = null
where winner != 'extra time';

select * from final_results

-- The winner is Brazil !

-- now let's check 3rd place game


 CREATE TABLE _3rd_place_pair
 (team_1 varchar(255),
  team_2 varchar(255),
  weight_calc_1 float,
  weight_calc_2 float
  );


INSERT INTO _3rd_place_pair(team_1)
select 
	case 
		when team_1 = winner then team_2
		when team_2 = winner then team_1 
	end as team_1
FROM semi_final_results
WHERE semi_final_results.id ='1';

-- base on semi_final results:
update _3rd_place_pair
	set team_2= 'Argentina'
	where team_2 is null;


-- fill in weight calcs

update _3rd_place_pair
	set weight_calc_1 =
		case team_1
			when 'Switzerland' then (select weight_calc_1 + weight_calc_2 from semi_final where next_round = 'Switzerland')
		end
	where weight_calc_1 is null;


update _3rd_place_pair
	set weight_calc_2 =
		case team_2
			when 'Argentina' then (select weight_calc_1 + weight_calc_2 from semi_final where next_round = 'Argentina')
		end
	where weight_calc_2 is null;



-- let's have winners - new rule, win 90 min when 0.5 diff, extra time when 0.3 diff - 3rd place pair

create table third_place_results as
WITH results AS (
  SELECT 
    team_1, 
    weight_calc_1, 
    team_2, 
    weight_calc_2
  FROM 
    _3rd_place_pair
),
SELECT_winners AS (
  select
    team_1, 
    weight_calc_1, 
    team_2, 
    weight_calc_2, 
    CASE 
      WHEN ABS(weight_calc_1 - weight_calc_2) > 0.5 THEN 
        CASE 
          WHEN weight_calc_1 > weight_calc_2 THEN team_1
          ELSE team_2
        END
      ELSE 
        'extra time' 
    END AS winner, 
    NULL AS extra_time, 
    NULL AS penalties
  FROM 
    results
), 
SELECT_extra_time AS (
  SELECT 
    team_1, 
    weight_calc_1, 
    team_2, 
    weight_calc_2, 
    winner, 
    CASE 
      WHEN winner = 'extra time' AND ABS(weight_calc_1 - weight_calc_2) > 0.3 THEN 
        CASE 
          WHEN weight_calc_1 > weight_calc_2 THEN team_1
          ELSE team_2
        END
      ELSE 
        'penalties'
    END AS extra_time, 
    NULL AS penalties
  FROM 
    SELECT_winners
), 
SELECT_penalties AS (
  SELECT 
    team_1, 
    weight_calc_1, 
    team_2, 
    weight_calc_2, 
    winner, 
    extra_time, 
    CASE 
      WHEN extra_time IS NULL THEN 
        null
      when extra_time is not null and ABS(weight_calc_1 - weight_calc_2) <= 0.3 then
        CASE 
          WHEN RANDOM() < 0.5 THEN team_1
          ELSE team_2
        END
    END AS penalties
  FROM 
    SELECT_extra_time
)
SELECT 
  team_1, 
  weight_calc_1, 
  team_2, 
  weight_calc_2, 
  winner, 
  extra_time, 
  penalties
FROM 
  SELECT_penalties;



select * from third_place_results;

-- Argentina got 3rd place after penalties :)




















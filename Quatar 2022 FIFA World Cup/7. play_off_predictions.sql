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


select * from p_r16_final;








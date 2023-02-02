select * from final_league_table;

-- creation of column fifa_rank to have overview and define rules for tournament expected winners in next phases --
alter table final_league_table 
add fifa_rank integer;

update final_league_table 
set fifa_rank = 
	case id 
		when 1 then 4
		when 2 then 3
		when 3 then 22
		when 4 then 12
		when 5 then 8
		when 6 then 5
		when 7 then 1
		when 8 then 9
		when 9 then 24
		when 10 then 38
		when 11 then 18
		when 12 then 15
		when 13 then 7
		when 14 then 16
		when 15 then 26
		when 16 then 28
		when 17 then 44
		when 18 then 11
		when 19 then 30
		when 20 then 43
		when 21 then 14
		when 22 then 13
		when 23 then 2
		when 24 then 60
		when 25 then 50
		when 26 then 20
		when 27 then 31
		when 28 then 10
		when 29 then 21
		when 30 then 19
		when 31 then 41
		when 32 then 51
	end;
---------------------------------------	
select * from final_league_table; -- check if all is fine



-- creation table which will be used for predition of results --
create table opposit_team_results
as select
opposite, opposite_average_posession , opposite_goals_per_90_minutes , opposite_goals_excluding_penalties_per_90_minutes , opposite_xg_per_90_minutes , opposite_non_penalty_xg , team, average_posession , goals_per_90_minutes , goals_excluding_penalties_per_90_minutes , xg_per_90_minutes , non_penalty_xg 
from team_and_opposition_stats; 
-----------------------------------
select * from opposit_team_results; -- check if all is fine

-------------------------------
-- creation table for direct macthes for future predictions - main table for direct matches
create table direct_match 
as
select phase, team_1, goals_1 , total_xg_1 , posession_1 , team_2, goals_2 , total_xg_2 , posession_2 
from match_by_match_stat
order by id asc;

alter table direct_match
add fifa_rank_1 integer;

alter table direct_match
add fifa_rank_2 integer;

--update by fifa ranks
UPDATE direct_match
SET fifa_rank_1 = (
SELECT fifa_rank
FROM final_league_table
WHERE final_league_table.team = direct_match.team_1
)
WHERE fifa_rank_1 IS null;


UPDATE direct_match
SET fifa_rank_2 = (
SELECT fifa_rank
FROM final_league_table
WHERE final_league_table.team = direct_match.team_2
)
WHERE fifa_rank_2 IS null;

select * from direct_match; -- check if we have all data

-- I will fill; in NULL by data from official ranks



update direct_match 
set fifa_rank_1 =
	case team_1
		when 'USA' then 16
		when 'Iran' then 20
		when 'Switzerland' then 15
	end
where fifa_rank_1 is null;

select * from direct_match; -- check if we have all fifa ranks

update direct_match 
set team_1 =
	case team_1
		when 'Iran ' then 'Iran'
		when 'Switzerland ' then 'Switzerland'
	end 
where fifa_rank_1 is null; -- I've seen white spaces here

update direct_match 
set fifa_rank_1 =
	case team_1
		when 'USA' then 16
		when 'Iran' then 20
		when 'Switzerland' then 15
	end
where fifa_rank_1 is null; -- double to be sure

update direct_match 
set fifa_rank_2 = 
	case team_2
		when 'USA' then 16
		when 'Iran' then 20
		when 'Switzerland' then 15
	end
where fifa_rank_2 is null;

select * from direct_match; -- check if we have all fifa ranks

-- now we will add winfo which group it was

alter table direct_match 
add column group_name varchar(100);

update direct_match
set group_name =
	case team_1  
		when 'Qatar' then 'A'
		when 'Senegal' then 'A'
		when 'Ecuador' then 'A'
		when 'England' then 'B'
		when 'Wales' then 'B'
		when 'USA' then 'B'
		when 'Argentina' then 'C'
		when 'Poland' then 'C'
		when 'Saudi Arabia' then 'C'
		when 'Tunisia' then 'D'
		when 'France' then 'D'
		when 'Australia' then 'D'
		when 'Germany' then 'E'
		when 'Spain' then 'E'
		when 'Japan' then 'E'
		when 'Canada' then 'F'
		when 'Croatia' then 'F'
		when 'Belgium' then 'F'
		when 'Serbia' then 'G'
		when 'Brazil' then 'G'
		when 'Cameroon' then 'G'
		when 'Ghana' then 'H'
		when 'Portugal' then 'H'
		when 'Uruguay' then 'H'
	end
where phase = 'GR';

update direct_match
set group_name =
	case team_2 
		when 'Qatar' then 'A'
		when 'Senegal' then 'A'
		when 'Ecuador' then 'A'
		when 'England' then 'B'
		when 'Wales' then 'B'
		when 'USA' then 'B'
		when 'Argentina' then 'C'
		when 'Poland' then 'C'
		when 'Saudi Arabia' then 'C'
		when 'Tunisia' then 'D'
		when 'France' then 'D'
		when 'Australia' then 'D'
		when 'Germany' then 'E'
		when 'Spain' then 'E'
		when 'Japan' then 'E'
		when 'Canada' then 'F'
		when 'Croatia' then 'F'
		when 'Belgium' then 'F'
		when 'Serbia' then 'G'
		when 'Brazil' then 'G'
		when 'Cameroon' then 'G'
		when 'Ghana' then 'H'
		when 'Portugal' then 'H'
		when 'Uruguay' then 'H'
	end
where phase = 'GR'
and group_name is null;

select * from direct_match 
order by group_name asc


-- now I will add columns for predicted goals 1 and goals 2 base on total xgs and goals against

alter table direct_match
add column goal_1_against integer;

alter table direct_match 
add column goal_2_against integer;

alter table direct_match 
add column p_goals_1 integer;

alter table direct_match 
add column p_goals_2 integer;

alter table direct_match
add column P_goals_1_against integer;

alter table direct_match
add column p_goals_2_against integer;




-- let's make assumption: number of predictect goals will be round to integer xg

UPDATE direct_match
SET p_goals_1 = ROUND(total_xg_1),
p_goals_2 = ROUND(total_xg_2)
where p_goals_1 is null and p_goals_2 is null and group_name is not null;

select * from direct_match
order by group_name asc;

-- fill in goal against

UPDATE direct_match
SET goal_1_against = (goals_2::INT), goal_2_against = (goals_1::INT)
where goal_1_against is null and goal_2_against is null and phase = 'GR';

select * from direct_match
order by group_name asc;


-- now I will add column for points after real result and predicted result 

alter table direct_match 
add column points_1 integer;

alter table direct_match 
add column points_2 integer;

alter  table direct_match 
add column p_points_1 integer;

alter  table direct_match 
add column p_points_2 integer;



-- here I will assign number of points base on results
UPDATE direct_match
SET points_1 = CASE
WHEN goals_1 > goals_2 THEN 3
WHEN goals_1 = goals_2 THEN 1
ELSE 0
END,
p_points_1 = CASE
WHEN p_goals_1 > p_goals_2 THEN 3
WHEN p_goals_1 = p_goals_2 THEN 1
ELSE 0
end,
points_2 = CASE
WHEN goals_1 < goals_2 THEN 3
WHEN goals_1 = goals_2 THEN 1
ELSE 0
end,
p_points_2 = CASE
WHEN p_goals_1 < p_goals_2 THEN 3
WHEN p_goals_1 = p_goals_2 THEN 1
ELSE 0
end
where group_name is not null;


select * from direct_match
order by group_name asc

-- now fill in p_goals against

UPDATE direct_match
SET p_goals_1_against = p_goals_2, p_goals_2_against = p_goals_1
where p_goals_1_against is null and p_goals_2_against is null and phase = 'GR';

select * from direct_match
order by group_name asc;

---
-- I will create table to have only data for team, group, points and goals 

create table group_table as
SELECT 
  group_name, 
  team, 
  SUM(points::INT) AS total_points,
  SUM(p_points::INT) AS total_p_points,
  SUM(goals::INT) AS total_goals,
  SUM(p_goals::INT) AS total_p_goals,
  SUM(goals_lost::INT) AS total_goals_lost,
  SUM(p_goals_lost::INT) AS total_p_goals_lost
FROM (
  SELECT 
    group_name, 
    team_1 AS team, 
    points_1 AS points,
    p_points_1 AS p_points,
    goals_1 AS goals,
    p_goals_1 AS p_goals,
    goal_1_against as goals_lost,
    p_goals_1_against as p_goals_lost
  FROM direct_match
  UNION ALL
  SELECT 
    group_name, 
    team_2 AS team, 
    points_2 AS points,
    p_points_2 AS p_points,
    goals_2 AS goals,
    p_goals_2 AS p_goals,
    goal_2_against as goals_lost,
    p_goals_2_against as p_goals_lost
  FROM direct_match
) subquery
where group_name is not null
GROUP BY 
  group_name, 
  team
order by group_name asc;


select * from group_table; -- check if is fine

-- now I will add diff goals columns
alter table group_table 
add column goal_diff integer;

alter table group_table
add column p_goal_diff integer;

UPDATE group_table 
SET goal_diff = total_goals - total_goals_lost,
p_goal_diff = total_p_goals - total_p_goals_lost
where goal_diff is null and p_goal_diff is null;

---
-- real data table

create table real_group_results
as
select group_name, team, total_points, total_goals, goal_diff
from group_table
order by group_name, total_points desc, goal_diff desc, total_goals desc;

-- predicted data table

create table predicted_group_results
as
select group_name, team, total_p_points, total_p_goals, p_goal_diff
from group_table
order by group_name, total_p_points desc, p_goal_diff desc, total_p_goals desc;


-- order
create table real_order as
SELECT group_name, team, total_points, total_goals, goal_diff, 
       (row_number() OVER (PARTITION BY group_name ORDER BY total_points desc, goal_diff desc, total_goals desc) - 1) % 4 + 1 AS rank
FROM real_group_results
ORDER BY group_name, rank;


create table predicted_order as
SELECT group_name, team, total_p_points, total_p_goals, p_goal_diff, 
       (row_number() OVER (PARTITION BY group_name ORDER BY total_p_points desc, p_goal_diff desc, total_p_goals desc) - 1) % 4 + 1 AS rank
FROM predicted_group_results
ORDER BY group_name, rank;


create table final_group as
SELECT real_order.group_name, real_order.team, real_order.rank,predicted_order.rank as predicted_rank,real_order.total_points, real_order.total_goals, real_order.goal_diff, 
		predicted_order.total_p_points, predicted_order.total_p_goals, predicted_order.p_goal_diff
FROM real_order
JOIN predicted_order
ON real_order.team = predicted_order.team;









-- start from creation output table
create table all_predicted_results
	(phase varchar(100),
	group_name varchar(100),
	team_1 varchar(100),
	team_2 varchar(100),
	goals_1 varchar(100),
	goals_2 varchar(100),
	extra_time varchar(100),
	penalties varchar(100));
	
-- insert predicted group results
insert into all_predicted_results (phase, group_name, team_1, team_2, goals_1, goals_2)
select phase, group_name, team_1, team_2, p_goals_1, p_goals_2
from direct_match
where phase = 'GR'

--change data type for goals
alter table all_predicted_results 
alter column goals_1 type integer
USING goals_1::integer;

alter table all_predicted_results 
alter column goals_2 type integer
USING goals_2::integer;

-- I will add column winner
alter table all_predicted_results 
add column winner varchar(100);

-- insert R16 results
insert into all_predicted_results (team_1,team_2,extra_time, penalties, winner)
select team_1, team_2, extra_time, penalties, next_round from p_r16_final;

--cleaninig
update all_predicted_results 
set phase = 'R16'
where phase is null;

update all_predicted_results 
set group_name = 'N/A'
where group_name is null;

update all_predicted_results 
set extra_time = 'N/A'
where phase = 'GR';

update all_predicted_results 
set penalties = 'N/A'
where phase = 'GR';

update all_predicted_results 
set extra_time = 'No'
where extra_time is null;

update all_predicted_results 
set penalties = 'No'
where penalties is null;

update all_predicted_results 
set extra_time = 'Yes'
where extra_time not in ('No', 'N/A');

-- insert quaters from predition
insert into all_predicted_results (team_1,team_2,extra_time, penalties, winner)
select team_1, team_2, extra_time, penalties, next_round from semi_final;

-- cleaning
update all_predicted_results 
set phase = 'Q'
where phase is null;

update all_predicted_results 
set group_name = 'N/A'
where group_name is null;

update all_predicted_results 
set extra_time = 'No'
where extra_time is null;

update all_predicted_results 
set penalties = 'No'
where penalties is null;

update all_predicted_results 
set extra_time = 'Yes'
where extra_time not in ('No', 'N/A');

update all_predicted_results 
set penalties = 'Yes'
where penalties not in ('No', 'N/A');

-- insert semifinal results
insert into all_predicted_results (team_1,team_2,extra_time, penalties, winner)
select team_1, team_2, extra_time, penalties, winner from semi_final_results ;

-- cleaning
update all_predicted_results 
set phase = 'SF'
where phase is null;

update all_predicted_results 
set group_name = 'N/A'
where group_name is null;

update all_predicted_results 
set extra_time = 'No'
where extra_time is null;

update all_predicted_results 
set penalties = 'No'
where penalties is null;

update all_predicted_results 
set extra_time = 'Yes'
where extra_time not in ('No', 'N/A');

update all_predicted_results 
set penalties = 'Yes'
where penalties not in ('No', 'N/A');

-- insert 3rd place
insert into all_predicted_results (team_1,team_2,extra_time, penalties, winner)
select team_1, team_2, extra_time, penalties, winner from third_place_results;

-- cleaning
update all_predicted_results 
set phase = '3P'
where phase is null;

update all_predicted_results 
set group_name = 'N/A'
where group_name is null;

update all_predicted_results 
set extra_time = 'No'
where extra_time is null;

update all_predicted_results 
set penalties = 'No'
where penalties is null;

update all_predicted_results 
set extra_time = 'Yes'
where extra_time not in ('No', 'N/A');

update all_predicted_results 
set penalties = 'Yes'
where penalties not in ('No', 'N/A');

update all_predicted_results 
set winner= 'Argentina'
where phase ='3P';

--insert final match
insert into all_predicted_results (team_1,team_2,extra_time, penalties, winner)
select team_1, team_2, extra_time, penalties, winner from final_results;

-- cleaning
update all_predicted_results 
set phase = 'F'
where phase is null;

update all_predicted_results 
set group_name = 'N/A'
where group_name is null;

update all_predicted_results 
set extra_time = 'No'
where extra_time is null;

update all_predicted_results 
set penalties = 'No'
where penalties is null;

update all_predicted_results 
set extra_time = 'Yes'
where extra_time not in ('No', 'N/A');

update all_predicted_results 
set penalties = 'Yes'
where penalties not in ('No', 'N/A');

-----------------------------------
select * from all_predicted_results 
order by group_name asc

-- let's have final manipulation - let' fill in winner for group stage and remove goals columns 
UPDATE all_predicted_results 
SET winner = 
    CASE 
        WHEN goals_1 > goals_2 THEN team_1 
        WHEN goals_1 < goals_2 THEN team_2 
        ELSE 'Draw' 
    END
WHERE goals_1 IS NOT NULL AND goals_2 IS NOT NULL AND winner IS NULL;

alter table all_predicted_results 
drop column goals_1,
drop column goals_2;

----------------
/* FINAL OUTPUT */
-----------------

select * from all_predicted_results 





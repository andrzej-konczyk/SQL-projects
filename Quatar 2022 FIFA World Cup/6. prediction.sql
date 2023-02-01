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
	
select * from final_league_table; -- check if all is fine



-- creation table which will be used for predition of results --
create table opposit_team_results
as select
opposite, opposite_average_posession , opposite_goals_per_90_minutes , opposite_goals_excluding_penalties_per_90_minutes , opposite_xg_per_90_minutes , opposite_non_penalty_xg , team, average_posession , goals_per_90_minutes , goals_excluding_penalties_per_90_minutes , xg_per_90_minutes , non_penalty_xg 
from team_and_opposition_stats; 

select * from opposit_team_results; -- check if all is fine

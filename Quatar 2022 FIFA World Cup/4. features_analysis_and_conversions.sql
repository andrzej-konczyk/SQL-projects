select * from team_and_opposition_stats; 

select * from final_league_table;

select * from match_by_match_stat
order by id asc;

select * from player_stats ps ;

/*in that sccript i will remove some columns in each table, which does not makes sense to keep them */

/*table team_and_opposition_stats:
- opposite_start_by_players
- opposite_matches_played
- start_by_players */

alter table team_and_opposition_stats 
	drop column opposite_start_by_players;
alter table team_and_opposition_stats 
	drop column opposite_matches_played;
alter table team_and_opposition_stats 
	drop column start_by_players;

alter table final_league_table 
	rename column depth_of_the_campaign to phase; -- here just rename column to have that consistent with other tables
	
	
/*for player stats there are some columns, which are simply sum of other - I will remove them. Such data we can get in visualisation later on */
	
alter table player_stats 
	drop column xg_and_xag;
alter table player_stats 
	drop column non_penalty_xg_and_xag;

-- now is needed to export data do csv and then start work with own visualization 
	

	

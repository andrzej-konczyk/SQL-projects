/* all ready tables: */

select * from final_league_table;

select * from match_by_match_stat;

select * from opposition_standard_stats;

select * from player_stats;

select * from squad_standard_stats;

/* Here let's do some data cleaning and check data */

select * 
from final_league_table
where not (final_league_table is not null);

select * 
from match_by_match_stat
where not (match_by_match_stat is not null);

select * 
from opposition_standard_stats
where not (opposition_standard_stats is not null);

select * 
from player_stats
where not (player_stats is not null);

/* only for player_stats tabel we have 5 rows with null data, I will check them in next step */

select * 
from squad_standard_stats
where not (squad_standard_stats is not null);

-- check nulls --


/* check number of rows with any null values */
select count(*)
from player_stats
where not (player_stats is not null);

select * 
from player_stats
where not (player_stats is not null);

/*update base on www.infogol.net. I will update odny exg,xag etc without 'expected' as such data is available. I will make assumption that xg and non_penalty xg 
 * here is the same as probably such players did not had chance to shoot penalty */

update player_stats 
set xg = 0.14
where xg is null and id = 525;

update player_stats 
set non_penalty_xg = 0.14
where non_penalty_xg is null and id = 525;

update player_stats 
set xag = 0.14
where xag is null and id = 525;


update player_stats 
set xg = 0.12
where xg is null and id = 548;

update player_stats 
set non_penalty_xg = 0.11
where non_penalty_xg is null and id = 548;

update player_stats 
set xag = 0.11
where xag is null and id = 548;

/* Other values are 0 - I will change nulls to 0 after removing columns with 'expected' as here I will not use them as I do not have all data */

alter table player_stats
	drop column expected_xg, 
	drop column expected_non_penalty_xg, 
	drop column expected_xag, 
	drop column expected_non_penalty_xg_and_xag;

/* xg_and_xag = sum xg and xag, the same for non_penalty */

update player_stats 
set xag = 0
where xag is null;

update player_stats 
set xg = 0
where xg is null;

update player_stats 
set non_penalty_xg = 0
where non_penalty_xg is null;

/* now sum */

update player_stats 
set xg_and_xag = xg + xag 
where xg_and_xag is null;

update player_stats 
set non_penalty_xg_and_xag = non_penalty_xg + xag 
where non_penalty_xg_and_xag is null;

/* check if there are still nulls - expected 0 rows*/

select * 
from player_stats
where not (player_stats is not null);

/*in tbales oppsition and standard sqad stats we have columns with 'expected' - as there are no columns like only 'xg' etc - I will simply rename it nad use them */

/* rename of columns for table opposite squad stats */

select * from opposition_standard_stats;

alter table opposition_standard_stats 
	rename column expected_xg to xg;
alter table opposition_standard_stats
	rename column expected_non_penalty_xg to non_penalty_xg;
alter table opposition_standard_stats
	rename column expected_xag to xag;
alter table opposition_standard_stats
	rename column expected_non_penalty_xg_and_xag to non_penalty_xg_and_xag;
alter table opposition_standard_stats
	rename column expected_xg_per_90_minutes to xg_per_90_minutes;
alter table opposition_standard_stats
	rename column expected_xag_per_90_minutes to xag_per_90_minutes;
alter table opposition_standard_stats
	rename column expected_xg_and_xag_per_90_minutes to xg_and_xag_per_90_minutes;
alter table opposition_standard_stats
	rename column expected_non_penalty_xg_per_90_minutes to non_penalty_xg_per_90_minutes;
alter table opposition_standard_stats
	rename column expected_non_penalty_xg_and_xag_per_90_minutes to non_penalty_xg_and_xag_per_90_minutes;


/* rename of columns for table team squad stats */

select * from squad_standard_stats;

alter table squad_standard_stats
	rename column expected_xg to xg;
alter table squad_standard_stats
	rename column expected_non_penalty_xg to non_penalty_xg;
alter table squad_standard_stats
	rename column expected_xag to xag;
alter table squad_standard_stats
	rename column expected_non_penalty_xg_and_xag to non_penalty_xg_and_xag;
alter table squad_standard_stats
	rename column expected_xg_per_90_minutes to xg_per_90_minutes;
alter table squad_standard_stats
	rename column expected_xag_per_90_minutes to xag_per_90_minutes;
alter table squad_standard_stats
	rename column expected_xg_and_xag_per_90_minutes to xg_and_xag_per_90_minutes;
alter table squad_standard_stats
	rename column expected_non_penalty_xg_per_90_minutes to non_penalty_xg_per_90_minutes;
alter table squad_standard_stats
	rename column expected_non_penalty_xg_and_xag_per_90_minutes to non_penalty_xg_and_xag_per_90_minutes;

/* for table match_by_match I will define match whioch are in group phase as GR and redefine such column to 'phase' */

select * from match_by_match_stat;

alter table match_by_match_stat 
	rename column match to phase;
	
update match_by_match_stat 
set phase = 'GR'
where phase not in('R16', 'QF', 'SF', '3P', 'F');

/*check after changes */

select * from match_by_match_stat
order by id asc;

/* in such situation our id is also match number */

/* I will join opposit and squad tables, but firstly remove 'VS' from opposition */

alter table opposition_standard_stats 
	rename column squad to opposite;

update opposition_standard_stats 
set opposite = regexp_replace(opposite, 'VS(?:$|\W)', '') ;

alter table opposition_standard_stats 
	rename column number_of_payers_used to opposite_number_of_players_used;
alter table opposition_standard_stats 
	rename column Average_Age_of_the_Team to opposite_Average_Age_of_the_Team;
alter table opposition_standard_stats 
	rename column Average_Posession to opposite_Average_Posession;
alter table opposition_standard_stats 
	rename column Matches_Played  to opposite_Matches_Played ;
alter table opposition_standard_stats 
	rename column Start_by_Players  to opposite_Start_by_Players ;
alter table opposition_standard_stats 
	rename column Total_Playing_Time  to opposite_Total_Playing_Time ;
alter table opposition_standard_stats 
	rename column _90_Minutes_Played  to opposite_90_Minutes_Played ;
alter table opposition_standard_stats 
	rename column Assists  to opposite_Assists ;
alter table opposition_standard_stats 
	rename column Non_Penalty_Golas  to opposite_Non_Penalty_Golas ;
alter table opposition_standard_stats 
	rename column Penalties_Converted  to opposite_Penalties_Converted ;
alter table opposition_standard_stats 
	rename column Penalties_Taken to opposite_Penalties_Taken ;
alter table opposition_standard_stats 
	rename column Yellow_Cards to opposite_Yellow_Cards ;
alter table opposition_standard_stats 
	rename column Red_Cards to opposite_Red_Cards ;
alter table opposition_standard_stats 
	rename column Goals_per_90_Minutes to opposite_Goals_per_90_Minutes ;
alter table opposition_standard_stats 
	rename column Assists_per_90_Minutes to opposite_Assists_per_90_Minutes ;
alter table opposition_standard_stats 
	rename column Goals_and_Assists_per_90_Minutes to opposite_Goals_and_Assists_per_90_Minutes ;
alter table opposition_standard_stats 
	rename column Goals_excluding_Penalties_per_90_Minutes to opposite_Goals_excluding_Penalties_per_90_Minutes ;
alter table opposition_standard_stats 
	rename column Goals_and_Assists_excluding_Penalties_per_90_Minutes to opposite_Goals_and_Assists_excluding_Penalties_per_90_Minutes ;	
alter table opposition_standard_stats 
	rename column xG to opposite_xG ;
alter table opposition_standard_stats 
	rename column Non_Penalty_xG to opposite_Non_Penalty_xG;
alter table opposition_standard_stats 
	rename column xAG to opposite_xAG;
alter table opposition_standard_stats 
	rename column Non_Penalty_xG_and_xAG to opposite_Non_Penalty_xG_and_xAG;
alter table opposition_standard_stats 
	rename column xG_per_90_Minutes to opposite_xG_per_90_Minutes;	
alter table opposition_standard_stats 
	rename column xAG_per_90_Minutes to opposite_xAG_per_90_Minutes;
alter table opposition_standard_stats 
	rename column xG_and_xAG_per_90_Minutes to opposite_xG_and_xAG_per_90_Minutes;
alter table opposition_standard_stats 
	rename column Non_Penalty_xG_per_90_Minutes to opposite_Non_Penalty_xG_per_90_Minutes;
alter table opposition_standard_stats 
	rename column Non_Penalty_xG_and_xAG_per_90_Minutes to opposite_Non_Penalty_xG_and_xAG_per_90_Minutes;
alter table opposition_standard_stats 
	rename column goals to opposite_goals;

/* I see that in opposite table Iran has name IR Iran - needed to replace that name correctly */

update 
	opposition_standard_stats 
set
	opposite = 'Iran'
where opposite = 'IR Iran';

	
alter table opposition_standard_stats 
drop column id;

create table team_and_opposition_stats as
	(select *
		from opposition_standard_stats oss 
	join
		squad_standard_stats sss 
	on oss.opposite = sss.team
);

select *
from team_and_opposition_stats; -- query only to check if we have 32 rows

drop table team_and_opposition_stats; -- use only if you made some changes in tbale

/* once agian all tables currentyly tu for analysis: */

select * from team_and_opposition_stats; 

select * from final_league_table;

select * from match_by_match_stat;

select * from player_stats ps ;



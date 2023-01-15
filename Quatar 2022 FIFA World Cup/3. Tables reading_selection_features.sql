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

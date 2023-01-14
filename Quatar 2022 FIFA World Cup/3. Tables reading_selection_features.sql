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

select * 
from player_stats
where not (player_stats is not null);
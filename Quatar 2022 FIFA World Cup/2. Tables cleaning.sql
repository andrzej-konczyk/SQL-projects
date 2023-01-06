select *
from player_stats;

/* Here we have same player names with '?' after change of unicode. We needed to finf such players and later on exchange such marks by proper naming base on transfermarkt */

select *
from player_stats ps 
where player like '%?'

/* There is 38 such players */

/*Croatia's players always have end of name with 'ć' */

select *
from player_stats ps 
where player like '%?'
and team = 'Croatia'

update 
	player_stats 
set
	player = left(player, -1)||'ć'
where player like '%?'
and team = 'Croatia';


select *
from player_stats ps 
where player like '%?'
and team = 'Serbia'

/* We will do the same here */

update 
	player_stats 
set
	player = left(player, -1)||'ć'
where player like '%?'
and team = 'Serbia';


/* Check how many players from other countries we have with same situation */
select *
from player_stats ps 
where player like '%?'

/* for Stefanović and Karacić we can do the same */
update 
	player_stats 
set
	player = left(player, -1)||'ć'
where player like '%?'
and team in ('Australia', 'Switzerland');

/* Now we have to individually check player's names - we have 19 players to check*/
select *
from player_stats ps 
where player like '%?%';


/*Looks, that we have many players from Poland, so let's start with them */
select *
from player_stats ps 
where player like '%?%'
and team = 'Poland';

update 
	player_stats 
set
	player = replace(player, 'Micha?', 'Michał')
where player like '%Micha?%'
and team = 'Poland';
update 
	player_stats 
set
	player = replace(player, 'Skóra?', 'Skóraś')
where player like '%Skóra?%'
and team = 'Poland';
update 
	player_stats 
set
	player = replace(player, '?widerski', 'Świderski')
where player like '%?widerski%'
and team = 'Poland';
update 
	player_stats 
set
	player = replace(player, 'Bereszy?ski', 'Bereszyński')
where player like '%Bereszy?ski%'
and team = 'Poland';
update 
	player_stats 
set
	player = replace(player, 'Przemys?aw', 'Przemysław')
where player like '%Frankowski%'
and team = 'Poland';
update 
	player_stats 
set
	player = replace(player, 'J?drzejczyk', 'Jędrzejczyk')
where player like '%J?drzejczyk%'
and team = 'Poland';
update 
	player_stats 
set
	player = replace(player, 'Kami?ski', 'Kamiński')
where player like '%Kami?ski%'
and team = 'Poland';
update 
	player_stats 
set
	player = replace(player, 'Pi?tek', 'Piątek')
where player like '%Pi?tek%'
and team = 'Poland';
update 
	player_stats 
set
	player = replace(player, 'Szcz?sny', 'Szczęsny')
where player like '%Szcz?sny%'
and team = 'Poland';
update 
	player_stats 
set
	player = replace(player, 'Szyma?ski', 'Szymański')
where player like '%Szyma?ski%'
and team = 'Poland';
update 
	player_stats 
set
	player = replace(player, 'Zieli?ski', 'Zieliński')
where player like '%Zieli?ski%'
and team = 'Poland';


/*Now rest of players */
update 
	player_stats 
set
	player = replace(player, 'Sr?an', 'Srdan')
where player like '%Sr?an%';
update 
	player_stats 
set
	player = replace(player, 'Sh?ichi', 'Shūichi')
where player like '%Sh?ichi%';
update 
	player_stats 
set
	player = replace(player, '?lkay', 'Ilkay')
where player like '%?lkay%';
update 
	player_stats 
set
	player = replace(player, 'Gündo?an', 'Gündoğan')
where player like '%Gündo?an%';
update 
	player_stats 
set
	player = replace(player, '?uri?ić', 'Đuričić')
where player like '%?uri?ić%';
update 
	player_stats 
set
	player = replace(player, 'Milinkovi?', 'Milinković')
where player like '%Milinkovi?%';
update 
	player_stats 
set
	player = replace(player, 'Kara?ić', 'Karačić')
where player like '%Kara?ić%';
update 
	player_stats 
set
	player = replace(player, 'Kova?ić', 'Kovačić')
where player like '%Kova?ić%';


/*Check if we have any plaers with '?' - expected 0 rows */
select *
from player_stats ps 
where player like '%?%';









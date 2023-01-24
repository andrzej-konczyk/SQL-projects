select * from team_and_opposition_stats; 

select * from final_league_table;

select * from match_by_match_stat
order by id asc;

select * from player_stats ps ;

----------------------------------------------

/*1 Focus on table team and opposition stats */


select opposite_number_of_players_used, count(opposite_number_of_players_used)
from team_and_opposition_stats taos 
group by opposite_number_of_players_used
order by count(opposite_number_of_players_used) desc;

-- mainly in game vs opposite were used 20-21 players (against 9 and 8 teams). 23-26 playeres used have the least frequent. 
-- 1 CONCLUSION: DURING TOURNAMENT ABOUT 6 PLAYERS WERE NOT USED

select opposite_assists , count(opposite_assists)
from team_and_opposition_stats taos 
group by opposite_assists 
order by count(opposite_assists) desc;

-- 2 CONCLUSION: NUMBER OF ASSIST AGAINST TEAM WAS 2-4

select opposite_penalties_converted , count(opposite_penalties_converted)
from team_and_opposition_stats taos 
group by opposite_penalties_converted 
order by count(opposite_penalties_converted) desc;

-- 3 AND 4 CONCLUSION: THERE WERE  0-1 PENALTIY FOR OPPOSITE IN MOST CASES AND SAME CONCLUSION FOR PENALTIES TAKEN BY OPPOSITES

select opposite_red_cards , count(opposite_red_cards)
from team_and_opposition_stats taos 
group by opposite_red_cards 
order by count(opposite_red_cards) desc;

-- 5 CONCLUSION: MAINLY THERE WAS NO RED CARD GIVEN 


select assists , count(assists)
from team_and_opposition_stats taos 
group by assists 
order by count(assists) desc;

-- 6 CONCLUSION: MAIN NUMBER OF ASSIST BY TEAM WAS 1

select penalties_converted , count(penalties_converted)
from team_and_opposition_stats taos 
group by penalties_converted 
order by count(penalties_converted) desc;

-- 7 CONCLUSION: MOST OF TEAMS DID NOT HAD A COVERED A PENALTY

select red_cards , count(red_cards)
from team_and_opposition_stats taos 
group by red_cards 
order by count(red_cards) desc;

-- 8 CONCLUSION: MAIN TEAMS DID NOT HAD A RED CARD

--------------------------------------------------------------
/*2 Focus on table final league table*/

-- no analysis as that too much depends on number of games

--------------------------------------------------------------
/*3 Focus on match by match table*/

select goals_1 , count(goals_1)
from match_by_match_stat mbms 
group by goals_1 
order by count(goals_1) desc;

-- 9 CONCLUSION : 'HOME' TEAM SCORED 0-2 GOALS IN MOST OF CASES


select goals_2 , count(goals_2)
from match_by_match_stat mbms 
group by goals_2 
order by count(goals_2) desc;

-- 10 CONCLUSION: 'AWAY' TEAM SCORED 0-2 GOALS IN MOST OF CASES

-- 11 CONCLUSION : MOST OF CASES WE HAD 0 - 4 GOALS

select shots_on_target_1 , count(shots_on_target_1)
from match_by_match_stat mbms 
group by shots_on_target_1 
order by count(shots_on_target_1) desc;

-- 12 CONCLUSION: 'HOME' TEAM HAD 3-4 SHOTS ON TARGET DURING match 

select shots_on_target_2 , count(shots_on_target_2)
from match_by_match_stat mbms 
group by shots_on_target_2
order by count(shots_on_target_2) desc;

-- 13 CONCLUSION: 'AWAY' TEAM HAD 1-3 SHOTS ON TARGET DURING match 

-- 14 CONCLUSION: ALTHOUGHT 'HOME' AND 'AWAY' TEAMS HAD SIMILAR NUMBER OF SCORED GOALS, 'AWAY' TEAM DID THAT WE LESS NUMBER OF SHOTS ON TARGET

select corner_1 , count(corner_1)
from match_by_match_stat mbms 
group by corner_1
order by count(corner_1) desc;

select corner_2 , count(corner_2)
from match_by_match_stat mbms 
group by corner_2
order by count(corner_2) desc;

-- 15 CONCLUSION: MAIN NUMBER OF CORNERS BY BOTH TEAMS WAS AROUND 10-12 DURING MATCH

select offside_1 , count(offside_1)
from match_by_match_stat mbms 
group by offside_1 
order by count(offside_1) desc;

select offside_2 , count(offside_2)
from match_by_match_stat mbms 
group by offside_2 
order by count(offside_2) desc;


-- 16 CONCLUSION: NUMBER OF OFFSIDES BY TEAM WAS 0-3

select yellow_card_1 , count(yellow_card_1)
from match_by_match_stat mbms 
group by yellow_card_1 
order by count(yellow_card_1) desc;

select yellow_card_2 , count(yellow_card_2)
from match_by_match_stat mbms 
group by yellow_card_2 
order by count(yellow_card_2) desc;


-- 17 CONCLUSION: DURING MATCH TEAM HAD 0-2 YELLOW CARDS

select red_card_1 , count(red_card_1)
from match_by_match_stat mbms 
group by red_card_1 
order by count(red_card_1) desc;

select red_card_2 , count(red_card_2) 
from match_by_match_stat mbms 
group by red_card_2 
order by count(red_card_2) desc;

-- 18 CONCLUSION: MOST OF MATCHES WITHOUT RED CARD. FUN DACT: 'AWAY' NEVER GOT A RED CARD DURING WHOLE TOURNAMENT

select player, TEAM, AGE, minutes_played 
from player_stats ps
where AGE in 
(select MIN(AGE) as AGE
from player_stats ps) 
order by minutes_played DESC;

-- 19 CONCLUSION: 4 PLAYERS HAD 17 YEARS - THE YOUNGESTS DURING TOURNAMENT: JEWISON BENNETTE (COSTA RICA), GAVI (SPAIN), GARANG KUOL (AUSTRALIA) AND YOUSSOUFA MOUKOKO (GERMANY). GAVI PLAYED 
-- THE GREATES NUMBER OF MINUTES (284)

select player, TEAM, AGE, minutes_played 
from player_stats ps
where AGE in 
(select MAX(AGE) as AGE
from player_stats ps) 
order by minutes_played DESC;

-- 20 CONCLUSION: 3 PLAYERS IN AGE 39: PEPE (PORTUGAL), ATIBA HUTCHINSON (CANADA) AND DANI ALVES (BRAZIL). PEPE PLAYED HAD THE GREATEST NUMBER OF PLAYED MINUTES (360)

select player, TEAM, minutes_played 
from player_stats ps
where minutes_played in 
(select MAX(minutes_played) as minutes_played 
from player_stats ps) 
order by minutes_played DESC;

-- 21 CONCLUSION: 5 PLAYERS HAD MAX NUMBER OF PLAYED MINUTES (690): JOSKO GVARDIOL (CROATIA), EMILIANO MARTINEZ (ARGENTINA), LIONEL MESSI(ARGENTINA), NICOLAS OTAMENDI (ARGENTINA) AND DOMINIK LIVAKOVIC (CROATIA)

select distinct YEAR_OF_BIRTH, COUNT(year_of_birth)
from player_stats ps 
group by year_of_birth 
order by year_of_birth asc;

select PLAYER, TEAM
from player_stats ps 
where year_of_birth = 1984

-- 22 CONCLUISON: WE HAD PLAYERS BORN BETWEEN 1983 AND 2004 AND AT LEAST ONE PLAYER BORN IN EACH OF THAT YEAR. MIN WAS FOR 1984 (JUST ONE PLAYER: THIAGO SILVA FROM BRAZIL) AND 73 (AS MAX) PLAYERS BORN IN 1997
-----------------------------------------------------------------------------------------------------------------

/*4 Focus on table player stats */

-- no analysis, depends on number of matches for pure statitists

-----------------------------------------------------------------------------------------------------------------

/* SUMMARY OF PURE STATUSTICS */

-- 1 CONCLUSION: DURING TOURNAMENT ABOUT 6 PLAYERS WERE NOT USED
-- 2 CONCLUSION: NUMBER OF ASSIST AGAINST TEAM WAS 2-4
-- 3 AND 4 CONCLUSION: THERE WERE  0-1 PENALTIY FOR OPPOSITE IN MOST CASES AND SAME CONCLUSION FOR PENALTIES TAKEN BY OPPOSITES
-- 5 CONCLUSION: MAINLY THERE WAS NO RED CARD GIVEN 
-- 6 CONCLUSION: MAIN NUMBER OF ASSIST BY TEAM WAS 1
-- 7 CONCLUSION: MOST OF TEAMS DID NOT HAD A COVERED A PENALTY
-- 8 CONCLUSION: MAIN TEAMS DID NOT HAD A RED CARD
-- 9 CONCLUSION : 'HOME' TEAM SCORED 0-2 GOALS IN MOST OF CASES
-- 10 CONCLUSION: 'AWAY' TEAM SCORED 0-2 GOALS IN MOST OF CASES
-- 11 CONCLUSION : MOST OF CASES WE HAD 0 - 4 GOALS
-- 12 CONCLUSION: 'HOME' TEAM HAD 3-4 SHOTS ON TARGET DURING match
-- 13 CONCLUSION: 'AWAY' TEAM HAD 1-3 SHOTS ON TARGET DURING match
-- 14 CONCLUSION: ALTHOUGHT 'HOME' AND 'AWAY' TEAMS HAD SIMILAR NUMBER OF SCORED GOALS, 'AWAY' TEAM DID THAT WE LESS NUMBER OF SHOTS ON TARGET
-- 15 CONCLUSION: MAIN NUMBER OF CORNERS BY BOTH TEAMS WAS AROUND 10-12 DURING MATCH (EACH OF THEM)
-- 16 CONCLUSION: NUMBER OF OFFSIDES BY TEAM WAS 0-3 (EACH OF THEM)
-- 17 CONCLUSION: DURING MATCH TEAM HAD 0-2 YELLOW CARDS (EACH OF THEM)
-- 18 CONCLUSION: MOST OF MATCHES WITHOUT RED CARD. FUN DACT: 'AWAY' NEVER GOT A RED CARD DURING WHOLE TOURNAMENT
-- 19 CONCLUSION: 4 PLAYERS HAD 17 YEARS - THE YOUNGESTS DURING TOURNAMENT: JEWISON BENNETTE (COSTA RICA), GAVI (SPAIN), GARANG KUOL (AUSTRALIA) AND YOUSSOUFA MOUKOKO (GERMANY). GAVI PLAYED THE GREATES NUMBER OF MINUTES (284)
-- 20 CONCLUSION: 3 PLAYERS IN AGE 39: PEPE (PORTUGAL), ATIBA HUTCHINSON (CANADA) AND DANI ALVES (BRAZIL). PEPE PLAYED HAD THE GREATEST NUMBER OF PLAYED MINUTES (360)
-- 21 CONCLUSION: 5 PLAYERS HAD MAX NUMBER OF PLAYED MINUTES (690): JOSKO GVARDIOL (CROATIA), EMILIANO MARTINEZ (ARGENTINA), LIONEL MESSI(ARGENTINA), NICOLAS OTAMENDI (ARGENTINA) AND DOMINIK LIVAKOVIC (CROATIA)
-- 22 CONCLUISON: WE HAD PLAYERS BORN BETWEEN 1983 AND 2004 AND AT LEAST ONE PLAYER BORN IN EACH OF THAT YEAR. MIN WAS FOR 1984 (JUST ONE PLAYER: THIAGO SILVA FROM BRAZIL) AND 73 (AS MAX) PLAYERS BORN IN 1997




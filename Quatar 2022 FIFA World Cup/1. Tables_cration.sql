-- Creation of empty tables for read of data --

/*About Dataset:

The 2022 FIFA World Cup was the 22nd edition of the FIFA World Cup, an international football tournament contested by the men's national teams of FIFA's member associations. 
It took place in Qatar from 20 November to 18 December 2022, making it the first World Cup held in the Arab World and Muslim World, 
and the second held entirely in Asia after the 2002 tournament in South Korea and Japan. France was the defending champions, having defeated Croatia 4–2 in the 2018 final. 
At an estimated cost of over $220 billion, it is the most expensive World Cup ever held to date, this figure is disputed by Qatari officials, 
including organising CEO Nasser Al Khater, who said the true cost was $8 billion, and other figures related to overall infrastructure development since the World Cup was awarded to Qatar in 2010.

This tournament was the last with 32 participating teams, with the field set to increase to 48 teams for the 2026 edition. 
To avoid the extremes of Qatar's hot climate, the event was held during November and December. It was held over a reduced time frame of 29 days with 64 matches played in eight venues across five cities. 
The Qatar national football team entered the event, their first World Cup, automatically as the host's national team, alongside 31 teams who were determined by the qualification process.

Argentina were the champions after winning the final against the title holder France 4–2 on penalties following a 3–3 draw after extra time. 
French player Kylian Mbappé became the first player to score a hat-trick in a World Cup final since Geoff Hurst in the 1966 final and won the Golden Boot as he scored the most goals, 8, during the tournament. 
Argentine captain Lionel Messi was voted the tournament's best player, winning the Golden Ball. Emiliano Martínez and Enzo Fernández, also from Argentina, won the Golden Glove, awarded to 
the tournament's best goalkeeper and the Young Player Award, awarded to the tournament's best young player, respectively.

Coming to the Dataset, it contains 5 different matrixes to compare teams and players. These include:

1.Final League Table: A table to compare the final performance of each team, irrespective of them qualifying for the knockout or not.
2.Match-by-Match Stat: A table which gives an elaborate look into the performance of each team, for each match.
3.Squad Standard Stats: A table which gives an elaborate look into each team and how they performed in the tournament.
4.Opposition Standard Stats: A table which gives an elaborate look into how the opposition teams performed against a team in the tournament.
5.Player Stats: A look into the performance of each player that played in the tournament.

source: https://www.kaggle.com/datasets/parasharmanas/decoded-qatar-2022-fifa-world-cup */

/* Path to files ...\Quatar 2022 FIFA World Cup\....csv */

-- Table 1  Final League Table--

create table final_league_table (
	id serial,
	Depth_of_the_Campaign varchar(255),
	Team varchar(100),
	Matches_Played integer,
	Wins integer,
	Draws integer,
	Losses integer,
	Goals_For integer,
	Goals_Against integer,
	Goal_Difference integer,
	Points integer,
	xG numeric,
	xG_Against numeric,
	xG_Difference numeric,
	xG_Difference_per_90 numeric,
	primary key (id)
);

drop table final_league_table; -- that to be used only when you would like to make modifications in creation of table

COPY final_league_table(Depth_of_the_Campaign, Team, Matches_Played, Wins, Draws, Losses, Goals_For, Goals_Against, Goal_Difference, Points, xG, xG_Against, xG_Difference, xG_Difference_per_90)
FROM 'C:\Users\andrz\Desktop\Prywatne\SQL projects\Quatar 2022 FIFA World Cup\Final League Table.csv'
DELIMITER ','
CSV HEADER;

select * from final_league_table;

--Table 2 Match by Mach Stat --

create table match_by_match_stat (
	id serial,
	Match varchar(50),
	Team_1 varchar(100),
	Goals_1 varchar(50),
	Total_xG_1 numeric,
	Posession_1 varchar(50),
	Total_Passes_1 integer,
	Accurate_Passes_1 integer,
	Shots_1 integer,
	Shots_on_Target_1 integer,
	Fouls_1 integer,
	Corner_1 integer,
	Crosses_1 integer,
	Touches_1 integer,
	Tackles_1 integer,
	Interceptions_1 integer,
	Aerials_Won_1 integer,
	Clearances_1 integer,
	Offside_1 integer,
	Goal_Kicks_1 integer,
	Throw_Ins_1 integer,
	Long_Ball_1 integer,
	Yellow_Card_1 integer,
	Red_Card_1 integer,
	Team_2 varchar(100),
	Goals_2 varchar(50),
	Total_xG_2 numeric,
	Posession_2 varchar(50),
	Total_Passes_2 integer,
	Accurate_Passes_2 integer,
	Shots_2 integer,
	Shots_on_Target_2 integer,
	Fouls_2 integer,
	Corner_2 integer,
	Crosses_2 integer,
	Touches_2 integer,
	Tackles_2 integer,
	Interceptions_2 integer,
	Aerials_Won_2 integer,
	Clearances_2 integer,
	Offside_2 integer,
	Goal_Kicks_2 integer,
	Throw_Ins_2 integer,
	Long_Ball_2 integer,
	Yellow_Card_2 integer,
	Red_Card_2 integer,
	primary key (id)
);

drop table match_by_match_stat; -- that to be used only when you would like to make modifications in creation of table

COPY match_by_match_stat(Match,Team_1,Goals_1,Total_xG_1,Posession_1,Total_Passes_1,Accurate_Passes_1,Shots_1,Shots_on_Target_1,Fouls_1,Corner_1,
Crosses_1,Touches_1,Tackles_1,Interceptions_1,Aerials_Won_1,Clearances_1,Offside_1,Goal_Kicks_1,Throw_Ins_1,Long_Ball_1,Yellow_Card_1,Red_Card_1,
Team_2,Goals_2,Total_xG_2,Posession_2,Total_Passes_2,Accurate_Passes_2,Shots_2,Shots_on_Target_2,Fouls_2,Corner_2,
Crosses_2,Touches_2,Tackles_2,Interceptions_2,Aerials_Won_2,Clearances_2,Offside_2,Goal_Kicks_2,Throw_Ins_2,Long_Ball_2,Yellow_Card_2,Red_Card_2)
FROM 'C:\Users\andrz\Desktop\Prywatne\SQL projects\Quatar 2022 FIFA World Cup\Match-by-Match Stat.csv'
DELIMITER ','
CSV HEADER;

select * from match_by_match_stat;

--Table 3 Opposition Standard Stats --

create table opposition_standard_stats (
	id serial,
	Squad varchar(100),
	Number_of_Payers_Used integer,
	Average_Age_of_the_Team numeric,
	Average_Posession numeric,
	Matches_Played integer,
	Start_by_Players integer,
	Total_Playing_Time integer,
	_90_Minutes_Played numeric,
	Goals integer,
	Assists integer,
	Non_Penalty_Golas integer,
	Penalties_Converted integer,
	Penalties_Taken integer,
	Yellow_Cards integer,
	Red_Cards integer,
	Goals_per_90_Minutes numeric,
	Assists_per_90_Minutes numeric,
	Goals_and_Assists_per_90_Minutes numeric,
	Goals_excluding_Penalties_per_90_Minutes numeric,
	Goals_and_Assists_excluding_Penalties_per_90_Minutes numeric,
	Expected_xG numeric,
	Expected_Non_Penalty_xG numeric,
	Expected_xAG numeric,
	Expected_Non_Penalty_xG_and_xAG numeric,
	Expected_xG_per_90_Minutes numeric,
	Expected_xAG_per_90_Minutes numeric,
	Expected_xG_and_xAG_per_90_Minutes numeric,
	Expected_Non_Penalty_xG_per_90_Minutes numeric,
	Expected_Non_Penalty_xG_and_xAG_per_90_Minutes numeric,
	primary key (id)
);

drop table opposition_standard_stats; -- that to be used only when you would like to make modifications in creation of table

COPY opposition_standard_stats(Squad,Number_of_Payers_Used,Average_Age_of_the_Team,Average_Posession,Matches_Played,Start_by_Players,Total_Playing_Time,_90_Minutes_Played,Goals,Assists,
Non_Penalty_Golas,Penalties_Converted,Penalties_Taken,Yellow_Cards,Red_Cards,Goals_per_90_Minutes,Assists_per_90_Minutes,Goals_and_Assists_per_90_Minutes,
Goals_excluding_Penalties_per_90_Minutes,Goals_and_Assists_excluding_Penalties_per_90_Minutes,Expected_xG,Expected_Non_Penalty_xG,Expected_xAG,Expected_Non_Penalty_xG_and_xAG,Expected_xG_per_90_Minutes,
Expected_xAG_per_90_Minutes,Expected_xG_and_xAG_per_90_Minutes,Expected_Non_Penalty_xG_per_90_Minutes,Expected_Non_Penalty_xG_and_xAG_per_90_Minutes)
FROM 'C:\Users\andrz\Desktop\Prywatne\SQL projects\Quatar 2022 FIFA World Cup\Opposition Standard Stats.csv'
DELIMITER ','
CSV HEADER;

select * from opposition_standard_stats;


--Table 4 Player Stats --

create table player_stats(
	id serial,
	Player varchar(500),
	Position varchar(50),
	Team varchar(100),
	Age integer,
	Year_of_Birth integer,
	Matches_Played integer,
	Starts integer,
	Minutes_Played integer,
	_90_Minutes_Played numeric,
	Goals integer,
	Assists integer,
	Non_Penalty_Goals integer,
	Penalties_Converted integer,
	Penalties_Taken integer,
	Yellow_Cards integer,
	Red_Cards integer,
	Goals_per_90_Minutes numeric,
	Assists_per_90_Minutes numeric,
	Goals_and_Assists_per_90_Minutes numeric,
	Goals_excluding_Penalties_per_90_Minutes numeric,
	Goals_and_Assists_excluding_Penalties_per_90_Minutes numeric,
	Expected_xG numeric,
	Expected_Non_Penalty_xG numeric,
	Expected_xAG numeric,
	Expected_Non_Penalty_xG_and_xAG numeric,
	xG numeric,
	xAG numeric,
	xG_and_xAG numeric,
	Non_Penalty_xG numeric,
	Non_Penalty_xG_and_xAG numeric,
	primary key (id)
);

drop table player_stats; -- that to be used only when you would like to make modifications in creation of table

COPY player_stats(Player,Position, Team,Age,Year_of_Birth,Matches_Played,Starts,Minutes_Played,_90_Minutes_Played,Goals,Assists,Non_Penalty_Goals,
Penalties_Converted,Penalties_Taken,Yellow_Cards,Red_Cards,Goals_per_90_Minutes,Assists_per_90_Minutes,Goals_and_Assists_per_90_Minutes,
Goals_excluding_Penalties_per_90_Minutes,Goals_and_Assists_excluding_Penalties_per_90_Minutes,Expected_xG,Expected_Non_Penalty_xG,
Expected_xAG,Expected_Non_Penalty_xG_and_xAG,xG,xAG,xG_and_xAG,Non_Penalty_xG,Non_Penalty_xG_and_xAG)
FROM 'C:\Users\andrz\Desktop\Prywatne\SQL projects\Quatar 2022 FIFA World Cup\Player Stats.csv'
DELIMITER ','
CSV HEADER;

/* 
 For creation table there was selected only one position for each player in case where initialy in database there were at least two positions.
 Position was selected base on transfermarkt data 
 */
 

select * from player_stats;



--Table 5 Squad Standard Stats --








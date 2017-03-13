/** ST 307 Project 2
	@author Christina Zhou
	Samantha & Aruna - 100 % 
*/

/**
1.	In one data step, reads the data called BoxScore into your library. 
	While reading in, make sure that all variables are read in entirely 
	(i.e. no character variables have values cut off) and numeric data is read in numerically.  
	The date values should be formatted to show in 01JAN2016 form.
	For the startTime variable - create a variable that is the start time in seconds from midnight. 
	1pm would be 13*60*60.
	For the duration variable - convert this to number of seconds as well. 
	Format both this and the new start time variable to display as HH:MM:SS.
	Drop the original startTime variable and any other temporary variables.
*/

libname Project2 "K:\Fall2016\ST307\";

data Project2.BoxScore;
	infile "K:\Fall2016\ST307\Scores2002.csv" firstobs=2 dsd;
	Length gid $ 12  week $ 9 awayTeam $ 20 homeTeam $ 20 stadium $ 30 toss $ 12 roof 
			$ 16 surface $ 10 weather $60 vegasline $ 25 OU $ 12;
	INPUT gid $ week $ date : anydtdte. day $ season : awayTeam $ AQ1 AQ2 AQ3 AQ4 AOT AOT2 AFinal homeTeam $ 
			HQ1 HQ2 HQ3 HQ4 HOT HOT2 HFinal stadium $ startTime $ toss $ roof $ surface $ duration attendance : Comma5. weather $ vegasLine $ OU $;
	Format date date9.;
	hourStart = scan(startTime,1,':');
	minuteStart = substr(scan(startTime,2,':'),1,2);
	if (substr(scan(startTime,2,':'),3,2) = "pm") then secondsStartTime = 43200;
	else if (substr(scan(startTime,2,':'),3,2) = "am") then secondsStartTime = 0;
	secondsStartTime = secondsStartTime + hourStart*60*60 + minuteStart*60;
	ScoreTotal=AFinal+HFinal;
	Drop hourStart;
	Drop minuteStart;
	Drop startTime;
	Duration=Duration*60;
	FORMAT secondsStartTime time. Duration time.;
run;

/**
	2.Conducts a test to determine if the mean number of total points scores on non-Sunday games is different from the Sunday games.
    Output a 90% CI for the difference in means.
	Also creates a new data set that has a new day variable consisting of days that are sunday and not sunday;
*/
data Project2.BoxScore2;
	set Project2.BoxScore;
	if (day = "Sun") then newday = "Sun";
	else newday = "NotSun";
PROC TTEST DATA=Project2.Boxscore2 ALPHA=0.1;
	CLASS newday;
	VAR ScoreTotal;
	title2 "Comparing difference in mean point scores";
RUN;
/**
	3.Conducts a test to determine if the average points scored by the away team in the first quarter is less than that of the home team.
    Also provide a 95% confidence interval for the difference (note - not a one-sided bound).
*/
PROC TTEST DATA=Project2.BoxScore alpha=0.05 SIDES=L;
	PAIRED AQ1*HQ1;
	title2 "One-sided pairwise test that the visiting team is scoring less than the home team in Q1";
RUN;

PROC TTEST DATA=Project2.BoxScore alpha=0.05;
	PAIRED AQ1*HQ1;
	title2 "Pairwise Test for computation of confidence interval";
RUN;



/**4.For each setting of surface, conduct a one-sample ttest to determine if the average duration of the game differs from 3 hours.;
	Sort the data by surface type;
*/
PROC SORT data=Project2.BoxScore;
	by surface;
run;

PROC TTEST data=Project2.BoxScore H0=10800;
	by surface; 
	var duration;
run;



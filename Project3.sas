libname Project3 "K:\Fall2016\ST307";
*1. In one data step, read the data (call it Lakes) into your library. While reading in, make sure that all
variables are read in entirely (i.e. no character variables have values cut off) and numeric data is read in
numerically.;

data Project3.Lakes;
	infile "K:\Fall2016\ST307\fish.txt" firstobs=2 delimiter='09'x dsd missover;
	Length name $ 25;
	input name $ : hg n elv sa z lt $ : st $ : da rf fr dam $ : lat1 lat2 lat3 long1 long2 long3;
	latdec = (lat1)+(lat2/60)+(lat3/3600);
	longdec=(long1)+(long2/60)+(long3/3600);
	DROP lat1 lat2 lat3 long1 long2 long3;
	FORMAT elv sa Comma7. latdec longdec Comma6.3 ;
	label name="Name of the lake"
		  hg="Mercury content of the sample in ppm"
		  n="Number of fish in the sample"
		  elv="Elevation of the lake in feet"
		  sa="Surface Area of the water in acres"
		  z= "Maximum depth of the lake in feet"
		  lt="Lake Type (1 is Oligotrophic, 2 is Eutrophic, 3 is Mesotrophic)"
		  st="Stratification type"
		  da="Drainage area of the lake"
		  rf="Runoff factor of the lake"
		  fr"Flushing rate of the lake"
		  dam="Dam (0 is no dam, 1 is no dam present)"
		  latdec="Latitude in decimal degrees"
		  longdec="Longitude in decimal degrees";
run;

*2. Run a model to determine if the average mercury level in the lakes differs for the different lake types.
Be sure to output model diagnostic plots.;
PROC GLM Data=Project3.Lakes PLOTS=ALL;
	CLASS lt;
	MODEL hg=lt;
	LSMEANS lt/ADJUST=TUKEY;
RUN;

*3. Rerun the above analysis using the log of the mercury content as the response. Do not reread in your
data here. Use a data step to add a variable (with label) to the already read in data set. Have SAS
produce simultaneous 90% confidence intervals for the difference in average mercury levels for the lake
types.;
data Project3.log;
	set Project3.lakes;
	loghg=log(hg);
	label loghg="Log of mercury content";
run;
PROC GLM Data=Project3.log PLOTS=ALL;
	CLASS lt;
	MODEL loghg=lt;
	LSMEANS lt/ADJUST=TUKEY ALPHA=0.1 CL;
RUN;

*4. Conduct a correlation analysis between Mercury, Elevation, Surface Area, Drainage Area, and Flushing
Rate. Have SAS produce scatterplots between all variables and p-values for tests of correlation.;
PROC CORR DATA=Project3.Lakes PLOTS=Matrix(hist);
	VAR hg elv sa da fr;
RUN;
*5. Run a model to investigate the linear relationship between Mercury (response) and Flushing Rate
(predictor). Have SAS produce a 99% confidence interval for the slope parameter.;
PROC GLM Data=Project3.Lakes Plots=all;
	Model hg=fr /clparm alpha=0.01;
run;
quit;
*6. Have SAS produce a 99% confidence interval for the mean value of mercury at a lake with flushing rate
0.78.;

Data temp;
	INPUT name $ : hg n elv sa z lt $ : st $ : da rf fr dam $ : latdec longdec;
	Datalines;
	. . . . . . . . . . 0.78 . . . . .
;
run;

proc Datasets;
	append base=Project3.Lakes Data=temp;
run;

proc GLM Data=Project3.Lakes;
	Model hg=fr /CLM Alpha=0.01;
run;

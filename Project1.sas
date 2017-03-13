/**ST 307 Project 1
	this data set shows the average spending levels during hospitals' Medicare Spending per Beneficiary episodes
	@author Christina Zhou
	Aruna 100% 
	Samantha 100%
	*/
*creates a library named Project1;
libname Project1 "K:\Fall2016\ST307";
/** reads in the data set and names it medicare into the library project1. 
	creates a new variable called Region. Region takes on the values 
	NE, SE, SW, MW, or W based on certain conditions. 
	It removes all percent variables from the data set.
	*/
data Project1.Medicare;
	infile "K:\Fall2016\ST307\Medicare_Spending.csv" delimiter = ',';
	LENGTH Hos_Name Period $65 Prov_Num $6 State $2 Claim_Type $25;
	input hos_name $ prov_num State $ Period $ claim_type $ avg_spend_per_ep_hospital
	avg_spend_per_ep_state avg_spend_per_ep_nation per_of_spend_hospital per_of_spend_state per_of_spend_nation;
		
	*Gives the region "NE" for States: DC, Maine, NEw Hampshire, Vermont,  Massachussets, 
	Rhode Island, Connecticut, New York, New Jersey, Delaware, Maryland, and Pennsylvania;		
			if (State = "DC") | (State= "ME")| (State = "NH")| (State = "VT")| (State = "MA")| 
			(State= "RI")| (State = "CT") | (State = "NY")| (State = "NJ")| (State = "DE")| (State = "MD") |(State = "PA") then Region = "NE"; 
	*give the region "SE" for States: Florida, Georgia, South Carolina, North Carolina, Virginia, 
	West Virginia, Kentucky, Tennessee, Alabama, Mississippi, Lousiana, Arkansas;
			else if (State = "FL") | (State= "GA")| (State = "SC")| (State = "NC")| (State = "VA")| 
			(State= "WV")| (State = "KY") | (State = "TN")| (State = "AL")| (State = "MS")| (State = "LA") |(State = "AR") then Region = "SE"; 
		
			else if (State = "TX") | (State= "OK")| (State = "NM")| (State = "AZ") then Region = "SW";
			
			else if (State = "OH") | (State= "MI")| (State = "IN")| (State = "IL")| (State = "WI")| 
			(State= "MN")| (State = "IA") | (State = "MO")| (State = "KS")| (State = "NE")| (State = "SD") |(State = "ND") then Region = "MW";
		
			else if (State = "CO") | (State= "WY")| (State = "MO")| (State = "MT")| (State = "ID")| 
			(State= "UT")| (State = "NV") | (State = "CA")| (State = "OR")| (State = "WA")| (State = "AK") |(State = "HI") then Region = "W";
			
			drop per_of_spend_hospital per_of_spend_state per_of_spend_nation; 

run;
/**creates a two way frequency table of the claim type and region variables 
	does not display row or column percentages
*/
proc freq data = Project1.Medicare; 
	tables claim_type* region /nocol 
							   norow;
run;
/** creates the plot below that displays distributon of the average spending per episode in the hospital
	the graph does not include observations larger than 2000
	bars are the width of 100
	the first bar does not go below 0
	*/
proc sgplot data= Project1.Medicare(where=(avg_spend_per_ep_hospital <=2000));
	histogram avg_spend_per_ep_hospital /binwidth = 100 
											binstart=50 
											nbins= 20 
											scale= percent;
	density avg_spend_per_ep_hospital / type = kernel;
run; 
/**4 creates a new data set in the library called MedNC 
	creates a new variable called Full_Name that is the hospitl name 
	and the state abreviated combined
	*/
data Project1.MedNC (drop = prov_num);
	set Project1.Medicare;	
	if State = ("NC");  
	Full_Name= cats(hos_name, ",", " ", State);
run;

proc print data = Project1.MedNC;
run;
proc sort data= Project1.MedNC;
	by claim_type;
run; 
/**5
	gives basic numeric summaries for the avg_spend_per_hospital variable 
	by claim type settings
	outputs the mean and variances for each setting of clame type into a working directory
	called summary
*/ 
proc univariate data =Project1.MedNC;
	by claim_type;
	var avg_spend_per_ep_hospital;
	output out= summary 
				mean = mean
				var = var;
	
		
run; 
/**6 
	removes the total category in the directory called summary 
*/
data summary1;
	set summary;
	If (claim_type = "Total") then delete;
run;
/**6 uses the oputted summary data set to create a bar plot of the claim type variable 
	with out the total category 
	shows the mean hospital average
*/
proc sgplot data = summary1;
	vbar claim_type	/ response = mean 
					  dataskin = sheen
					  datalabel 
					  datalabelpos=top;
	yaxis label = "avg_spend_per_ep_hospital";
	xaxis label = "Claim Type";
run;
 	

	 

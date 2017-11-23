/********************************************************************************
Presidential Prescriptions for State Policy // Howell and Magazinnik // JPAM 2017
Replication File 

Figure 1: Section Scores by Prior Achievement and Future Commitment 
********************************************************************************/

/* set working directory to Replication folder */ 
/* cd "~/Desktop/Replication" */ 

cd "Output"
use "../Data/scores_apps12", clear

set scheme s2color, perm

twoway scatter pctscore2 past2 if section2!="B"|| lowess pctscore past if section2!="B", ///
	   title("Past Achievement and Section Score", size(3.5)) xtitle("Past achievement") ytitle("Section score") ///
	   legend(lab(1 "Section score (% possible points)") lab(2 "Lowess fitted values")) ///
	   graphregion(color(white)) mcolor(gs0) lcolor(black)
graph export scatter7.pdf, replace 

twoway scatter pctscore2 future2 if section2!="B"|| lowess pctscore future if section2!="B", ///
	   title("Future Policy Commitment and Section Score", size(3.5)) xtitle("Future commitment") ytitle("Section score") ///
	   legend(lab(1 "Section score (% possible points)") lab(2 "Lowess fitted values")) ///
	   graphregion(color(white)) lcolor(black)
graph export scatter8.pdf, replace 

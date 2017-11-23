/********************************************************************************
Presidential Prescriptions for State Policy // Howell and Magazinnik // JPAM 2017
Replication File 

Figure 2: Trends in RttT Policy Mentions
********************************************************************************/

/* set working directory to Replication folder */ 
/* cd "~/Desktop/Replication" */ 

cd "Output"
use "../Data/speeches_long", clear

gen type=3
	replace type=1 if win1==1 | win2==1 | win3==1
	replace type=2 if lose_p1==1 & lose_p2==1

/* DV: all RttT policies (no controls) */ 
keep if outcome=="total"
gen Yprop=wcpctrttt/100
gen Y2prop=Y2/100

/* Generate means */ 
bysort statename year: egen stateyrmean=mean(Yprop)
bysort year: egen yrmean=mean(stateyrmean)
bysort type year: egen groupyrmean=mean(stateyrmean) 

bysort statename year: egen stateyrmean2=mean(Y2prop)
bysort year: egen yrmean2=mean(stateyrmean2)
bysort type year: egen groupyrmean2=mean(stateyrmean2)

sort statename year outcome

/*********Y**********/

/* Plots by group, Y */ 
sort type year
quietly by type year:  gen dup = cond(_N==1,0,_n)
keep if dup==1
keep type year yrmean yrmean2 groupyrmean groupyrmean2

twoway scatter groupyrmean year if type==1, connect(l) lcolor(black) lpattern(solid) mcolor(black) text(.12 2009 "Race to the Top  ", placement(w)) xline(2009, lcolor(black)) text(.113 2009 "announced   ", placement(w))  || ///
	   scatter groupyrmean year if type==2, connect(l) lcolor(black) lpattern(dash) mcolor(black) || ///
	   scatter groupyrmean year if type==3, connect(l) lcolor(black) lpattern(dot) mcolor(black) ///
title("Average Annual Proportion of Speech Devoted to Policies over Time by Group", size(3.5)) xtitle("Year") ytitle("Proportion of speech word count") xlabel(2001(1)2013) ylabel(0(.05).15) ///
	   legend(lab(1 "Winners") lab(2 "Applicants") lab(3 "Never applied") size(small) ring(0) bplacement(nw)) graphregion(color(white))
graph export scatter_speeches_mean_all.pdf, replace 

/* Plots by group, Y2 */ 
twoway scatter groupyrmean2 year if type==1, connect(l) lcolor(black) lpattern(solid) mcolor(black) text(.3 2009 "Race to the Top  ", placement(w)) xline(2009, lcolor(black)) text(.25 2009 "announced   ", placement(w))  || ///
	   scatter groupyrmean2 year if type==2, connect(l) lcolor(black) lpattern(dash) mcolor(black) || ///
	   scatter groupyrmean2 year if type==3, connect(l) lcolor(black) lpattern(dot) mcolor(black) ///
title("Average Annual Words Supporting RttT as a Proportion of Words Devoted to RttT over Time by Group", size(2.7)) xtitle("Year") ytitle("Proportion of words devoted to RttT") xlabel(2001(1)2013) ylabel(0(.2)1) ///
	   legend(lab(1 "Winners") lab(2 "Applicants") lab(3 "Never applied") size(small) ring(0) bplacement(sw)) graphregion(color(white))
graph export scatter_speeches_mean_all_pro.pdf, replace

/* Overall plots, Y */ 
sort year
twoway scatter yrmean year, connect(l) lcolor(gray) mcolor(gray) text(.12 2009 "Race to the Top  ", placement(w)) xline(2009, lcolor(black)) text(.113 2009 "announced   ", placement(w)) ///
title("Average Annual Proportion of Speech Devoted to Policies over Time", size(3.5)) xtitle("Year") ytitle("Proportion of speech word count") xlabel(2001(1)2013) ylabel(0(.05).15) graphregion(color(white))
graph export scatter_speeches_mean.pdf, replace 

/* Overall plots, Y2 */ 
twoway scatter yrmean2 year, connect(l) lcolor(gray) mcolor(gray) text(.3 2009 "Race to the Top  ", placement(w)) xline(2009, lcolor(black)) text(.25 2009 "announced   ", placement(w)) ///
title("Average Annual Words Supporting RttT as a Proportion of Words Devoted to RttT over Time", size(3)) xtitle("Year") ytitle("Proportion of speech word count") xlabel(2001(1)2013) ylabel(0(.2)1) graphregion(color(white))
graph export scatter_speeches_mean_pro.pdf, replace 

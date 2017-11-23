/********************************************************************************
Presidential Prescriptions for State Policy // Howell and Magazinnik // JPAM 2017
Replication File 

Figure 3: Trends in RttT Policy Enactment 
********************************************************************************/

/* set working directory to Replication folder */ 
cd "~/Desktop/Replication" 

cd "Output"
use "../Data/leghist_nagg", clear

gen type=3
	replace type=1 if win1==1 | win2==1 | win3==1
	replace type=2 if lose_p1==1 & lose_p2==1 

/* DV: All RttT policies (no controls) */ 
keep if all==1

/* Generate means */ 
bysort statename year: egen stateyrmean=mean(Y)
bysort year: egen yrmean=mean(stateyrmean)
bysort type year: egen groupyrmean=mean(stateyrmean) 

sort statename year outcome
order statename type year Y stateyrmean yrmean groupyrmean 

/* Plots by group */ 
sort type year
quietly by type year:  gen dup = cond(_N==1,0,_n)
keep if dup==1
keep type year yrmean groupyrmean

twoway scatter groupyrmean year if type==1, connect(l) lcolor(black) lpattern(solid) mcolor(black) text(.75 2009 "Race to the Top  ", placement(w)) text(.70 2009 "announced   ", placement(w)) ///
	   xline(2009, lcolor(black))  || ///
	   scatter groupyrmean year if type==2, connect(l) lcolor(black) lpattern(dash) mcolor(black) || ///
	   scatter groupyrmean year if type==3, connect(l) lcolor(black) lpattern(dot) mcolor(black) ///
title("Average Annual Proportion of Policies Implemented over Time by Group", size(3.5)) xtitle("Year") ytitle("Proportion of policies enacted") xlabel(2001(1)2014) ylabel(0(.2)1) ///
	   legend(lab(1 "Winners") lab(2 "Applicants") lab(3 "Never applied") size(small) ring(0) bplacement(nw)) graphregion(color(white))

graph export scatter_leghist_mean_all.pdf, replace 
	
/* Overall plots */ 
sort year
keep if type==1
drop groupyrmean

mkmat year yrmean, mat(A)

gen line2=.
	replace line2=yrmean if year==2007
	replace line2=yrmean if year==2008
	replace line2=line2[_n-1]+A[8,2]-A[7,2] if year==2009
	replace line2=line2[_n-1]+A[8,2]-A[7,2] if year==2010
	replace line2=line2[_n-1]+A[8,2]-A[7,2] if year==2011
	replace line2=line2[_n-1]+A[8,2]-A[7,2] if year==2012
	replace line2=line2[_n-1]+A[8,2]-A[7,2] if year==2013
	replace line2=line2[_n-1]+A[8,2]-A[7,2] if year==2014

twoway scatter yrmean year, connect(l) lcolor(gray) mcolor(gray) text(.75 2009 "Race to the Top  ", placement(w)) text(.70 2009 "announced   ", placement(w)) xline(2009, lcolor(black)) || ///
	   line line2 year, lpattern(dash) lcolor(gray) ///
title("Average Annual Proportion of Policies Implemented over Time", size(3.5)) xtitle("Year") ytitle("Proportion of policies enacted") xlabel(2001(1)2014) ylabel(0(.2)1) ///
		legend(off) graphregion(color(white))

graph export scatter_leghist_mean.pdf, replace 

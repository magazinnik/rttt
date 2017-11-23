/********************************************************************************
Presidential Prescriptions for State Policy // Howell and Magazinnik // JPAM 2017
Replication File 

Table 3: Assessments of RttT Influence by State Legislators 
********************************************************************************/

/* set working directory to Replication folder */ 
cd "~/Desktop/Replication" 

cd "Output"
use "../Data/survey", clear

#delimit ; 
local addnote   "\begin{minipage}{5.5in} \vspace{3mm} \footnotesize 
				This table reports responses from an online survey conducted in the spring of 2014 in which state legislators were 
				asked the following question: \enquote{In an effort to encourage state governments to pass elements of his education agenda, 
				President Obama in 2010 launched a series of competitions known as Race to the Top. In these competitions, states had 
				a chance of winning federal monies in exchange for their commitments to enact a series of specific education policies 
				that were supported by the federal Department of Education. We're wondering what impact, if any, these initiatives have 
				had on education policymaking in your state.  Have they had a massive impact, a big impact, a minor impact, or no impact 
				at all?} A two-tailed t-test finds the responses of each paired combination of winners, losers, and non-applicants to be
				statistically significantly different from one another at the p\$<\$0.01 level. 
				\end{minipage}"; 
#delimit cr				

estimates clear

estpost tab response
	est store A
estpost tab response if win1==1 | win2==1 | win3==1
	est store B
estpost tab response if (win1==0 & win2==0 & win3==0) & (lose_p1==1 | lose_p2==1)
	est store C
estpost tab response if win1==0 & win2==0 & win3==0 & lose_p1==0 & lose_p2==0
	est store D

esttab A B C D using survey.tex, ///
cell(pct(fmt(2))) ///
stats(N, fmt(0) labels("Number of respondents")) ///
booktabs style(tex) ///
nonumber nomtitle ///
mlabels("All states (\%)" "RttT winning states (\%)" "RttT applicants (\%)" "RttT non-applicants (\%)") ///
collabels(none) ///
varlabels(1 "Massive influence" 2 "Big influence" 3 "Minor influence" 4 "No influence at all") ///
alignment(C{2.1cm}C{2.1cm}C{2.1cm}C{2.1cm}) ///
addnote("`addnote'") ///
replace

gen wincat=0
replace wincat=1 if win1==1 | win2==1 | win3==1
replace wincat=2 if (win1==0 & win2==0 & win3==0) & (lose_p1==1 | lose_p2==1)
replace wincat=3 if win1==0 & win2==0 & win3==0 & lose_p1==0 & lose_p2==0

gen wincat_12 = wincat
replace wincat_12=. if wincat==3

gen wincat_13 = wincat
replace wincat_13=. if wincat==2

gen wincat_23 = wincat
replace wincat_23=. if wincat==1

destring response, replace force
ttest response, by(wincat_12)
ttest response, by(wincat_23)
ttest response, by(wincat_13)



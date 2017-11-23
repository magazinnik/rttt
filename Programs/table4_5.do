/********************************************************************************
Presidential Prescriptions for State Policy // Howell and Magazinnik // JPAM 2017
Replication File 

Table 4: RttT Policy Enactment Among Winners and Losers 
Table 5: Linking RttT Policy Enactments to Application Promises
********************************************************************************/

cd "~/Desktop/Replication" 

cd "Output"
use "../Data/leghist_agg", clear

/* Create fixed effects */ 
gen outcome1=outcome if all==1
gen outcome2=outcome if control==1
xi i.outcome1 i.outcome2 i.year i.statename
drop outcome1 outcome2 

/* Create interactions */ 
gen last_fxwint = last_f*wint
gen last_fxloset = last_f*loset 

/* Majority in both houses */ 
gen ldem = 0
	replace ldem = 1 if (sdem==1 & hdem==1)

/* Scale variables */
gen enroll_th = enroll/1000
gen statepop_th = statepop/1000
gen edrevstatepc_th = edrevstatepc/1000
gen edexppc_th = edexppc/1000
gen bexppc_th = bexppc/1000
gen expnoedpc_th = expnoedpc/1000
gen ppsinstwages_h = ppsinstwages/100
gen ppsinstbens_h = ppsinstbens/100
gen ppssupppup_h = ppssupppup/100
gen ppssuppstaff_h = ppssuppstaff/100
gen ppsadmingen_h = ppsadmingen/100
gen ppsadminsch_h = ppsadminsch/100

local varlist1 all control

estimates clear 

/* TABLE 4 */ 

foreach i in `varlist1' {
	if ("`i'"=="all")   	local x="1"
	if ("`i'"=="control") 	local x="2"
	
/* 1. Just year fixed effects */ 

	eststo: quietly reg y wint loset _Iyear* if year>=2010 & `i'==1, vce(cluster statename)
	est store `i'_a

/* 2. Add state fixed effects */ 
	
	eststo: quietly reg y wint loset _Iyear* _Ioutcome`x'* if year>=2010 & `i'==1, vce(cluster statename)
	est store `i'_b
	
/* 3. Add policy fixed effects */ 
	
	eststo: quietly reg y wint loset _Iyear* _Ioutcome`x'* _Istatename* if year>=2010 & `i'==1, vce(cluster statename)
	est store `i'_c

/* 4. Add year, policy, and state fixed effects */ 
	
	eststo: reg y wint loset _Iyear* _Ioutcome`x'* _Istatename* edrevstatepc_th gov_dem ldem if year>=2010 & `i'==1, vce(cluster statename)
	est store `i'_d
}

test wint=loset
esttab all_a control_a all_b control_b all_c control_c all_d control_d ///
	using final.leghist_a2.tex, ///
	indicate("Year fixed effects = _Iyear*" "Policy fixed effects = _Ioutcome*" "State fixed effects = _Istatename*") ///
	cells(b(star fmt(%9.3f))  ///
	se(par fmt(%9.3f))) ///
	starlevels(* .10 ** .05 *** .01) ///
	stats(r2 N, fmt(3 0) labels("$ R ^ {2} $" "N")) ///
	booktabs style(tex) ///
	mlabels("RttT Policies" "Control Policies" "RttT Policies" "Control Policies" "RttT Policies" "Control Policies" "RttT Policies" "Control Policies") ///
	mgroups("(1a)" "(1b)" "(2a)" "(2b)" "(3a)" "(3b)" "(4a)" "(4b)", pattern(1 1 1 1 1 1 1 1) span prefix(\multicolumn{@span}{c}{) suffix(})) ///
	keep(wint loset edrevstatepc_th gov_dem ldem _cons) ///
	order(wint loset edrevstatepc_th gov_dem ldem _cons) ///
	collabels(none) ///
	varlabels(wint "Won RttT (up to time t)" loset "Applied and lost RttT (up to time t)" ///
			  edrevstatepc_th "State education revenue per capita" gov_dem "Democratic governor" ldem "Democratic majority, both chambers"  ///
			  rtw "Right to work state" incomepcth "Per-capita income" _cons "Constant") ///
	alignment(C{1.6cm}C{1.6cm}C{1.6cm}C{1.6cm}C{1.6cm}C{1.6cm}C{1.6cm}C{1.6cm}) ///
	nonumber ///
	replace ///
	label
	

/* TABLE 5 */ 
		
	eststo: quietly reg y wint last_fxwint last_fxloset _Istatename* _Iyear* _Ioutcome1* if year>=2010 & all==1 & (wint==1 | loset==1), vce(cluster statename)
	est store all_a
	test wint + last_fxwint=last_fxloset 
	
	eststo: quietly reg y wint last_fxwint last_fxloset edrevstatepc_th gov_dem ldem ///
					    _Iyear* _Ioutcome1* _Istatename* if year>=2010 & all==1 & (wint==1 | loset==1), vce(cluster statename)
	est store all_b
	test wint + last_fxwint=last_fxloset 

	/*eststo: reg y wint last_fxwint last_fxloset statepop_th pcthisp pctblack enroll_th incomepcth edrevstatepc_th edexppc_th gov_dem ldem rtw ///
					    _Iyear* _Ioutcome1* _Istatename* if year>=2010 & all==1 & (wint==1 | loset==1), vce(cluster statename)*/ 


esttab all_a all_b ///
	using final.leghist_b2.tex, ///
	indicate("Year fixed effects = _Iyear*" "Policy fixed effects = _Ioutcome*" "State fixed effects = _Istatename*") ///
	cells(b(star fmt(%9.3f))  ///
	se(par fmt(%9.3f))) ///
	starlevels(* .10 ** .05 *** .01) ///
	stats(r2 N, fmt(3 0) labels("$ R ^ {2} $" "N")) ///
	booktabs style(tex) ///
	mlabels(none) ///
	keep(wint last_fxwint last_fxloset edrevstatepc_th gov_dem ldem _cons) ///
	order(wint last_fxwint last_fxloset edrevstatepc_th gov_dem ldem _cons) ///
	collabels(none) ///
	varlabels(wint "Won RttT (up to time t)" loset "Applied and lost RttT" last_fxwint "Promise * won" last_fxloset "Promise * applied and lost" ///
			  statepop_th "State population" pcthisp "Percent Hispanic" pctblack "Percent Black" enroll_th "Elementary-secondary school enrollment" ///
			  incomepcth "Per capita income" edrevstatepc_th "State education revenue per capita" ///
			  edexppc_th "State education expenditure per capita" gov_dem "Democratic governor" ldem "Democratic majority, both chambers"  ///
			  rtw "Right to work state" incomepcth "Per-capita income" control_2009 "Policy in place, 2009" _cons "Constant") ///
	alignment(C{1.6cm}C{1.6cm}C{1.6cm}C{1.6cm}C{1.6cm}C{1.6cm}) ///
	replace ///
	label


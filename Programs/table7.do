/********************************************************************************
Presidential Prescriptions for State Policy // Howell and Magazinnik // JPAM 2017
Replication File 

Table 7: Effect of Adoption of Same Policy in Proximate States
********************************************************************************/

/* set working directory to Replication folder */ 
cd "~/Desktop/Replication" 

cd "Output"
use "../Data/leghist_agg", clear

/* Create interactions */ 
gen postrttt_na = 0
	replace postrttt = 1 if (year>=2009 & wint==0 & loset==0)

gen post_na_m1 = postrttt_na * ym1pol
gen post_na_n = postrttt_na * ynpol

/* Create fixed effects */ 
xi i.outcome i.year i.statename

/* Democratic majority in both houses */ 
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

egen statepop_z = std(statepop)
egen pcthisp_z = std(pcthisp)
egen pctblack_z = std(pctblack)
egen enroll_z = std(enroll)
egen edrevstatepc_z = std(edrevstatepc)
egen edexppc_z = std(edexppc)
egen ym1pol_z = std(ym1pol)
egen ynpol_z = std(ynpol)
egen ym1type_z = std(ym1type)
egen yntype_z = std(yntype)
egen ym2pol_z = std(ym2pol)
egen ym3pol_z = std(ym3pol)
egen ym4pol_z = std(ym4pol)
egen bexppc_z = std(bexppc)
egen expnoedpc_z = std(expnoedpc)
egen ppsinstwages_z = std(ppsinstwages)
egen ppsinstbens_z =  std(ppsinstbens) 
egen ppssupppup_z = std(ppssupppup)
egen ppssuppstaff_z = std(ppssuppstaff)
egen ppsadmingen_z = std(ppsadmingen)
egen ppsadminsch_z = std(ppsadminsch)

/* Analysis 1: Effect of neighboring/similar state adoption on own adoption, same policy */ 

estimates clear

eststo: quietly reg y ym1pol_z wint loset _Iyear* _Ioutcome* _Istatename* if all==1, vce(cluster statename) 
	est store est_m1_pol_fe
	
eststo: quietly reg y ynpol_z wint loset _Iyear* _Ioutcome* _Istatename* if all==1, vce(cluster statename) 
	est store est_n_pol_fe

eststo: quietly reg y ym1pol_z wint loset edrevstatepc_z gov_dem ldem _Iyear* _Ioutcome* _Istatename* if all==1, vce(cluster statename) 
	est store est_m1_pol
	
eststo: quietly reg y ynpol_z wint loset edrevstatepc_z gov_dem ldem _Iyear* _Ioutcome* _Istatename* if all==1, vce(cluster statename) 
	est store est_n_pol
	
esttab est_m1_pol_fe est_m1_pol est_n_pol_fe est_n_pol  ///
	using diffreg1.tex, ///
	indicate("Year fixed effects = _Iyear*" "Policy fixed effects = _Ioutcome*" "State fixed effects = _Istatename*") ///
	cells(b(star fmt(%9.3f))  ///
	se(par fmt(%9.3f))) ///
	starlevels(* .10 ** .05 *** .01) ///
	stats(r2 N, fmt(3 0) labels("$ R ^ {2} $" "N")) ///
	booktabs style(tex) ///
	mlabels(none) ///
	collabels(none) ///
	keep(wint loset ym1pol_z ynpol_z edrevstatepc_z gov_dem ldem _cons) ///
	order(wint loset ym1pol_z ynpol_z edrevstatepc_z gov_dem ldem _cons) ///
	varlabels(wint "Won RttT (up to time t)" loset "Applied and lost RttT (up to time t)" ///
			  ym1pol_z "Same policy in similar states" ///
			  ynpol_z "Same policy in neighboring states" ///
			  statepop_z "State population" pcthisp_z "Percent Hispanic" pctblack_z "Percent Black" enroll_z "Elementary-secondary school enrollment" ///
			  incomepcth_z "Per capita income" edrevstatepc_z "State education revenue per capita" ///
			  edexppc_z "State education expenditure per capita" bexppc_z "State overall expenditure per capita" ///
			  expnoedpc "State overall minus education expenditure per capita" ppsinstwages "Per pupil spending, wages" ///
			  ppsinstbens "Per pupil spending, benefits" ppssupppup "Per pupil spending, pupil support" ///
			  ppssuppstaff "Per pupil spending, staff support" ppsadmingen "Per pupil spending, admin general" ///
			  ppsadminsch "Per pupil spending, admin school" ///
			  gov_dem "Democratic governor" ldem "Democratic majority, both chambers"  ///
			  rtw "Right to work state" incomepcth "Per-capita income" _cons "Constant") ///
	alignment(C{1.8cm}C{1.8cm}C{1.8cm}C{1.8cm}C{1.8cm}C{1.8cm}) ///
	replace ///
	label

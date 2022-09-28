/*
Angela Pinot de Moira
Asthma outcome variable
4th February 2021
*/

********************************************************************************

*Announce directories:

global lprdiag "D:\Data\workdata\707796\LPRDIAG"
global lmdb "D:\Data\workdata\707796\LMDB"
global dnbc "D:\Data\workdata\707796\uploaded data"


********************************************************************************
*Merge population with lmdb data

cd $lmdb

clear all

use eventda lbgravff bcpr flerfold flernr outcome using "$dnbc\DNBC_data.dta"

by bcpr, sort: gen n=_N
keep if n==1 
drop n

gen pnr=bcpr

merge 1:m pnr using "lmdb_1995-2019.dta"
drop if _merge==2
drop _merge

*Remove duplicates:
tempvar dup n
unab vlist: _all //place all variables in the current dataset in the local macro vlist
summ `vlist'
by `vlist', sort: gen `dup'=_n
tab `dup'
keep if `dup'==1 

********************************************************************************
*Append with lpr data

tempfile lmdb
save `lmdb'

use eventda lbgravff bcpr flerfold flernr outcome using "$dnbc\DNBC_data.dta", clear

by bcpr, sort: gen n=_N
keep if n==1 
drop n

gen pnr=bcpr

merge 1:m pnr using "$lprdiag\merged_lpradm_lprdiag_1995-2018.dta", keepusing(pnr recnum d_inddto d_uddto c_adiag c_diag c_diagtype c_tildiag)
drop if _merge==2
*keep if _merge==3 // to base denominator on children with an event in lpr
drop _merge


/*
tempvar dup n
unab vlist: _all //place all variables in the current dataset in the local macro vlist
summ `vlist'
by `vlist', sort: gen `dup'=_n
tab `dup' // there are no duplicates
*/

append using `lmdb', gen(append)

********************************************************************************
*Create an age at diagnosis:

*Create an start date for hospital episodes:
replace eksd = d_inddto if eksd==.

gen age = floor((eksd - eventda)/365.25)

drop if age<6 //ONLY INCLUDE DIAGNOSES MADE AFTER 6 YEARS


/*FOR SENSITIVITY ANALYSIS:

*Create a start date one year before 7 year FU
gen start_date= y7_dato - 365.25 // create a start date

*Drop observations that occurred before start date:
drop if eksd <start_date & start_date!=.

*/

*****************************************************
/*Asthma

CRITERIA 1 (BASED ON ICD-10)

>=1 hospital contact for:

J45.0 "allergic asthma"
J45.1 "non-allergic asthma"
J45.8 "asthma , different types"
J45.9 "asthma, unspecified"
J46.0 "status asthmaticus"
J46.9 "status asthmaticus, unspecified"

CRITERIA 2 (BASED ON ATC)

>=2 filled prescriptions within 12 months of:

R03BA01 -R03BA08 "inhaled glucocorticoids"
R03DC01 - R03DC04 "leukotriene-receptor antagonists"
R03DC03 "montelukast" (if no diagnosis of J30 - allergic rhinitis)
R03DB04 "theophylline and adrenergics"
R03DA54 "theophylline, combinations excl. psycholeptics"
R03BB01 "anticholinergica, Ipratropium bromide"
R03DX05 "omalizumab"

*/

gen criteria_1 = 1 if regexm(c_adiag,"^DJ450") | regexm(c_adiag,"^DJ451")| ///
				regexm(c_adiag, "^DJ458") | regexm(c_adiag,"^DJ459")| ///
				regexm(c_adiag, "^DJ460") | regexm(c_adiag,"^DJ469")

replace criteria_1 = 1 if regexm(c_adiag,"^DR06") & (regexm(c_diag,"^DJ450") ///
				| regexm(c_diag,"^DJ451")| regexm(c_diag, "^DJ458") | ///
				regexm(c_diag,"^DJ459") | regexm(c_diag, "^DJ460") | ///
				regexm(c_diag,"^DJ469"))

	
				
*Create an in (start) date
gen criteria_1_in = d_inddto if criteria_1==1

*****************************************************************************
				
gen criteria_2a = 1 if regexm(atc,"^R03BA01") | regexm(atc,"^R03BA02") | ///
							regexm(atc,"^R03BA03") | regexm(atc,"^R03BA04") | ///
							regexm(atc,"^R03BA05") | regexm(atc,"^R03BA06") | ///
							regexm(atc,"^R03BA07") | regexm(atc,"^R03BA08") | ///
							regexm(atc,"^R03DC01") | regexm(atc,"^R03DC02") | ///
							regexm(atc,"^R03DC04") | ///
							regexm(atc,"^R03DB04") | regexm(atc,"^R03DA54") | ///
							regexm(atc,"^R03BB01") | regexm(atc,"^R03DX05")  

******************************************************************************
							
gen montelukast = 1 if regexm(atc,"^R03DC03")


*****************************************************************************
gen rhinitis = 1 if regexm(c_adiag,"^DJ30")


*****************************************************************************
tab atc if regexm(atc,"^R03DX") 

********************************************************************************

//Now create timebands for each medication use 
//- to identify overlapping medication
// and exclude montelukast with diagnoses of allergic rhinits


*Create an end date for prescriptions (6 months after prescription/discharge)
gen eksd_out = eksd + 182.625 if append==1 // prescription data - creates a window of a year 
										  //(but note this could end up being longer than a year)
											// use for montelukast in combination with rhinitis
replace eksd_out = d_uddto + 182.625 if append==0 // prescription data - creates a window of a year 
										  //(but note this could end up being longer than a year)
											// use for montelukast in combination with rhinitis

format eksd_* %d

****
*drop irrelevant observations:

drop if criteria_1==. & criteria_2a==. & montelukast==. & rhinitis==. 

****

*Generate an id for each observation:
sort pnr eksd
gen id =_n

*Expand the dataset
expand 2


*Create a time variable for each duplicate observation
by id, sort: gen time =cond(_n==1, eksd, eksd_out) 
format time %d

*Create a variable which indicates whether each time is a start or end date
by id: gen inout = cond(_n==1, 1,-1) 

*Create a status variable for each individual
gsort pnr time -inout
by pnr: gen status = sum(inout) 

*Now create the time band
by pnr: gen time_band = sum(inlist(status[_n-1],0,.))

****
*Identify co-occurring rhinitis and montelukast:

by pnr time_band, sort: egen rhinitis_count = total(rhinitis)
*by pnr time_band, sort: egen asthma_count = total(montelukast)

replace montelukast=. if rhinitis_count>0


*Create an in (start) date
gen criteria_2 = 1 if criteria_2a==1 | montelukast==1
gen criteria_2_in = eksd if criteria_2==1
format *_in %d

****
*Identify multiple prescriptions in a year for criteria 2:

*drop duplicate observations:
drop if inout==-1

*Create an interval between prescriptions 
by pnr (time), sort: gen c2_interval = (criteria_2_in[_n+1] - criteria_2_in )/365.25 if criteria_2==1

replace criteria_2=. if c2_interval>=1
replace criteria_2_in=. if c2_interval>=1

*Collapse the dataset to obtain summaries for each criteria:

collapse (max) criteria_1 criteria_2 (min) criteria_1_in criteria_2_in, by(pnr)

egen asthma = rowmax(criteria_1 criteria_2)
egen asthma_date = rowmin(criteria_1_in criteria_2_in)

************************************************************************
*keep relevant variables:
keep pnr asthma asthma_date

*Merge with DNBC data to obtain denominator:

tempfile asthma
save `asthma'

clear all

use bcpr using "$dnbc\DNBC_data.dta"

by bcpr, sort: gen n=_N
keep if n==1 
drop n

rename bcpr pnr

merge 1:1 pnr using `asthma'
drop if _merge==2
drop _merge




